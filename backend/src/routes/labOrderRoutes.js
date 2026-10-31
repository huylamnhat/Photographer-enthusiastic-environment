const express = require('express');
const router = express.Router();
const labOrderController = require('../controllers/labOrderController');

// Lấy danh sách & chi tiết đơn hàng
router.get('/', labOrderController.getOrders);
router.get('/:id', labOrderController.getOrderById);

// Cập nhật trạng thái tổng đơn
router.patch('/:id/status', labOrderController.updateOrderStatus);

// Cập nhật công đoạn cuộn film
router.patch('/:orderId/rolls/:rollId/process', labOrderController.updateRollStage);

// Gán vị trí khay âm bản (Bin Code)
router.patch('/:orderId/rolls/:rollId/bin-code', labOrderController.assignRollBinCode);

// Đánh dấu phim trắng (Blank film)
router.patch('/:orderId/rolls/:rollId/blank-film', labOrderController.markBlankFilm);

module.exports = router;
