/**
 * Middleware phân quyền RBAC cho Web Lab
 * Phân định quyền giữa:
 * - LAB_OWNER: Toàn quyền (đổi giá, pause dịch vụ, cấu hình hồ sơ)
 * - LAB_MANAGER: Quản lý dịch vụ nhưng không xóa
 * - LAB_OPERATOR: Vận hành đơn, công đoạn, gán file scan, KHÔNG được sửa giá
 */

const { ROLES } = require('../config/constants');

const authenticateLabUser = (req, res, next) => {
  // Đọc từ header hoặc query để dễ dàng chuyển vai trò trên giao diện Web Lab
  // Hỗ trợ cả mã chuẩn: LAB_OWNER/OWNER, LAB_OPERATOR/OPERATOR, LAB_MANAGER/MANAGER
  const rawRole = (req.headers['x-user-role'] || req.query.role || ROLES.OWNER).toString().toUpperCase();
  let role = ROLES.OWNER;
  if (rawRole === 'LAB_OPERATOR' || rawRole === 'OPERATOR') {
    role = ROLES.OPERATOR;
  } else if (rawRole === 'LAB_MANAGER' || rawRole === 'MANAGER') {
    role = ROLES.MANAGER;
  } else {
    role = ROLES.OWNER;
  }

  const name = req.headers['x-user-name'] || (role === ROLES.OWNER ? 'Nguyen Van Chu (Lab Owner)' : 'Le Hoang (Lab Operator)');

  req.user = {
    name,
    role,
    isOwner: role === ROLES.OWNER,
    isManager: role === ROLES.MANAGER,
    isOperator: role === ROLES.OPERATOR
  };

  next();
};

const requireOwner = (req, res, next) => {
  if (req.user && req.user.role === ROLES.OWNER) {
    return next();
  }
  return res.status(403).json({
    success: false,
    message: 'Truy cập bị từ chối: Chỉ Chủ Lab (Lab Owner) mới có quyền thực hiện thao tác này.'
  });
};

const requireOwnerOrManager = (req, res, next) => {
  if (req.user && (req.user.role === ROLES.OWNER || req.user.role === ROLES.MANAGER)) {
    return next();
  }
  return res.status(403).json({
    success: false,
    message: 'Truy cập bị từ chối: Yêu cầu quyền Chủ Lab hoặc Quản lý Lab.'
  });
};

module.exports = {
  authenticateLabUser,
  requireOwner,
  requireOwnerOrManager
};
