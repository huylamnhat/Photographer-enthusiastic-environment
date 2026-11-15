const { mockUsers, mockOrders, mockLabs, mockServicePackages, mockDisputes, mockArchivePhotos, mockAuditLogs, mockNotifications } = require('../data/mockStore');
const { runQuery } = require('../config/db');
const { getDriveConfigStatus } = require('../services/googleDriveService');

function enrichOrderWithDisputeAndDrive(order, currentUserId = '', currentUserEmail = '') {
  if (!order) return order;
  const dispute = mockDisputes.find(d => d.order_id === order.order_id);
  const cleanEmail = (currentUserEmail || '').toLowerCase();

  // Find photos specifically sent to this customer for THIS exact order
  const orderCustomerPhotos = mockArchivePhotos.filter(p => {
    if (String(p.order_id || '').toLowerCase() !== String(order.order_id || '').toLowerCase()) return false;
    if (!p.drive_link) return false;
    if (currentUserId && p.user_id === currentUserId) return true;
    if (cleanEmail && (p.recipient_email || '').toLowerCase() === cleanEmail) return true;
    return false;
  });

  let compensationNote = order.compensation_note || '';
  if (dispute) {
    if (dispute.compensation_note) {
      compensationNote = dispute.compensation_note;
    } else if (Array.isArray(dispute.messages) && dispute.messages.length > 0) {
      const labOrAdminMsg = [...dispute.messages].reverse().find(m =>
        m.sender && (m.sender.includes('Lab') || m.sender.includes('Admin') || m.text?.toLowerCase().includes('tặng') || m.text?.toLowerCase().includes('hoàn tiền'))
      );
      if (labOrAdminMsg) {
        compensationNote = labOrAdminMsg.text;
      }
    }
  }

  let resolvedDriveLink =
    (currentUserId && order.drive_links_by_user?.[currentUserId]) ||
    (cleanEmail && order.drive_links_by_user?.[cleanEmail]) ||
    orderCustomerPhotos[0]?.drive_link ||
    '';

  if (
    resolvedDriveLink.includes('1FilmLabArchive') ||
    resolvedDriveLink.includes('1MiniLabDigitalArchive') ||
    resolvedDriveLink.includes('/file/d/') ||
    resolvedDriveLink.includes('/drive/my-drive')
  ) {
    resolvedDriveLink = '';
  }

  const rawHistory =
    (currentUserId && order.drive_link_history_by_user?.[currentUserId]) ||
    (cleanEmail && order.drive_link_history_by_user?.[cleanEmail]) ||
    [];
  const photoLinks = orderCustomerPhotos.map(p => p.drive_link).filter(Boolean);
  const driveLinkHistory = Array.from(new Set([...rawHistory, ...photoLinks])).filter(
    l =>
      !l.includes('1FilmLabArchive') &&
      !l.includes('1MiniLabDigitalArchive') &&
      !l.includes('/file/d/') &&
      !l.includes('/drive/my-drive')
  );

  return {
    ...order,
    dispute_id: dispute?.dispute_id || order.dispute_id || null,
    dispute_status: dispute?.status || order.dispute_status || null,
    dispute_issue: dispute?.issue_type || order.dispute_issue || null,
    dispute_description: dispute?.description || order.dispute_description || null,
    dispute_created_at: dispute?.created_at || order.dispute_created_at || null,
    compensation_note: compensationNote || null,
    dispute_messages: dispute?.messages || [],
    drive_link: resolvedDriveLink || null,
    drive_link_history: driveLinkHistory,
    scan_photos: orderCustomerPhotos.map(p => ({
      photo_id: p.photo_id,
      title: p.title,
      image_url: p.image_url,
      drive_link: p.drive_link,
      roll_code: p.roll_code,
      created_at: p.created_at,
    })),
  };
}

exports.getMyOrders = (req, res) => {
  const { status } = req.query;
  const currentUserId = req.user?.user_id || '';
  const currentUserEmail = (req.user?.email || '').toLowerCase();

  // Strictly return ONLY orders belonging to the logged-in customer
  let orders = mockOrders
    .filter(o => {
      if (currentUserId && o.user_id === currentUserId) return true;
      if (currentUserEmail && (o.customer_email || '').toLowerCase() === currentUserEmail) return true;
      if (
        currentUserId &&
        mockDisputes.some(d => d.order_id === o.order_id && d.customer_id === currentUserId)
      ) {
        return true;
      }
      return false;
    })
    .map(o => enrichOrderWithDisputeAndDrive(o, currentUserId, currentUserEmail));

  if (status && status !== 'ALL') {
    orders = orders.filter(o => o.status === status);
  }

  // Sort orders that have a drive_link for this customer first, then by order_date descending
  orders.sort((a, b) => {
    const aHasDrive = Boolean(a.drive_link);
    const bHasDrive = Boolean(b.drive_link);
    if (aHasDrive !== bHasDrive) return aHasDrive ? -1 : 1;
    return new Date(b.order_date) - new Date(a.order_date);
  });

  const userNotifications = mockNotifications.filter(n => {
    if (!currentUserId && !currentUserEmail) return true;
    if (n.type !== 'GOOGLE_DRIVE_SCAN') return true;
    return (
      (currentUserId && n.customer_id === currentUserId) ||
      (currentUserEmail && (n.recipient_email || '').toLowerCase() === currentUserEmail)
    );
  });

  res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
  return res.json({
    success: true,
    count: orders.length,
    data: orders,
    notifications: userNotifications
  });
};

exports.getNotifications = (req, res) => {
  const currentUserId = req.user?.user_id || '';
  const currentUserEmail = (req.user?.email || '').toLowerCase();

  const userNotifications = mockNotifications.filter(n => {
    if (!currentUserId && !currentUserEmail) return true;
    if (n.type !== 'GOOGLE_DRIVE_SCAN') return true;
    return (
      (currentUserId && n.customer_id === currentUserId) ||
      (currentUserEmail && (n.recipient_email || '').toLowerCase() === currentUserEmail)
    );
  });

  return res.json({
    success: true,
    count: userNotifications.length,
    data: userNotifications
  });
};

exports.getOrderById = (req, res) => {
  const { id } = req.params;
  const order = mockOrders.find(o => o.order_id === id);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
  return res.json({
    success: true,
    data: enrichOrderWithDisputeAndDrive(order, req.user?.user_id || '', req.user?.email || '')
  });
};

exports.createOrder = (req, res) => {
  const userId = req.user?.user_id || 'usr-001';
  const customerName = req.user?.full_name || req.body.customer_name || 'Nguyễn Hoàng Anh';
  const customerPhone = req.user?.phone || req.body.customer_phone || '0912345678';
  const { lab_id, items, shipping_method, pickup_address, payment_method, note } = req.body;

  // Support both lab_id ('lab-001', 'lab-002') and mobile shorthand ('croplab', 'llab', 'nadar')
  const labAliasMap = {
    croplab: 'lab-001',
    llab: 'lab-002',
    nadar: 'lab-003'
  };
  const resolvedLabId = labAliasMap[String(lab_id || '').toLowerCase()] || lab_id;
  const lab =
    mockLabs.find(l => l.lab_id === resolvedLabId || l.name.toLowerCase().includes(String(lab_id || '').toLowerCase())) ||
    mockLabs[0] || { lab_id: 'lab-001', name: 'CropLab Hà Nội' };

  let totalAmount = 0;
  const processedItems = (items || []).map((it, idx) => {
    const pkg =
      mockServicePackages.find(p => p.package_id === it.package_id) ||
      mockServicePackages.find(p => p.lab_id === lab.lab_id) ||
      mockServicePackages[0] || {
        package_id: 'pkg-001',
        name: 'Tráng & Scan 135 Color (C-41)',
        price: 70000
      };
    const qty = Number(it.quantity) || 1;
    const unitPrice = Number(it.price) || Number(pkg.price) || 70000;
    const itemTotal = unitPrice * qty;
    totalAmount += itemTotal;

    return {
      item_id: `item-${Date.now()}-${idx}`,
      package_id: pkg.package_id,
      name: it.name || pkg.name,
      film_name: it.film_name || 'Kodak ColorPlus 200',
      roll_code: it.roll_code || `ROLL-${Math.floor(100 + Math.random() * 900)}`,
      quantity: qty,
      price: unitPrice,
      options: it.options || { push_pull: 'Normal (Box speed)', cut_negatives: 'Cắt 6 frames/dải' }
    };
  });

  if (req.body.total_amount && Number(req.body.total_amount) > 0) {
    totalAmount = Number(req.body.total_amount);
  }

  const now = new Date();
  const formattedTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getFullYear()}`;

  const newOrder = {
    order_id: `ORD-2026-${Math.floor(1000 + Math.random() * 9000)}`,
    user_id: userId,
    customer_email: req.user?.email || '',
    customer_name: customerName,
    customer_phone: customerPhone,
    lab_id: lab.lab_id,
    lab_name: lab.name,
    order_date: now.toISOString(),
    status: 'RECEIVED',
    kanban_column: 'QUEUE',
    total_amount: totalAmount > 0 ? totalAmount : 70000,
    shipping_method: shipping_method || 'PICKUP',
    pickup_address: pickup_address || '123 Phố Huế, Hai Bà Trưng, Hà Nội',
    payment_status: 'PAID',
    payment_method: payment_method || 'MOMO',
    note: note || '',
    created_from_mobile: true,
    sla_deadline: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    items: processedItems.length > 0 ? processedItems : [
      {
        item_id: `item-${Date.now()}`,
        package_id: 'pkg-001',
        name: 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
        film_name: 'Kodak Gold 200',
        roll_code: `ROLL-${Math.floor(100 + Math.random() * 900)}`,
        quantity: 1,
        price: 70000,
        options: { push_pull: 'Normal', cut_negatives: 'Cắt 6 frames/dải' }
      }
    ],
    timeline: [
      { step: 1, name: '1. Tiếp nhận', status: 'IN_PROGRESS', time: formattedTime, note: `Thanh toán ${payment_method || 'MOMO'} thành công • Đã vào hàng chờ Lab` },
      { step: 2, name: '2. Vào Tank / Tráng', status: 'PENDING', time: '', note: '' },
      { step: 3, name: '3. Sấy khô', status: 'PENDING', time: '', note: '' },
      { step: 4, name: '4. Scan số hóa', status: 'PENDING', time: '', note: '' },
      { step: 5, name: '5. QC & Archive', status: 'PENDING', time: '', note: '' }
    ]
  };

  mockOrders.unshift(newOrder);

  // Persist new Order & Order_Item directly to SQL Server (FilmLabPlatform)
  const matchedUser = mockUsers.find(u => u.user_id === userId);
  const dbCustomerId = req.user?.db_user_id || matchedUser?.db_user_id || 5;
  const dbLabId = lab.db_lab_id || 1;
  const totalNum = Number(newOrder.total_amount) || 70000;
  const safeCode = newOrder.order_id.replace(/'/g, "''");
  const safeAddr = String(newOrder.pickup_address || '').replace(/'/g, "''");
  const safeNote = String(newOrder.note || '').replace(/'/g, "''");
  const firstItem = newOrder.items[0] || {};
  const safeFilmName = String(firstItem.film_name || 'Kodak Portra 400').replace(/'/g, "''");
  const safeRollCode = String(firstItem.roll_code || `ROLL-${Date.now().toString().slice(-4)}`).replace(/'/g, "''");
  const itemQty = Number(firstItem.quantity) || 1;
  const itemPrice = Number(firstItem.price) || totalNum;
  runQuery(`
    INSERT INTO Orders (order_code, customer_id, lab_id, status, kanban_column, receive_method, return_method, pickup_address, payment_status, payment_method, subtotal, shipping_fee, platform_fee, discount_amount, total_amount, sla_deadline, customer_note)
    VALUES ('${safeCode}', ${dbCustomerId}, ${dbLabId}, 'RECEIVED', 'QUEUE', 'PICKUP', 'DIGITAL_ONLY', N'${safeAddr}', 'PAID', 'MOMO', ${totalNum}, 0, 0, 0, ${totalNum}, DATEADD(HOUR, 24, SYSUTCDATETIME()), N'${safeNote}');
    DECLARE @newOrdId BIGINT = SCOPE_IDENTITY();
    DECLARE @pkgId INT = (SELECT TOP 1 package_id FROM Service_Package WHERE lab_id = ${dbLabId} ORDER BY package_id);
    IF @newOrdId IS NOT NULL AND @pkgId IS NOT NULL
    BEGIN
      INSERT INTO Order_Item (item_code, order_id, package_id, film_stock_id, film_name, roll_code, quantity, unit_price, line_total, push_pull, cut_negatives, status)
      VALUES ('item-' + CAST(@newOrdId AS VARCHAR(20)), @newOrdId, @pkgId, 1, N'${safeFilmName}', '${safeRollCode}', ${itemQty}, ${itemPrice}, ${itemPrice * itemQty}, N'Normal (Box speed)', N'Cắt 6 frames/dải', 'RECEIVED');
    END
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${customerName} (CUSTOMER)`,
    action: 'CREATE_ORDER',
    entity: `Orders #${newOrder.order_id}`,
    entity_name: 'Orders',
    entity_id: newOrder.order_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ lab: lab.name, total_amount: newOrder.total_amount, status: newOrder.status })
  });

  return res.status(201).json({
    success: true,
    message: 'Tạo đơn hàng thành công!',
    data: newOrder
  });
};

exports.createDispute = (req, res) => {
  const { id } = req.params;
  const { issue_type, description, amount_requested } = req.body;
  const order = mockOrders.find(o => o.order_id === id) || mockOrders[0];

  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng để khiếu nại' });
  }

  const now = new Date();
  const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}`;
  const customerName = req.user?.full_name || order.customer_name || 'Nguyễn Hoàng Anh';

  const newDispute = {
    dispute_id: `DSP-${Math.floor(1000 + Math.random() * 9000)}`,
    order_id: order.order_id,
    customer_id: req.user?.user_id || order.user_id || 'usr-001',
    customer_name: customerName,
    lab_id: order.lab_id || 'lab-001',
    lab_name: order.lab_name || 'CropLab Hà Nội',
    issue_type: issue_type || 'Khiếu nại chất lượng Tráng / Scan',
    description: description || 'Ảnh scan có vết xước dọc và sai lệch màu sắc so với yêu cầu.',
    status: 'IN_NEGOTIATION',
    amount_requested: Number(amount_requested) || Number(order.total_amount) || 70000,
    evidence_urls: [
      'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600'
    ],
    created_at: now.toISOString(),
    messages: [
      {
        sender: `${customerName} (Khách)`,
        text: description || 'Nhờ Lab và Admin kiểm tra giúp đơn hàng này.',
        time: timeStr
      }
    ]
  };

  mockDisputes.unshift(newDispute);
  order.dispute_id = newDispute.dispute_id;
  order.dispute_status = newDispute.status;
  order.dispute_issue = newDispute.issue_type;
  order.dispute_description = newDispute.description;

  // Persist new Dispute directly to SQL Server (FilmLabPlatform)
  const safeDspCode = newDispute.dispute_id.replace(/'/g, "''");
  const safeOrdCode = String(order.order_id || '').replace(/'/g, "''");
  const safeIssue = String(newDispute.issue_type || '').replace(/'/g, "''");
  const safeDesc = String(newDispute.description || '').replace(/'/g, "''");
  const reqAmt = Number(newDispute.amount_requested) || 70000;
  const dbCustomerId = req.user?.db_user_id || 5;
  runQuery(`
    DECLARE @ordId BIGINT = (SELECT TOP 1 order_id FROM Orders WHERE order_code = '${safeOrdCode}');
    IF @ordId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Dispute_Complaint WHERE order_id = @ordId)
    BEGIN
      INSERT INTO Dispute_Complaint (dispute_code, order_id, complainant_id, reason_type, issue_title, description, requested_amount, status)
      VALUES ('${safeDspCode}', @ordId, ${dbCustomerId}, 'QUALITY', N'${safeIssue}', N'${safeDesc}', ${reqAmt}, 'NEGOTIATING');
    END
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${customerName} (CUSTOMER)`,
    action: 'OPEN_DISPUTE',
    entity: `Dispute_Complaint #${newDispute.dispute_id}`,
    entity_name: 'Dispute_Complaint',
    entity_id: newDispute.dispute_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ order_id: order.order_id, issue_type: newDispute.issue_type, amount: newDispute.amount_requested })
  });

  return res.status(201).json({
    success: true,
    message: 'Đã gửi khiếu nại tới Tiệm Lab và Ban Quản trị!',
    data: newDispute
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

