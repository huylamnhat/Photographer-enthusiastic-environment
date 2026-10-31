const express = require('express');
const router = express.Router();
const labServiceController = require('../controllers/labServiceController');
const { requireOwner, requireOwnerOrManager } = require('../middlewares/authMiddleware');

// Lấy danh sách & chi tiết
router.get('/', labServiceController.getServices);
router.get('/price-logs', labServiceController.getPriceAuditLogs);
router.get('/:id', labServiceController.getServiceById);
router.get('/:id/price-logs', labServiceController.getPriceAuditLogs);

// Thêm mới (Owner/Manager)
router.post('/', requireOwnerOrManager, labServiceController.createService);

// Sửa giá & thông tin gói dịch vụ (Chỉ Owner)
router.put('/:id', requireOwner, labServiceController.updateService);

// Tạm ngưng / Mở lại (Owner/Manager)
router.patch('/:id/toggle-pause', requireOwnerOrManager, labServiceController.togglePauseService);

module.exports = router;
