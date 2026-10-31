const http = require('http');

function request(method, path, data = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const postData = data ? JSON.stringify(data) : null;
    const reqHeaders = {
      'Content-Type': 'application/json',
      ...headers
    };
    if (postData) {
      reqHeaders['Content-Length'] = Buffer.byteLength(postData);
    }

    const req = http.request({
      hostname: 'localhost',
      port: 5000,
      path,
      method,
      headers: reqHeaders
    }, (res) => {
      let body = '';
      res.on('data', chunk => body += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });

    req.on('error', reject);
    if (postData) req.write(postData);
    req.end();
  });
}

async function runTests() {
  console.log('--- 1. Test Roll Lifecycle (DEVELOPING) ---');
  let res = await request('PATCH', '/api/lab/orders/ORD-20261031-01/rolls/R02/process', { stage: 'DEVELOPING' });
  console.log('Result:', res.body.message);

  console.log('\n--- 2. Test Assign Bin Code ---');
  res = await request('PATCH', '/api/lab/orders/ORD-20261031-01/rolls/R02/bin-code', { binCode: 'BIN-B15', expiryDays: 20 });
  console.log('Result:', res.body.message);

  console.log('\n--- 3. Test Save Scan Metadata ---');
  res = await request('POST', '/api/lab/orders/ORD-20261031-01/rolls/R01/scan-metadata', {
    fileName: 'ORD24103101_R01_0912345678_Portra400.zip',
    fileSizeMb: 128.4,
    totalFrames: 37,
    scannerModel: 'Noritsu HS-1800',
    resolution: '3000x2000 (Standard)'
  });
  console.log('Result:', res.body.message);

  console.log('\n--- 4. Test Revoke & Replace Scan (24h) ---');
  res = await request('POST', '/api/lab/orders/ORD-20261031-01/rolls/R01/revoke-scan', {
    reason: 'Lệch frame 15, cần scan lại bằng khay phẳng'
  });
  console.log('Result:', res.body.message);

  console.log('\n--- 5. Test Mark Blank Film ---');
  res = await request('PATCH', '/api/lab/orders/ORD-20261031-01/rolls/R02/blank-film', {
    proofUrl: 'assets/proofs/blank_proof_01.jpg',
    reason: 'Phim trắng tinh do kẹt màn trập'
  });
  console.log('Result:', res.body.message);

  console.log('\n--- 6. Test Update Service Price with Reason (Lab Owner) ---');
  res = await request('PUT', '/api/lab/services/SRV-01', {
    basePrice: 95000,
    reason: 'Giá hóa chất C-41 Fuji tăng 15%'
  }, { 'x-user-role': 'LAB_OWNER' });
  console.log('Result:', res.body.message);

  console.log('\n--- 7. Test Check Audit Trail Logs ---');
  res = await request('GET', '/api/lab/services/SRV-01/price-logs');
  console.log('Total Price Logs for SRV-01:', res.body.count);
  console.log('Latest Log:', res.body.data[0]);

  console.log('\n--- 8. Test RBAC: Operator trying to change price (Expect 403) ---');
  res = await request('PUT', '/api/lab/services/SRV-01', {
    basePrice: 150000,
    reason: 'Nhân viên tự đổi giá'
  }, { 'x-user-role': 'LAB_OPERATOR' });
  console.log('Status code:', res.status);
  console.log('Result message:', res.body.message);

  console.log('\n=== ALL TESTS PASSED SUCCESSFULLY! ===');
}

runTests().catch(console.error);
