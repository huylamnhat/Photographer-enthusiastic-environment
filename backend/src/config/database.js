/**
 * Cấu hình cơ sở dữ liệu nội bộ
 * Thiết kế theo mô hình quan hệ SQL Server, đi kèm In-Memory Store có sẵn dữ liệu mẫu
 * để có thể chạy và kiểm thử độc lập ngay lập tức mà không phụ thuộc cài đặt bên ngoài.
 */

const { ROLES, ORDER_STATUS, ROLL_PROCESS_STAGES, SERVICE_STATUS, PROCESS_TYPES, FILM_FORMATS } = require('./constants');

module.exports = {
  dbType: 'IN_MEMORY_SQL_ADAPTER',
  connectionString: process.env.DB_CONNECTION || 'Server=localhost;Database=FilmLabDB;Trusted_Connection=True;',
  isMockEnabled: true
};
