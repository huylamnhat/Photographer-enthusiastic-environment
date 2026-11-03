const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const { authenticate } = require('../middleware/auth');

router.get('/', authenticate, orderController.getMyOrders);
router.get('/:id', authenticate, orderController.getOrderById);
router.post('/create', authenticate, orderController.createOrder);
router.put('/:id/cancel', authenticate, orderController.cancelOrder);

module.exports = router;

