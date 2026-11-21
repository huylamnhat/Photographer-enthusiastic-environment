const { mockOrders, mockLabs, mockAuditLogs, mockNotifications } = require('../data/mockStore');
const { runQuery } = require('../config/db');
const config = require('../config');
const {
  isVnpayConfigured,
  createVnpayPaymentUrl,
  verifyVnpayCallback,
  queryVnpayTransaction,
} = require('../services/vnpayService');

function formatTimeNow(now = new Date()) {
  return `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getFullYear()}`;
}

function escapeSql(val) {
  return String(val ?? '').replace(/'/g, "''");
}

function findOrderFromVnpayTxnRef(txnRef) {
  const cleanRef = String(txnRef || '').trim();
  const baseOrderId = cleanRef.replace(/-VNP-\d+$/, '');
  return (
    mockOrders.find(o => o.vnp_txn_ref === cleanRef) ||
    mockOrders.find(o => o.order_id === baseOrderId) ||
    mockOrders.find(o => o.order_id === cleanRef) ||
    null
  );
}

async function markOrderPaidViaGateway({
  order,
  gateway = 'VNPAY',
  txnRef,
  transNo,
  amount,
  bankCode = '',
  responseCode = '00',
}) {
  if (!order) return;
  const now = new Date();
  const formattedTime = formatTimeNow(now);
  const wasPaid = order.payment_status === 'PAID';
  const upperGateway = String(gateway || 'VNPAY').toUpperCase();

  order.payment_status = 'PAID';
  order.payment_method = upperGateway;
  if (order.status === 'PENDING_PAYMENT') {
    order.status = 'RECEIVED';
  }
  order.kanban_column = order.kanban_column || 'QUEUE';
  order.vnp_txn_ref = String(txnRef || order.vnp_txn_ref || '');
  order.vnp_trans_no = String(transNo || order.vnp_trans_no || '');
  order.vnp_bank_code = String(bankCode || order.vnp_bank_code || '');

  if (Array.isArray(order.timeline) && order.timeline.length > 0) {
    order.timeline[0].status = order.kanban_column === 'QUEUE' ? 'IN_PROGRESS' : 'COMPLETED';
    order.timeline[0].time = formattedTime;
    order.timeline[0].note = `Thanh toán ${upperGateway} thành công${order.vnp_trans_no ? ` (Mã GD: ${order.vnp_trans_no})` : ''} • Đã vào hàng chờ Lab`;
  }

  const safeOrderCode = escapeSql(order.order_id);
  const safeGateway = escapeSql(upperGateway);
  const safeTxnRef = escapeSql(txnRef || order.vnp_txn_ref || `${order.order_id}-VNP`);
  const safeTransNo = escapeSql(transNo || '');
  const safeCode = escapeSql(responseCode);
  const numAmount = Number(amount || order.total_amount || 0) || 1;

  await runQuery(`
    UPDATE Orders
    SET payment_status = 'PAID',
        payment_method = '${safeGateway}',
        status = CASE WHEN status = 'PENDING_PAYMENT' THEN 'RECEIVED' ELSE status END,
        updated_at = SYSUTCDATETIME()
    WHERE order_code = '${safeOrderCode}';

    DECLARE @ordId BIGINT = (SELECT TOP 1 order_id FROM Orders WHERE order_code = '${safeOrderCode}');
    IF @ordId IS NOT NULL
    BEGIN
      IF EXISTS (SELECT 1 FROM Payment WHERE txn_ref = '${safeTxnRef}')
      BEGIN
        UPDATE Payment
        SET status = 'PAID',
            gateway_txn_no = '${safeTransNo}',
            response_code = '${safeCode}',
            paid_at = SYSUTCDATETIME()
        WHERE txn_ref = '${safeTxnRef}';
      END
      ELSE
      BEGIN
        INSERT INTO Payment (order_id, gateway, txn_ref, gateway_txn_no, amount, currency, status, response_code, paid_at)
        VALUES (@ordId, '${safeGateway}', '${safeTxnRef}', '${safeTransNo}', ${numAmount}, 'VND', 'PAID', '${safeCode}', SYSUTCDATETIME());
      END
    END
  `).catch((err) => {
    console.error('[markOrderPaidViaGateway SQL Error]:', err.message);
  });

  if (!wasPaid) {
    mockNotifications.unshift({
      notification_id: `NTF-${upperGateway}-${Date.now()}`,
      type: `PAYMENT_${upperGateway}_SUCCESS`,
      order_id: order.order_id,
      customer_id: order.user_id,
      recipient_email: order.customer_email || '',
      title: `💳 Thanh toán ${upperGateway} đơn #${order.order_id} thành công`,
      message: `Đơn hàng #${order.order_id} (${numAmount.toLocaleString('vi-VN')}đ) đã được thanh toán qua ${upperGateway}${order.vnp_trans_no ? ` (Mã GD: ${order.vnp_trans_no})` : ''} và chuyển tới ${order.lab_name}.`,
      created_at: now.toISOString(),
      is_read: false,
    });

    mockAuditLogs.unshift({
      id: `LOG-${Date.now().toString().slice(-5)}`,
      timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
      actor: `${order.customer_name || 'Customer'} (${upperGateway}_GATEWAY)`,
      action: `${upperGateway}_PAYMENT_PAID`,
      entity: `Orders #${order.order_id}`,
      entity_name: 'Payment',
      entity_id: order.order_id,
      ip: 'vnpay-gateway',
      oldVal: '{"payment_status":"PENDING"}',
      newVal: JSON.stringify({ payment_status: 'PAID', transNo: order.vnp_trans_no, txnRef }),
    });
  }
}

exports.getVnpayConfigStatus = (req, res) => {
  return res.json({
    success: true,
    data: {
      configured: isVnpayConfigured(),
      url: config.VNPAY.url,
      api_url: config.VNPAY.apiUrl,
    },
  });
};

exports.createVnpayPayment = async (req, res) => {
  const { order_id, amount, order_info, bank_code } = req.body;
  if (!order_id) {
    return res.status(400).json({ success: false, message: 'Thiếu order_id để khởi tạo thanh toán VNPAY' });
  }

  const order = mockOrders.find(o => o.order_id === order_id);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  if (order.status === 'CANCELLED' || order.payment_status === 'CANCELLED') {
    return res.status(400).json({
      success: false,
      code: 'ORDER_CANCELLED',
      message: 'Đơn hàng này đã bị tiệm Lab hủy do quá hạn thanh toán. Vui lòng tạo đơn hàng mới.',
    });
  }

  if (order.payment_status === 'PAID') {
    return res.json({
      success: true,
      already_paid: true,
      message: 'Đơn hàng này đã được thanh toán',
      data: {
        paid: true,
        order_id: order.order_id,
        trans_id: order.vnp_trans_no || '',
      },
    });
  }

  if (!isVnpayConfigured()) {
    return res.status(400).json({
      success: false,
      code: 'VNPAY_NOT_CONFIGURED',
      message:
        'Chưa cấu hình VNP_TMN_CODE và VNP_HASH_SECRET trong file backend/.env. Hãy đăng ký miễn phí tại https://pay.vnpaytest.vn/dev-registration để lấy thông tin kết nối Sandbox.',
    });
  }

  const numericAmount = Math.max(1000, Math.round(Number(amount || order.total_amount || 0)));
  const txnRef = `${order.order_id}-VNP-${Date.now()}`;
  const hostBase = `${req.protocol}://${req.get('host')}`;
  const reqHostLower = String(req.get('host') || '').toLowerCase();
  const cfgReturn = config.VNPAY.returnUrl || '';
  const isCfgLocal = cfgReturn.includes('localhost') || cfgReturn.includes('127.0.0.1');
  const isReqPublic = Boolean(reqHostLower) && !reqHostLower.startsWith('localhost') && !reqHostLower.startsWith('127.0.0.1') && !reqHostLower.startsWith('192.168.');
  const returnUrl = (!cfgReturn || (isCfgLocal && isReqPublic))
    ? `${hostBase}/api/payments/vnpay/return`
    : cfgReturn;
  const orderInfo = (order_info || `Thanh toan don trang film ${order.order_id}`)
    .replace(/[^a-zA-Z0-9\s\-_.:]/g, '')
    .slice(0, 240);
  const ipAddr = req.headers['x-forwarded-for'] || req.socket?.remoteAddress || req.ip || '127.0.0.1';

  const result = createVnpayPaymentUrl({
    txnRef,
    amount: numericAmount,
    orderInfo,
    ipAddr,
    returnUrl,
    bankCode: bank_code || '',
  });

  order.vnp_txn_ref = result.txnRef;
  order.vnp_create_date = result.createDate;
  order.payment_method = 'VNPAY';

  const safeOrderCode = escapeSql(order.order_id);
  const safeTxnRef = escapeSql(result.txnRef);
  await runQuery(`
    DECLARE @ordId BIGINT = (SELECT TOP 1 order_id FROM Orders WHERE order_code = '${safeOrderCode}');
    IF @ordId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Payment WHERE txn_ref = '${safeTxnRef}')
    BEGIN
      INSERT INTO Payment (order_id, gateway, txn_ref, amount, currency, status)
      VALUES (@ordId, 'VNPAY', '${safeTxnRef}', ${numericAmount}, 'VND', 'PENDING');
    END
  `).catch(() => {});

  return res.json({
    success: true,
    message: 'Khởi tạo cổng thanh toán VNPAY Sandbox thành công',
    data: {
      order_id: order.order_id,
      txn_ref: result.txnRef,
      create_date: result.createDate,
      amount: numericAmount,
      paymentUrl: result.paymentUrl,
    },
  });
};

exports.vnpayIpnWebhook = async (req, res) => {
  const query = req.query || {};
  if (!verifyVnpayCallback(query)) {
    return res.status(200).json({ RspCode: '97', Message: 'Invalid Checksum' });
  }

  const order = findOrderFromVnpayTxnRef(query.vnp_TxnRef);
  if (!order) {
    return res.status(200).json({ RspCode: '01', Message: 'Order not found' });
  }

  const expectedVnpAmount = Math.round(Number(order.total_amount || 0)) * 100;
  if (Number(query.vnp_Amount) !== expectedVnpAmount) {
    return res.status(200).json({ RspCode: '04', Message: 'Invalid amount' });
  }

  if (order.status === 'CANCELLED' || order.payment_status === 'CANCELLED') {
    return res.status(200).json({ RspCode: '02', Message: 'Order already cancelled' });
  }

  if (order.payment_status === 'PAID') {
    return res.status(200).json({ RspCode: '02', Message: 'Order already confirmed' });
  }

  const rspCode = String(query.vnp_ResponseCode || '');
  const txnStatus = String(query.vnp_TransactionStatus || '');

  if (rspCode === '00' && (txnStatus === '00' || txnStatus === '')) {
    await markOrderPaidViaGateway({
      order,
      gateway: 'VNPAY',
      txnRef: query.vnp_TxnRef,
      transNo: query.vnp_TransactionNo,
      amount: Number(query.vnp_Amount) / 100,
      bankCode: query.vnp_BankCode,
      responseCode: rspCode,
    });
  } else {
    const safeTxnRef = escapeSql(query.vnp_TxnRef);
    const safeCode = escapeSql(rspCode);
    await runQuery(`
      UPDATE Payment
      SET status = 'FAILED', response_code = '${safeCode}'
      WHERE txn_ref = '${safeTxnRef}' AND status = 'PENDING';
    `).catch(() => {});
  }

  return res.status(200).json({ RspCode: '00', Message: 'Confirm Success' });
};

exports.vnpayReturnCallback = async (req, res) => {
  const query = req.query || {};
  const sigValid = verifyVnpayCallback(query);
  const rspCode = String(query.vnp_ResponseCode || '');
  const txnStatus = String(query.vnp_TransactionStatus || '');
  const order = findOrderFromVnpayTxnRef(query.vnp_TxnRef);

  const isCancelled = order?.status === 'CANCELLED' || order?.payment_status === 'CANCELLED';
  const isSuccess = sigValid && !isCancelled && rspCode === '00' && (txnStatus === '00' || txnStatus === '');
  if (isSuccess && order) {
    await markOrderPaidViaGateway({
      order,
      gateway: 'VNPAY',
      txnRef: query.vnp_TxnRef,
      transNo: query.vnp_TransactionNo,
      amount: Number(query.vnp_Amount) / 100,
      bankCode: query.vnp_BankCode,
      responseCode: rspCode,
    });
  }

  const displayOrderId = order?.order_id || query.vnp_TxnRef || '';
  const displayAmount = query.vnp_Amount
    ? `${(Number(query.vnp_Amount) / 100).toLocaleString('vi-VN')}đ`
    : '';
  const statusMsg = !sigValid
    ? 'Chữ ký phản hồi VNPAY không hợp lệ'
    : isCancelled
      ? 'Đơn hàng này đã bị hủy trước đó do quá hạn thanh toán'
      : isSuccess
        ? 'Giao dịch đã được VNPAY xác thực thành công'
        : `Giao dịch chưa hoàn tất (Mã phản hồi VNPAY: ${rspCode || 'Hủy'})`;

  const esc = (v) => String(v || '').replace(/[<>&"]/g, '');

  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  return res.send(`<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${isSuccess ? 'Thanh toán VNPAY thành công' : 'Thanh toán VNPAY chưa hoàn tất'} - MiniLab</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; background: #FAF8F4; color: #1F1C18; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; padding: 16px; }
    .card { background: #fff; border: 1px solid #E3DFD7; border-radius: 12px; padding: 28px; max-width: 440px; width: 100%; text-align: center; box-shadow: 0 8px 24px rgba(0,0,0,0.06); }
    .badge { display: inline-block; padding: 6px 14px; border-radius: 999px; font-weight: 700; font-size: 13px; margin-bottom: 14px; background: ${isSuccess ? '#DCFCE7' : '#FEE2E2'}; color: ${isSuccess ? '#166534' : '#991B1B'}; }
    h2 { margin: 0 0 8px; font-size: 20px; }
    p { margin: 6px 0; color: #5F5A52; font-size: 14px; line-height: 1.5; }
    .meta { background: #F2EFE9; border-radius: 8px; padding: 12px; margin: 16px 0; text-align: left; font-size: 13px; line-height: 1.7; }
  </style>
</head>
<body>
  <div class="card">
    <div class="badge">${isSuccess ? 'VNPAY SANDBOX // THÀNH CÔNG' : 'VNPAY SANDBOX // CHƯA HOÀN TẤT'}</div>
    <h2>${isSuccess ? 'Thanh toán VNPAY thành công!' : 'Thanh toán chưa hoàn tất'}</h2>
    <p>${esc(statusMsg)}</p>
    <div class="meta">
      <div><strong>Đơn hàng:</strong> ${esc(displayOrderId)}</div>
      ${displayAmount ? `<div><strong>Số tiền:</strong> ${esc(displayAmount)}</div>` : ''}
      ${query.vnp_BankCode ? `<div><strong>Ngân hàng:</strong> ${esc(query.vnp_BankCode)}</div>` : ''}
      ${query.vnp_TransactionNo ? `<div><strong>Mã giao dịch VNPAY:</strong> ${esc(query.vnp_TransactionNo)}</div>` : ''}
    </div>
    <p>Bạn có thể đóng tab trình duyệt này và quay lại ứng dụng <strong>MiniLab</strong>.</p>
  </div>
</body>
</html>`);
};

exports.checkVnpayPaymentStatus = async (req, res) => {
  const { orderId } = req.params;
  const order = mockOrders.find(o => o.order_id === orderId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  if (order.status === 'CANCELLED' || order.payment_status === 'CANCELLED') {
    return res.json({
      success: true,
      data: {
        paid: false,
        cancelled: true,
        payment_status: 'CANCELLED',
        vnpay_message: order.cancel_reason || 'Đơn hàng đã bị tiệm Lab hủy do quá hạn thanh toán.',
      },
    });
  }

  if (order.payment_status === 'PAID') {
    return res.json({
      success: true,
      data: {
        paid: true,
        payment_status: 'PAID',
        trans_id: order.vnp_trans_no || '',
        bank_code: order.vnp_bank_code || '',
        txn_ref: order.vnp_txn_ref || '',
        order,
      },
    });
  }

  if (!order.vnp_txn_ref || !order.vnp_create_date || !isVnpayConfigured()) {
    return res.json({
      success: true,
      data: {
        paid: false,
        payment_status: order.payment_status || 'PENDING',
        vnpay_message: 'Đang chờ xác nhận thanh toán từ cổng VNPAY',
      },
    });
  }

  try {
    const ipAddr = req.headers['x-forwarded-for'] || req.socket?.remoteAddress || req.ip || '127.0.0.1';
    const qRes = await queryVnpayTransaction({
      txnRef: order.vnp_txn_ref,
      transactionDate: order.vnp_create_date,
      ipAddr,
      orderInfo: `Truy van giao dich ${order.order_id}`,
    });
    const qData = qRes.data || {};

    if (String(qData.vnp_ResponseCode) === '00' && String(qData.vnp_TransactionStatus) === '00') {
      await markOrderPaidViaGateway({
        order,
        gateway: 'VNPAY',
        txnRef: order.vnp_txn_ref,
        transNo: qData.vnp_TransactionNo,
        amount: Number(qData.vnp_Amount) / 100 || order.total_amount,
        bankCode: qData.vnp_BankCode || '',
        responseCode: qData.vnp_ResponseCode,
      });
      return res.json({
        success: true,
        data: {
          paid: true,
          payment_status: 'PAID',
          trans_id: qData.vnp_TransactionNo ? String(qData.vnp_TransactionNo) : '',
          bank_code: qData.vnp_BankCode || '',
          txn_ref: order.vnp_txn_ref,
          order,
        },
      });
    }

    return res.json({
      success: true,
      data: {
        paid: false,
        payment_status: order.payment_status || 'PENDING',
        vnp_response_code: qData.vnp_ResponseCode,
        vnp_transaction_status: qData.vnp_TransactionStatus,
        vnpay_message: qData.vnp_Message || 'Giao dịch chưa được thanh toán trên cổng VNPAY',
      },
    });
  } catch (err) {
    return res.json({
      success: true,
      data: {
        paid: false,
        payment_status: order.payment_status || 'PENDING',
        vnpay_message: `Đang chờ xác nhận từ VNPAY (${err.message})`,
      },
    });
  }
};

exports.processPayment = (req, res) => {
  const { order_id, method, amount } = req.body;
  const order = mockOrders.find(o => o.order_id === order_id);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng để thanh toán' });
  }

  const transactionId = `TXN-MINILAB-${Date.now()}`;
  const now = new Date();
  const formattedTime = formatTimeNow(now);

  order.payment_status = 'PAID';
  order.payment_method = method || 'CASH_ON_DROP';

  if (order.timeline && order.timeline.length > 0) {
    order.timeline[0].status = 'COMPLETED';
    order.timeline[0].time = formattedTime;
    order.timeline[0].note = `Thanh toán ${order.payment_method} thành công`;
  }

  const receipt = {
    receipt_no: `REC-${Date.now().toString().slice(-8)}`,
    transaction_id: transactionId,
    order_id: order.order_id,
    lab_name: order.lab_name,
    amount: amount || order.total_amount,
    payment_method: order.payment_method,
    payment_time: now.toISOString(),
    status: 'SUCCESS',
    note: 'Giao dịch thanh toán hợp lệ trong hệ thống MiniLab',
  };

  return res.json({
    success: true,
    message: 'Thanh toán thành công',
    data: receipt,
  });
};

exports.getReceipt = (req, res) => {
  const { orderId } = req.params;
  const order = mockOrders.find(o => o.order_id === orderId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy biên lai' });
  }

  return res.json({
    success: true,
    data: {
      receipt_no: `REC-${order.order_id.replace('ORD-', '')}`,
      transaction_id: order.vnp_trans_no || `TXN-LOCAL-${order.order_id}`,
      order_id: order.order_id,
      lab_name: order.lab_name,
      amount: order.total_amount,
      payment_method: order.payment_method,
      payment_time: order.order_date,
      status: order.payment_status || 'PAID',
      items: order.items,
    },
  });
};

exports.getOrderQrInfo = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const { orderId } = req.params;
  const order = mockOrders.find(o => o.order_id.toLowerCase() === String(orderId || '').toLowerCase());
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  const lab = mockLabs.find(l => l.lab_id === order.lab_id) || {};
  const fallbackQr = config.PAYMENT_QR || {};
  let rawQrUrl = String(lab.qr_image_url || fallbackQr.qrImageUrl || '').trim();
  const bankName = String(lab.bank_name || fallbackQr.bankName || '').trim();
  const accountNo = String(lab.account_no || fallbackQr.accountNo || '').trim();
  const accountName = String(lab.account_name || fallbackQr.accountName || '').trim();

  if (rawQrUrl && rawQrUrl.startsWith('/')) {
    rawQrUrl = `${req.protocol}://${req.get('host')}${rawQrUrl}`;
  } else if (!rawQrUrl && bankName && accountNo) {
    const numAmount = Math.round(Number(order.total_amount || 0));
    rawQrUrl =
      `https://img.vietqr.io/image/${encodeURIComponent(bankName)}-${encodeURIComponent(accountNo)}-compact2.png` +
      `?amount=${numAmount}&addInfo=${encodeURIComponent(order.order_id)}` +
      (accountName ? `&accountName=${encodeURIComponent(accountName)}` : '');
  }

  const isCancelled = order.status === 'CANCELLED' || order.payment_status === 'CANCELLED';
  const isPaid = order.payment_status === 'PAID';

  return res.json({
    success: true,
    data: {
      order_id: order.order_id,
      lab_id: order.lab_id,
      lab_name: order.lab_name || lab.name || 'Film Lab',
      amount: Number(order.total_amount || 0),
      transfer_content: order.order_id,
      payment_status: order.payment_status || 'PENDING',
      paid: isPaid,
      cancelled: isCancelled,
      cancel_reason: order.cancel_reason || '',
      qr_image_url: rawQrUrl,
      bank_name: bankName,
      account_no: accountNo,
      account_name: accountName,
    },
  });
};
