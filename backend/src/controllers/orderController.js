const mockDb = require('../data/mockDb');

exports.getKanbanOrders = (req, res) => {
  const { process, search } = req.query;

  let filtered = [...mockDb.orders];

  if (process && process !== 'ALL') {
    filtered = filtered.filter(o => o.process_type.toUpperCase().includes(process.toUpperCase()));
  }

  if (search) {
    const q = search.toLowerCase();
    filtered = filtered.filter(o =>
      o.order_id.toLowerCase().includes(q) ||
      o.customer_name.toLowerCase().includes(q) ||
      o.film_type.toLowerCase().includes(q)
    );
  }

  // Count by stage
  const counts = {
    RECEIVED: filtered.filter(o => o.stage === 'RECEIVED').length,
    WAITING_DEV: filtered.filter(o => o.stage === 'WAITING_DEV').length,
    PROCESSING_DEV: filtered.filter(o => o.stage === 'PROCESSING_DEV').length,
    PROCESSING_SCAN: filtered.filter(o => o.stage === 'PROCESSING_SCAN').length,
    READY_QC: filtered.filter(o => o.stage === 'READY_QC').length
  };

  return res.status(200).json({
    success: true,
    data: {
      orders: filtered,
      counts,
      telemetry: mockDb.telemetry
    }
  });
};

exports.updateOrderStage = (req, res) => {
  const { id } = req.params;
  const { stage } = req.body;

  const validStages = ['RECEIVED', 'WAITING_DEV', 'PROCESSING_DEV', 'PROCESSING_SCAN', 'READY_QC', 'COMPLETED'];
  if (!validStages.includes(stage)) {
    return res.status(400).json({ success: false, message: 'Giai đoạn công đoạn không hợp lệ.' });
  }

  const order = mockDb.orders.find(o => o.order_id === id);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng.' });
  }

  const prevStage = order.stage;
  order.stage = stage;

  return res.status(200).json({
    success: true,
    message: `Đơn ${id} đã chuyển từ ${prevStage} sang ${stage}`,
    data: order
  });
};

exports.scanNewBarcode = (req, res) => {
  const { barcode, customer_name, film_type, process_type, roll_count } = req.body;

  const newOrderId = barcode || `ORD-${new Date().getFullYear()}-${Math.floor(10000 + Math.random() * 90000)}`;

  const newOrder = {
    order_id: newOrderId,
    customer_name: customer_name || 'Khách vãng lai (Quầy)',
    customer_phone: '0909 000 999',
    stage: 'RECEIVED',
    roll_count: Number(roll_count) || 1,
    film_type: film_type || 'Kodak ColorPlus 200 (135)',
    process_type: process_type || 'C-41',
    scanner: 'Noritsu HS-1800',
    resolution: 'JPEG Hi-Res',
    push_pull: 'Standard',
    sla_deadline: new Date(Date.now() + 48 * 3600 * 1000).toISOString(),
    sla_hours_left: 48,
    is_urgent: false,
    note: 'Tiếp nhận trực tiếp qua máy quét mã vạch phòng tối',
    created_at: new Date().toISOString()
  };

  mockDb.orders.unshift(newOrder);
  mockDb.telemetry.today_total_rolls += newOrder.roll_count;

  return res.status(201).json({
    success: true,
    message: `Đã quét và tiếp nhận cuộn phim mới: ${newOrderId}`,
    data: newOrder
  });
};

exports.getOrderDetails = (req, res) => {
  const { id } = req.params;
  const order = mockDb.orders.find(o => o.order_id === id);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng.' });
  }

  const qc = mockDb.qcBatches[id] || null;

  return res.status(200).json({
    success: true,
    data: {
      order,
      qc_batch: qc
    }
  });
};

