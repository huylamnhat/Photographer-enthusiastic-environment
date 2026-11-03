const { mockUsers } = require('../data/mockStore');

exports.getProfile = (req, res) => {
  return res.json({
    success: true,
    data: req.user
  });
};

exports.updateProfile = (req, res) => {
  const user = req.user;
  const { full_name, phone, address, bio, avatar_url } = req.body;

  if (full_name) user.full_name = full_name;
  if (phone) user.phone = phone;
  if (address) user.address = address;
  if (bio) user.bio = bio;
  if (avatar_url) user.avatar_url = avatar_url;

  return res.json({
    success: true,
    message: 'Cập nhật thông tin thành công',
    data: user
  });
};

