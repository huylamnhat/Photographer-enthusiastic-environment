const express = require('express');
const cors = require('cors');
const path = require('path');

const { authenticateLabUser } = require('./middlewares/authMiddleware');
const errorHandler = require('./middlewares/errorHandler');

const labProfileRoutes = require('./routes/labProfileRoutes');
const labServiceRoutes = require('./routes/labServiceRoutes');
const labOrderRoutes = require('./routes/labOrderRoutes');
const labScanRoutes = require('./routes/labScanRoutes');

const app = express();

// Middlewares cơ bản
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Giả lập xác thực RBAC cho Web Lab
app.use(authenticateLabUser);

// Serve Static Frontend trực tiếp từ thư mục frontend
const frontendPath = path.join(__dirname, '../../frontend');
app.use(express.static(frontendPath));

// API Routes nội bộ
app.use('/api/lab/profile', labProfileRoutes);
app.use('/api/lab/services', labServiceRoutes);
app.use('/api/lab/orders', labOrderRoutes);
app.use('/api/lab/orders', labScanRoutes); // Hỗ trợ POST /api/lab/orders/:orderId/rolls/:rollId/scan-metadata

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ONLINE',
    system: 'Web Lab Internal Portal',
    timestamp: new Date().toISOString()
  });
});

// Fallback route cho Frontend
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api/')) {
    return next();
  }
  res.sendFile(path.join(frontendPath, 'index.html'));
});

// Middleware xử lý lỗi
app.use(errorHandler);

module.exports = app;
