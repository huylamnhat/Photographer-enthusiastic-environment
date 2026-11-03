const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const { authenticate } = require('../middleware/auth');

router.post('/process', authenticate, paymentController.processPayment);
router.get('/receipt/:orderId', authenticate, paymentController.getReceipt);

module.exports = router;

