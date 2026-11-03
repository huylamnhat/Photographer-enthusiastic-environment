const path = require('path');
require('dotenv').config();

module.exports = {
  PORT: process.env.PORT || 5000,
  JWT_SECRET: process.env.JWT_SECRET || 'minilab_secret_jwt_key_2026',
  JWT_EXPIRES_IN: '7d',
  UPLOAD_DIR: path.join(__dirname, '../../uploads'),
};

