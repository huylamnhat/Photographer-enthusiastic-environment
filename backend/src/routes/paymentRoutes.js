const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { authenticate } = require('../middleware/auth');

router.get('/vnpay/config-status', authenticate, paymentController.getVnpayConfigStatus);
router.post('/vnpay/create', authenticate, paymentController.createVnpayPayment);
router.get('/vnpay/ipn', paymentController.vnpayIpnWebhook);
router.get('/vnpay/return', paymentController.vnpayReturnCallback);
router.get('/vnpay/status/:orderId', authenticate, paymentController.checkVnpayPaymentStatus);
router.get('/qr-info/:orderId', authenticate, paymentController.getOrderQrInfo);

router.post('/process', authenticate, paymentController.processPayment);
router.get('/receipt/:orderId', authenticate, paymentController.getReceipt);

module.exports = router;
