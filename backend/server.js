const express = require('express');
const cors = require('cors');
const path = require('path');
const apiRoutes = require('./src/routes/apiRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for Flutter Web, localhost, and cross-origin clients
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Mount REST API routes
app.use('/api', apiRoutes);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ONLINE',
    service: 'MiniLab Film Lab Operational Platform API',
    version: '4.8.2-LAB',
    timestamp: new Date().toISOString()
  });
});

// Serve web lab client from public directory
const publicDir = path.join(__dirname, 'public');
app.use(express.static(publicDir));

// Fallback route for SPA or root navigation
app.get('/', (req, res) => {
  res.redirect('/web_lab_02.html');
});

// 404 handler for unknown API routes
app.use('/api/*', (req, res) => {
  res.status(404).json({
    success: false,
    message: `API endpoint '${req.originalUrl}' không tồn tại trên hệ thống MiniLab.`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('[SERVER ERROR]:', err);
  res.status(500).json({
    success: false,
    message: 'Lỗi máy chủ nội bộ MiniLab.',
    error: process.env.NODE_ENV === 'production' ? null : err.message
  });
});

app.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`🎬 MiniLab Film Lab Backend Server is running!`);
  console.log(`🌐 Base URL:   http://localhost:${PORT}`);
  console.log(`📡 API Base:   http://localhost:${PORT}/api`);
  console.log(`💻 Web Portal: http://localhost:${PORT}/web_lab_02.html`);
  console.log(`=======================================================`);
});

