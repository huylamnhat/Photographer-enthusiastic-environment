const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
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
  VNPAY: {
    tmnCode: (process.env.VNP_TMN_CODE || process.env.VNP_TERMINAL_ID || '').trim(),
    hashSecret: (process.env.VNP_HASH_SECRET || process.env.VNP_SECRET_KEY || '').trim(),
    url: (process.env.VNP_URL || 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html').trim(),
    apiUrl: (process.env.VNP_API_URL || 'https://sandbox.vnpayment.vn/merchant_webapi/api/transaction').trim(),
    returnUrl: (process.env.VNP_RETURN_URL || '').trim(),
    locale: (process.env.VNP_LOCALE || 'vn').trim(),
  },
  PAYMENT_QR: {
    qrImageUrl: (process.env.PAYMENT_QR_IMAGE_URL || '').trim(),
    bankName: (process.env.PAYMENT_BANK_NAME || '').trim(),
    accountNo: (process.env.PAYMENT_ACCOUNT_NO || '').trim(),
    accountName: (process.env.PAYMENT_ACCOUNT_NAME || '').trim(),
  },
  AHAMOVE: {
    baseUrl: (process.env.AHAMOVE_BASE_URL || 'https://partner-apistg.ahamove.com/v3').trim(),
    token: (process.env.AHAMOVE_TOKEN || '').trim(),
    apiKey: (process.env.AHAMOVE_API_KEY || '').trim(),
    mobile: (process.env.AHAMOVE_MOBILE || '').trim(),
    allowProduction: process.env.AHAMOVE_ALLOW_PRODUCTION === 'true',
  },
};
