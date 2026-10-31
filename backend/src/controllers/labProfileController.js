/**
 * Controller quản lý hồ sơ tiệm Film Lab
 */

const dbStore = require('../models/labDataStore');

// Lấy thông tin hồ sơ tiệm
exports.getProfile = (req, res, next) => {
  try {
    const profile = dbStore.getProfile();
    res.json({
      success: true,
      data: profile
    });
  } catch (error) {
    next(error);
  }
};

// Cập nhật hồ sơ tiệm (Yêu cầu quyền Owner)
exports.updateProfile = (req, res, next) => {
  try {
    const updated = dbStore.updateProfile(req.body);
    res.json({
      success: true,
      message: 'Cập nhật hồ sơ Film Lab thành công.',
      data: updated
    });
  } catch (error) {
    next(error);
  }
};
