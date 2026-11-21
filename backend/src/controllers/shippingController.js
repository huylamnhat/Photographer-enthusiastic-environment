const { mockOrders, mockLabs, mockAuditLogs, mockNotifications } = require('../data/mockStore');
const { upsertShipmentRecord } = require('../config/db');
const config = require('../config');
const {
  isAhamoveConfigured,
  resolveServiceId,
  estimateAhamoveOrder,
  createAhamoveOrder,
  getAhamoveOrderDetail,
  cancelAhamoveOrder,
} = require('../services/ahamoveService');

function resolveLabForOrder(order, bodyLabId) {
  const targetId = order?.lab_id || bodyLabId || 'lab-001';
  return mockLabs.find(l => l.lab_id === targetId) || mockLabs[0] || {
    lab_id: 'lab-001',
    name: order?.lab_name || 'CropLab Hà Nội',
    address: 'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ',
    city: 'Hà Nội',
    phone: '0904567890',
  };
}

exports.getAhamoveConfigStatus = (req, res) => {
  return res.json({
    success: true,
    data: {
      configured: isAhamoveConfigured(),
      environment: 'SANDBOX_STAGING',
      base_url: config.AHAMOVE?.baseUrl || 'https://partner-apistg.ahamove.com/v3',
      allow_production: Boolean(config.AHAMOVE?.allowProduction),
      portal_url: 'https://business-stg.ahamove.com',
    },
  });
};

exports.estimatePickupFee = async (req, res) => {
  const { lab_id, pickup_address, pickup_name, pickup_phone, item_value, items } = req.body;
  const lab = resolveLabForOrder(null, lab_id);
  const serviceId = resolveServiceId(`${lab.city || ''} ${pickup_address || ''}`);

  if (!isAhamoveConfigured()) {
    return res.status(400).json({
      success: false,
      code: 'AHAMOVE_NOT_CONFIGURED',
      message:
        'Chưa cấu hình AHAMOVE_TOKEN (hoặc AHAMOVE_API_KEY + AHAMOVE_MOBILE) trong backend/.env. Hãy đăng nhập https://business-stg.ahamove.com (Staging Sandbox) để lấy token test mà không gọi shipper thật.',
      data: {
        environment: 'SANDBOX_STAGING',
        service_id: serviceId,
      },
    });
  }

  try {
    const est = await estimateAhamoveOrder({
      pickupAddress: pickup_address || 'Số 1 Đại Cồ Việt, Hai Bà Trưng, Hà Nội',
      pickupName: pickup_name || req.user?.full_name || 'Khách hàng MiniLab',
      pickupPhone: pickup_phone || req.user?.phone || '0901234567',
      lab,
      itemValue: item_value || 100000,
      items,
    });

    return res.json({
      success: true,
      message: 'Ước tính phí giao nhận AhaMove thành công',
      data: est,
    });
  } catch (err) {
    return res.status(400).json({
      success: false,
      code: 'AHAMOVE_ESTIMATE_ERROR',
      message: `Không ước tính được phí giao nhận: ${err.message}`,
    });
  }
};

exports.bookAhamovePickup = async (req, res) => {
  const { orderId } = req.params;
  const order = mockOrders.find(o => o.order_id.toLowerCase() === String(orderId || '').toLowerCase());

  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }
  if (order.status === 'CANCELLED' || order.payment_status === 'CANCELLED') {
    return res.status(400).json({ success: false, message: 'Đơn hàng đã bị hủy, không thể đặt shipper AhaMove' });
  }
  if (order.payment_status === 'PENDING' || order.status === 'PENDING_PAYMENT') {
    return res.status(400).json({
      success: false,
      message: 'Đơn hàng đang chờ xác nhận thanh toán, vui lòng hoàn tất thanh toán trước khi gọi shipper',
    });
  }

  if (order.shipment && order.shipment.external_order_id && order.shipment.status !== 'CANCELLED') {
    return res.json({
      success: true,
      already_booked: true,
      message: `Đơn #${order.order_id} đã có vận đơn AhaMove #${order.shipment.external_order_id}`,
      data: order.shipment,
    });
  }

  if (!isAhamoveConfigured()) {
    return res.status(400).json({
      success: false,
      code: 'AHAMOVE_NOT_CONFIGURED',
      message:
        'Chưa cấu hình AHAMOVE_TOKEN (hoặc AHAMOVE_API_KEY + AHAMOVE_MOBILE) trong backend/.env. Hãy lấy Token Staging tại https://business-stg.ahamove.com để đặt shipper test Sandbox.',
    });
  }

  const lab = resolveLabForOrder(order);
  const pickupAddress = String(req.body?.pickup_address || order.pickup_address || '').trim();
  const pickupPhone = String(req.body?.pickup_phone || order.pickup_phone || order.customer_phone || req.user?.phone || '0901234567').trim();
  const pickupName = String(req.body?.pickup_name || order.customer_name || req.user?.full_name || 'Khách hàng MiniLab').trim();

  if (!pickupAddress) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập địa chỉ lấy cuộn film cho shipper AhaMove' });
  }

  try {
    const ahaRes = await createAhamoveOrder({
      pickupAddress,
      pickupName,
      pickupPhone,
      lab,
      orderId: order.order_id,
      itemValue: order.total_amount,
      remarks: req.body?.remarks,
    });

    const now = new Date();
    const shipment = {
      provider: 'AHAMOVE',
      direction: 'PICKUP_TO_LAB',
      external_order_id: ahaRes.ahamove_order_id,
      tracking_code: ahaRes.shared_link || ahaRes.ahamove_order_id,
      shared_link: ahaRes.shared_link || '',
      ahamove_status: ahaRes.ahamove_status,
      status: ahaRes.status,
      service_id: ahaRes.service_id,
      shipping_fee: ahaRes.total_fee,
      sender_name: pickupName,
      sender_phone: pickupPhone,
      sender_address: pickupAddress,
      receiver_name: lab.name,
      receiver_phone: lab.phone || '0904567890',
      receiver_address: `${lab.address || ''}${lab.city ? `, ${lab.city}` : ''}`,
      driver_name: ahaRes.driver_name || '',
      driver_phone: ahaRes.driver_phone || '',
      sandbox: true,
      created_at: now.toISOString(),
    };

    order.pickup_address = pickupAddress;
    order.pickup_phone = pickupPhone;
    order.shipment = shipment;

    await upsertShipmentRecord({
      order_code: order.order_id,
      ...shipment,
    });

    mockNotifications.unshift({
      notification_id: `NTF-AHA-${Date.now()}`,
      type: 'SHIPMENT_BOOKED',
      order_id: order.order_id,
      customer_id: order.user_id,
      recipient_email: order.customer_email || '',
      title: `🛵 Đã đặt tài xế AhaMove #${ahaRes.ahamove_order_id} cho đơn #${order.order_id}`,
      message: `Tài xế AhaMove sẽ tới lấy cuộn film tại "${pickupAddress}" và giao tới ${lab.name}.`,
      created_at: now.toISOString(),
      is_read: false,
    });

    mockAuditLogs.unshift({
      id: `LOG-${Date.now().toString().slice(-5)}`,
      timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
      actor: `${req.user?.full_name || 'User'} (${req.user?.role || 'USER'})`,
      action: 'BOOK_AHAMOVE_SANDBOX',
      entity: `Shipment #${ahaRes.ahamove_order_id}`,
      entity_name: 'Shipment',
      entity_id: order.order_id,
      ip: req.ip || '127.0.0.1',
      oldVal: '{}',
      newVal: JSON.stringify({ external_order_id: ahaRes.ahamove_order_id, service_id: ahaRes.service_id, sandbox: true }),
    });

    return res.json({
      success: true,
      message: `Đã đặt tài xế AhaMove thành công (#${ahaRes.ahamove_order_id})`,
      data: shipment,
    });
  } catch (err) {
    return res.status(400).json({
      success: false,
      code: 'AHAMOVE_BOOK_ERROR',
      message: `Không đặt được tài xế AhaMove: ${err.message}`,
    });
  }
};

exports.getAhamoveShipmentStatus = async (req, res) => {
  const { orderId } = req.params;
  const order = mockOrders.find(o => o.order_id.toLowerCase() === String(orderId || '').toLowerCase());
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }
  if (!order.shipment || !order.shipment.external_order_id) {
    return res.json({
      success: true,
      data: order.shipment || null,
    });
  }

  if (!isAhamoveConfigured() || order.shipment.status === 'CANCELLED' || order.shipment.status === 'DELIVERED') {
    return res.json({
      success: true,
      data: order.shipment,
    });
  }

  try {
    const detail = await getAhamoveOrderDetail(order.shipment.external_order_id);
    order.shipment.ahamove_status = detail.ahamove_status;
    order.shipment.status = detail.status;
    if (detail.shared_link) order.shipment.shared_link = detail.shared_link;
    if (detail.driver_name) order.shipment.driver_name = detail.driver_name;
    if (detail.driver_phone) order.shipment.driver_phone = detail.driver_phone;
    if (detail.total_fee > 0) order.shipment.shipping_fee = detail.total_fee;

    await upsertShipmentRecord({
      order_code: order.order_id,
      ...order.shipment,
    });

    return res.json({
      success: true,
      data: order.shipment,
    });
  } catch (err) {
    return res.json({
      success: true,
      warning: err.message,
      data: order.shipment,
    });
  }
};

exports.cancelAhamovePickup = async (req, res) => {
  const { orderId } = req.params;
  const order = mockOrders.find(o => o.order_id.toLowerCase() === String(orderId || '').toLowerCase());
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }
  if (!order.shipment || !order.shipment.external_order_id) {
    return res.status(400).json({ success: false, message: 'Đơn hàng chưa có vận đơn AhaMove để hủy' });
  }

  if (isAhamoveConfigured() && order.shipment.status !== 'CANCELLED') {
    try {
      await cancelAhamoveOrder(
        order.shipment.external_order_id,
        req.body?.comment || 'Khách hàng muốn hủy đơn'
      );
    } catch (err) {
      return res.status(400).json({
        success: false,
        message: `Lỗi hủy đơn AhaMove Sandbox: ${err.message}`,
      });
    }
  }

  order.shipment.status = 'CANCELLED';
  order.shipment.ahamove_status = 'CANCELLED';
  await upsertShipmentRecord({
    order_code: order.order_id,
    ...order.shipment,
  });

  return res.json({
    success: true,
    message: `Đã hủy chuyến AhaMove #${order.shipment.external_order_id}`,
    data: order.shipment,
  });
};
