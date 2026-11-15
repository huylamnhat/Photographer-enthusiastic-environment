const fs = require('fs');
const { 
  mockUsers,
  mockOrders, 
  mockLabs, 
  mockServicePackages, 
  mockArchivePhotos, 
  mockDisputes,
  mockReviews,
  mockAuditLogs,
  mockNotifications
} = require('../data/mockStore');
const { runQuery } = require('../config/db');
const { uploadFileToGoogleDrive } = require('../services/googleDriveService');

function resolveCurrentLabId(req) {
  return (req.query?.lab_id || req.user?.lab_id || 'lab-001').toString();
}

exports.getLabKanban = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const lab = mockLabs.find(l => l.lab_id === labId) || mockLabs[0] || {};
  // Filter orders strictly by the logged-in Film Lab so each Lab only manages its own orders & customers
  const orders = mockOrders.filter(o => o.lab_id === labId);

  const columns = {
    QUEUE: orders.filter(o => o.kanban_column === 'QUEUE' || (!o.kanban_column && (o.status === 'RECEIVED' || o.status === 'PENDING_FILM'))),
    DEVELOPING: orders.filter(o => o.kanban_column === 'DEVELOPING' || (!o.kanban_column && o.status === 'PROCESSING')),
    DRYING: orders.filter(o => o.kanban_column === 'DRYING' || o.kanban_column === 'QC' || (!o.kanban_column && o.status === 'QC_CHECK')),
    SCANNING: orders.filter(o => o.kanban_column === 'SCANNING'),
    READY: orders.filter(o => o.kanban_column === 'READY' || (!o.kanban_column && (o.status === 'READY_FOR_DOWNLOAD' || o.status === 'COMPLETED')))
  };
  // Keep QC alias pointing to DRYING for backward compatibility
  columns.QC = columns.DRYING;
  columns.lab_info = {
    lab_id: labId,
    name: lab.name || 'CropLab Hà Nội',
    address: lab.address || '',
    city: lab.city || '',
  };

  return res.json({
    success: true,
    data: columns
  });
};

exports.updateKanbanStep = (req, res) => {
  const { orderId } = req.params;
  const { column, note } = req.body; // QUEUE (1. Tiếp nhận), DEVELOPING (2. Vào Tank / Tráng), DRYING (3. Sấy khô), SCANNING (4. Scan số hóa), READY (5. QC & Archive)

  const order = mockOrders.find(o => o.order_id === orderId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy đơn hàng' });
  }

  const oldCol = order.kanban_column || 'QUEUE';
  const normalizedCol = column === 'QC' ? 'DRYING' : column;
  order.kanban_column = normalizedCol;

  const now = new Date();
  const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}`;

  if (!Array.isArray(order.timeline) || order.timeline.length < 5) {
    order.timeline = [
      { step: 1, name: '1. Tiếp nhận', status: 'COMPLETED', time: timeStr, note: 'Đã tiếp nhận cuộn film tại Lab' },
      { step: 2, name: '2. Vào Tank / Tráng', status: 'PENDING', time: '', note: '' },
      { step: 3, name: '3. Sấy khô', status: 'PENDING', time: '', note: '' },
      { step: 4, name: '4. Scan số hóa', status: 'PENDING', time: '', note: '' },
      { step: 5, name: '5. QC & Archive', status: 'PENDING', time: '', note: '' }
    ];
  }

  switch (normalizedCol) {
    case 'QUEUE':
      order.status = 'RECEIVED';
      break;
    case 'DEVELOPING':
      order.status = 'PROCESSING';
      if (order.timeline[0]) order.timeline[0].status = 'COMPLETED';
      if (order.timeline[1]) {
        order.timeline[1].status = 'IN_PROGRESS';
        order.timeline[1].time = timeStr;
        order.timeline[1].note = note || 'Đang vào Tank hóa chất tráng phim 37.8°C';
      }
      break;
    case 'DRYING':
      order.status = 'PROCESSING';
      if (order.timeline[0]) order.timeline[0].status = 'COMPLETED';
      if (order.timeline[1]) order.timeline[1].status = 'COMPLETED';
      if (order.timeline[2]) {
        order.timeline[2].status = 'IN_PROGRESS';
        order.timeline[2].time = timeStr;
        order.timeline[2].note = note || 'Đang sấy khô buồng kín & cân bằng phẳng';
      }
      break;
    case 'SCANNING':
      order.status = 'PROCESSING';
      if (order.timeline[0]) order.timeline[0].status = 'COMPLETED';
      if (order.timeline[1]) order.timeline[1].status = 'COMPLETED';
      if (order.timeline[2]) order.timeline[2].status = 'COMPLETED';
      if (order.timeline[3]) {
        order.timeline[3].status = 'IN_PROGRESS';
        order.timeline[3].time = timeStr;
        order.timeline[3].note = note || 'Đang Scan số hóa trên máy Noritsu / Frontier';
      }
      break;
    case 'READY':
      order.status = 'READY_FOR_DOWNLOAD';
      order.timeline.forEach(step => {
        step.status = 'COMPLETED';
      });
      if (order.timeline[4]) {
        order.timeline[4].time = timeStr;
        order.timeline[4].note = 'Đã hoàn tất QC & đồng bộ vào kho ảnh Digital Archive';
      }
      // Auto-create an Archive_Photo for this order if none exists yet so Customer sees it immediately in Archive
      if (!mockArchivePhotos.some(p => p.order_id === order.order_id)) {
        const defaultScan = {
          photo_id: `pho-ready-${Date.now()}`,
          user_id: order.user_id || 'usr-001',
          order_id: order.order_id,
          roll_code: order.items?.[0]?.roll_code || 'ROLL-135-01',
          title: `Scan ${order.items?.[0]?.film_name || 'Kodak Portra 400'} (${order.order_id})`,
          image_url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=1200',
          thumbnail_url: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600',
          album_name: `Đơn ${order.order_id} - ${order.lab_name || 'MiniLab'}`,
          is_favorite: false,
          created_from_lab: true,
          created_at: now.toISOString(),
          metadata: {
            camera: 'Leica M6 Classic',
            lens: 'Summicron 35mm f/2',
            film_stock: order.items?.[0]?.film_name || 'Kodak Portra 400',
            iso: 400,
            aperture: 'f/2.8',
            shutter_speed: '1/250s',
            focal_length: '35mm',
            process: 'C-41 Noritsu HS-1800',
            lab: order.lab_name || 'CropLab Hà Nội',
            dimensions: '6048 x 4032',
            file_size: '18.4 MB TIFF'
          }
        };
        mockArchivePhotos.unshift(defaultScan);
      }
      break;
  }

  // Persist Kanban update directly into SQL Server (FilmLabPlatform)
  const dbKanbanCol = normalizedCol === 'DRYING' ? 'QC' : normalizedCol;
  const safeOrderId = String(order.order_id || '').replace(/'/g, "''");
  runQuery(`
    UPDATE Orders
    SET kanban_column = '${dbKanbanCol}', status = '${order.status}', updated_at = SYSUTCDATETIME()
    WHERE order_code = '${safeOrderId}';
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${req.user?.full_name || 'Lab Technician'} (LAB_STAFF)`,
    action: 'UPDATE_KANBAN_STEP',
    entity: `Orders #${order.order_id}`,
    entity_name: 'Orders',
    entity_id: order.order_id,
    ip: req.ip || '127.0.0.1',
    oldVal: JSON.stringify({ kanban_column: oldCol }),
    newVal: JSON.stringify({ kanban_column: column, status: order.status })
  });

  return res.json({
    success: true,
    message: `Đã cập nhật tiến độ đơn hàng sang cột: ${column}`,
    data: order
  });
};

exports.uploadScanFiles = async (req, res) => {
  const { orderId } = req.params;
  const {
    roll_code,
    scanner_model,
    photo_title,
    film_stock,
    image_url,
    drive_link,
    file_base64,
    file_name,
    selected_photos,
    recipient_user_id,
    recipient_email,
  } = req.body;
  const file = req.file;

  const requestedOrderId = String(orderId || req.body.order_id || '').trim();
  if (!requestedOrderId) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng chọn đơn hàng đã đến bước 5. QC & Archive của khách hàng trước khi gửi link!'
    });
  }

  const order = mockOrders.find(o => o.order_id.toLowerCase() === requestedOrderId.toLowerCase());
  if (!order) {
    return res.status(404).json({
      success: false,
      message: `Không tìm thấy đơn hàng #${requestedOrderId}.`
    });
  }

  const currentLabId = req.user?.lab_id || '';
  if (currentLabId && order.lab_id && order.lab_id !== currentLabId) {
    return res.status(403).json({
      success: false,
      message: `Đơn hàng #${order.order_id} thuộc tiệm ${order.lab_name || order.lab_id}, không thuộc tiệm Lab đang đăng nhập!`
    });
  }

  // Resolve target customer explicitly selected by Lab
  const targetUser =
    mockUsers.find(
      u =>
        (recipient_user_id && u.user_id === recipient_user_id) ||
        (recipient_email && u.email.toLowerCase() === String(recipient_email).toLowerCase())
    ) ||
    mockUsers.find(u => u.user_id === order.user_id) ||
    { user_id: order.user_id || '', email: order.customer_email || '', full_name: order.customer_name || 'Khách hàng' };

  const targetUserId = targetUser.user_id;
  const targetUserEmail = targetUser.email || '';
  const targetUserName = targetUser.full_name || 'Khách hàng';

  // Ensure the order actually belongs to the selected customer
  if (recipient_user_id || recipient_email) {
    const belongsToCustomer =
      (targetUserId && order.user_id === targetUserId) ||
      (targetUserEmail && (order.customer_email || '').toLowerCase() === targetUserEmail.toLowerCase());
    if (!belongsToCustomer) {
      return res.status(400).json({
        success: false,
        message: `Đơn hàng #${order.order_id} không thuộc về khách hàng ${targetUserName}!`
      });
    }
  }

  // Only allow sending scan link for orders that have reached step 5. QC & Archive; keep earlier orders untouched at their current step
  const isReadyStep =
    order.kanban_column === 'READY' ||
    order.status === 'READY_FOR_DOWNLOAD' ||
    order.status === 'COMPLETED';
  if (!isReadyStep) {
    const stepMap = {
      QUEUE: '1. Tiếp nhận',
      DEVELOPING: '2. Vào Tank / Tráng',
      DRYING: '3. Sấy khô',
      QC: '3. Sấy khô',
      SCANNING: '4. Scan số hóa',
    };
    const currentStepName = stepMap[order.kanban_column] || order.kanban_column || '1. Tiếp nhận';
    return res.status(400).json({
      success: false,
      message: `Đơn hàng #${order.order_id} hiện đang ở bước ${currentStepName}, chưa đến bước 5. QC & Archive. Các đơn đang xử lý sẽ giữ nguyên bước hiện tại — hãy chuyển đơn sang bước 5. QC & Archive trên bảng Kanban trước khi gửi link!`
    });
  }

  let fileBuffer = null;
  if (file && file.path && fs.existsSync(file.path)) {
    try {
      fileBuffer = fs.readFileSync(file.path);
    } catch (_) {}
  } else if (file_base64) {
    try {
      const cleanBase64 = String(file_base64).replace(/^data:[^;]+;base64,/, '');
      fileBuffer = Buffer.from(cleanBase64, 'base64');
    } catch (_) {}
  }

  const hasBatch = Array.isArray(selected_photos) && selected_photos.length > 0;

  const driveResult = await uploadFileToGoogleDrive({
    fileName: file_name || (file ? file.originalname : `Scan-${order.order_id}-${roll_code || 'ROLL'}-1080x720.jpg`),
    mimeType: file ? file.mimetype : 'image/jpeg',
    fileBuffer,
    imageUrl: image_url || 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1080&h=720&fit=crop&fm=jpg&q=85',
    customDriveLink: drive_link || '',
    orderId: order.order_id,
    selectedPhotos: hasBatch ? selected_photos : null,
    replaceFolderContents: true,
  });

  const resolvedDriveLink = driveResult.folder_url || driveResult.web_view_link;
  const now = new Date();

  // Keep all previous links, photos, and notifications intact (each upload creates a new Google Drive folder & link!)
  const uploadedItems = Array.isArray(driveResult.uploaded_items) && driveResult.uploaded_items.length > 0
    ? driveResult.uploaded_items
    : [
        {
          file_name: file_name || 'Scan-1080x720.jpg',
          title: photo_title || `Ảnh scan ${order.order_id}`,
          image_url: file ? `/uploads/${file.filename}` : (image_url || 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1080&h=720&fit=crop&fm=jpg&q=85'),
        },
      ];

  const createdScans = [];
  for (let i = uploadedItems.length - 1; i >= 0; i--) {
    const uItem = uploadedItems[i];
    const scanEntry = {
      photo_id: `pho-lab-${Date.now()}-${i}`,
      user_id: targetUserId,
      recipient_email: targetUserEmail,
      recipient_name: targetUserName,
      order_id: order.order_id,
      roll_code: roll_code || order.items?.[0]?.roll_code || 'ROLL-135-01',
      title: uItem.title || photo_title || `Ảnh scan ${order.order_id} #${i + 1}`,
      image_url: uItem.image_url,
      thumbnail_url: uItem.image_url,
      drive_link: resolvedDriveLink,
      drive_mode: driveResult.mode,
      album_name: `Đơn hàng ${order.order_id}`,
      is_favorite: false,
      created_from_lab: true,
      created_at: now.toISOString(),
      metadata: {
        camera: 'Máy ảnh Film 35mm',
        lens: '50mm f/1.4 Standard',
        film_stock: film_stock || order.items?.[0]?.film_name || 'Kodak Portra 400',
        iso: 400,
        aperture: 'f/2.8',
        shutter_speed: '1/250s',
        focal_length: '50mm',
        process: scanner_model || 'C-41 Noritsu HS-1800',
        lab: order.lab_name || 'CropLab Hà Nội',
        dimensions: '1080 x 720',
        file_size: '2.4 MB JPEG (1080x720)',
        drive_link: resolvedDriveLink
      }
    };
    mockArchivePhotos.unshift(scanEntry);
    createdScans.unshift(scanEntry);
  }

  const newScan = createdScans[0];

  // Attach Google Drive link per (customer, order) for this already-READY order (never alter non-READY orders)
  if (!order.drive_links_by_user) order.drive_links_by_user = {};
  order.drive_links_by_user[targetUserId] = resolvedDriveLink;
  if (targetUserEmail) {
    order.drive_links_by_user[targetUserEmail.toLowerCase()] = resolvedDriveLink;
  }
  if (!order.drive_link_history_by_user) order.drive_link_history_by_user = {};
  const prevUserLinks = order.drive_link_history_by_user[targetUserId] || [];
  if (!prevUserLinks.includes(resolvedDriveLink)) {
    order.drive_link_history_by_user[targetUserId] = [resolvedDriveLink, ...prevUserLinks];
  }
  if (targetUserEmail) {
    const emailKey = targetUserEmail.toLowerCase();
    const prevEmailLinks = order.drive_link_history_by_user[emailKey] || [];
    if (!prevEmailLinks.includes(resolvedDriveLink)) {
      order.drive_link_history_by_user[emailKey] = [resolvedDriveLink, ...prevEmailLinks];
    }
  }
  if (Array.isArray(order.timeline)) {
    order.timeline.forEach(step => {
      step.status = 'COMPLETED';
    });
  }

  // Send Notification with Google Drive link ONLY to the selected Customer & for the selected Order
  mockNotifications.unshift({
    notification_id: `NTF-DRV-${Date.now()}`,
    type: 'GOOGLE_DRIVE_SCAN',
    order_id: order.order_id,
    customer_id: targetUserId,
    recipient_email: targetUserEmail,
    title: `☁️ Đơn #${order.order_id}: Đã có ${createdScans.length} ảnh Scan & Link Google Drive`,
    message: `Xin chào ${targetUserName}, tiệm ${order.lab_name || 'Film Lab'} đã gửi ${createdScans.length} ảnh scan (1080x720) của đơn hàng #${order.order_id} lên Google Drive: ${resolvedDriveLink}`,
    drive_link: resolvedDriveLink,
    created_at: now.toISOString(),
    is_read: false,
  });

  // Persist READY status and new Scan Photo directly into SQL Server (FilmLabPlatform)
  const safeOrderId = String(order.order_id || '').replace(/'/g, "''");
  const safePhotoCode = newScan.photo_id.replace(/'/g, "''");
  const safeRoll = String(newScan.roll_code || '').replace(/'/g, "''");
  const safeTitle = String(newScan.title || '').replace(/'/g, "''");
  const safeImgUrl = String(newScan.image_url || '').replace(/'/g, "''");
  runQuery(`
    UPDATE Orders
    SET kanban_column = 'READY', status = '${order.status}', updated_at = SYSUTCDATETIME()
    WHERE order_code = '${safeOrderId}';
    INSERT INTO Archive_Photo (photo_code, archive_id, roll_code, title, file_name, storage_key, thumbnail_key, mime_type, size_bytes, width_px, height_px, is_favorite)
    VALUES ('${safePhotoCode}', 1, '${safeRoll}', N'${safeTitle}', N'scan.tiff', '${safeImgUrl}', '${safeImgUrl}', 'image/tiff', 18000000, 6048, 4032, 0);
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${req.user?.full_name || 'Lab Technician'} (LAB_STAFF)`,
    action: 'UPLOAD_ARCHIVE_SCAN',
    entity: `Digital_Film_Archive #${order.order_id}`,
    entity_name: 'Digital_Film_Archive',
    entity_id: order.order_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ photo_id: newScan.photo_id, roll_code: newScan.roll_code, scanner: scanner_model, drive_link: resolvedDriveLink })
  });

  return res.status(201).json({
    success: true,
    message: 'Đã tải file scan lên Google Drive, gửi link cho khách và nạp vào Digital Archive!',
    drive_link: resolvedDriveLink,
    drive_mode: driveResult.mode,
    data: newScan
  });
};

exports.getLabPackages = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const lab = mockLabs.find(l => l.lab_id === labId) || mockLabs[0] || {};
  const packages = mockServicePackages.filter(p => p.lab_id === labId);
  const auditTrail = mockAuditLogs.filter(
    a => a.entity_name === 'Service_Package' && (!a.lab_id || a.lab_id === labId)
  );
  return res.json({
    success: true,
    lab_id: labId,
    lab_name: lab.name || '',
    data: packages,
    process_table: lab.process_table || [],
    audit_trail: auditTrail
  });
};

exports.updatePackagePrice = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const { packageId } = req.params;
  const { price, status, estimated_hours, name, scan_resolution, description, film_format, process_type } = req.body;

  const pkg = mockServicePackages.find(p => p.package_id === packageId && p.lab_id === labId)
    || mockServicePackages.find(p => p.package_id === packageId);
  if (!pkg) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy gói dịch vụ' });
  }
  if (pkg.lab_id !== labId && req.user?.role === 'LabOwner') {
    return res.status(403).json({ success: false, message: 'Bạn chỉ có quyền chỉnh sửa gói dịch vụ của tiệm Lab mình!' });
  }

  const oldPrice = pkg.price;
  const oldStatus = pkg.status;
  if (price !== undefined) pkg.price = Number(price);
  if (status !== undefined) pkg.status = status;
  if (estimated_hours !== undefined) pkg.estimated_hours = Number(estimated_hours);
  if (name !== undefined && String(name).trim()) pkg.name = String(name).trim();
  if (scan_resolution !== undefined && String(scan_resolution).trim()) pkg.scan_resolution = String(scan_resolution).trim();
  if (description !== undefined) pkg.description = String(description);
  if (film_format !== undefined) pkg.film_format = String(film_format);
  if (process_type !== undefined) pkg.process_type = String(process_type);

  const now = new Date();
  const safePkgCode = String(pkg.package_id || '').replace(/'/g, "''");
  const safePkgName = String(pkg.name || '').replace(/'/g, "''");
  const safeScanRes = String(pkg.scan_resolution || 'M (3000x2000px)').replace(/'/g, "''");
  const safeDesc = String(pkg.description || '').replace(/'/g, "''");
  runQuery(`
    UPDATE Service_Package
    SET price = ${Number(pkg.price) || 50000},
        name = N'${safePkgName}',
        scan_resolution = N'${safeScanRes}',
        description = N'${safeDesc}',
        is_active = ${pkg.status === 'ACTIVE' ? 1 : 0},
        estimated_hours = ${Number(pkg.estimated_hours) || 12}
    WHERE package_code = '${safePkgCode}';
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    lab_id: pkg.lab_id,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${req.user?.full_name || 'Lab Owner'} (LAB_STAFF)`,
    action: 'UPDATE_SERVICE_PRICE',
    entity: `Service_Package #${pkg.package_id}`,
    entity_name: 'Service_Package',
    entity_id: pkg.package_id,
    ip: req.ip || '127.0.0.1',
    oldVal: JSON.stringify({ price: oldPrice, status: oldStatus }),
    newVal: JSON.stringify({ price: pkg.price, status: pkg.status })
  });

  return res.json({
    success: true,
    message: 'Cập nhật giá và cấu hình gói dịch vụ thành công',
    data: pkg
  });
};

exports.createPackage = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const lab = mockLabs.find(l => l.lab_id === labId) || mockLabs[0] || { lab_id: 'lab-001', db_lab_id: 1, name: 'CropLab Hà Nội' };
  const { name, film_format, process_type, scan_resolution, price, estimated_hours, description } = req.body;

  const newPkg = {
    package_id: `pkg-${Date.now().toString().slice(-5)}`,
    lab_id: labId,
    lab_name: lab.name,
    name: name || 'Gói dịch vụ tráng mới',
    film_format: film_format || '135',
    process_type: process_type || 'C-41',
    scan_resolution: scan_resolution || 'M (3000x2000px)',
    price: Number(price) || 70000,
    estimated_hours: Number(estimated_hours) || 12,
    status: 'ACTIVE',
    description: description || 'Mô tả gói dịch vụ'
  };

  mockServicePackages.unshift(newPkg);

  const now = new Date();
  const dbLabId = Number(lab.db_lab_id || 1);
  const fmtUpper = String(newPkg.film_format).toUpperCase();
  const formatId = fmtUpper.includes('4X5') ? 7 : (fmtUpper.includes('120') ? 3 : 1);
  const procUpper = String(newPkg.process_type).toUpperCase();
  const procId = procUpper.includes('E-6') || procUpper.includes('E6')
    ? 2
    : (procUpper.includes('B&W') || procUpper.includes('BW')
        ? 3
        : (procUpper.includes('ECN') ? 4 : 1));
  const safeNewPkgCode = String(newPkg.package_id || '').replace(/'/g, "''");
  const safeNewPkgName = String(newPkg.name || '').replace(/'/g, "''");
  const safeNewPkgDesc = String(newPkg.description || '').replace(/'/g, "''");
  const safeNewScanRes = String(newPkg.scan_resolution || '').replace(/'/g, "''");
  runQuery(`
    INSERT INTO Service_Package (package_code, lab_id, service_type, name, description, format_id, process_type_id, scan_quality, scan_resolution, output_format, price, est_processing_days, estimated_hours, is_active)
    VALUES ('${safeNewPkgCode}', ${dbLabId}, 'DEVELOP_SCAN', N'${safeNewPkgName}', N'${safeNewPkgDesc}', ${formatId}, ${procId}, 'STANDARD', N'${safeNewScanRes}', 'JPEG', ${Number(newPkg.price) || 70000}, 1, ${Number(newPkg.estimated_hours) || 12}, 1);
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    lab_id: labId,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${req.user?.full_name || 'Lab Owner'} (LAB_STAFF)`,
    action: 'CREATE_SERVICE_PACKAGE',
    entity: `Service_Package #${newPkg.package_id}`,
    entity_name: 'Service_Package',
    entity_id: newPkg.package_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ name: newPkg.name, price: newPkg.price })
  });

  return res.status(201).json({
    success: true,
    message: 'Tạo gói dịch vụ mới thành công',
    data: newPkg
  });
};

exports.updateProcessTable = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const lab = mockLabs.find(l => l.lab_id === labId);
  if (!lab) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy tiệm Film Lab' });
  }
  const { process_table } = req.body;
  if (!Array.isArray(process_table)) {
    return res.status(400).json({ success: false, message: 'Dữ liệu bảng tráng không hợp lệ' });
  }
  lab.process_table = process_table;
  const derivedProcesses = Array.from(
    new Set(process_table.map(row => row.process_code).filter(Boolean))
  );
  if (derivedProcesses.length > 0) {
    lab.supported_processes = derivedProcesses;
  }

  return res.json({
    success: true,
    message: 'Cập nhật Bảng Tráng & Quy Trình Hóa Chất của tiệm thành công!',
    data: lab.process_table
  });
};

exports.getLabProfile = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const lab = mockLabs.find(l => l.lab_id === labId) || mockLabs[0];
  return res.json({
    success: true,
    data: lab
  });
};

exports.updateLabProfile = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const lab = mockLabs.find(l => l.lab_id === labId) || mockLabs[0];

  if (!lab) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy lab' });
  }

  const { name, tagline, address, phone, email, description, scanner_models, supported_processes, process_table } = req.body;
  if (name) lab.name = name;
  if (tagline) lab.tagline = tagline;
  if (address) lab.address = address;
  if (phone) lab.phone = phone;
  if (email) lab.email = email;
  if (description) lab.description = description;
  if (scanner_models) lab.scanner_models = scanner_models;
  if (supported_processes) lab.supported_processes = supported_processes;
  if (Array.isArray(process_table)) lab.process_table = process_table;

  const safeCode = String(lab.lab_id || '').replace(/'/g, "''");
  const safeName = String(lab.name || '').replace(/'/g, "''");
  const safeAddr = String(lab.address || '').replace(/'/g, "''");
  const safePhone = String(lab.phone || '').replace(/'/g, "''");
  const safeEmail = String(lab.email || '').replace(/'/g, "''");
  runQuery(`
    UPDATE Lab_Profile
    SET lab_name = N'${safeName}',
        street_address = N'${safeAddr}',
        phone = '${safePhone}',
        email = N'${safeEmail}',
        updated_at = SYSUTCDATETIME()
    WHERE lab_code = '${safeCode}';
  `).catch(() => {});

  return res.json({
    success: true,
    message: 'Cập nhật hồ sơ tiệm Film Lab thành công',
    data: lab
  });
};

exports.getLabDisputes = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const labDisputes = mockDisputes.filter(d => d.lab_id === labId);
  return res.json({
    success: true,
    data: labDisputes
  });
};

exports.replyDispute = (req, res) => {
  const { disputeId } = req.params;
  const { reply_text, escalate } = req.body;

  const dispute = mockDisputes.find(d => d.dispute_id === disputeId);
  if (!dispute) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy khiếu nại' });
  }

  const now = new Date();
  const timeStr = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')} ${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}`;
  const finalReply = reply_text || (escalate
    ? 'Lab đề nghị chuyển hồ sơ lên Admin Tổng Sàn phân xử.'
    : 'Lab đã đền bù tặng 01 cuộn phim mới, voucher giảm 50% và hỗ trợ scan lại miễn phí cho khách hàng.');

  if (escalate) {
    dispute.status = 'ESCALATED';
    dispute.messages.push({
      sender: `${dispute.lab_name || 'Film Lab'} (Lab)`,
      text: finalReply,
      time: timeStr
    });
  } else {
    dispute.status = 'COMPENSATED';
    dispute.compensation_note = finalReply;
    dispute.messages.push({
      sender: `${dispute.lab_name || 'Film Lab'} (Lab)`,
      text: finalReply,
      time: timeStr
    });
  }

  // Đồng bộ ngay vào đơn hàng tương ứng để Khách hàng thấy trên danh sách & chi tiết đơn
  const targetOrder = mockOrders.find(o => o.order_id === dispute.order_id);
  if (targetOrder) {
    targetOrder.dispute_id = dispute.dispute_id;
    targetOrder.dispute_status = dispute.status;
    targetOrder.compensation_note = dispute.compensation_note || finalReply;
  }

  // Gửi thông báo realtime đến tài khoản Khách hàng
  mockNotifications.unshift({
    notification_id: `NTF-${Date.now()}`,
    type: escalate ? 'DISPUTE_ESCALATED' : 'COMPENSATION',
    order_id: dispute.order_id,
    dispute_id: dispute.dispute_id,
    customer_id: dispute.customer_id || 'usr-001',
    title: escalate
      ? `⚖️ Khiếu nại đơn #${dispute.order_id} đã chuyển lên Admin phân xử`
      : `🎁 Tiệm ${dispute.lab_name || 'Film Lab'} đã đền bù cuộn film cho đơn #${dispute.order_id}!`,
    message: finalReply,
    created_at: now.toISOString(),
    is_read: false,
  });

  const safeDspCode = String(dispute.dispute_id || '').replace(/'/g, "''");
  const safeReply = String(finalReply || '').replace(/'/g, "''");
  if (escalate) {
    runQuery(`
      UPDATE Dispute_Complaint
      SET status = 'ESCALATED', escalated_at = SYSUTCDATETIME(), assigned_admin_id = 1
      WHERE dispute_code = '${safeDspCode}';
      DECLARE @dspId BIGINT = (SELECT TOP 1 dispute_id FROM Dispute_Complaint WHERE dispute_code = '${safeDspCode}');
      IF @dspId IS NOT NULL
      BEGIN
        INSERT INTO Dispute_Message (dispute_id, sender_id, content) VALUES (@dspId, 3, N'${safeReply}');
      END
    `).catch(() => {});
  } else {
    runQuery(`
      UPDATE Dispute_Complaint
      SET status = 'RESOLVED', resolved_at = SYSUTCDATETIME()
      WHERE dispute_code = '${safeDspCode}';
      DECLARE @dspId2 BIGINT = (SELECT TOP 1 dispute_id FROM Dispute_Complaint WHERE dispute_code = '${safeDspCode}');
      IF @dspId2 IS NOT NULL
      BEGIN
        INSERT INTO Dispute_Message (dispute_id, sender_id, content) VALUES (@dspId2, 3, N'${safeReply}');
      END
    `).catch(() => {});
  }

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${req.user?.full_name || 'Lab Owner'} (LAB_STAFF)`,
    action: escalate ? 'ESCALATE_DISPUTE' : 'COMPENSATE_CUSTOMER_FILM',
    entity: `Dispute_Complaint #${dispute.dispute_id}`,
    entity_name: 'Dispute_Complaint',
    entity_id: dispute.dispute_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{"status":"NEGOTIATING"}',
    newVal: JSON.stringify({ status: dispute.status, reply: finalReply })
  });

  return res.json({
    success: true,
    message: escalate ? 'Đã chuyển khiếu nại lên Admin phân xử' : 'Đã gửi thông báo đền bù cuộn film mới cho khách hàng!',
    data: dispute
  });
};

exports.getSlaPerformance = (req, res) => {
  const labId = resolveCurrentLabId(req);
  const lab = mockLabs.find(l => l.lab_id === labId) || mockLabs[0] || {};
  const labOrders = mockOrders.filter(o => o.lab_id === labId);
  const slaTargetHours = lab.turnaround_hours || 12;

  const enrichedOrders = labOrders.map(o => {
    const normOrderId = String(o.order_id || '').replace(/^#/, '').trim().toUpperCase();
    const review = mockReviews.find(
      r => r.order_id && String(r.order_id).replace(/^#/, '').trim().toUpperCase() === normOrderId
    );
    return {
      ...o,
      rating: review ? Number(review.rating) : null,
      review_comment: review ? (review.comment || '') : null,
      review_service: review ? (review.service_name || '') : null,
      sla_target_hours: slaTargetHours,
    };
  });

  res.set('Cache-Control', 'no-store, no-cache, must-revalidate');
  return res.json({
    success: true,
    data: {
      lab_id: labId,
      lab_name: lab.name || 'CropLab Hà Nội',
      sla_target_hours: slaTargetHours,
      on_time_delivery_rate: '98.7%',
      total_completed_orders: enrichedOrders.length,
      delayed_orders: 0,
      average_turnaround_hours: lab.turnaround_hours ? Number((lab.turnaround_hours * 0.8).toFixed(1)) : 9.4,
      daily_capacity: labId === 'lab-003' ? '35 cuộn thủ công / ngày' : (labId === 'lab-002' ? '95 cuộn / ngày' : '80 cuộn / ngày'),
      qc_pass_rate: '99.2%',
      orders: enrichedOrders
    }
  });
};

