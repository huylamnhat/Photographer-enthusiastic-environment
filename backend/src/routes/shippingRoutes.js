const express = require('express');
const router = express.Router();
const shippingController = require('../controllers/shippingController');
const { authenticate } = require('../middleware/auth');

router.get('/ahamove/config-status', authenticate, shippingController.getAhamoveConfigStatus);
router.post('/ahamove/estimate', authenticate, shippingController.estimatePickupFee);
router.post('/ahamove/orders/:orderId/book', authenticate, shippingController.bookAhamovePickup);
router.get('/ahamove/orders/:orderId', authenticate, shippingController.getAhamoveShipmentStatus);
router.post('/ahamove/orders/:orderId/cancel', authenticate, shippingController.cancelAhamovePickup);

module.exports = router;
