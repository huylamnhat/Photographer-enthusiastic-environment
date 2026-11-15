const path = require('path');
require('dotenv').config();

const rawServer = process.env.DB_SERVER || 'localhost\\SQLEXPRESS';
const [hostPart, instancePart] = rawServer.split('\\');

module.exports = {
  PORT: process.env.PORT || 5000,
  JWT_SECRET: process.env.JWT_SECRET || 'minilab_secret_jwt_key_2026',
  JWT_EXPIRES_IN: '7d',
  UPLOAD_DIR: path.join(__dirname, '../../uploads'),
  DB_RAW_SERVER: rawServer,
  DB_WINDOWS_AUTH: process.env.DB_WINDOWS_AUTH !== 'false',
  DB: {
    server: hostPart || 'localhost',
    ...(instancePart ? {} : { port: parseInt(process.env.DB_PORT || '1433', 10) }),
    database: process.env.DB_DATABASE || 'FilmLabPlatform',
    user: process.env.DB_USER || 'filmlab_user',
    password: process.env.DB_PASSWORD || 'FilmLab@123456',
    options: {
      ...(instancePart ? { instanceName: instancePart } : {}),
      encrypt: process.env.DB_ENCRYPT === 'true',
      trustServerCertificate: process.env.DB_TRUST_SERVER_CERT !== 'false',
      enableArithAbort: true,
    },
    pool: {
      max: 10,
      min: 0,
      idleTimeoutMillis: 30000,
    },
  },
};
