const { mockOrders } = require('../data/mockStore');

exports.processPayment = (req, res) => {
  const { order_id, method, amount } = req.body;
  const order = mockOrders.find(o => o.order_id === order_id);

  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng để thanh toán' });
  }

  // Internal payment simulation (No external gateway calls as requested)
  const transactionId = `TXN-MINILAB-${Date.now()}`;
  const now = new Date();
  const formattedTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getFullYear()}`;

  order.payment_status = 'PAID';
  order.payment_method = method || 'MOMO';

  // Update timeline if needed
  if (order.timeline && order.timeline.length > 0) {
    order.timeline[0].status = 'COMPLETED';
    order.timeline[0].time = formattedTime;
    order.timeline[0].note = `Thanh toán ${order.payment_method} thành công (Giao dịch nội bộ)`;
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
    note: 'Giao dịch thanh toán hợp lệ trong hệ thống MiniLab'
  };

  return res.json({
    success: true,
    message: 'Thanh toán thành công (Xử lý nội bộ)',
    data: receipt
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
      transaction_id: `TXN-LOCAL-${order.order_id}`,
      order_id: order.order_id,
      lab_name: order.lab_name,
      amount: order.total_amount,
      payment_method: order.payment_method,
      payment_time: order.order_date,
      status: 'PAID',
      items: order.items
    }
  });
};

