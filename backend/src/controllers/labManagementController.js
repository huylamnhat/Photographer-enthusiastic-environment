const { 
  mockOrders, 
  mockLabs, 
  mockServicePackages, 
  mockArchivePhotos, 
  mockDisputes 
} = require('../data/mockStore');

exports.getLabKanban = (req, res) => {
  const labId = req.user?.lab_id || 'lab-001';
  const orders = mockOrders.filter(o => o.lab_id === labId);

  const columns = {
    QUEUE: orders.filter(o => o.kanban_column === 'QUEUE' || o.status === 'RECEIVED' || o.status === 'PENDING_FILM'),
    DEVELOPING: orders.filter(o => o.kanban_column === 'DEVELOPING' || o.status === 'PROCESSING'),
    SCANNING: orders.filter(o => o.kanban_column === 'SCANNING'),
    QC: orders.filter(o => o.kanban_column === 'QC' || o.status === 'QC_CHECK'),
    READY: orders.filter(o => o.kanban_column === 'READY' || o.status === 'READY_FOR_DOWNLOAD' || o.status === 'COMPLETED')
  };

  return res.json({
    success: true,
    data: columns
  });
};

exports.updateKanbanStep = (req, res) => {
  const { orderId } = req.params;
  const { column, note } = req.body; // QUEUE, DEVELOPING, SCANNING, QC, READY

  const order = mockOrders.find(o => o.order_id === orderId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  order.kanban_column = column;

  const now = new Date();
  const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}`;

  switch (column) {
    case 'DEVELOPING':
      order.status = 'PROCESSING';
      if (order.timeline[2]) {
        order.timeline[2].status = 'IN_PROGRESS';
        order.timeline[2].time = timeStr;
        order.timeline[2].note = note || 'Bắt đầu pha hóa chất & nạp tank tráng';
      }
      break;
    case 'SCANNING':
      order.status = 'PROCESSING';
      if (order.timeline[3]) order.timeline[3].status = 'COMPLETED';
      if (order.timeline[4]) {
        order.timeline[4].status = 'IN_PROGRESS';
        order.timeline[4].time = timeStr;
        order.timeline[4].note = note || 'Đang scan trên máy Noritsu HS-1800';
      }
      break;
    case 'QC':
      order.status = 'QC_CHECK';
      if (order.timeline[4]) order.timeline[4].status = 'COMPLETED';
      if (order.timeline[5]) {
        order.timeline[5].status = 'IN_PROGRESS';
        order.timeline[5].time = timeStr;
        order.timeline[5].note = note || 'Kiểm tra bụi, xước và cân bằng màu sắc';
      }
      break;
    case 'READY':
      order.status = 'READY_FOR_DOWNLOAD';
      order.timeline.forEach(step => step.status = 'COMPLETED');
      if (order.timeline[6]) {
        order.timeline[6].time = timeStr;
        order.timeline[6].note = 'File TIFF/JPG đã đồng bộ vào kho ảnh Digital Archive';
      }
      break;
  }

  return res.json({
    success: true,
    message: `Đã cập nhật tiến độ đơn hàng sang cột: ${column}`,
    data: order
  });
};

exports.uploadScanFiles = (req, res) => {
  const { orderId } = req.params;
  const { roll_code, scanner_model, photo_title } = req.body;
  const file = req.file;

  const order = mockOrders.find(o => o.order_id === orderId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  const imageUrl = file 
    ? `/uploads/${file.filename}` 
    : 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1200';

  const newScan = {
    photo_id: `pho-lab-${Date.now()}`,
    user_id: order.user_id,
    order_id: order.order_id,
    roll_code: roll_code || 'ROLL-135-01',
    title: photo_title || `Ảnh scan ${order.order_id}`,
    image_url: imageUrl,
    thumbnail_url: imageUrl,
    album_name: `Đơn hàng ${order.order_id}`,
    is_favorite: false,
    created_at: new Date().toISOString(),
    metadata: {
      camera: 'Máy ảnh Film 35mm',
      lens: '50mm Standard',
      film_stock: order.items[0]?.film_name || 'Color Negative',
      iso: 400,
      aperture: 'f/2.8',
      shutter_speed: '1/250s',
      focal_length: '50mm',
      process: 'C-41 Scan chuẩn',
      lab: order.lab_name,
      dimensions: '6000 x 4000',
      file_size: '17.2 MB TIFF'
    }
  };

  mockArchivePhotos.unshift(newScan);

  // Auto advance order to READY
  order.status = 'READY_FOR_DOWNLOAD';
  order.kanban_column = 'READY';
  order.timeline.forEach(step => step.status = 'COMPLETED');

  return res.status(201).json({
    success: true,
    message: 'Đã upload file scan và nạp tự động vào Digital Archive của khách!',
    data: newScan
  });
};

exports.getLabPackages = (req, res) => {
  const labId = req.user?.lab_id || 'lab-001';
  const packages = mockServicePackages.filter(p => p.lab_id === labId);
  return res.json({
    success: true,
    data: packages
  });
};

exports.updatePackagePrice = (req, res) => {
  const { packageId } = req.params;
  const { price, status, estimated_hours } = req.body;

  const pkg = mockServicePackages.find(p => p.package_id === packageId);
  if (!pkg) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy gói dịch vụ' });
  }

  if (price !== undefined) pkg.price = Number(price);
  if (status !== undefined) pkg.status = status;
  if (estimated_hours !== undefined) pkg.estimated_hours = Number(estimated_hours);

  return res.json({
    success: true,
    message: 'Cập nhật giá và cấu hình gói dịch vụ thành công',
    data: pkg
  });
};

exports.createPackage = (req, res) => {
  const labId = req.user?.lab_id || 'lab-001';
  const { name, film_format, process_type, scan_resolution, price, estimated_hours, description } = req.body;

  const newPkg = {
    package_id: `pkg-${Date.now()}`,
    lab_id: labId,
    name: name || 'Gói dịch vụ tráng mới',
    film_format: film_format || '135',
    process_type: process_type || 'C-41',
    scan_resolution: scan_resolution || 'M (3000x2000px)',
    price: Number(price) || 50000,
    estimated_hours: Number(estimated_hours) || 12,
    status: 'ACTIVE',
    description: description || 'Mô tả gói dịch vụ'
  };

  mockServicePackages.push(newPkg);

  return res.status(201).json({
    success: true,
    message: 'Tạo gói dịch vụ mới thành công',
    data: newPkg
  });
};

exports.getLabProfile = (req, res) => {
  const labId = req.user?.lab_id || 'lab-001';
  const lab = mockLabs.find(l => l.lab_id === labId) || mockLabs[0];
  return res.json({
    success: true,
    data: lab
  });
};

exports.updateLabProfile = (req, res) => {
  const labId = req.user?.lab_id || 'lab-001';
  const lab = mockLabs.find(l => l.lab_id === labId);

  if (!lab) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy lab' });
  }

  const { name, tagline, address, phone, email, description, scanner_models, supported_processes } = req.body;
  if (name) lab.name = name;
  if (tagline) lab.tagline = tagline;
  if (address) lab.address = address;
  if (phone) lab.phone = phone;
  if (email) lab.email = email;
  if (description) lab.description = description;
  if (scanner_models) lab.scanner_models = scanner_models;
  if (supported_processes) lab.supported_processes = supported_processes;

  return res.json({
    success: true,
    message: 'Cập nhật hồ sơ tiệm Film Lab thành công',
    data: lab
  });
};

exports.getLabDisputes = (req, res) => {
  const labId = req.user?.lab_id || 'lab-001';
  const disputes = mockDisputes.filter(d => d.lab_id === labId);
  return res.json({
    success: true,
    data: disputes
  });
};

exports.replyDispute = (req, res) => {
  const { disputeId } = req.params;
  const { reply_text } = req.body;

  const dispute = mockDisputes.find(d => d.dispute_id === disputeId);
  if (!dispute) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy khiếu nại' });
  }

  const now = new Date();
  const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}`;

  dispute.messages.push({
    sender: 'CropLab',
    text: reply_text || 'Lab đã tiếp nhận và sẽ xử lý ngay.',
    time: timeStr
  });

  return res.json({
    success: true,
    message: 'Đã gửi phản hồi thương lượng cho khách hàng',
    data: dispute
  });
};

exports.getSlaPerformance = (req, res) => {
  return res.json({
    success: true,
    data: {
      lab_name: 'CropLab Hà Nội',
      sla_target_hours: 12,
      on_time_delivery_rate: '98.7%',
      total_completed_orders: 1284,
      delayed_orders: 17,
      average_turnaround_hours: 9.4,
      daily_capacity: '80 cuộn / ngày',
      qc_pass_rate: '99.2%'
    }
  });
};

