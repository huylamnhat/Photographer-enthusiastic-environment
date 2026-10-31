/**
 * Middleware xử lý lỗi tập trung
 */

const errorHandler = (err, req, res, next) => {
  console.error('[WebLab Error]:', err.stack || err.message);
  
  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    message: err.message || 'Đã có lỗi hệ thống xảy ra tại Web Lab.',
    error: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
};

module.exports = errorHandler;
