const express = require('express');
const router = express.Router();
const labProfileController = require('../controllers/labProfileController');
const { requireOwner } = require('../middlewares/authMiddleware');

router.get('/', labProfileController.getProfile);
router.put('/', requireOwner, labProfileController.updateProfile);

module.exports = router;
