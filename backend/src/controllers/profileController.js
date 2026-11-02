const mockDb = require('../data/mockDb');

exports.getProfile = (req, res) => {
  return res.status(200).json({
    success: true,
    data: mockDb.labProfile
  });
};

exports.updateProfile = (req, res) => {
  const updates = req.body;

  mockDb.labProfile = {
    ...mockDb.labProfile,
    ...updates
  };

  return res.status(200).json({
    success: true,
    message: 'Hồ sơ tiệm Lab công khai đã được lưu và đồng bộ thành công!',
    data: mockDb.labProfile
  });
};

