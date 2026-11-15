const fs = require('fs');
const { mockArchivePhotos, mockOrders, mockNotifications, mockUsers } = require('../data/mockStore');
const { getDriveConfigStatus, updateDriveConfig, uploadFileToGoogleDrive, ensureRealDriveFolder, getValidAccessToken } = require('../services/googleDriveService');

function getKanbanStepLabel(kanbanColumn, status) {
  if (kanbanColumn === 'READY' || status === 'READY_FOR_DOWNLOAD' || status === 'COMPLETED') {
    return '5. QC & Archive';
  }
  switch (kanbanColumn) {
    case 'SCANNING':
      return '4. Scan số hóa';
    case 'DRYING':
    case 'QC':
      return '3. Sấy khô';
    case 'DEVELOPING':
      return '2. Vào Tank / Tráng';
    case 'QUEUE':
    default:
      return '1. Tiếp nhận';
  }
}

function isOrderReadyForQcArchive(o) {
  return (
    o.kanban_column === 'READY' ||
    o.status === 'READY_FOR_DOWNLOAD' ||
    o.status === 'COMPLETED'
  );
}

function getCustomerRecipientsList(filterLabId = '') {
  const scopedOrders = filterLabId
    ? mockOrders.filter(o => o.lab_id === filterLabId)
    : mockOrders;

  const allOrdersFormatted = scopedOrders.map(o => {
    const firstItem = (Array.isArray(o.items) && o.items[0]) || {};
    const filmName = firstItem.film_name || 'Kodak Portra 400';
    const rollCode = firstItem.roll_code || 'ROLL-135-01';
    const pkgName = firstItem.name || 'Tráng & Scan Tiêu chuẩn';
    const kanbanCol = o.kanban_column || 'QUEUE';
    const stepLabel = getKanbanStepLabel(kanbanCol, o.status);
    return {
      order_id: o.order_id,
      user_id: o.user_id || '',
      customer_email: o.customer_email || '',
      customer_name: o.customer_name || '',
      lab_id: o.lab_id || '',
      film_name: filmName,
      roll_code: rollCode,
      package_name: pkgName,
      status: o.status || 'RECEIVED',
      kanban_column: kanbanCol,
      step_label: stepLabel,
      lab_name: o.lab_name || 'CropLab Hà Nội',
      order_date: o.order_date || '',
      label: `#${o.order_id} • ${filmName} (${rollCode}) [${stepLabel}]`,
    };
  });

  const customers = mockUsers
    .filter(u => (u.role === 'Customer' || u.role === 'Expert') && u.status !== 'LOCKED')
    .map(u => {
      // Strictly match ONLY orders owned by this customer AT THIS LAB (never share customer records across labs)
      const ownOrders = allOrdersFormatted.filter(
        o =>
          (u.user_id && o.user_id === u.user_id) ||
          (u.email && o.customer_email && o.customer_email.toLowerCase() === u.email.toLowerCase())
      );
      if (filterLabId && ownOrders.length === 0) {
        return null;
      }
      const readyOrders = ownOrders.filter(isOrderReadyForQcArchive);
      const inProgressOrders = ownOrders.filter(o => !isOrderReadyForQcArchive(o));

      return {
        user_id: u.user_id,
        full_name: u.full_name,
        email: u.email,
        phone: u.phone || '',
        order_id: readyOrders[0]?.order_id || '',
        orders: readyOrders,
        in_progress_orders: inProgressOrders,
        total_orders_count: ownOrders.length,
        ready_orders_count: readyOrders.length,
      };
    })
    .filter(Boolean);

  // Put customers with READY orders at the top for quick selection
  customers.sort((a, b) => {
    const aHasReady = a.ready_orders_count > 0 ? 0 : 1;
    const bHasReady = b.ready_orders_count > 0 ? 0 : 1;
    if (aHasReady !== bHasReady) return aHasReady - bHasReady;
    const aPriority = a.email === 'thutrang.pham@gmail.com' ? 0 : (a.email === 'khachhang@minilab.vn' ? 1 : 2);
    const bPriority = b.email === 'thutrang.pham@gmail.com' ? 0 : (b.email === 'khachhang@minilab.vn' ? 1 : 2);
    if (aPriority !== bPriority) return aPriority - bPriority;
    return a.full_name.localeCompare(b.full_name, 'vi');
  });

  return customers;
}

exports.getMyPhotos = async (req, res) => {
  const { album, roll_code, favorite_only, order_id } = req.query;
  const currentUserId = req.user?.user_id || '';
  const currentUserEmail = (req.user?.email || '').toLowerCase();

  // Filter strictly by the logged-in customer so other accounts do NOT receive links/photos meant for another customer
  let photos = mockArchivePhotos.filter(p => {
    if (!p.drive_link) return false;
    if (currentUserId && p.user_id === currentUserId) return true;
    if (currentUserEmail && p.recipient_email && p.recipient_email.toLowerCase() === currentUserEmail) return true;
    return false;
  });

  if (order_id && order_id !== 'ALL') {
    photos = photos.filter(p => String(p.order_id || '').toLowerCase() === String(order_id).toLowerCase());
  }
  if (album) {
    photos = photos.filter(p => p.album_name === album);
  }
  if (roll_code) {
    photos = photos.filter(p => p.roll_code === roll_code);
  }
  if (favorite_only === 'true') {
    photos = photos.filter(p => p.is_favorite);
  }

  return res.json({
    success: true,
    count: photos.length,
    data: photos
  });
};

exports.getPhotoById = (req, res) => {
  const { id } = req.params;
  const photo = mockArchivePhotos.find(p => p.photo_id === id);
  if (!photo) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy ảnh' });
  }

  return res.json({
    success: true,
    data: photo
  });
};

exports.toggleFavorite = (req, res) => {
  const { id } = req.params;
  const photo = mockArchivePhotos.find(p => p.photo_id === id);
  if (!photo) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy ảnh' });
  }

  photo.is_favorite = !photo.is_favorite;
  return res.json({
    success: true,
    is_favorite: photo.is_favorite,
    message: photo.is_favorite ? 'Đã thêm vào yêu thích' : 'Đã bỏ khỏi yêu thích'
  });
};

exports.getAlbums = (req, res) => {
  const currentUserId = req.user?.user_id || '';
  const currentUserEmail = (req.user?.email || '').toLowerCase();
  const userPhotos = mockArchivePhotos.filter(
    p => (currentUserId && p.user_id === currentUserId) || (currentUserEmail && (p.recipient_email || '').toLowerCase() === currentUserEmail)
  );

  const albumMap = {};
  userPhotos.forEach(p => {
    const name = p.album_name || 'Chung';
    if (!albumMap[name]) {
      albumMap[name] = {
        name,
        count: 0,
        cover_image: p.image_url,
        latest_date: p.created_at
      };
    }
    albumMap[name].count++;
  });

  return res.json({
    success: true,
    data: Object.values(albumMap)
  });
};

exports.getGoogleDriveConfig = async (req, res) => {
  try {
    const cfg = getDriveConfigStatus();
    if (!cfg.folder_id && cfg.is_live_api_ready) {
      const token = await getValidAccessToken();
      if (token) await ensureRealDriveFolder(token);
    }
  } catch (_) {}
  const filterLabId = (req.query?.lab_id || req.user?.lab_id || '').toString();
  return res.json({
    success: true,
    data: {
      ...getDriveConfigStatus(),
      lab_id: filterLabId,
      customers: getCustomerRecipientsList(filterLabId),
    }
  });
};

exports.saveGoogleDriveConfig = (req, res) => {
  const updated = updateDriveConfig(req.body || {});
  const filterLabId = (req.query?.lab_id || req.user?.lab_id || '').toString();
  return res.json({
    success: true,
    message: 'Đã cập nhật cấu hình tài khoản Google Drive API thành công!',
    data: {
      ...updated,
      lab_id: filterLabId,
      customers: getCustomerRecipientsList(filterLabId),
    }
  });
};

exports.uploadScan = async (req, res) => {
  const {
    title,
    album_name,
    roll_code,
    order_id,
    camera,
    lens,
    film_stock,
    iso,
    drive_link,
    file_base64,
    file_name,
    image_url,
    selected_photos,
    replace_folder,
    recipient_user_id,
    recipient_email,
  } = req.body;
  const file = req.file;

  // Resolve target customer receiving the photos & link
  const targetUser =
    mockUsers.find(
      u =>
        (recipient_user_id && u.user_id === recipient_user_id) ||
        (recipient_email && u.email.toLowerCase() === String(recipient_email).toLowerCase())
    ) ||
    mockUsers.find(u => u.user_id === req.user?.user_id) ||
    { user_id: req.user?.user_id || 'usr-015', email: req.user?.email || 'thutrang.pham@gmail.com', full_name: req.user?.full_name || 'Phạm Thu Trang' };

  const targetUserId = targetUser.user_id;
  const targetUserEmail = targetUser.email || '';
  const targetUserName = targetUser.full_name || 'Khách hàng';

  // Verify the selected order belongs to the target customer and has reached step 5. QC & Archive
  if (!order_id || !String(order_id).trim()) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng chọn một đơn hàng đã đến bước 5. QC & Archive của khách hàng để gửi link ảnh!',
    });
  }
  const targetOrderId = String(order_id).trim();
  const matchingOrder = mockOrders.find(o => o.order_id.toLowerCase() === targetOrderId.toLowerCase());
  if (!matchingOrder) {
    return res.status(404).json({
      success: false,
      message: `Không tìm thấy đơn hàng #${targetOrderId} trong hệ thống.`,
    });
  }
  const currentLabId = req.user?.lab_id || '';
  if (currentLabId && matchingOrder.lab_id && matchingOrder.lab_id !== currentLabId) {
    return res.status(403).json({
      success: false,
      message: `Đơn hàng #${matchingOrder.order_id} thuộc tiệm ${matchingOrder.lab_name || matchingOrder.lab_id}, không thuộc tiệm Lab đang đăng nhập!`,
    });
  }
  const belongsToTarget =
    (targetUserId && matchingOrder.user_id === targetUserId) ||
    (targetUserEmail && (matchingOrder.customer_email || '').toLowerCase() === targetUserEmail.toLowerCase());
  if (!belongsToTarget) {
    return res.status(400).json({
      success: false,
      message: `Đơn hàng #${matchingOrder.order_id} không thuộc về khách hàng ${targetUserName}!`,
    });
  }
  if (!isOrderReadyForQcArchive(matchingOrder)) {
    const stepLabel = getKanbanStepLabel(matchingOrder.kanban_column, matchingOrder.status);
    return res.status(400).json({
      success: false,
      message: `Đơn hàng #${matchingOrder.order_id} hiện đang ở bước ${stepLabel}, chưa đến bước 5. QC & Archive. Vui lòng giữ nguyên hoặc chuyển đơn sang bước 5. QC & Archive trên bảng Kanban trước khi gửi link!`,
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
  const shouldReplaceFolder = replace_folder !== undefined ? Boolean(replace_folder) : true;

  const driveResult = await uploadFileToGoogleDrive({
    fileName: file_name || (file ? file.originalname : `Archive-${Date.now()}.jpg`),
    mimeType: file ? file.mimetype : 'image/jpeg',
    fileBuffer,
    imageUrl: image_url || '',
    customDriveLink: drive_link || '',
    orderId: matchingOrder.order_id,
    selectedPhotos: hasBatch ? selected_photos : null,
    replaceFolderContents: shouldReplaceFolder,
  });

  const resolvedDriveLink = driveResult.folder_url || driveResult.web_view_link;

  // Keep all previous links, photos, and notifications intact (every send creates a new folder & link!)
  const uploadedItems = Array.isArray(driveResult.uploaded_items) && driveResult.uploaded_items.length > 0
    ? driveResult.uploaded_items
    : [
        {
          file_name: file_name || 'Archive-1080x720.jpg',
          title: title || 'Ảnh scan mới (Google Drive 1080x720)',
          image_url: file ? `/uploads/${file.filename}` : (image_url || 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1080&h=720&fit=crop&fm=jpg&q=85'),
        },
      ];

  const orderFilmStock = matchingOrder?.items?.[0]?.film_name || film_stock || 'Kodak Portra 400';
  const orderRollCode = roll_code || matchingOrder?.items?.[0]?.roll_code || 'ROLL-135-01';

  const createdPhotos = [];
  for (let i = uploadedItems.length - 1; i >= 0; i--) {
    const uItem = uploadedItems[i];
    const pEntry = {
      photo_id: `pho-${Date.now()}-${i}`,
      user_id: targetUserId,
      recipient_email: targetUserEmail,
      recipient_name: targetUserName,
      order_id: matchingOrder ? matchingOrder.order_id : targetOrderId,
      roll_code: orderRollCode,
      title: uItem.title || title || `Ảnh scan #${i + 1}`,
      image_url: uItem.image_url,
      thumbnail_url: uItem.image_url,
      drive_link: resolvedDriveLink,
      drive_mode: driveResult.mode,
      album_name: album_name || `Đơn hàng ${matchingOrder ? matchingOrder.order_id : targetOrderId}`,
      is_favorite: false,
      created_from_lab: true,
      created_at: new Date().toISOString(),
      metadata: {
        camera: camera || 'Máy ảnh cơ 35mm',
        lens: lens || 'Ống kính tiêu chuẩn 50mm',
        film_stock: orderFilmStock,
        iso: parseInt(iso) || 400,
        aperture: 'f/2.8',
        shutter_speed: '1/250s',
        focal_length: '50mm',
        process: 'C-41 Scan chuẩn',
        lab: matchingOrder?.lab_name || 'CropLab Hà Nội',
        dimensions: '1080 x 720',
        file_size: file ? `${(file.size / (1024 * 1024)).toFixed(1)} MB` : '2.4 MB JPEG (1080x720)',
        drive_link: resolvedDriveLink
      }
    };
    mockArchivePhotos.unshift(pEntry);
    createdPhotos.unshift(pEntry);
  }

  const newPhoto = createdPhotos[0];

  if (matchingOrder) {
    if (!matchingOrder.drive_links_by_user) matchingOrder.drive_links_by_user = {};
    matchingOrder.drive_links_by_user[targetUserId] = resolvedDriveLink;
    if (targetUserEmail) {
      matchingOrder.drive_links_by_user[targetUserEmail.toLowerCase()] = resolvedDriveLink;
    }
    if (!matchingOrder.drive_link_history_by_user) matchingOrder.drive_link_history_by_user = {};
    const prevUserLinks = matchingOrder.drive_link_history_by_user[targetUserId] || [];
    if (!prevUserLinks.includes(resolvedDriveLink)) {
      matchingOrder.drive_link_history_by_user[targetUserId] = [resolvedDriveLink, ...prevUserLinks];
    }
    if (targetUserEmail) {
      const emailKey = targetUserEmail.toLowerCase();
      const prevEmailLinks = matchingOrder.drive_link_history_by_user[emailKey] || [];
      if (!prevEmailLinks.includes(resolvedDriveLink)) {
        matchingOrder.drive_link_history_by_user[emailKey] = [resolvedDriveLink, ...prevEmailLinks];
      }
    }
    matchingOrder.status = 'READY_FOR_DOWNLOAD';
    matchingOrder.kanban_column = 'READY';
    if (Array.isArray(matchingOrder.timeline)) {
      matchingOrder.timeline.forEach(step => {
        step.status = 'COMPLETED';
      });
    }
  }

  mockNotifications.unshift({
    notification_id: `NTF-ARC-${Date.now()}`,
    type: 'GOOGLE_DRIVE_SCAN',
    order_id: newPhoto.order_id,
    customer_id: targetUserId,
    recipient_email: targetUserEmail,
    title: `☁️ Đơn #${newPhoto.order_id}: Đã có ${createdPhotos.length} ảnh Scan & Link Google Drive`,
    message: `Xin chào ${targetUserName}, ${createdPhotos.length} ảnh scan (1080x720) của đơn hàng #${newPhoto.order_id} đã được tải lên Google Drive: ${resolvedDriveLink}`,
    drive_link: resolvedDriveLink,
    created_at: new Date().toISOString(),
    is_read: false,
  });

  return res.status(201).json({
    success: true,
    message: `Đã gửi ${createdPhotos.length} ảnh lên Google Drive cho đơn #${newPhoto.order_id} của ${targetUserName} (${targetUserEmail})!`,
    drive_link: resolvedDriveLink,
    drive_mode: driveResult.mode,
    order_id: newPhoto.order_id,
    recipient_name: targetUserName,
    recipient_email: targetUserEmail,
    data: newPhoto
  });
};
