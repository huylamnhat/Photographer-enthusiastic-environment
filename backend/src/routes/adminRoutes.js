const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authenticate } = require('../middleware/auth');

router.get('/dashboard', authenticate, adminController.getDashboardStats);
router.get('/users', authenticate, adminController.getUsers);
router.put('/users/:id', authenticate, adminController.updateUserStatus);
router.get('/pending-labs', authenticate, adminController.getPendingLabs);
router.post('/pending-labs/:id/review', authenticate, adminController.reviewLabApplication);
router.get('/expert-applications', authenticate, adminController.getExpertApplications);
router.post('/expert-applications/:id/review', authenticate, adminController.reviewExpertApplication);
router.get('/marketplace/pending', authenticate, adminController.getPendingMarketplace);
router.post('/marketplace/:id/moderate', authenticate, adminController.moderateMarketplace);
router.get('/community/reports', authenticate, adminController.getReportedContent);
router.post('/community/:id/moderate', authenticate, adminController.moderateCommunityPost);
router.get('/disputes', authenticate, adminController.getDisputes);
router.post('/disputes/:id/resolve', authenticate, adminController.resolveDispute);
router.get('/audit-logs', authenticate, adminController.getAuditLogs);
router.get('/services', authenticate, adminController.getAdminServices);
router.get('/notifications', authenticate, adminController.getAdminNotifications);

module.exports = router;
