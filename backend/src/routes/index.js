const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const labRoutes = require('./labRoutes');
const orderRoutes = require('./orderRoutes');
const paymentRoutes = require('./paymentRoutes');
const archiveRoutes = require('./archiveRoutes');
const marketplaceRoutes = require('./marketplaceRoutes');
const communityRoutes = require('./communityRoutes');
const reviewRoutes = require('./reviewRoutes');
const userRoutes = require('./userRoutes');
const adminRoutes = require('./adminRoutes');
const labManagementRoutes = require('./labManagementRoutes');

router.use('/auth', authRoutes);
router.use('/labs', labRoutes);
router.use('/orders', orderRoutes);
router.use('/payments', paymentRoutes);
router.use('/archive', archiveRoutes);
router.use('/marketplace', marketplaceRoutes);
router.use('/community', communityRoutes);
router.use('/reviews', reviewRoutes);
router.use('/users', userRoutes);
router.use('/admin', adminRoutes);
router.use('/lab-portal', labManagementRoutes);

router.get('/health', (req, res) => {
  res.json({
    status: 'ONLINE',
    app: 'MiniLab Platform API',
    version: '1.2.0',
    shared_for: ['Mobile App', 'Web Lab Portal', 'Web Admin Console'],
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
