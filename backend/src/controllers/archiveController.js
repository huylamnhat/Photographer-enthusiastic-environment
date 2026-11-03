const { mockArchivePhotos } = require('../data/mockStore');

exports.getMyPhotos = (req, res) => {
  const userId = req.user.user_id;
  const { album, roll_code, favorite_only } = req.query;

  let photos = mockArchivePhotos.filter(p => p.user_id === userId);

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
  const userId = req.user.user_id;
  const userPhotos = mockArchivePhotos.filter(p => p.user_id === userId);

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

exports.uploadScan = (req, res) => {
  const userId = req.user.user_id;
  const { title, album_name, roll_code, camera, lens, film_stock, iso } = req.body;
  const file = req.file;

  const imageUrl = file 
    ? `/uploads/${file.filename}` 
    : 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1200';

  const newPhoto = {
    photo_id: `pho-${Date.now()}`,
    user_id: userId,
    roll_code: roll_code || 'ROLL-CUSTOM',
    title: title || 'Ảnh scan mới',
    image_url: imageUrl,
    thumbnail_url: imageUrl,
    album_name: album_name || 'Kho ảnh mới',
    is_favorite: false,
    created_at: new Date().toISOString(),
    metadata: {
      camera: camera || 'Máy ảnh cơ 35mm',
      lens: lens || 'Ống kính tiêu chuẩn 50mm',
      film_stock: film_stock || 'Kodak Portra 400',
      iso: parseInt(iso) || 400,
      aperture: 'f/2.8',
      shutter_speed: '1/250s',
      focal_length: '50mm',
      process: 'C-41 Scan chuẩn',
      lab: 'CropLab Hà Nội',
      dimensions: '6000 x 4000',
      file_size: file ? `${(file.size / (1024 * 1024)).toFixed(1)} MB` : '15.2 MB'
    }
  };

  mockArchivePhotos.unshift(newPhoto);

  return res.status(201).json({
    success: true,
    message: 'Tải ảnh scan thành công',
    data: newPhoto
  });
};

