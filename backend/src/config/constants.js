/**
 * Constants & Enum định nghĩa theo tài liệu film-lab-workflow.md
 */

// Vai trò người dùng trong Lab
const ROLES = {
  OWNER: 'LAB_OWNER',         // Toàn quyền: sửa giá, cấu hình, quản lý dịch vụ
  MANAGER: 'LAB_MANAGER',     // Quản lý: sửa dịch vụ nhưng không xóa, cập nhật đơn
  OPERATOR: 'LAB_OPERATOR'    // Nhân viên: chỉ cập nhật đơn, công đoạn, gán scan, không sửa giá
};

// Trạng thái đơn hàng tổng quát
const ORDER_STATUS = {
  PENDING_PAYMENT: 'PENDING_PAYMENT',
  PENDING_CONFIRMATION: 'PENDING_CONFIRMATION',
  RECEIVED_AT_LAB: 'RECEIVED_AT_LAB',
  PROCESSING: 'PROCESSING',
  SCANS_UPLOADED: 'SCANS_UPLOADED',
  READY_FOR_PICKUP: 'READY_FOR_PICKUP',
  READY_FOR_DELIVERY: 'READY_FOR_DELIVERY',
  DELIVERED: 'DELIVERED',
  CLOSED: 'CLOSED',
  CANCELLED: 'CANCELLED'
};

// Công đoạn xử lý cuộn phim trong xưởng Lab
const ROLL_PROCESS_STAGES = {
  RECEIVED: 'RECEIVED',               // Đã nhận phim tại tiệm
  DEVELOPING: 'DEVELOPING',           // Đang tráng / rửa / sấy
  SCANNING: 'SCANNING',               // Đang scan
  QUALITY_CHECK: 'QUALITY_CHECK',     // Kiểm tra chất lượng (QC)
  SCANS_UPLOADED: 'SCANS_UPLOADED',   // Đã hoàn tất nạp file scan
  BLANK_FILM: 'BLANK_FILM'            // Phim trắng do lỗi chụp/hỏng màn trập
};

// Trạng thái gói dịch vụ
const SERVICE_STATUS = {
  ACTIVE: 'ACTIVE',
  PAUSED: 'PAUSED' // Tạm ẩn khỏi marketplace nhưng bảo lưu dữ liệu và đơn cũ
};

// Quy trình tráng phim
const PROCESS_TYPES = {
  C41: 'C-41',       // Film màu tiêu chuẩn
  BW: 'B&W',         // Film đen trắng
  ECN2: 'ECN-2',     // Film điện ảnh / Cine Vision tẩy muội than
  E6: 'E-6'          // Film đảo / Slide dương bản
};

// Khổ phim
const FILM_FORMATS = {
  F135: '135 (35mm)',
  F120: '120 (Medium Format)',
  F110: '110',
  FAPS: 'APS (240)'
};

module.exports = {
  ROLES,
  ORDER_STATUS,
  ROLL_PROCESS_STAGES,
  SERVICE_STATUS,
  PROCESS_TYPES,
  FILM_FORMATS
};
