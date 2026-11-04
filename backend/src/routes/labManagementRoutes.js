const express = require('express');
const router = express.Router();
const labManagementController = require('../controllers/labManagementController');
const { authenticate } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/kanban', authenticate, labManagementController.getLabKanban);
router.post('/orders/:orderId/kanban-step', authenticate, labManagementController.updateKanbanStep);
router.post('/orders/:orderId/upload-scans', authenticate, upload.single('scan_file'), labManagementController.uploadScanFiles);
router.get('/services', authenticate, labManagementController.getLabPackages);
router.put('/services/:packageId', authenticate, labManagementController.updatePackagePrice);
router.post('/services', authenticate, labManagementController.createPackage);
router.get('/profile', authenticate, labManagementController.getLabProfile);
router.put('/profile', authenticate, labManagementController.updateLabProfile);
router.get('/disputes', authenticate, labManagementController.getLabDisputes);
router.post('/disputes/:disputeId/reply', authenticate, labManagementController.replyDispute);
router.get('/sla-report', authenticate, labManagementController.getSlaPerformance);

module.exports = router;

