const express = require('express');
const router = express.Router();
const communityController = require('../controllers/communityController');
const { authenticate } = require('../middleware/auth');

// Posts
router.get('/posts', communityController.getAllPosts);
router.get('/posts/:id', communityController.getPostById);
router.post('/posts/create', authenticate, communityController.createPost);
router.post('/posts/:id/comments', authenticate, communityController.addComment);
router.post('/posts/:id/like', authenticate, communityController.toggleLike);

// Events
router.get('/events', communityController.getAllEvents);
router.get('/events/:id', communityController.getEventById);
router.post('/events/:id/register', authenticate, communityController.registerEvent);

module.exports = router;

