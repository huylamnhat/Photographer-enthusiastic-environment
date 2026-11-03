const jwt = require('jsonwebtoken');
const config = require('../config');
const { mockUsers } = require('../data/mockStore');

// In-memory OTP storage for internal demo
const otpStore = {};

exports.login = (req, res) => {
  const { identifier, password } = req.body;
  if (!identifier) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập Email hoặc Số điện thoại' });
  }

  // Find user by email or phone
  let user = mockUsers.find(u => u.email === identifier || u.phone === identifier);
  if (!user) {
    // If user doesn't exist, create customer on-the-fly for smooth demo
    user = {
      user_id: 'usr-' + Date.now(),
      email: identifier.includes('@') ? identifier : `${identifier}@minilab.vn`,
      phone: identifier.includes('@') ? '0912345678' : identifier,
      full_name: 'Khách hàng MiniLab',
      role: 'Customer',
      avatar_url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      created_at: new Date().toISOString()
    };
    mockUsers.push(user);
  }

  const token = jwt.sign(
    { user_id: user.user_id, email: user.email, role: user.role },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRES_IN }
  );

  return res.json({
    success: true,
    message: 'Đăng nhập thành công',
    token,
    user
  });
};

exports.register = (req, res) => {
  const { email, phone, full_name, password } = req.body;
  if (!phone && !email) {
    return res.status(400).json({ success: false, message: 'Vui lòng cung cấp số điện thoại hoặc email' });
  }

  const generatedOtp = '8888'; // Mock internal OTP
  const key = phone || email;
  otpStore[key] = {
    otp: generatedOtp,
    tempUser: { email, phone, full_name, password },
    createdAt: Date.now()
  };

  return res.json({
    success: true,
    message: 'Mã xác thực OTP đã được tạo (Mô phỏng nội bộ: 8888)',
    otp_hint: '8888',
    target: key
  });
};

exports.verifyOtp = (req, res) => {
  const { target, otp } = req.body;
  const entry = otpStore[target];

  if (!entry || (otp !== entry.otp && otp !== '8888')) {
    return res.status(400).json({ success: false, message: 'Mã OTP không chính xác hoặc đã hết hạn' });
  }

  const newUser = {
    user_id: 'usr-' + Date.now(),
    email: entry.tempUser.email || `${entry.tempUser.phone}@minilab.vn`,
    phone: entry.tempUser.phone || '',
    full_name: entry.tempUser.full_name || 'Nhiếp ảnh gia mới',
    role: 'Customer',
    avatar_url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    created_at: new Date().toISOString()
  };
  mockUsers.push(newUser);
  delete otpStore[target];

  const token = jwt.sign(
    { user_id: newUser.user_id, email: newUser.email, role: newUser.role },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRES_IN }
  );

  return res.json({
    success: true,
    message: 'Xác thực OTP thành công, tài khoản đã được kích hoạt',
    token,
    user: newUser
  });
};

exports.forgotPassword = (req, res) => {
  const { identifier, new_password } = req.body;
  const user = mockUsers.find(u => u.email === identifier || u.phone === identifier);
  if (user) {
    user.password = new_password || '123456';
  }
  return res.json({
    success: true,
    message: 'Mật khẩu mới đã được cập nhật thành công (Mô phỏng nội bộ)'
  });
};

exports.getMe = (req, res) => {
  return res.json({
    success: true,
    user: req.user
  });
};

