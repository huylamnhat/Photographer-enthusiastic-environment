/**
 * Controller quản lý gói dịch vụ và biểu phí Film Lab
 */

const dbStore = require('../models/labDataStore');

// Lấy danh sách dịch vụ
exports.getServices = (req, res, next) => {
  try {
    const { status, process } = req.query;
    const services = dbStore.getServices({ status, process });
    res.json({
      success: true,
      count: services.length,
      data: services
    });
  } catch (error) {
    next(error);
  }
};

// Lấy chi tiết một dịch vụ
exports.getServiceById = (req, res, next) => {
  try {
    const service = dbStore.getServiceById(req.params.id);
    if (!service) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy gói dịch vụ yêu cầu.'
      });
    }
    res.json({
      success: true,
      data: service
    });
  } catch (error) {
    next(error);
  }
};

// Tạo mới gói dịch vụ (Yêu cầu quyền Owner/Manager)
exports.createService = (req, res, next) => {
  try {
    const { name, format, process, basePath, basePrice } = req.body;
    if (!name || !basePrice) {
      return res.status(400).json({
        success: false,
        message: 'Tên dịch vụ và giá cơ bản là bắt buộc.'
      });
    }

    const created = dbStore.createService(req.body);
    res.status(201).json({
      success: true,
      message: 'Tạo mới gói dịch vụ thành công.',
      data: created
    });
  } catch (error) {
    next(error);
  }
};

// Cập nhật dịch vụ & Ghi log nếu đổi giá (Chỉ Chủ Lab)
exports.updateService = (req, res, next) => {
  try {
    const serviceId = req.params.id;
    const current = dbStore.getServiceById(serviceId);
    if (!current) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy gói dịch vụ cần sửa.'
      });
    }

    const newPrice = req.body.basePrice !== undefined ? Number(req.body.basePrice) : current.basePrice;
    const isPriceChanged = newPrice !== current.basePrice;
    const reason = req.body.reason;

    if (isPriceChanged && (!reason || reason.trim().length === 0)) {
      return res.status(400).json({
        success: false,
        message: 'Yêu cầu bắt buộc: Khi điều chỉnh giá, bạn phải nhập lý do thay đổi để lưu vào Audit Trail.'
      });
    }

    const updated = dbStore.updateService(serviceId, req.body, req.user, reason);
    res.json({
      success: true,
      message: isPriceChanged 
        ? `Cập nhật dịch vụ và đã lưu nhật ký điều chỉnh giá (${current.basePrice.toLocaleString()}đ -> ${newPrice.toLocaleString()}đ).`
        : 'Cập nhật dịch vụ thành công.',
      data: updated
    });
  } catch (error) {
    next(error);
  }
};

// Tạm ngừng hoặc kích hoạt lại gói dịch vụ (PAUSED <-> ACTIVE)
exports.togglePauseService = (req, res, next) => {
  try {
    const serviceId = req.params.id;
    const updated = dbStore.togglePauseService(serviceId);
    if (!updated) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy gói dịch vụ.'
      });
    }

    const actionText = updated.status === 'PAUSED' ? 'Tạm dừng nhận đơn mới' : 'Kích hoạt nhận đơn trở lại';
    res.json({
      success: true,
      message: `Đã chuyển dịch vụ sang trạng thái ${updated.status} (${actionText}). Toàn bộ đơn cũ vẫn được bảo lưu.`,
      data: updated
    });
  } catch (error) {
    next(error);
  }
};

// Lấy lịch sử thay đổi giá (Audit Trail)
exports.getPriceAuditLogs = (req, res, next) => {
  try {
    const serviceId = req.query.serviceId || req.params.id;
    const logs = dbStore.getPriceAuditLogs(serviceId);
    res.json({
      success: true,
      count: logs.length,
      data: logs
    });
  } catch (error) {
    next(error);
  }
};
