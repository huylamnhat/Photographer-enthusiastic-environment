const crypto = require('crypto');
const config = require('../config');

function isVnpayConfigured() {
  const { tmnCode, hashSecret } = config.VNPAY || {};
  return Boolean(
    tmnCode &&
    hashSecret &&
    !String(tmnCode).startsWith('YOUR_') &&
    !String(hashSecret).startsWith('YOUR_')
  );
}

function pad2(n) {
  return String(n).padStart(2, '0');
}

function formatVnDate(date = new Date()) {
  const vnTime = new Date(date.getTime() + 7 * 60 * 60 * 1000);
  return (
    String(vnTime.getUTCFullYear()) +
    pad2(vnTime.getUTCMonth() + 1) +
    pad2(vnTime.getUTCDate()) +
    pad2(vnTime.getUTCHours()) +
    pad2(vnTime.getUTCMinutes()) +
    pad2(vnTime.getUTCSeconds())
  );
}

function normalizeClientIp(rawIp) {
  if (!rawIp) return '127.0.0.1';
  const first = String(rawIp).split(',')[0].trim();
  if (first === '::1' || first === '::ffff:127.0.0.1') return '127.0.0.1';
  if (first.startsWith('::ffff:')) return first.slice(7);
  return first || '127.0.0.1';
}

function hmacSha512Hex(secretKey, rawData) {
  return crypto
    .createHmac('sha512', String(secretKey))
    .update(Buffer.from(String(rawData), 'utf-8'))
    .digest('hex');
}

function safeEqualHex(a, b) {
  if (!a || !b) return false;
  const strA = String(a).toLowerCase();
  const strB = String(b).toLowerCase();
  if (strA.length !== strB.length) return false;
  return crypto.timingSafeEqual(Buffer.from(strA, 'utf8'), Buffer.from(strB, 'utf8'));
}

function sortAndEncodeParams(obj = {}) {
  const sorted = {};
  const keys = Object.keys(obj)
    .filter(k => obj[k] !== undefined && obj[k] !== null && String(obj[k]) !== '')
    .sort();

  for (const k of keys) {
    const encodedKey = encodeURIComponent(k);
    const encodedVal = encodeURIComponent(String(obj[k])).replace(/%20/g, '+');
    sorted[encodedKey] = encodedVal;
  }
  return sorted;
}

function stringifySortedParams(sortedObj) {
  return Object.keys(sortedObj)
    .map(k => `${k}=${sortedObj[k]}`)
    .join('&');
}

function createVnpayPaymentUrl({
  txnRef,
  amount,
  orderInfo,
  ipAddr,
  returnUrl,
  bankCode = '',
  locale = 'vn',
}) {
  const { tmnCode, hashSecret, url } = config.VNPAY;
  const now = new Date();
  const createDate = formatVnDate(now);
  const expireDate = formatVnDate(new Date(now.getTime() + 15 * 60 * 1000));
  const vnpAmount = Math.max(1000, Math.round(Number(amount) || 0)) * 100;

  const params = {
    vnp_Version: '2.1.0',
    vnp_Command: 'pay',
    vnp_TmnCode: tmnCode,
    vnp_Locale: locale || config.VNPAY.locale || 'vn',
    vnp_CurrCode: 'VND',
    vnp_TxnRef: txnRef,
    vnp_OrderInfo: orderInfo,
    vnp_OrderType: 'other',
    vnp_Amount: vnpAmount,
    vnp_ReturnUrl: returnUrl,
    vnp_IpAddr: normalizeClientIp(ipAddr),
    vnp_CreateDate: createDate,
    vnp_ExpireDate: expireDate,
  };

  if (bankCode) {
    params.vnp_BankCode = bankCode;
  }

  const sortedParams = sortAndEncodeParams(params);
  const signData = stringifySortedParams(sortedParams);
  const vnpSecureHash = hmacSha512Hex(hashSecret, signData);
  sortedParams.vnp_SecureHash = vnpSecureHash;

  const paymentUrl = `${url}?${stringifySortedParams(sortedParams)}`;
  return {
    paymentUrl,
    txnRef,
    createDate,
    expireDate,
  };
}

function verifyVnpayCallback(query = {}) {
  if (!isVnpayConfigured()) return false;
  const receivedHash = query.vnp_SecureHash;
  if (!receivedHash) return false;

  const cloned = { ...query };
  delete cloned.vnp_SecureHash;
  delete cloned.vnp_SecureHashType;

  const sorted = sortAndEncodeParams(cloned);
  const signData = stringifySortedParams(sorted);
  const expectedHash = hmacSha512Hex(config.VNPAY.hashSecret, signData);
  return safeEqualHex(expectedHash, receivedHash);
}

async function queryVnpayTransaction({ txnRef, transactionDate, ipAddr, orderInfo }) {
  const { tmnCode, hashSecret, apiUrl } = config.VNPAY;
  const vnpRequestId = `QRY${Date.now()}`;
  const vnpVersion = '2.1.0';
  const vnpCommand = 'querydr';
  const vnpCreateDate = formatVnDate(new Date());
  const vnpIpAddr = normalizeClientIp(ipAddr);
  const vnpOrderInfo = orderInfo || `Truy van giao dich ${txnRef}`;

  // VNPay v2.1.0 querydr checksum format: pipe-separated fields in fixed order
  const rawData = [
    vnpRequestId,
    vnpVersion,
    vnpCommand,
    tmnCode,
    txnRef,
    transactionDate,
    vnpCreateDate,
    vnpIpAddr,
    vnpOrderInfo,
  ].join('|');

  const vnpSecureHash = hmacSha512Hex(hashSecret, rawData);

  const response = await fetch(apiUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      vnp_RequestId: vnpRequestId,
      vnp_Version: vnpVersion,
      vnp_Command: vnpCommand,
      vnp_TmnCode: tmnCode,
      vnp_TxnRef: txnRef,
      vnp_OrderInfo: vnpOrderInfo,
      vnp_TransactionDate: transactionDate,
      vnp_CreateDate: vnpCreateDate,
      vnp_IpAddr: vnpIpAddr,
      vnp_SecureHash: vnpSecureHash,
    }),
    signal: AbortSignal.timeout(15000),
  });

  const data = await response.json();
  return {
    httpStatus: response.status,
    data,
  };
}

module.exports = {
  isVnpayConfigured,
  formatVnDate,
  normalizeClientIp,
  sortAndEncodeParams,
  createVnpayPaymentUrl,
  verifyVnpayCallback,
  queryVnpayTransaction,
};
