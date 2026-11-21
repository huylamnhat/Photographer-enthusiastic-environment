const jwt = require('jsonwebtoken');
const config = require('../config');
const { mockUsers, mockLabs, mockPendingLabs, mockAuditLogs } = require('../data/mockStore');
const { initDatabase, runQuery, getDbStatus } = require('../config/db');

// In-memory OTP storage for internal demo
const otpStore = {};

exports.login = async (req, res) => {
  const { identifier, password } = req.body;
  if (!identifier || !String(identifier).trim()) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập Email hoặc Số điện thoại' });
  }
  if (!password || !String(password).trim()) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập mật khẩu' });
  }

  // Ensure SQL Server store is synced before checking credentials
  if (mockUsers.length === 0) {
    try {
      await initDatabase();
    } catch (_) {}
  }

  // Find user by email, phone, or user_code from SQL Server synced store
  const cleanId = String(identifier).trim();
  const lowerId = cleanId.toLowerCase();
  const user = mockUsers.find(
    u =>
      (u.email && u.email.toLowerCase() === lowerId) ||
      (u.phone && u.phone === cleanId) ||
      (u.user_id && u.user_id.toLowerCase() === lowerId)
  );

  if (!user) {
    return res.status(401).json({
      success: false,
      message: 'Tài khoản không tồn tại trong hệ thống'
    });
  }

  if (user.status && user.status !== 'ACTIVE') {
    return res.status(403).json({
      success: false,
      message: 'Tài khoản của bạn đã bị khóa (ban) do vi phạm quy định cộng đồng. Vui lòng liên hệ Quản trị viên để được hỗ trợ mở khóa.'
    });
  }

  if (user.role === 'LabOwner' && user.lab_id) {
    const approvedLab = mockLabs.find(l => l.lab_id === user.lab_id && l.status === 'APPROVED');
    if (!approvedLab) {
      const pendingApp = mockPendingLabs.find(p => p.application_id === user.lab_id || p.email?.toLowerCase() === user.email?.toLowerCase());
      if (pendingApp && pendingApp.status === 'REJECTED') {
        return res.status(403).json({
          success: false,
          message: `Hồ sơ tiệm Film Lab của bạn đã bị Admin từ chối: ${pendingApp.inspection_note || 'Chưa đạt yêu cầu thẩm định'}`
        });
      }
      if (pendingApp && pendingApp.status !== 'APPROVED') {
        return res.status(403).json({
          success: false,
          message: 'Hồ sơ tiệm Film Lab của bạn đang chờ Admin thẩm định phê duyệt trước khi đăng nhập.'
        });
      }
    }
  }

  const expectedPassword = user.password || 'password123';
  if (password !== expectedPassword) {
    return res.status(401).json({
      success: false,
      message: 'Mật khẩu không chính xác'
    });
  }

  const token = jwt.sign(
    {
      user_id: user.user_id,
      db_user_id: user.db_user_id,
      email: user.email,
      role: user.role,
      full_name: user.full_name,
      phone: user.phone,
      lab_id: user.lab_id
    },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRES_IN }
  );

  const { password: _pw, ...safeUser } = user;

  return res.json({
    success: true,
    message: 'Đăng nhập thành công',
    token,
    user: safeUser
  });
};

exports.register = async (req, res) => {
  const { email, phone, full_name, password } = req.body;
  const cleanName = String(full_name || '').trim();
  const cleanEmail = String(email || '').trim().toLowerCase();
  const cleanPhone = String(phone || '').trim();
  const cleanPass = String(password || '').trim();

  if (!cleanName) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập họ và tên' });
  }
  if (!cleanEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập email hợp lệ' });
  }
  if (!cleanPhone) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập số điện thoại' });
  }
  if (cleanPass.length < 6) {
    return res.status(400).json({ success: false, message: 'Mật khẩu phải có ít nhất 6 ký tự' });
  }

  const dup = mockUsers.find(
    u =>
      (u.email && u.email.toLowerCase() === cleanEmail) ||
      (cleanPhone && u.phone && u.phone === cleanPhone)
  );
  if (dup) {
    return res.status(400).json({ success: false, message: 'Email hoặc số điện thoại đã được đăng ký trong hệ thống' });
  }

  const userCode = `usr-${Date.now().toString().slice(-6)}`;
  const nowIso = new Date().toISOString();
  const avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';
  let dbUserId = null;

  if (getDbStatus().connected) {
    try {
      const esc = (v) => String(v || '').replace(/'/g, "''");
      const sqlRes = await runQuery(`
        INSERT INTO Users (user_code, email, phone, password_hash, full_name, avatar_url, status, email_verified)
        VALUES ('${esc(userCode)}', N'${esc(cleanEmail)}', '${esc(cleanPhone)}', '${esc(cleanPass)}', N'${esc(cleanName)}', '${avatarUrl}', 'ACTIVE', 1);
        DECLARE @newUid INT = SCOPE_IDENTITY();
        IF @newUid IS NOT NULL
        BEGIN
          INSERT INTO User_Roles (user_id, role_id) VALUES (@newUid, 1);
        END
        SELECT @newUid AS new_user_id;
      `);
      dbUserId = Number(sqlRes.recordset?.[0]?.new_user_id || 0) || null;
    } catch (err) {
      return res.status(500).json({ success: false, message: `Lỗi lưu tài khoản vào CSDL: ${err.message}` });
    }
  }

  const newUser = {
    user_id: userCode,
    db_user_id: dbUserId,
    email: cleanEmail,
    phone: cleanPhone,
    password: cleanPass,
    full_name: cleanName,
    role: 'Customer',
    status: 'ACTIVE',
    avatar_url: avatarUrl,
    orders_count: 0,
    created_at: nowIso
  };
  mockUsers.push(newUser);

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: nowIso.replace('T', ' ').slice(0, 19),
    actor: `${newUser.full_name} (${newUser.user_id})`,
    action: 'REGISTER_CUSTOMER',
    entity: `Users #${newUser.user_id}`,
    entity_name: 'Users',
    entity_id: newUser.user_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ email: newUser.email, phone: newUser.phone, role: 'Customer' })
  });

  const token = jwt.sign(
    {
      user_id: newUser.user_id,
      db_user_id: newUser.db_user_id,
      email: newUser.email,
      role: newUser.role,
      full_name: newUser.full_name,
      phone: newUser.phone,
    },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRES_IN }
  );

  const { password: _pw, ...safeUser } = newUser;

  return res.status(201).json({
    success: true,
    message: 'Đăng ký thành công, tài khoản đã được kích hoạt',
    token,
    user: safeUser
  });
};

exports.verifyOtp = async (req, res) => {
  const { target, otp } = req.body;
  const entry = otpStore[target];

  if (!entry || (otp !== entry.otp && otp !== '8888')) {
    return res.status(400).json({ success: false, message: 'Mã OTP không chính xác hoặc đã hết hạn' });
  }

  const cleanEmail = entry.tempUser.email || `${entry.tempUser.phone}@minilab.vn`;
  const cleanPhone = entry.tempUser.phone || '';
  const dup = mockUsers.find(
    u =>
      (u.email && u.email.toLowerCase() === cleanEmail.toLowerCase()) ||
      (cleanPhone && u.phone && u.phone === cleanPhone)
  );
  if (dup) {
    delete otpStore[target];
    return res.status(400).json({ success: false, message: 'Tài khoản đã tồn tại trong hệ thống' });
  }

  const userCode = `usr-${Date.now().toString().slice(-6)}`;
  const nowIso = new Date().toISOString();
  const avatarUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';
  let dbUserId = null;

  if (getDbStatus().connected) {
    try {
      const esc = (v) => String(v || '').replace(/'/g, "''");
      const sqlRes = await runQuery(`
        INSERT INTO Users (user_code, email, phone, password_hash, full_name, avatar_url, status, email_verified)
        VALUES ('${esc(userCode)}', N'${esc(cleanEmail)}', '${esc(cleanPhone)}', '${esc(entry.tempUser.password || 'password123')}', N'${esc(entry.tempUser.full_name)}', '${avatarUrl}', 'ACTIVE', 1);
        DECLARE @newUid INT = SCOPE_IDENTITY();
        IF @newUid IS NOT NULL
        BEGIN
          INSERT INTO User_Roles (user_id, role_id) VALUES (@newUid, 1);
        END
        SELECT @newUid AS new_user_id;
      `);
      dbUserId = Number(sqlRes.recordset?.[0]?.new_user_id || 0) || null;
    } catch (err) {
      return res.status(500).json({ success: false, message: `Lỗi lưu tài khoản vào CSDL: ${err.message}` });
    }
  }

  const newUser = {
    user_id: userCode,
    db_user_id: dbUserId,
    email: cleanEmail,
    phone: cleanPhone,
    password: entry.tempUser.password || 'password123',
    full_name: entry.tempUser.full_name || 'Nhiếp ảnh gia mới',
    role: 'Customer',
    status: 'ACTIVE',
    avatar_url: avatarUrl,
    orders_count: 0,
    created_at: nowIso
  };
  mockUsers.push(newUser);
  delete otpStore[target];

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: nowIso.replace('T', ' ').slice(0, 19),
    actor: `${newUser.full_name} (${newUser.user_id})`,
    action: 'REGISTER_CUSTOMER',
    entity: `Users #${newUser.user_id}`,
    entity_name: 'Users',
    entity_id: newUser.user_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ email: newUser.email, phone: newUser.phone, role: 'Customer' })
  });

  const token = jwt.sign(
    {
      user_id: newUser.user_id,
      db_user_id: newUser.db_user_id,
      email: newUser.email,
      role: newUser.role,
      full_name: newUser.full_name,
      phone: newUser.phone,
    },
    config.JWT_SECRET,
    { expiresIn: config.JWT_EXPIRES_IN }
  );

  const { password: _pw, ...safeUser } = newUser;

  return res.status(201).json({
    success: true,
    message: 'Đăng ký thành công, tài khoản đã được kích hoạt',
    token,
    user: safeUser
  });
};

exports.registerLab = async (req, res) => {
  const {
    owner_name,
    email,
    phone,
    password,
    lab_name,
    city,
    district,
    street_address,
    business_license,
    scanner_models,
    supported_processes,
    inspection_note,
  } = req.body;

  const cleanOwner = String(owner_name || '').trim();
  const cleanEmail = String(email || '').trim().toLowerCase();
  const cleanPhone = String(phone || '').trim();
  const cleanPass = String(password || '').trim();
  const cleanLabName = String(lab_name || '').trim();
  const cleanCity = String(city || 'Hà Nội').trim();
  const cleanDistrict = String(district || 'Trung tâm').trim();
  const cleanAddress = String(street_address || '').trim();
  const cleanLicense = String(business_license || `GPKD-${Date.now().toString().slice(-6)}`).trim();
  const cleanNote = String(inspection_note || 'Phòng tối đạt chuẩn nhiệt độ hóa chất và máy scan phim chuyên dụng').trim();

  if (!cleanOwner || !cleanLabName || !cleanAddress || !cleanPhone) {
    return res.status(400).json({ success: false, message: 'Vui lòng điền đầy đủ họ tên chủ tiệm, tên tiệm Lab, địa chỉ và số điện thoại' });
  }
  if (!cleanEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập email đăng nhập hợp lệ' });
  }
  if (cleanPass.length < 6) {
    return res.status(400).json({ success: false, message: 'Mật khẩu phải có ít nhất 6 ký tự' });
  }

  const dupUser = mockUsers.find(
    u =>
      (u.email && u.email.toLowerCase() === cleanEmail) ||
      (cleanPhone && u.phone && u.phone === cleanPhone)
  );
  if (dupUser) {
    return res.status(400).json({ success: false, message: 'Email hoặc số điện thoại đã được đăng ký trong hệ thống' });
  }

  const scanners = Array.isArray(scanner_models) && scanner_models.length > 0
    ? scanner_models.map(s => String(s))
    : ['Noritsu HS-1800'];
  const processes = Array.isArray(supported_processes) && supported_processes.length > 0
    ? supported_processes.map(p => String(p))
    : ['C-41', 'B&W'];

  const ownerCode = `usr-${Date.now().toString().slice(-6)}`;
  const labCode = `lab-${Date.now().toString().slice(-5)}`;
  const slug = `lab-${Date.now()}`;
  const nowIso = new Date().toISOString();
  let dbUserId = null;
  let dbLabId = null;

  if (getDbStatus().connected) {
    try {
      const esc = (v) => String(v || '').replace(/'/g, "''");
      const scannersJson = JSON.stringify(scanners);
      const processesJson = JSON.stringify(processes);
      const sqlRes = await runQuery(`
        INSERT INTO Users (user_code, email, phone, password_hash, full_name, avatar_url, address_text, status, email_verified)
        VALUES ('${esc(ownerCode)}', N'${esc(cleanEmail)}', '${esc(cleanPhone)}', '${esc(cleanPass)}', N'${esc(cleanOwner)}', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', N'${esc(cleanAddress)}', 'ACTIVE', 1);
        DECLARE @newUid INT = SCOPE_IDENTITY();
        IF @newUid IS NOT NULL
        BEGIN
          INSERT INTO User_Roles (user_id, role_id) VALUES (@newUid, 2);
          INSERT INTO Lab_Profile (
            lab_code, owner_id, lab_name, slug, tagline, description, phone, email,
            province, district, street_address, business_license_no, scanner_models,
            supported_processes, supports_pickup, turnaround_hours, price_range, approval_status, inspection_note
          )
          VALUES (
            '${esc(labCode)}', @newUid, N'${esc(cleanLabName)}', '${esc(slug)}',
            N'Tiệm Film Lab đối tác mới đăng ký', N'${esc(cleanNote)}',
            '${esc(cleanPhone)}', N'${esc(cleanEmail)}',
            N'${esc(cleanCity)}', N'${esc(cleanDistrict)}', N'${esc(cleanAddress)}',
            '${esc(cleanLicense)}', N'${esc(scannersJson)}', N'${esc(processesJson)}',
            1, 12, N'55.000đ - 120.000đ', 'PENDING', N'${esc(cleanNote)}'
          );
          SELECT @newUid AS new_user_id, SCOPE_IDENTITY() AS new_lab_id;
        END
      `);
      dbUserId = Number(sqlRes.recordset?.[0]?.new_user_id || 0) || null;
      dbLabId = Number(sqlRes.recordset?.[0]?.new_lab_id || 0) || null;
    } catch (err) {
      return res.status(500).json({ success: false, message: `Lỗi lưu hồ sơ Lab vào CSDL: ${err.message}` });
    }
  }

  mockUsers.push({
    user_id: ownerCode,
    db_user_id: dbUserId,
    email: cleanEmail,
    phone: cleanPhone,
    password: cleanPass,
    full_name: cleanOwner,
    role: 'LabOwner',
    lab_id: labCode,
    status: 'ACTIVE',
    avatar_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    address: cleanAddress,
    orders_count: 0,
    created_at: nowIso,
  });

  const pendingApp = {
    application_id: labCode,
    db_lab_id: dbLabId,
    owner_id: ownerCode,
    name: cleanLabName,
    owner_name: cleanOwner,
    email: cleanEmail,
    phone: cleanPhone,
    city: cleanCity,
    address: `${cleanAddress}, ${cleanDistrict}, ${cleanCity}`,
    business_license: cleanLicense,
    scanner_models: scanners,
    supported_processes: processes,
    applied_date: nowIso,
    status: 'PENDING',
    inspection_note: cleanNote,
  };
  mockPendingLabs.unshift(pendingApp);

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: nowIso.replace('T', ' ').slice(0, 19),
    actor: `${cleanOwner} (${ownerCode})`,
    action: 'REGISTER_LAB',
    entity: `Lab_Profile #${labCode}`,
    entity_name: 'Lab_Profile',
    entity_id: labCode,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ lab_name: cleanLabName, city: cleanCity, status: 'PENDING' })
  });

  return res.status(201).json({
    success: true,
    message: 'Đã gửi hồ sơ đăng ký mở Tiệm Film Lab! Hồ sơ đã chuyển tới Admin thẩm định.',
    data: pendingApp
  });
};

exports.forgotPassword = (req, res) => {
  const { identifier, new_password } = req.body;
  const user = mockUsers.find(u => u.email === identifier || u.phone === identifier);
  if (user) {
    user.password = new_password || '123456';
  }
  return res.json({
    success: true,
    message: 'Mật khẩu mới đã được cập nhật thành công (Mô phỏng nội bộ)'
  });
};

exports.getMe = (req, res) => {
  return res.json({
    success: true,
    user: req.user
  });
};

