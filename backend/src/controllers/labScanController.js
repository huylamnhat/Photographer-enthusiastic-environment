/**
 * Controller xử lý Upload metadata file scan và Thu hồi / Ghi đè (Revoke & Replace)
 */

const dbStore = require('../models/labDataStore');

// Nạp metadata file scan trả khách cho từng cuộn film
exports.saveScanMetadata = (req, res, next) => {
  try {
    const { orderId, rollId } = req.params;
    const { fileName, fileSizeMb, totalFrames, format, scannerModel, resolution, cloudPath } = req.body;

    const result = dbStore.saveScanMetadata(
      orderId,
      rollId,
      { fileName, fileSizeMb, totalFrames, format, scannerModel, resolution, cloudPath },
      req.user?.name
    );

    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn hàng hoặc cuộn film.'
      });
    }

    res.json({
      success: true,
      message: `Đã nạp thành công metadata file scan cho cuộn [${rollId}] và chuyển trạng thái SCANS_UPLOADED.`,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

// Thu hồi và ghi đè file scan (Revoke & Replace) trong 24 giờ
exports.revokeAndReplaceScan = (req, res, next) => {
  try {
    const { orderId, rollId } = req.params;
    const { reason } = req.body;

    if (!reason) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng cung cấp lý do thu hồi file scan (để ghi vào nhật ký kiểm toán).'
      });
    }

    const result = dbStore.revokeAndReplaceScan(orderId, rollId, reason, req.user?.name);
    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn hàng hoặc cuộn film này chưa từng có file scan để thu hồi.'
      });
    }

    res.json({
      success: true,
      message: `Đã thu hồi link file scan cũ cho cuộn [${rollId}]. Đơn hàng chuyển lại công đoạn SCANNING để sẵn sàng nạp bản scan mới.`,
      data: result
    });
  } catch (error) {
    next(error);
  }
};
