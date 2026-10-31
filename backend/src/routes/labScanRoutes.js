const express = require('express');
const router = express.Router();
const labScanController = require('../controllers/labScanController');

// Nạp metadata file scan
router.post('/:orderId/rolls/:rollId/scan-metadata', labScanController.saveScanMetadata);

// Thu hồi và nạp lại file scan (Revoke & Replace) trong 24 giờ
router.post('/:orderId/rolls/:rollId/revoke-scan', labScanController.revokeAndReplaceScan);

module.exports = router;
