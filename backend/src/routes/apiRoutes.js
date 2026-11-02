const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const orderController = require('../controllers/orderController');
const scanController = require('../controllers/scanController');
const serviceController = require('../controllers/serviceController');
const profileController = require('../controllers/profileController');
const disputeController = require('../controllers/disputeController');
const reportController = require('../controllers/reportController');

// 1. Authentication & KYC (WEB-LAB-01, WEB-LAB-02)
router.post('/auth/register-lab', authController.registerLab);
router.post('/auth/login', authController.login);
router.get('/auth/me', authController.getCurrentUser);

// 2. Orders & Kanban Board (WEB-LAB-03)
router.get('/orders/kanban', orderController.getKanbanOrders);
router.get('/orders/:id', orderController.getOrderDetails);
router.put('/orders/:id/stage', orderController.updateOrderStage);
router.post('/orders/scan-barcode', orderController.scanNewBarcode);

// 3. Scan & QC (WEB-LAB-04)
router.get('/scans/:orderId', scanController.getQCBatch);
router.put('/scans/:orderId/frames/:frameId/qc', scanController.toggleFrameQC);
router.post('/scans/:orderId/release', scanController.approveAndRelease);

// 4. Services & Pricing (WEB-LAB-05)
router.get('/services', serviceController.getServices);
router.post('/services', serviceController.createService);
router.put('/services/:id', serviceController.updateService);
router.patch('/services/:id/toggle', serviceController.toggleServiceStatus);
router.get('/services/price-history', serviceController.getPriceHistory);

// 5. Public Profile (WEB-LAB-06)
router.get('/lab/profile', profileController.getProfile);
router.put('/lab/profile', profileController.updateProfile);

// 6. Disputes & Negotiation (WEB-LAB-07)
router.get('/disputes', disputeController.getDisputes);
router.get('/disputes/:id', disputeController.getDisputeDetail);
router.post('/disputes/:id/message', disputeController.sendDisputeMessage);
router.post('/disputes/:id/settle', disputeController.settleDispute);

// 7. Reports & SLA (WEB-LAB-08)
router.get('/reports/sla', reportController.getSlaReports);
router.get('/reports/history', reportController.getOrderHistory);

module.exports = router;

