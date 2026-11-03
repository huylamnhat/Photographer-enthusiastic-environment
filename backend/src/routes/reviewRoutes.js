const express = require('express');
const router = express.Router();
const reviewController = require('../controllers/reviewController');
const { authenticate } = require('../middleware/auth');

router.get('/lab/:labId', reviewController.getLabReviews);
router.post('/create', authenticate, reviewController.createReview);

module.exports = router;

