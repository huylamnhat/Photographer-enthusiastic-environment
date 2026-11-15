// ============================================================================
// RUNTIME DATA STORE (Populated from SQL Server Database: FilmLabPlatform)
// Tất cả dữ liệu khởi tạo đã được chuyển sang database/05_seed.sql và
// database/init_database.sql. Khi server khởi động, src/config/db.js sẽ đồng bộ
// dữ liệu trực tiếp từ SQL Server vào các mảng này.
// ============================================================================

const mockUsers = [];
const mockLabs = [];
const mockPendingLabs = [];
const mockExpertApplications = [];
const mockServicePackages = [];
const mockProcessStandards = [];
const mockOrders = [];
const mockArchivePhotos = [];
const mockListings = [];
const mockCommunityPosts = [];
const mockEvents = [];
const mockDisputes = [];
const mockReviews = [];
const mockAuditLogs = [];
const mockNotifications = [];

module.exports = {
  mockUsers,
  mockLabs,
  mockPendingLabs,
  mockExpertApplications,
  mockServicePackages,
  mockProcessStandards,
  mockOrders,
  mockArchivePhotos,
  mockListings,
  mockCommunityPosts,
  mockEvents,
  mockDisputes,
  mockReviews,
  mockAuditLogs,
  mockNotifications,
};
