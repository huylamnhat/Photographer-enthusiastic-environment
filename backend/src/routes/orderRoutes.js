const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { authenticate } = require('../middleware/auth');

router.get('/', authenticate, orderController.getMyOrders);
router.get('/notifications', authenticate, orderController.getNotifications);
router.get('/:id', authenticate, orderController.getOrderById);
router.post('/create', authenticate, orderController.createOrder);
router.post('/:id/dispute', authenticate, orderController.createDispute);
router.put('/:id/cancel', authenticate, orderController.cancelOrder);

module.exports = router;

