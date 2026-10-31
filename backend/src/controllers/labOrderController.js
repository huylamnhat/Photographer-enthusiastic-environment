/**
 * Controller quản lý đơn hàng và vòng đời xử lý cuộn film
 */

const dbStore = require('../models/labDataStore');

// Lấy danh sách đơn hàng
exports.getOrders = (req, res, next) => {
  try {
    const { status, search } = req.query;
    const orders = dbStore.getOrders({ status, search });
    res.json({
      success: true,
      count: orders.length,
      data: orders
    });
  } catch (error) {
    next(error);
  }
};

// Xem chi tiết đơn hàng (kèm Price Snapshotting của từng cuộn film)
exports.getOrderById = (req, res, next) => {
  try {
    const order = dbStore.getOrderById(req.params.id);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn hàng yêu cầu.'
      });
    }
    res.json({
      success: true,
      data: order
    });
  } catch (error) {
    next(error);
  }
};

// Cập nhật trạng thái tổng thể của đơn hàng
exports.updateOrderStatus = (req, res, next) => {
  try {
    const { status } = req.body;
    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Trạng thái đơn hàng là bắt buộc.'
      });
    }

    const order = dbStore.updateOrderStatus(req.params.id, status, req.user?.name);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn hàng.'
      });
    }

    res.json({
      success: true,
      message: `Đã cập nhật trạng thái đơn sang ${status}.`,
      data: order
    });
  } catch (error) {
    next(error);
  }
};

// Cập nhật công đoạn xử lý cuộn film (RECEIVED -> DEVELOPING -> SCANNING -> SCANS_UPLOADED)
exports.updateRollStage = (req, res, next) => {
  try {
    const { orderId, rollId } = req.params;
    const { stage } = req.body;

    if (!stage) {
      return res.status(400).json({
        success: false,
        message: 'Công đoạn xử lý là bắt buộc.'
      });
    }

    const result = dbStore.updateRollStage(orderId, rollId, stage, req.user?.name);
    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn hàng hoặc cuộn film chỉ định.'
      });
    }

    res.json({
      success: true,
      message: `Cuộn ${rollId} đã chuyển sang công đoạn: ${stage}.`,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

// Gán vị trí khay lưu trữ âm bản vật lý (Bin Code)
exports.assignRollBinCode = (req, res, next) => {
  try {
    const { orderId, rollId } = req.params;
    const { binCode, expiryDays } = req.body;

    if (!binCode) {
      return res.status(400).json({
        success: false,
        message: 'Mã khay âm bản (Bin Code) là bắt buộc (Ví dụ: BIN-A12).'
      });
    }

    const result = dbStore.assignRollBinCode(orderId, rollId, binCode, expiryDays || 15);
    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn hàng hoặc cuộn film.'
      });
    }

    res.json({
      success: true,
      message: `Đã gán cuộn ${rollId} vào khay ${binCode}. Hạn giữ âm bản: ${expiryDays || 15} ngày.`,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

// Đánh dấu phim trắng hoàn toàn (Blank Film)
exports.markBlankFilm = (req, res, next) => {
  try {
    const { orderId, rollId } = req.params;
    const { proofUrl, reason } = req.body;

    const result = dbStore.markBlankFilm(orderId, rollId, proofUrl, reason);
    if (!result) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn hàng hoặc cuộn film.'
      });
    }

    res.json({
      success: true,
      message: `Đã đánh dấu cuộn ${rollId} là Blank Film. Hệ thống ghi nhận chính sách hoàn tiền scan/in cho khách.`,
      data: result
    });
  } catch (error) {
    next(error);
  }
};
