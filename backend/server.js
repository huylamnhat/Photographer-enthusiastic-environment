const express = require('express');
const cors = require('cors');
const path = require('path');
const config = require('./src/config');
const routes = require('./src/routes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static uploaded files (scans, thumbnails, avatars)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Register API Routes
app.use('/api', routes);

// Global root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Chào mừng đến với MiniLab Backend API Server',
    docs: '/api/health',
    endpoints: [
      '/api/auth/login',
      '/api/labs',
      '/api/orders',
      '/api/payments/process',
      '/api/archive/photos',
      '/api/marketplace/listings',
      '/api/community/posts',
      '/api/community/events',
      '/api/reviews/lab/:labId'
    ]
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('[MiniLab Error]:', err.stack);
  res.status(500).json({
    success: false,
    message: 'Lỗi máy chủ nội bộ',
    error: err.message
  });
});

const PORT = config.PORT;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`=======================================================`);
  console.log(`MiniLab Backend Server running on:`);
  console.log(`- Web / PC:    http://localhost:${PORT}`);
  console.log(`- Phone (LAN): http://192.168.1.7:${PORT}`);
  console.log(`API Base:      http://localhost:${PORT}/api`);
  console.log(`Status Check:  http://localhost:${PORT}/api/health`);
  console.log(`Self-contained mode: Active (No external API calls)`);
  console.log(`=======================================================`);
});

module.exports = app;
