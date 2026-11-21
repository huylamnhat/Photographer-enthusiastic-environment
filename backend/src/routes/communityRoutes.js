const express = require('express');
const router = express.Router();
const communityController = require('../controllers/communityController');
const { authenticate } = require('../middleware/auth');

// Posts
router.get('/posts', authenticate, communityController.getAllPosts);
router.get('/posts/:id', authenticate, communityController.getPostById);
router.post('/posts/create', authenticate, communityController.createPost);
router.post('/posts/:id/comments', authenticate, communityController.addComment);
router.post('/posts/:id/like', authenticate, communityController.toggleLike);
router.post('/posts/:id/report', authenticate, communityController.reportPost);

// Events
router.get('/events', communityController.getAllEvents);
router.get('/events/:id', communityController.getEventById);
router.post('/events/:id/register', authenticate, communityController.registerEvent);

module.exports = router;

