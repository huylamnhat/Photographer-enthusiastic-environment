const mockDb = require('../data/mockDb');

exports.registerLab = (req, res) => {
  const {
    brand_name,
    license_no,
    region,
    address,
    hotline,
    email,
    has_dropbox,
    representative_name,
    cccd_number,
    scanners,
    processor,
    chemistries
  } = req.body;

  if (!brand_name || !email) {
    return res.status(400).json({ success: false, message: 'Vui lòng cung cấp tên tiệm và email hợp lệ.' });
  }

  const newLabId = `LAB-${region || 'VN'}-${Date.now().toString().slice(-4)}`;
  const newProfile = {
    lab_id: newLabId,
    brand_name,
    license_no: license_no || 'Đang xác minh',
    region: region || 'HCM',
    address: address || 'Chưa cập nhật',
    hotline: hotline || '',
    email,
    has_dropbox: Boolean(has_dropbox),
    representative_name: representative_name || '',
    cccd_number: cccd_number || '',
    scanners: scanners || ['Noritsu HS-1800'],
    processor: processor || 'Noritsu V30',
    chemistries: chemistries || ['C-41'],
    status: 'PENDING_APPROVAL',
    created_at: new Date().toISOString()
  };

  mockDb.labProfile = { ...mockDb.labProfile, ...newProfile };

  return res.status(201).json({
    success: true,
    message: 'Hồ sơ thẩm định mở tiệm Film Lab đã được ghi nhận thành công!',
    data: {
      lab_id: newLabId,
      status: 'PENDING_APPROVAL',
      profile: mockDb.labProfile
    }
  });
};

exports.login = (req, res) => {
  const { email, password, branch_id, role } = req.body;

  // Find user by email or provide fallback for demo
  let user = mockDb.users.find(u => u.email.toLowerCase() === (email || '').toLowerCase());
  if (!user) {
    user = {
      user_id: 'USR-TEMP',
      email: email || 'lab@saigonfilm.vn',
      full_name: 'Lê Hoài Nam',
      role: role ? role.toUpperCase() : 'OPERATOR',
      title: 'KỸ THUẬT VIÊN TRƯỞNG',
      branch_id: branch_id || 'sgn-01'
    };
  }

  // Generate demo bearer token
  const token = `minilab_jwt_${Buffer.from(user.email).toString('base64')}_${Date.now()}`;

  return res.status(200).json({
    success: true,
    message: 'Đăng nhập trạm Film Lab thành công!',
    data: {
      token,
      user: {
        user_id: user.user_id,
        email: user.email,
        full_name: user.full_name,
        role: user.role,
        title: user.title,
        branch_id: branch_id || user.branch_id
      },
      lab: {
        lab_id: mockDb.labProfile.lab_id,
        brand_name: mockDb.labProfile.brand_name
      },
      telemetry: mockDb.telemetry
    }
  });
};

exports.getCurrentUser = (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      user: mockDb.users[0],
      lab: mockDb.labProfile,
      telemetry: mockDb.telemetry
    }
  });
};

