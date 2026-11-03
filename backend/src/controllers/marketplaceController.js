const { mockListings } = require('../data/mockStore');

exports.getAllListings = (req, res) => {
  const { category, search, min_price, max_price } = req.query;
  let results = [...mockListings];

  if (search) {
    const q = search.toLowerCase();
    results = results.filter(l => 
      l.title.toLowerCase().includes(q) || 
      l.description.toLowerCase().includes(q) ||
      l.location.toLowerCase().includes(q)
    );
  }

  if (category) {
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
  const user = req.user;
  const { title, category, condition, price, location, description, phone_contact, zalo_contact, image_urls } = req.body;

  if (!title || !price) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập tiêu đề và giá bán' });
  }

  const newListing = {
    listing_id: `mkt-${Date.now()}`,
    seller_id: user.user_id,
    seller_name: user.full_name || 'Người bán MiniLab',
    seller_avatar: user.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    title,
    category: category || 'Máy ảnh Film',
    condition: condition || '95% Hoạt động tốt',
    price: Number(price),
    status: 'ACTIVE',
    location: location || 'Hà Nội',
    phone_contact: phone_contact || user.phone || '0912345678',
    zalo_contact: zalo_contact || user.phone || '0912345678',
    image_urls: image_urls && image_urls.length > 0 ? image_urls : ['https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800'],
    description: description || 'Thiết bị hoạt động bình thường, bao test 7 ngày.',
    created_at: new Date().toISOString()
  };

  mockListings.unshift(newListing);

  return res.status(201).json({
    success: true,
    message: 'Đăng tin thành công',
    data: newListing
  });
};

exports.getMyListings = (req, res) => {
  const userId = req.user.user_id;
  const list = mockListings.filter(l => l.seller_id === userId);
  return res.json({
    success: true,
    count: list.length,
    data: list
  });
};

