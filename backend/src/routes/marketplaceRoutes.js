const express = require('express');
const router = express.Router();
const marketplaceController = require('../controllers/marketplaceController');
const { authenticate } = require('../middleware/auth');

router.get('/listings', marketplaceController.getAllListings);
router.get('/listings/:id', marketplaceController.getListingById);
router.post('/create', authenticate, marketplaceController.createListing);
router.get('/my-listings', authenticate, marketplaceController.getMyListings);

module.exports = router;

