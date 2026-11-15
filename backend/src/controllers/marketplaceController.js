const fs = require('fs');
const path = require('path');
const { mockListings, mockAuditLogs } = require('../data/mockStore');
const { runQuery } = require('../config/db');

const UPLOADS_DIR = path.join(__dirname, '../../uploads');

function persistImageInput(imgStr, prefix = 'mkt') {
  const raw = String(imgStr || '').trim();
  if (!raw) return '';
  if (!raw.startsWith('data:image')) return raw;
  try {
    if (!fs.existsSync(UPLOADS_DIR)) {
      fs.mkdirSync(UPLOADS_DIR, { recursive: true });
    }
    const match = raw.match(/^data:image\/([a-zA-Z0-9+]+);base64,(.+)$/);
    if (!match) return raw;
    const extRaw = match[1].toLowerCase().replace('jpeg', 'jpg').replace('svg+xml', 'svg');
    const ext = ['jpg', 'png', 'webp', 'gif'].includes(extRaw) ? extRaw : 'jpg';
    const fileName = `${prefix}-${Date.now()}-${Math.floor(Math.random() * 10000)}.${ext}`;
    fs.writeFileSync(path.join(UPLOADS_DIR, fileName), Buffer.from(match[2], 'base64'));
    return `/uploads/${fileName}`;
  } catch (_) {
    return raw;
  }
}

function resolveCategoryId(cat) {
  const s = String(cat || '').toLowerCase();
  if (s.includes('rangefinder')) return 2;
  if (s.includes('slr')) return 3;
  if (s.includes('point')) return 4;
  if (s.includes('lens') || s.includes('ống kính')) return 5;
  return 2;
}

exports.getAllListings = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const { category, search, min_price, max_price, include_pending } = req.query;
  let results = mockListings.filter(l => include_pending === 'true' || l.status === 'ACTIVE');

  if (search) {
    const q = search.toLowerCase();
    results = results.filter(l => 
      l.title.toLowerCase().includes(q) || 
      l.description.toLowerCase().includes(q) ||
      l.location.toLowerCase().includes(q)
    );
  }

  if (category && category !== 'Tất cả') {
    results = results.filter(l => l.category.toLowerCase().includes(category.toLowerCase()));
  }

  if (min_price) {
    results = results.filter(l => l.price >= Number(min_price));
  }

  if (max_price) {
    results = results.filter(l => l.price <= Number(max_price));
  }

  return res.json({
    success: true,
    count: results.length,
    data: results
  });
};

exports.getListingById = (req, res) => {
  const { id } = req.params;
  const item = mockListings.find(l => l.listing_id === id);
  if (!item) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy tin đăng thiết bị' });
  }

  return res.json({
    success: true,
    data: item
  });
};

exports.createListing = (req, res) => {
  const user = req.user || {};
  const {
    title,
    category,
    condition,
    price,
    location,
    description,
    phone_contact,
    zalo_contact,
    image_urls,
    mechanical_checklist,
  } = req.body;

  if (!title || !String(title).trim() || !(Number(price) > 0)) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập tiêu đề và giá bán hợp lệ' });
  }

  const savedImages = Array.isArray(image_urls)
    ? image_urls
        .map((u, idx) => persistImageInput(u, `mkt-${Date.now().toString().slice(-4)}-${idx}`))
        .filter(Boolean)
    : [];

  const now = new Date();
  const finalImages = savedImages.length > 0
    ? savedImages
    : ['https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800'];

  const newListing = {
    listing_id: `mkt-${Date.now().toString().slice(-5)}`,
    seller_id: user.user_id || 'usr-001',
    seller_name: user.full_name || 'Nguyễn Hoàng Anh',
    seller_avatar: user.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    title: String(title).trim(),
    category: category || 'Máy ảnh Film',
    condition: (condition && String(condition).trim()) ? String(condition).trim() : '95% Hoạt động tốt',
    price: Number(price),
    status: 'PENDING_REVIEW',
    moderation_status: 'PENDING',
    location: (location && String(location).trim()) ? String(location).trim() : 'Hà Nội',
    phone_contact: (phone_contact && String(phone_contact).trim()) ? String(phone_contact).trim() : (user.phone || '0912345678'),
    zalo_contact: (zalo_contact && String(zalo_contact).trim()) ? String(zalo_contact).trim() : (phone_contact || user.phone || '0912345678'),
    image_urls: finalImages,
    description: (description && String(description).trim()) ? String(description).trim() : 'Thiết bị hoạt động bình thường.',
    mechanical_checklist: mechanical_checklist || null,
    created_from_mobile: true,
    created_at: now.toISOString()
  };

  mockListings.unshift(newListing);

  // Persist new Listing directly to SQL Server (FilmLabPlatform)
  const sellerDbId = Number(user.db_user_id) || 5;
  const catDbId = resolveCategoryId(newListing.category);
  const safeCode = newListing.listing_id.replace(/'/g, "''");
  const safeTitle = String(newListing.title || '').replace(/'/g, "''");
  const safeDesc = String(newListing.description || '').replace(/'/g, "''");
  const safeCond = String(newListing.condition || '').replace(/'/g, "''");
  const safeLoc = String(newListing.location || '').replace(/'/g, "''");
  const safePhone = String(newListing.phone_contact || '0912345678').replace(/'/g, "''");
  const imgInsertStatements = finalImages
    .slice(0, 6)
    .map((imgUrl, idx) => {
      const safeImg = String(imgUrl || '').slice(0, 490).replace(/'/g, "''");
      return `INSERT INTO Listing_Image (listing_id, image_url, sort_order) VALUES (@newListId, '${safeImg}', ${idx});`;
    })
    .join('\n      ');
  runQuery(`
    INSERT INTO Equipment_Listing (listing_code, seller_id, category_id, listing_type, title, description, item_condition, condition_note, price, location_text, contact_phone, contact_zalo, status)
    VALUES ('${safeCode}', ${sellerDbId}, ${catDbId}, 'SELL', N'${safeTitle}', N'${safeDesc}', 'GOOD', N'${safeCond}', ${Number(newListing.price) || 1000000}, N'${safeLoc}', '${safePhone}', '${safePhone}', 'PENDING_REVIEW');
    DECLARE @newListId BIGINT = SCOPE_IDENTITY();
    IF @newListId IS NOT NULL
    BEGIN
      ${imgInsertStatements}
    END
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${newListing.seller_name} (CUSTOMER)`,
    action: 'CREATE_LISTING',
    entity: `Equipment_Listing #${newListing.listing_id}`,
    entity_name: 'Equipment_Listing',
    entity_id: newListing.listing_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ title: newListing.title, price: newListing.price, status: 'PENDING_REVIEW' })
  });

  return res.status(201).json({
    success: true,
    message: 'Đăng tin thành công! Tin đang chờ Admin duyệt trước khi hiển thị công khai.',
    data: newListing
  });
};

exports.getMyListings = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const userId = req.user?.user_id;
  const list = userId
    ? mockListings.filter(l => l.seller_id === userId)
    : [...mockListings];
  return res.json({
    success: true,
    count: list.length,
    data: list
  });
};

