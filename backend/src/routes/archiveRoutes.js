const express = require('express');
const router = express.Router();
const archiveController = require('../controllers/archiveController');
const { authenticate } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.get('/photos', authenticate, archiveController.getMyPhotos);
router.get('/photos/:id', authenticate, archiveController.getPhotoById);
router.put('/photos/:id/favorite', authenticate, archiveController.toggleFavorite);
router.get('/albums', authenticate, archiveController.getAlbums);
router.post('/upload', authenticate, upload.single('photo'), archiveController.uploadScan);

module.exports = router;

