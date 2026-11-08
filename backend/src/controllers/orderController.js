const { mockOrders, mockLabs, mockServicePackages } = require('../data/mockStore');

exports.getMyOrders = (req, res) => {
  const userId = req.user.user_id;
  const { status } = req.query;

  let orders = mockOrders.filter(o => o.user_id === userId);

  if (status && status !== 'ALL') {
    orders = orders.filter(o => o.status === status);
  }

  // Sort latest first
  orders.sort((a, b) => new Date(b.order_date) - new Date(a.order_date));

  return res.json({
    success: true,
    count: orders.length,
    data: orders
  });
};

exports.getOrderById = (req, res) => {
  const { id } = req.params;
  const order = mockOrders.find(o => o.order_id === id);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  return res.json({
    success: true,
    data: order
  });
};

exports.createOrder = (req, res) => {
  const userId = req.user.user_id;
  const { lab_id, items, shipping_method, pickup_address, payment_method, note } = req.body;

  const lab = mockLabs.find(l => l.lab_id === lab_id) || mockLabs[0];

  let totalAmount = 0;
  const processedItems = (items || []).map((it, idx) => {
    const pkg = mockServicePackages.find(p => p.package_id === it.package_id) || mockServicePackages[0];
    const qty = it.quantity || 1;
    const itemTotal = (it.price || pkg.price) * qty;
    totalAmount += itemTotal;

    return {
      item_id: `item-${Date.now()}-${idx}`,
      package_id: pkg.package_id,
      name: pkg.name,
      film_name: it.film_name || 'Kodak ColorPlus 200',
      quantity: qty,
      price: pkg.price,
      options: it.options || { push_pull: 'Normal (Box speed)', cut_negatives: 'Cắt 6 frames/dải' }
    };
  });

  const now = new Date();
  const formattedTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getFullYear()}`;

  const newOrder = {
    order_id: `ORD-2026-${Math.floor(1000 + Math.random() * 9000)}`,
    user_id: userId,
    lab_id: lab.lab_id,
    lab_name: lab.name,
    order_date: now.toISOString(),
    status: 'RECEIVED',
    kanban_column: 'QUEUE',
    total_amount: totalAmount > 0 ? totalAmount : 50000,
    shipping_method: shipping_method || 'PICKUP',
    pickup_address: pickup_address || '123 Phố Huế, Hai Bà Trưng, Hà Nội',
    payment_status: 'PAID',
    payment_method: payment_method || 'MOMO',
    note: note || '',
    sla_deadline: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    items: processedItems.length > 0 ? processedItems : [
      {
        item_id: `item-${Date.now()}`,
        package_id: 'pkg-001',
        name: 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
        film_name: 'Kodak Gold 200',
        quantity: 1,
        price: 50000,
        options: { push_pull: 'Normal', cut_negatives: 'Cắt 6 frames/dải' }
      }
    ],
    timeline: [
      { step: 1, name: 'Tạo đơn & Đã thanh toán', status: 'COMPLETED', time: formattedTime, note: 'Thanh toán thành công' },
      { step: 2, name: 'Đã nhận cuộn film tại Lab', status: 'IN_PROGRESS', time: formattedTime, note: 'Đã tạo mã tiếp nhận' },
      { step: 3, name: 'Tráng hóa chất', status: 'PENDING', time: '', note: '' },
      { step: 4, name: 'Rửa sạch & Sấy khô', status: 'PENDING', time: '', note: '' },
      { step: 5, name: 'Scan máy chuyên dụng', status: 'PENDING', time: '', note: '' },
      { step: 6, name: 'Kiểm định chất lượng QC', status: 'PENDING', time: '', note: '' },
      { step: 7, name: 'File sẵn sàng trong Archive', status: 'PENDING', time: '', note: '' }
    ]
  };

  mockOrders.unshift(newOrder);

  return res.status(201).json({
    success: true,
    message: 'Tạo đơn hàng thành công!',
    data: newOrder
  });
};

exports.cancelOrder = (req, res) => {
  const { id } = req.params;
  const order = mockOrders.find(o => o.order_id === id);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  order.status = 'CANCELLED';
  return res.json({
    success: true,
    message: 'Hủy đơn hàng thành công',
    data: order
  });
};

