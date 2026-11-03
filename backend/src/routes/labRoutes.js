const express = require('express');
const router = express.Router();
const labController = require('../controllers/labController');

router.get('/', labController.getAllLabs);
router.get('/:id', labController.getLabById);
router.get('/:id/packages', labController.getLabPackages);

module.exports = router;

