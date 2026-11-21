/**
 * MiniLab Platform - SQL Server Connection & Store Synchronizer
 * Connects to Microsoft SQL Server (localhost\SQLEXPRESS -> FilmLabPlatform)
 * Supports both:
 *  1) Direct TCP/IP connection via 'mssql' package (SQL Server Authentication)
 *  2) Native Windows Authentication (.NET SqlClient) for localhost\SQLEXPRESS (no TCP/SA setup required)
 */
const fs = require('fs');
const path = require('path');
const { execFile } = require('child_process');
const config = require('./index');
const store = require('../data/mockStore');

let sql = null;
try {
  sql = require('mssql');
} catch (_) {
  // 'mssql' package optional when using Windows Authentication bridge
}

let pool = null;
let useWindowsSqlClient = false;
let dbStatus = {
  connected: false,
  mode: 'DISCONNECTED',
  database: config.DB.database,
  server: config.DB_RAW_SERVER || `${config.DB.server}:${config.DB.port || 1433}`,
  lastSync: null,
  error: null,
};

function safeIsoDate(val) {
  if (!val) return new Date().toISOString();
  if (val instanceof Date && !isNaN(val.getTime())) return val.toISOString();
  const str = String(val);
  // Handle PowerShell / .NET JSON date format: /Date(1710000000000)/
  const msMatch = str.match(/\/Date\((-?\d+)\)\//);
  if (msMatch) {
    const d = new Date(Number(msMatch[1]));
    if (!isNaN(d.getTime())) return d.toISOString();
  }
  const parsed = new Date(str);
  if (!isNaN(parsed.getTime())) return parsed.toISOString();
  return new Date().toISOString();
}

function safeJsonArray(str, fallback = []) {
  if (!str) return fallback;
  if (Array.isArray(str)) return str;
  try {
    const parsed = JSON.parse(str);
    return Array.isArray(parsed) ? parsed : [String(str)];
  } catch (_) {
    return String(str).split(',').map(s => s.trim()).filter(Boolean);
  }
}

function mapRoleCodeToAppRole(roleCode) {
  switch (roleCode) {
    case 'ADMIN': return 'Admin';
    case 'LAB_OWNER': return 'LabOwner';
    case 'EXPERT': return 'Expert';
    case 'DELIVERY_PARTNER': return 'DeliveryPartner';
    default: return 'Customer';
  }
}

function getDefaultProcessTableForLab(labCode) {
  switch (labCode) {
    case 'lab-002': // LLab Film Sài Gòn
      return [
        {
          process_code: 'C-41',
          process_name: 'Tráng Màu Âm Bản C-41 (Siêu tốc 8h)',
          chemistry: 'Fujifilm Hunt C-41RA (Mở mới mỗi sáng)',
          temperature: '37.8°C ± 0.1°C',
          dev_machine: 'Fuji FP-363SC',
          scanner: 'Fuji Frontier SP-3000 / Noritsu LS-600',
          turnaround_hours: 8,
          push_pull_policy: 'Hỗ trợ +1/+2 stop (+15.000đ/stop)',
        },
        {
          process_code: 'ECN-2',
          process_name: 'Tráng Phim Điện Ảnh ECN-2 (Vision3)',
          chemistry: 'Bellini ECN-2 Motion Picture (Tẩy Remjet)',
          temperature: '41.1°C ± 0.1°C',
          dev_machine: 'Rotary Cine Tank',
          scanner: 'Fuji Frontier SP-3000 (Log / Rec709)',
          turnaround_hours: 16,
          push_pull_policy: 'Hỗ trợ +1/+2 stop (+20.000đ/stop)',
        },
        {
          process_code: 'B&W',
          process_name: 'Tráng Đen Trắng B&W Street Contrast',
          chemistry: 'Kodak D-76 1:1 / Rodinal',
          temperature: '20.0°C ± 0.2°C',
          dev_machine: 'Paterson Hand Inversion',
          scanner: 'Noritsu LS-600',
          turnaround_hours: 16,
          push_pull_policy: 'Hỗ trợ +1/+2 stop (+15.000đ/stop)',
        },
      ];
    case 'lab-003': // Nadar Darkroom & Lab
      return [
        {
          process_code: 'B&W',
          process_name: 'Tráng Thủ Công Fine-Art B&W (35mm/120/4x5)',
          chemistry: 'Ilford Microphen / Pyrocat-HD / XTOL (Pha mới)',
          temperature: '20.0°C ± 0.05°C (Chiller phòng tối)',
          dev_machine: 'Jobo Expert Drum 3010 & Tráng tay',
          scanner: 'Hasselblad Flextight X5 (16-bit TIFF)',
          turnaround_hours: 24,
          push_pull_policy: 'Hỗ trợ -2 đến +3 stop tùy chỉnh theo từng cuộn',
        },
        {
          process_code: 'C-41',
          process_name: 'Tráng Màu C-41 Pro One-Shot Archival',
          chemistry: 'Kodak Flexicolor One-Shot (Không tái sử dụng)',
          temperature: '37.8°C ± 0.05°C',
          dev_machine: 'Jobo CPP-3 One-Shot',
          scanner: 'Noritsu HS-1800 / Hasselblad Flextight X5',
          turnaround_hours: 24,
          push_pull_policy: 'Hỗ trợ -1 đến +2 stop (+25.000đ/stop)',
        },
        {
          process_code: 'E-6',
          process_name: 'Tráng Dương Bản Slide E-6 (6 bước)',
          chemistry: 'Fuji Hunt Chrome 6X One-Shot',
          temperature: '38.0°C ± 0.1°C',
          dev_machine: 'Jobo CPP-3 Rotary',
          scanner: 'Hasselblad Flextight X5 (Dmax 4.0)',
          turnaround_hours: 36,
          push_pull_policy: 'Hỗ trợ -1 đến +2 stop (+30.000đ/stop)',
        },
      ];
    case 'lab-001': // CropLab Hà Nội
    default:
      return [
        {
          process_code: 'C-41',
          process_name: 'Tráng Màu Âm Bản C-41 Chuẩn Kodak',
          chemistry: 'Kodak Flexicolor LU',
          temperature: '37.8°C ± 0.1°C',
          dev_machine: 'Noritsu V30RA Tự Động',
          scanner: 'Noritsu HS-1800 / Fuji Frontier SP-3000',
          turnaround_hours: 12,
          push_pull_policy: 'Hỗ trợ -1 đến +3 stop (+20.000đ/stop)',
        },
        {
          process_code: 'B&W',
          process_name: 'Tráng Đen Trắng B&W Thủ Công',
          chemistry: 'Ilford ID-11 / DD-X / Kodak HC-110',
          temperature: '20.0°C (Chuẩn phòng tối)',
          dev_machine: 'Jobo CPP-3 Rotary / Hand Tank',
          scanner: 'Noritsu HS-1800',
          turnaround_hours: 24,
          push_pull_policy: 'Hỗ trợ Push +1/+2/+3 stop (+20.000đ/stop)',
        },
        {
          process_code: 'ECN-2',
          process_name: 'Tráng Phim Điện Ảnh ECN-2 (Tẩy Remjet)',
          chemistry: 'Kodak ECN-2 Kit (Bể khử than Remjet riêng)',
          temperature: '41.1°C ± 0.1°C',
          dev_machine: 'Cine Processor Dedicated',
          scanner: 'Fuji Frontier SP-3000',
          turnaround_hours: 24,
          push_pull_policy: 'Hỗ trợ +1/+2 stop (+25.000đ/stop)',
        },
        {
          process_code: 'E-6',
          process_name: 'Tráng Phim Dương Bản Slide E-6',
          chemistry: 'Tetenal Colortec E-6 6-Bath',
          temperature: '38.0°C ± 0.1°C',
          dev_machine: 'Jobo Autolab',
          scanner: 'Noritsu HS-1800 (Dmax 4.0)',
          turnaround_hours: 36,
          push_pull_policy: 'Hỗ trợ +1 stop (+30.000đ/stop)',
        },
      ];
  }
}

/**
 * Executes a SQL query via Windows .NET SqlClient (Integrated Security=True)
 * Works out-of-the-box with localhost\SQLEXPRESS in SSMS without TCP/IP or SA setup.
 */
function queryViaWindowsAuth(sqlQuery, targetDb) {
  return new Promise((resolve, reject) => {
    const serverName = config.DB_RAW_SERVER || 'localhost\\SQLEXPRESS';
    const dbName = targetDb || config.DB.database || 'FilmLabPlatform';
    const b64Query = Buffer.from(sqlQuery, 'utf8').toString('base64');

    const psScript = `
      [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
      $ErrorActionPreference = 'Stop'
      $connStr = "Server=${serverName};Database=${dbName};Integrated Security=True;TrustServerCertificate=True;"
      $sql = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${b64Query}'))
      $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
      $conn.Open()
      try {
        $cmd = $conn.CreateCommand()
        $cmd.CommandTimeout = 60
        $cmd.CommandText = $sql
        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        [void]$adapter.Fill($dt)
        $rows = @()
        foreach ($row in $dt.Rows) {
          $obj = @{}
          foreach ($col in $dt.Columns) {
            $val = $row[$col.ColumnName]
            if ($val -is [System.DBNull]) { $obj[$col.ColumnName] = $null }
            elseif ($val -is [System.DateTime]) { $obj[$col.ColumnName] = $val.ToString('o') }
            elseif ($val -is [System.TimeSpan]) { $obj[$col.ColumnName] = $val.ToString() }
            else { $obj[$col.ColumnName] = $val }
          }
          $rows += [PSCustomObject]$obj
        }
        ConvertTo-Json -InputObject @($rows) -Depth 5 -Compress
      } finally {
        $conn.Close()
      }
    `;

    execFile(
      'powershell.exe',
      ['-NoProfile', '-NonInteractive', '-Command', psScript],
      { encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 },
      (err, stdout, stderr) => {
        if (err) {
          return reject(new Error((stderr || err.message).trim()));
        }
        const trimmed = (stdout || '').trim();
        if (!trimmed) return resolve({ recordset: [] });
        try {
          const parsed = JSON.parse(trimmed);
          const arr = Array.isArray(parsed) ? parsed : [parsed];
          return resolve({ recordset: arr });
        } catch (parseErr) {
          return reject(new Error(`JSON Parse Error: ${parseErr.message}`));
        }
      }
    );
  });
}

/**
 * Automatically executes database/init_database.sql against localhost\SQLEXPRESS
 * if FilmLabPlatform does not exist yet or still has an older seed (< 20 users).
 */
function runInitDatabaseSqlViaWindowsAuth() {
  return new Promise((resolve, reject) => {
    const sqlFilePath = path.resolve(__dirname, '../../../database/init_database.sql');
    if (!fs.existsSync(sqlFilePath)) {
      return reject(new Error(`Không tìm thấy file ${sqlFilePath}`));
    }
    const serverName = config.DB_RAW_SERVER || 'localhost\\SQLEXPRESS';
    const b64Path = Buffer.from(sqlFilePath, 'utf8').toString('base64');

    const psScript = `
      [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
      $ErrorActionPreference = 'Stop'
      $filePath = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${b64Path}'))
      $scriptText = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
      $batches = [System.Text.RegularExpressions.Regex]::Split($scriptText, '^\\s*GO\\s*$', [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
      [System.Data.SqlClient.SqlConnection]::ClearAllPools()
      $connStr = "Server=${serverName};Database=master;Integrated Security=True;TrustServerCertificate=True;Pooling=False;"
      $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
      $conn.Open()
      try {
        foreach ($batch in $batches) {
          $trimmed = $batch.Trim()
          if ($trimmed.Length -gt 0) {
            $cmd = $conn.CreateCommand()
            $cmd.CommandTimeout = 120
            $cmd.CommandText = $trimmed
            [void]$cmd.ExecuteNonQuery()
          }
        }
        Write-Output "INIT_OK"
      } finally {
        $conn.Close()
      }
    `;

    execFile(
      'powershell.exe',
      ['-NoProfile', '-NonInteractive', '-Command', psScript],
      { encoding: 'utf8', maxBuffer: 20 * 1024 * 1024 },
      (err, stdout, stderr) => {
        if (err) {
          return reject(new Error((stderr || err.message).trim()));
        }
        resolve(true);
      }
    );
  });
}

async function runQuery(sqlQuery) {
  if (pool && !useWindowsSqlClient) {
    return pool.request().query(sqlQuery);
  }
  return queryViaWindowsAuth(sqlQuery);
}

async function initDatabase() {
  // 1. Try Windows Authentication first if DB_WINDOWS_AUTH is enabled (matches SSMS localhost\SQLEXPRESS)
  if (config.DB_WINDOWS_AUTH) {
    try {
      // Step 1a: Verify SQL Server instance is reachable and check if FilmLabPlatform has the 3-way synchronized seed
      const checkRes = await queryViaWindowsAuth(
        "SELECT CASE WHEN OBJECT_ID('dbo.Orders', 'U') IS NOT NULL THEN (SELECT COUNT(*) FROM dbo.Orders) ELSE 0 END AS cnt"
      );
      const cnt = Number(checkRes.recordset[0]?.cnt || 0);

      if (cnt < 8) {
        console.log(`[SQL Server]: Đang tự động khởi tạo/cập nhật CSDL FilmLabPlatform đồng bộ 3 bên từ database/init_database.sql...`);
        await runInitDatabaseSqlViaWindowsAuth();
        console.log(`[SQL Server]: Đã đồng bộ đầy đủ 44 bảng, 20 users, 8 labs, 9 orders trong FilmLabPlatform!`);
      }

      useWindowsSqlClient = true;
      dbStatus.connected = true;
      dbStatus.mode = 'SQL_SERVER_WINDOWS_AUTH';
      dbStatus.error = null;
      console.log(`[SQL Server]: Đã kết nối thành công tới ${dbStatus.server}/${dbStatus.database} (Windows Authentication)`);
      await syncStoreFromSqlServer();
      return dbStatus;
    } catch (winErr) {
      console.log(`[SQL Server Windows Auth]: Không thể kết nối tới ${dbStatus.server} (${winErr.message.split('\n')[0]})`);
    }
  }

  // 2. Fallback to 'mssql' package (TCP/IP + SQL Login)
  if (sql) {
    try {
      pool = await new sql.ConnectionPool(config.DB).connect();
      useWindowsSqlClient = false;
      dbStatus.connected = true;
      dbStatus.mode = 'SQL_SERVER_TCP';
      dbStatus.error = null;
      console.log(`[SQL Server]: Đã kết nối thành công tới ${dbStatus.server}/${dbStatus.database} (SQL Login)`);
      await syncStoreFromSqlServer();
      return dbStatus;
    } catch (err) {
      dbStatus.connected = false;
      dbStatus.mode = 'DISCONNECTED';
      dbStatus.error = err.message;
      console.log(`[SQL Server]: Không thể kết nối (${err.message}) -> Vui lòng kiểm tra SQL Server (${dbStatus.server}) và chắc chắn đã chạy database/init_database.sql`);
      await hydratePersistedDriveLinks();
      return dbStatus;
    }
  }

  dbStatus.connected = false;
  dbStatus.mode = 'DISCONNECTED';
  dbStatus.error = 'Không thể kết nối SQL Server. Hãy chạy database/init_database.sql trong SSMS.';
  await hydratePersistedDriveLinks();
  return dbStatus;
}

async function syncStoreFromSqlServer() {
  if (!dbStatus.connected) return false;

  try {
    // Tự động đồng bộ chuẩn hóa dữ liệu tài khoản nếu CSDL đang giữ bản ghi cũ
    await runQuery(`
      UPDATE Users
      SET full_name = N'Phạm Thu Trang', email = 'thutrang.pham@gmail.com'
      WHERE user_id = 15 AND (full_name = N'Đỗ Thùy Trang' OR email = 'trang.do@gmail.com');

      UPDATE Users
      SET full_name = N'Trần Đình Trọng', email = 'trong.tran@minilab.vn', status = 'LOCKED',
          locked_by = 1, locked_at = SYSUTCDATETIME(),
          locked_reason = N'Phát tán link spam tài chính cá độ trái phép trên cộng đồng'
      WHERE user_id = 8 AND (full_name = N'Người dùng vi phạm' OR email = 'spammer@minilab.vn');

      UPDATE Post_Article
      SET author_id = 12
      WHERE post_code = 'REP-COM-104' AND author_id = 8;

      UPDATE Orders
      SET customer_id = 15
      WHERE order_code = 'ORD-2026-8835'
        AND customer_id = 5;

      UPDATE o
      SET o.customer_id = dc.complainant_id
      FROM Orders o
      JOIN Dispute_Complaint dc ON dc.order_id = o.order_id
      WHERE o.customer_id <> dc.complainant_id;

      -- Đảm bảo 3 Film Lab (CropLab Hà Nội, LLab Film Sài Gòn, Nadar Darkroom & Lab) lưu trữ khách hàng & đơn hàng tách biệt
      IF NOT EXISTS (SELECT 1 FROM Orders WHERE lab_id IN (2, 3))
      BEGIN
        UPDATE Orders SET lab_id = 2, customer_id = 14, status = 'RECEIVED', kanban_column = 'QUEUE', subtotal = 60000, total_amount = 60000 WHERE order_code = 'ORD-2026-8803';
        UPDATE Orders SET lab_id = 2, customer_id = 14, status = 'READY_FOR_DOWNLOAD', kanban_column = 'READY', subtotal = 120000, total_amount = 120000 WHERE order_code = 'ORD-2026-8841';
        UPDATE Orders SET lab_id = 2, customer_id = 17, status = 'PROCESSING', kanban_column = 'DEVELOPING', subtotal = 75000, total_amount = 75000 WHERE order_code = 'ORD-2026-8839';
        UPDATE Orders SET lab_id = 3, customer_id = 6,  status = 'READY_FOR_DOWNLOAD', kanban_column = 'READY', subtotal = 180000, total_amount = 180000 WHERE order_code = 'ORD-2026-8838';
      END

      IF NOT EXISTS (SELECT 1 FROM Orders WHERE order_code = 'ORD-2026-8845')
      BEGIN
        INSERT INTO Orders (order_code, customer_id, lab_id, status, kanban_column, receive_method, return_method, pickup_address, payment_status, payment_method, subtotal, shipping_fee, platform_fee, discount_amount, total_amount, sla_deadline)
        VALUES ('ORD-2026-8845', 16, 3, 'PROCESSING', 'QC', 'DROP_AT_LAB', 'DIGITAL_ONLY', N'Cầu Giấy, Hà Nội', 'PAID', 'BANK_TRANSFER', 160000, 0, 0, 0, 160000, DATEADD(HOUR, 36, SYSUTCDATETIME()));
        DECLARE @ord8845 BIGINT = SCOPE_IDENTITY();
        DECLARE @pkgNadar BIGINT = (SELECT TOP 1 package_id FROM Service_Package WHERE lab_id = 3 ORDER BY package_id);
        IF @ord8845 IS NOT NULL AND @pkgNadar IS NOT NULL
        BEGIN
          INSERT INTO Order_Item (item_code, order_id, package_id, film_stock_id, film_name, roll_code, quantity, unit_price, line_total, push_pull, cut_negatives, status)
          VALUES ('item-110', @ord8845, @pkgNadar, 2, N'Fuji Provia 100F', 'ROLL-PROVIA-10', 1, 160000, 160000, N'Normal (Box speed)', N'Để nguyên cuộn không cắt', 'PROCESSING');
        END
      END

      -- Cập nhật đồng bộ gói dịch vụ riêng của LLab Film Sài Gòn (lab_id = 2) và Nadar Darkroom & Lab (lab_id = 3)
      UPDATE Service_Package
      SET name = N'Gói C-41 Siêu Tốc 8 Giờ (Fuji Frontier SP-3000)',
          description = N'Gói tráng và scan màu chất ảnh Frontier SP-3000 ấm áp, trả file trong 8 giờ tại LLab Film Sài Gòn.'
      WHERE package_code = 'pkg-006';

      UPDATE Service_Package
      SET name = N'Gói B&W Thủ Công Fine-Art (Hasselblad Flextight X5)',
          description = N'Tráng tay phòng tối Nadar Darkroom với thuốc Microphen/Pyrocat và scan Hasselblad Flextight X5 16-bit TIFF.'
      WHERE package_code = 'pkg-007';

      IF NOT EXISTS (SELECT 1 FROM Service_Package WHERE package_code = 'pkg-201')
      BEGIN
        INSERT INTO Service_Package (package_code, lab_id, service_type, name, description, format_id, process_type_id, scan_quality, scan_resolution, output_format, price, est_processing_days, estimated_hours, is_active) VALUES
        ('pkg-201', 2, 'DEVELOP_SCAN', N'Gói C-41 Hi-Res Medium Format 120 (Noritsu LS-600)', N'Tráng máy Fuji FP-363SC và scan khổ 120 (6x6, 6x7) sắc nét độ phân giải cao.', 3, 1, 'HIGH', N'L (4800x4800px 16-bit)', 'TIFF', 95000, 1, 12, 1),
        ('pkg-202', 2, 'DEVELOP_SCAN', N'Gói Cine ECN-2 Sài Gòn (Vision3 250D/500T)', N'Quy trình tẩy than Remjet chuẩn điện ảnh bằng hóa chất Bellini, xuất profile màu Log/Rec709.', 1, 4, 'STANDARD', N'M (3000x2000px Log)', 'JPEG', 85000, 1, 16, 1),
        ('pkg-203', 2, 'DEVELOP_SCAN', N'Gói B&W Street Contrast (Kodak D-76 1:1)', N'Tráng đen trắng kéo sáng tương phản cao cho ảnh đường phố, scan Noritsu LS-600.', 1, 3, 'STANDARD', N'M (3000x2000px)', 'JPEG', 75000, 1, 16, 1),
        ('pkg-301', 3, 'DEVELOP_SCAN', N'Gói Tráng Tay B&W 135 (Ilford Pyrocat / XTOL)', N'Kiểm soát nhiệt độ chiller 20.0°C ± 0.05°C, độ mịn hạt tối đa cho phim đen trắng 35mm.', 1, 3, 'HIGH', N'L (4000x6000px TIFF)', 'TIFF', 110000, 1, 24, 1),
        ('pkg-302', 3, 'DEVELOP_SCAN', N'Gói C-41 Pro One-Shot Archival (Noritsu HS-1800)', N'Hóa chất Kodak Flexicolor pha mới dùng 1 lần (One-Shot) không tái sử dụng cho màu sắc chuẩn mực.', 1, 1, 'PRO', N'L (6000x4000px 16-bit)', 'TIFF', 120000, 1, 24, 1),
        ('pkg-303', 3, 'DEVELOP_SCAN', N'Gói Slide Dương Bản E-6 Exhibition (Flextight X5)', N'Tráng quy trình 6 bước Fuji Hunt Chrome E-6 cho phim dương bản Provia/Velvia.', 3, 2, 'PRO', N'XL (5000 DPI Master TIFF)', 'TIFF', 160000, 2, 36, 1),
        ('pkg-304', 3, 'DEVELOP_SCAN', N'Gói Large Format 4x5 Sheet Film (B&W / C-41)', N'Tráng phim tấm khổ lớn 4x5 bằng trống Jobo Expert 3010 & scan drum ảo Hasselblad X5.', 7, 3, 'PRO', N'XL (Hasselblad X5 Drum)', 'TIFF', 195000, 2, 36, 1);
      END

      IF NOT EXISTS (SELECT 1 FROM Lab_Profile WHERE lab_code = 'lab-002' AND scanner_models LIKE '%Noritsu LS-600%')
      BEGIN
        UPDATE Lab_Profile SET scanner_models = N'["Fuji Frontier SP-3000","Noritsu LS-600"]' WHERE lab_code = 'lab-002';
      END
    `).catch(() => {});

    // 1. Users
    const usersRes = await runQuery(`
      SELECT u.*,
             (SELECT TOP 1 r.role_code FROM User_Roles ur JOIN Roles r ON r.role_id = ur.role_id WHERE ur.user_id = u.user_id ORDER BY r.role_id DESC) AS role_code,
             (SELECT TOP 1 COALESCE(l.lab_code, CONCAT('lab-', l.lab_id)) FROM Lab_Profile l WHERE l.owner_id = u.user_id) AS owned_lab_code,
             (SELECT COUNT(*) FROM Orders o WHERE o.customer_id = u.user_id) AS orders_count
      FROM Users u
    `);
    store.mockUsers.length = 0;
    usersRes.recordset.forEach(u => {
      store.mockUsers.push({
        user_id: u.user_code || `usr-${u.user_id}`,
        db_user_id: u.user_id,
        email: u.email,
        phone: u.phone || '',
        password: u.password_hash,
        full_name: u.full_name,
        avatar_url: u.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        role: mapRoleCodeToAppRole(u.role_code),
        lab_id: u.owned_lab_code || undefined,
        address: u.address_text || '',
        bio: u.bio || undefined,
        status: u.status,
        orders_count: Number(u.orders_count || 0),
        created_at: safeIsoDate(u.created_at),
      });
    });

    // 2. Expert Applications / Profiles
    const expRes = await runQuery(`
      SELECT ep.*, u.user_code, u.full_name, u.email, u.phone
      FROM Expert_Profile ep
      JOIN Users u ON u.user_id = ep.user_id
    `);
    store.mockExpertApplications.length = 0;
    expRes.recordset.forEach(ep => {
      store.mockExpertApplications.push({
        id: ep.user_code || `APP-EXP-${ep.expert_id}`,
        expert_id: ep.expert_id,
        db_user_id: ep.user_id,
        user_id: ep.user_code || `usr-${ep.user_id}`,
        name: ep.full_name,
        email: ep.email,
        phone: ep.phone || '',
        specialty: ep.specialties || 'Nhiếp ảnh gia Film',
        portfolioUrl: ep.portfolio_url || '',
        experience: ep.bio || `${ep.years_experience || 5} năm kinh nghiệm nhiếp ảnh film`,
        years_experience: Number(ep.years_experience || 5),
        status: ep.verification_status,
      });
    });

    // 3. Labs (Approved & Pending)
    const labsRes = await runQuery(`
      SELECT l.*, u.user_code AS owner_code, u.full_name AS owner_name,
             STRING_AGG(f.name, ',') AS formats_csv
      FROM Lab_Profile l
      JOIN Users u ON u.user_id = l.owner_id
      LEFT JOIN Lab_Film_Format lff ON lff.lab_id = l.lab_id
      LEFT JOIN Film_Format f ON f.format_id = lff.format_id
      GROUP BY l.lab_id, l.lab_code, l.owner_id, l.lab_name, l.slug, l.tagline, l.description,
               l.phone, l.email, l.province, l.district, l.street_address, l.latitude, l.longitude,
               l.business_license_no, l.license_image_url, l.logo_url, l.cover_url, l.opening_time,
               l.closing_time, l.turnaround_hours, l.price_range, l.scanner_models, l.supported_processes,
               l.supports_pickup, l.avg_rating, l.review_count, l.approval_status, l.inspection_note,
               l.reviewed_by, l.reviewed_at, l.reject_reason, l.created_at, l.updated_at,
               u.user_code, u.full_name
    `);
    store.mockLabs.length = 0;
    store.mockPendingLabs.length = 0;
    labsRes.recordset.forEach(l => {
      if (l.approval_status === 'APPROVED') {
        store.mockLabs.push({
          lab_id: l.lab_code || `lab-${l.lab_id}`,
          db_lab_id: l.lab_id,
          owner_id: l.owner_code || `usr-${l.owner_id}`,
          name: l.lab_name,
          tagline: l.tagline || '',
          address: l.street_address,
          city: l.province,
          phone: l.phone,
          email: l.email || '',
          rating: Number(l.avg_rating || 5.0),
          review_count: Number(l.review_count || 0),
          turnaround_hours: Number(l.turnaround_hours || 12),
          scanner_models: safeJsonArray(l.scanner_models, ['Noritsu HS-1800']),
          supported_formats: l.formats_csv ? l.formats_csv.split(',') : ['135', '120'],
          supported_processes: safeJsonArray(l.supported_processes, ['C-41', 'B&W']),
          process_table: getDefaultProcessTableForLab(l.lab_code || `lab-${l.lab_id}`),
          cover_image: l.cover_url || 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
          logo_url: l.logo_url || 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200',
          is_verified: true,
          status: l.approval_status,
          price_range: l.price_range || '50.000đ - 120.000đ',
          description: l.description || '',
          created_at: safeIsoDate(l.created_at),
        });
      } else {
        store.mockPendingLabs.push({
          application_id: l.lab_code || `app-lab-${l.lab_id}`,
          db_lab_id: l.lab_id,
          owner_id: l.owner_code || `usr-${l.owner_id}`,
          name: l.lab_name,
          owner_name: l.owner_name,
          email: l.email || '',
          phone: l.phone,
          city: l.province,
          address: l.street_address,
          business_license: l.business_license_no || '',
          scanner_models: safeJsonArray(l.scanner_models, ['Noritsu HS-1800']),
          supported_processes: safeJsonArray(l.supported_processes, ['C-41']),
          applied_date: safeIsoDate(l.created_at),
          status: l.approval_status,
          inspection_note: l.inspection_note || l.description || '',
        });
      }
    });

    // Hydrate custom Lab payment QR settings if configured in SQL
    await ensureLabPaymentQrTable();
    try {
      const qrRes = await runQuery(`SELECT lab_code, qr_image_url, bank_name, account_no, account_name FROM dbo.Lab_Payment_Qr`);
      (qrRes.recordset || []).forEach(q => {
        const target = store.mockLabs.find(m => m.lab_id === q.lab_code);
        if (target) {
          if (q.qr_image_url) target.qr_image_url = q.qr_image_url;
          if (q.bank_name) target.bank_name = q.bank_name;
          if (q.account_no) target.account_no = q.account_no;
          if (q.account_name) target.account_name = q.account_name;
        }
      });
    } catch (_) {}

    // 4. Process Standards & Service Packages
    const procRes = await runQuery(`SELECT * FROM Process_Type ORDER BY process_type_id`);
    store.mockProcessStandards.length = 0;
    procRes.recordset.forEach(pt => {
      store.mockProcessStandards.push({
        process_type_id: pt.process_type_id,
        code: pt.code === 'C41' ? 'C-41' : (pt.code === 'ECN2' ? 'ECN-2' : (pt.code === 'E6' ? 'E-6' : (pt.code === 'BW' ? 'B&W' : pt.code))),
        name: pt.name,
        formats: '135, 120, 220, 4x5',
        status: 'ACTIVE',
      });
    });

    const pkgRes = await runQuery(`
      SELECT sp.*, l.lab_code, l.lab_name, f.name AS format_name, pt.code AS process_code
      FROM Service_Package sp
      JOIN Lab_Profile l ON l.lab_id = sp.lab_id
      JOIN Film_Format f ON f.format_id = sp.format_id
      LEFT JOIN Process_Type pt ON pt.process_type_id = sp.process_type_id
    `);
    store.mockServicePackages.length = 0;
    pkgRes.recordset.forEach(p => {
      store.mockServicePackages.push({
        package_id: p.package_code || `pkg-${p.package_id}`,
        db_package_id: p.package_id,
        lab_id: p.lab_code || `lab-${p.lab_id}`,
        lab_name: p.lab_name,
        name: p.name,
        film_format: p.format_name || '135',
        process_type: p.process_code === 'C41' ? 'C-41' : (p.process_code === 'ECN2' ? 'ECN-2' : (p.process_code === 'E6' ? 'E-6' : (p.process_code === 'BW' ? 'B&W' : (p.process_code || 'C-41')))),
        scan_resolution: p.scan_resolution || p.scan_quality || 'M (3000x2000px)',
        price: Number(p.price),
        estimated_hours: Number(p.estimated_hours || (p.est_processing_days * 12)),
        status: p.is_active ? 'ACTIVE' : 'INACTIVE',
        description: p.description || '',
      });
    });

    // 5. Orders & Order Items
    const ordersRes = await runQuery(`
      SELECT o.*, u.user_code, u.email AS customer_email, u.full_name AS customer_name, u.phone AS customer_phone, l.lab_code, l.lab_name
      FROM Orders o
      JOIN Users u ON u.user_id = o.customer_id
      JOIN Lab_Profile l ON l.lab_id = o.lab_id
      ORDER BY o.created_at DESC
    `);
    const itemsRes = await runQuery(`
      SELECT oi.*, sp.package_code, sp.name AS package_name
      FROM Order_Item oi
      JOIN Service_Package sp ON sp.package_id = oi.package_id
    `);
    store.mockOrders.length = 0;
    ordersRes.recordset.forEach(o => {
      const orderItems = itemsRes.recordset
        .filter(it => Number(it.order_id) === Number(o.order_id))
        .map(it => ({
          item_id: it.item_code || `item-${it.order_item_id}`,
          package_id: it.package_code || `pkg-${it.package_id}`,
          name: it.package_name,
          film_name: it.film_name || 'Kodak Portra 400',
          roll_code: it.roll_code || `ROLL-${it.order_item_id}`,
          quantity: Number(it.quantity),
          price: Number(it.unit_price),
          options: {
            push_pull: it.push_pull || 'Normal (Box speed)',
            cut_negatives: it.cut_negatives || 'Cắt 6 frames/dải',
          },
        }));
      store.mockOrders.push({
        order_id: o.order_code,
        db_order_id: Number(o.order_id),
        user_id: o.user_code || `usr-${o.customer_id}`,
        customer_email: o.customer_email || '',
        customer_name: o.customer_name,
        customer_phone: o.customer_phone || '',
        lab_id: o.lab_code || `lab-${o.lab_id}`,
        lab_name: o.lab_name,
        order_date: safeIsoDate(o.created_at),
        status: o.status,
        kanban_column: o.kanban_column || 'QUEUE',
        total_amount: Number(o.total_amount),
        shipping_fee: Number(o.shipping_fee || 0),
        shipping_method: (o.receive_method === 'PICKUP' && Number(o.shipping_fee || 0) > 0)
          ? 'AHAMOVE_PICKUP'
          : (o.receive_method || 'DROP_AT_LAB'),
        pickup_address: o.pickup_address || '',
        payment_status: o.payment_status || 'PAID',
        payment_method: o.payment_method || 'VNPAY',
        cancel_reason: o.cancel_reason || '',
        sla_deadline: safeIsoDate(o.sla_deadline),
        items: orderItems,
        timeline: [
          {
            step: 1,
            name: '1. Tiếp nhận',
            status: o.status === 'CANCELLED' ? 'COMPLETED' : (o.payment_status === 'PENDING' ? 'PENDING' : (o.kanban_column === 'QUEUE' ? 'IN_PROGRESS' : 'COMPLETED')),
            time: o.payment_status === 'PENDING' ? '' : '09:30 01/03/2026',
            note: o.status === 'CANCELLED'
              ? `Đơn hàng đã bị hủy: ${o.cancel_reason || 'Quá hạn thanh toán VNPAY'}`
              : (o.payment_status === 'PENDING'
                ? `Đang chờ khách hàng thanh toán qua cổng ${o.payment_method || 'VNPAY'}`
                : `Thanh toán ${o.payment_method || 'VNPAY'} thành công • Đã tiếp nhận tại ${o.lab_name}`),
          },
          {
            step: 2,
            name: '2. Vào Tank / Tráng',
            status: o.kanban_column === 'QUEUE' ? 'PENDING' : (o.kanban_column === 'DEVELOPING' ? 'IN_PROGRESS' : 'COMPLETED'),
            time: o.kanban_column === 'QUEUE' ? '' : '11:15 01/03/2026',
            note: o.kanban_column === 'QUEUE' ? '' : 'Tráng hóa chất tiêu chuẩn 37.8°C',
          },
          {
            step: 3,
            name: '3. Sấy khô',
            status: ['QUEUE', 'DEVELOPING'].includes(o.kanban_column)
              ? 'PENDING'
              : (['QC', 'DRYING'].includes(o.kanban_column) ? 'IN_PROGRESS' : 'COMPLETED'),
            time: ['SCANNING', 'READY'].includes(o.kanban_column) ? '14:00 01/03/2026' : '',
            note: ['QC', 'DRYING', 'SCANNING', 'READY'].includes(o.kanban_column) ? 'Sấy khô buồng kín & cân bằng phẳng' : '',
          },
          {
            step: 4,
            name: '4. Scan số hóa',
            status: o.kanban_column === 'SCANNING' ? 'IN_PROGRESS' : (o.kanban_column === 'READY' ? 'COMPLETED' : 'PENDING'),
            time: o.kanban_column === 'READY' ? '16:20 01/03/2026' : '',
            note: ['SCANNING', 'READY'].includes(o.kanban_column) ? 'Quét số hóa trên máy Noritsu HS-1800 / Frontier' : '',
          },
          {
            step: 5,
            name: '5. QC & Archive',
            status: o.kanban_column === 'READY' ? 'COMPLETED' : 'PENDING',
            time: o.kanban_column === 'READY' ? '17:15 01/03/2026' : '',
            note: o.kanban_column === 'READY' ? 'Đã hoàn tất QC & đồng bộ vào kho ảnh Digital Archive' : '',
          },
        ]
      });
    });

    // Hydrate Shipment (AhaMove / delivery) records onto mockOrders
    try {
      const shipRes = await runQuery(`
        SELECT s.*, o.order_code
        FROM Shipment s
        JOIN Orders o ON o.order_id = s.order_id
        ORDER BY s.created_at DESC
      `);
      (shipRes.recordset || []).forEach(s => {
        const ord = store.mockOrders.find(m => m.order_id === s.order_code);
        if (ord && !ord.shipment) {
          ord.shipment = {
            provider: s.provider || 'AHAMOVE',
            direction: s.direction || 'PICKUP_TO_LAB',
            external_order_id: s.external_order_id || '',
            tracking_code: s.tracking_code || s.external_order_id || '',
            shared_link: (s.tracking_code && String(s.tracking_code).startsWith('http')) ? s.tracking_code : '',
            sender_name: s.sender_name || '',
            sender_phone: s.sender_phone || '',
            sender_address: s.sender_address || '',
            receiver_name: s.receiver_name || '',
            receiver_phone: s.receiver_phone || '',
            receiver_address: s.receiver_address || '',
            shipping_fee: Number(s.shipping_fee || 0),
            status: s.status || 'PENDING',
            sandbox: true,
            created_at: safeIsoDate(s.created_at),
          };
          if ((s.provider || 'AHAMOVE') === 'AHAMOVE') {
            ord.shipping_method = 'AHAMOVE_PICKUP';
          }
          if (!ord.pickup_phone && s.sender_phone) {
            ord.pickup_phone = s.sender_phone;
          }
        }
      });
    } catch (_) {}

    // 6. Archive Photos & Metadata
    const photosRes = await runQuery(`
      SELECT ap.*, dfa.title AS album_name, u.user_code, o.order_code,
             pm.camera_model, pm.lens, pm.focal_length, pm.iso, pm.aperture,
             pm.shutter_speed, pm.scan_device, pm.notes, fs.name AS film_stock_name
      FROM Archive_Photo ap
      JOIN Digital_Film_Archive dfa ON dfa.archive_id = ap.archive_id
      JOIN Users u ON u.user_id = dfa.owner_id
      LEFT JOIN Order_Item oi ON oi.order_item_id = dfa.order_item_id
      LEFT JOIN Orders o ON o.order_id = oi.order_id
      LEFT JOIN Photo_Metadata pm ON pm.photo_id = ap.photo_id
      LEFT JOIN Film_Stock fs ON fs.film_stock_id = COALESCE(pm.film_stock_id, dfa.film_stock_id)
      WHERE ap.is_deleted = 0
      ORDER BY ap.uploaded_at DESC
    `);
    store.mockArchivePhotos.length = 0;
    photosRes.recordset.forEach(p => {
      store.mockArchivePhotos.push({
        photo_id: p.photo_code || `pho-${p.photo_id}`,
        user_id: p.user_code,
        order_id: p.order_code || 'ORD-2026-8801',
        roll_code: p.roll_code || 'ROLL-PORTRA400-01',
        title: p.title || p.file_name,
        image_url: p.storage_key,
        thumbnail_url: p.thumbnail_key || p.storage_key,
        drive_link: (p.notes && String(p.notes).startsWith('http'))
          ? p.notes
          : '',
        album_name: p.album_name,
        is_favorite: Boolean(p.is_favorite),
        created_at: safeIsoDate(p.uploaded_at),
        metadata: {
          camera: p.camera_model || 'Leica M6 Classic',
          lens: p.lens || 'Summicron 35mm f/2 ASPH',
          film_stock: p.film_stock_name || 'Kodak Portra 400',
          iso: Number(p.iso || 400),
          aperture: p.aperture ? `f/${p.aperture}` : 'f/2.8',
          shutter_speed: p.shutter_speed || '1/250s',
          focal_length: p.focal_length || '35mm',
          process: p.scan_device || 'C-41 Noritsu HS-1800',
          lab: 'CropLab Hà Nội',
          dimensions: p.width_px && p.height_px ? `${p.width_px} x ${p.height_px}` : '6048 x 4032',
          file_size: `${(Number(p.size_bytes || 18000000) / (1024 * 1024)).toFixed(1)} MB TIFF`,
        },
      });
    });

    // 7. Marketplace Listings
    const listingsRes = await runQuery(`
      SELECT el.*, u.user_code, u.full_name AS seller_name, u.avatar_url AS seller_avatar,
             ec.name AS category_name,
             (SELECT TOP 1 li.image_url FROM Listing_Image li WHERE li.listing_id = el.listing_id ORDER BY li.sort_order) AS primary_image
      FROM Equipment_Listing el
      JOIN Users u ON u.user_id = el.seller_id
      JOIN Equipment_Category ec ON ec.category_id = el.category_id
      ORDER BY el.created_at DESC
    `);
    store.mockListings.length = 0;
    listingsRes.recordset.forEach(l => {
      store.mockListings.push({
        listing_id: l.listing_code || `mkt-${l.listing_id}`,
        seller_id: l.user_code || `usr-${l.seller_id}`,
        seller_name: l.seller_name,
        seller_avatar: l.seller_avatar || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        title: l.title,
        category: l.category_name,
        condition: l.condition_note || l.item_condition,
        price: Number(l.price || 0),
        status: l.status === 'PENDING_APPROVAL' ? 'PENDING_REVIEW' : l.status,
        moderation_status: l.status === 'ACTIVE' ? 'APPROVED' : (l.status === 'REJECTED' ? 'REJECTED' : 'PENDING'),
        rejection_reason: l.reject_reason || '',
        location: l.location_text || 'Hà Nội',
        phone_contact: l.contact_phone,
        zalo_contact: l.contact_zalo || l.contact_phone,
        image_urls: l.primary_image ? [l.primary_image] : ['https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800'],
        description: l.description || '',
        created_at: safeIsoDate(l.created_at),
      });
    });

    // 8. Community Posts, Comments & Likes
    await runQuery(`
      IF OBJECT_ID('dbo.Post_Like', 'U') IS NULL
      BEGIN
        CREATE TABLE dbo.Post_Like (
          post_code VARCHAR(40) NOT NULL,
          user_code VARCHAR(40) NOT NULL,
          created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
          CONSTRAINT PK_Post_Like PRIMARY KEY (post_code, user_code)
        );
      END
    `).catch(() => {});

    const postsRes = await runQuery(`
      SELECT p.*, u.user_code, u.full_name AS author_name, u.avatar_url AS author_avatar, u.status AS author_status, pc.name AS category_name
      FROM Post_Article p
      JOIN Users u ON u.user_id = p.author_id
      LEFT JOIN Post_Category pc ON pc.post_category_id = p.post_category_id
      ORDER BY p.created_at DESC
    `);
    const postCommentsRes = await runQuery(`
      SELECT pc.*, p.post_code, u.user_code, u.full_name AS user_name, u.avatar_url
      FROM Post_Comment pc
      JOIN Post_Article p ON p.post_id = pc.post_id
      JOIN Users u ON u.user_id = pc.user_id
      WHERE pc.status = 'VISIBLE'
      ORDER BY pc.created_at ASC, pc.comment_id ASC
    `).catch(() => ({ recordset: [] }));
    const postLikesRes = await runQuery(`
      SELECT post_code, user_code FROM dbo.Post_Like
    `).catch(() => ({ recordset: [] }));

    store.mockCommunityPosts.length = 0;
    postsRes.recordset.forEach(p => {
      const postCode = p.post_code || `post-${p.post_id}`;
      const isAudited = Boolean(p.moderated_by || p.post_code === 'post-001');
      const isLocked = p.author_status === 'LOCKED';
      const commentsForPost = (postCommentsRes.recordset || [])
        .filter(c => Number(c.post_id) === Number(p.post_id) || c.post_code === postCode)
        .map(c => ({
          comment_id: c.comment_code || `cmt-${c.comment_id}`,
          user_id: c.user_code || `usr-${c.user_id}`,
          user_name: c.user_name || 'Thành viên MiniLab',
          avatar_url: c.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          content: c.content || '',
          created_at: safeIsoDate(c.created_at),
        }));
      const likedUserIds = (postLikesRes.recordset || [])
        .filter(l => l.post_code === postCode)
        .map(l => String(l.user_code));
      const sqlLikes = Number(p.likes_count || 0);
      store.mockCommunityPosts.push({
        post_id: postCode,
        db_post_id: Number(p.post_id),
        author_id: p.user_code || `usr-${p.author_id}`,
        author_name: isLocked ? 'Người dùng vi phạm' : p.author_name,
        author_avatar: isLocked ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150' : (p.author_avatar || 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150'),
        author_badge: isLocked ? 'NGƯỜI DÙNG VI PHẠM' : (p.post_type === 'TUTORIAL' ? 'Chuyên gia nhiếp ảnh' : 'Thành viên cộng đồng'),
        author_status: p.author_status || 'ACTIVE',
        is_author_locked: isLocked,
        title: p.title,
        content: p.content,
        category: p.category_name || 'Kỹ thuật chụp',
        image_url: p.cover_image_url || 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
        likes_count: Math.max(sqlLikes, likedUserIds.length),
        liked_user_ids: likedUserIds,
        comments_count: commentsForPost.length,
        status: p.status === 'PUBLISHED' ? 'ACTIVE' : p.status,
        report_count: Number(p.report_count || 0),
        report_reason: p.report_reason || undefined,
        moderated_by: p.moderated_by || null,
        moderated_at: p.moderated_by ? safeIsoDate(p.updated_at || p.created_at) : null,
        needs_audit: !isAudited && (p.status === 'ACTIVE' || p.status === 'REPORTED'),
        created_at: safeIsoDate(p.created_at),
        comments: commentsForPost,
      });
    });

    // 9. Events (Workshops & Photowalks)
    const eventsRes = await runQuery(`
      SELECT e.*, u.full_name AS host_name,
             (SELECT COUNT(*) FROM Event_Registration er WHERE er.event_id = e.event_id AND er.status IN ('REGISTERED', 'ATTENDED')) AS attendees_count
      FROM Event e
      JOIN Users u ON u.user_id = e.host_id
      ORDER BY e.start_at ASC
    `);
    store.mockEvents.length = 0;
    eventsRes.recordset.forEach(e => {
      store.mockEvents.push({
        event_id: e.event_code || `evt-${e.event_id}`,
        title: e.title,
        host_name: `${e.host_name} (Expert)`,
        type: e.event_type,
        date: safeIsoDate(e.start_at),
        location: e.venue,
        max_participants: Number(e.capacity || 20),
        current_participants: Number(e.attendees_count || 0),
        fee: Number(e.fee || 0),
        cover_image: e.cover_image_url || 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
        description: e.description || '',
      });
    });

    // 10. Disputes, Messages & Evidence
    const disputesRes = await runQuery(`
      SELECT dc.*, o.order_code, l.lab_code, l.lab_name, u.user_code AS customer_code, u.full_name AS customer_name
      FROM Dispute_Complaint dc
      JOIN Orders o ON o.order_id = dc.order_id
      JOIN Lab_Profile l ON l.lab_id = o.lab_id
      JOIN Users u ON u.user_id = dc.complainant_id
      ORDER BY dc.created_at DESC
    `);
    const dmRes = await runQuery(`
      SELECT dm.*, u.full_name AS sender_name
      FROM Dispute_Message dm
      JOIN Users u ON u.user_id = dm.sender_id
      ORDER BY dm.created_at ASC
    `);
    const deRes = await runQuery(`SELECT * FROM Dispute_Evidence ORDER BY uploaded_at ASC`);

    store.mockDisputes.length = 0;
    store.mockNotifications.length = 0;
    disputesRes.recordset.forEach(d => {
      const messages = dmRes.recordset
        .filter(m => Number(m.dispute_id) === Number(d.dispute_id))
        .map(m => ({
          sender: m.sender_name,
          text: m.content,
          time: safeIsoDate(m.created_at).replace('T', ' ').slice(0, 19),
        }));
      const evidence = deRes.recordset
        .filter(ev => Number(ev.dispute_id) === Number(d.dispute_id))
        .map(ev => ev.file_url);

      const labReplyMsg = [...messages].reverse().find(m =>
        m.text && (m.text.toLowerCase().includes('tặng cuộn') || m.text.toLowerCase().includes('đền bù') || m.text.toLowerCase().includes('hoàn tiền'))
      );

      const isCompensated = Boolean(labReplyMsg && (labReplyMsg.text.toLowerCase().includes('tặng cuộn') || labReplyMsg.text.toLowerCase().includes('đền bù')));
      const effectiveStatus = isCompensated && d.status === 'NEGOTIATING' ? 'COMPENSATED' : d.status;

      store.mockDisputes.push({
        dispute_id: d.dispute_code,
        order_id: d.order_code,
        customer_id: d.customer_code || `usr-${d.complainant_id}`,
        customer_name: d.customer_name,
        lab_id: d.lab_code || `lab-${d.lab_id}`,
        lab_name: d.lab_name,
        issue_type: d.issue_title || d.reason_type,
        description: d.description,
        status: effectiveStatus,
        compensation_note: labReplyMsg ? labReplyMsg.text : undefined,
        amount_requested: Number(d.requested_amount || 0),
        refund_amount: d.approved_refund_amount ? Number(d.approved_refund_amount) : undefined,
        evidence_urls: evidence,
        created_at: safeIsoDate(d.created_at),
        messages,
      });

      if (labReplyMsg || ['COMPENSATED', 'REFUNDED', 'RESOLVED'].includes(effectiveStatus)) {
        store.mockNotifications.push({
          notification_id: `NTF-DSP-${d.dispute_id}`,
          type: effectiveStatus === 'REFUNDED' ? 'REFUND' : 'COMPENSATION',
          order_id: d.order_code,
          dispute_id: d.dispute_code,
          customer_id: d.customer_code || `usr-${d.complainant_id}`,
          title: effectiveStatus === 'REFUNDED'
            ? `💰 Admin đã phê duyệt hoàn tiền đơn #${d.order_code}`
            : `🎁 Tiệm ${d.lab_name} đã đền bù cuộn film cho đơn #${d.order_code}`,
          message: labReplyMsg
            ? labReplyMsg.text
            : `Khiếu nại #${d.dispute_code} của đơn #${d.order_code} đã được giải quyết (${effectiveStatus}).`,
          created_at: safeIsoDate(d.resolved_at || d.created_at),
          is_read: false,
        });
      }
    });

    // 11. Reviews
    const revRes = await runQuery(`
      SELECT r.*, u.user_code, u.full_name AS user_name, o.order_code, l.lab_code
      FROM Review r
      JOIN Users u ON u.user_id = r.reviewer_id
      LEFT JOIN Orders o ON o.order_id = r.order_id
      LEFT JOIN Lab_Profile l ON l.lab_id = o.lab_id
      ORDER BY r.created_at DESC
    `);
    store.mockReviews.length = 0;
    revRes.recordset.forEach(r => {
      store.mockReviews.push({
        review_id: r.review_code || `rev-${r.review_id}`,
        order_id: r.order_code || '',
        lab_id: r.lab_code || 'lab-001',
        user_id: r.user_code || `usr-${r.reviewer_id}`,
        user_name: r.user_name,
        rating: Number(r.rating),
        comment: r.comment || '',
        service_name: r.service_name || 'Tráng & Scan Film',
        created_at: safeIsoDate(r.created_at),
      });
    });

    // 12. Audit Logs
    const auditRes = await runQuery(`
      SELECT al.*, u.full_name AS actor_name,
             (SELECT TOP 1 r.role_code FROM User_Roles ur JOIN Roles r ON r.role_id = ur.role_id WHERE ur.user_id = al.user_id ORDER BY r.role_id DESC) AS role_code
      FROM Audit_Log al
      LEFT JOIN Users u ON u.user_id = al.user_id
      ORDER BY al.created_at DESC
    `);
    store.mockAuditLogs.length = 0;
    auditRes.recordset.forEach(al => {
      store.mockAuditLogs.push({
        id: `LOG-${al.log_id}`,
        timestamp: safeIsoDate(al.created_at).replace('T', ' ').slice(0, 19),
        actor: al.actor_name ? `${al.actor_name} (${al.role_code || 'USER'})` : 'System',
        action: al.action,
        entity: `${al.entity_name} #${al.entity_id || ''}`,
        entity_name: al.entity_name,
        entity_id: al.entity_id || '',
        ip: al.ip_address || '127.0.0.1',
        oldVal: al.old_value || '{}',
        newVal: al.new_value || '{}',
      });
    });

    await hydratePersistedDriveLinks();
    dbStatus.lastSync = new Date().toISOString();
    console.log(`[SQL Server Sync]: Đã tải ${store.mockUsers.length} users, ${store.mockLabs.length + store.mockPendingLabs.length} labs, ${store.mockOrders.length} orders từ CSDL.`);
    return true;
  } catch (err) {
    console.error('[SQL Server Sync Error]:', err.message);
    await hydratePersistedDriveLinks();
    return false;
  }
}

const DRIVE_LINKS_BACKUP_PATH = path.resolve(__dirname, '../../uploads/sent_drive_links.json');
let persistedDriveLinksCache = [];

function isValidPersistedDriveLink(link) {
  const s = String(link || '').trim();
  if (!s || !s.startsWith('http')) return false;
  if (
    s.includes('1FilmLabArchive') ||
    s.includes('1MiniLabDigitalArchive') ||
    s.includes('/file/d/') ||
    s.includes('/drive/my-drive')
  ) {
    return false;
  }
  return true;
}

function readBackupDriveLinksFile() {
  try {
    if (!fs.existsSync(DRIVE_LINKS_BACKUP_PATH)) return [];
    const raw = fs.readFileSync(DRIVE_LINKS_BACKUP_PATH, 'utf8');
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed.filter(r => r && isValidPersistedDriveLink(r.drive_link)) : [];
  } catch (_) {
    return [];
  }
}

function writeBackupDriveLinksFile(records) {
  try {
    const dir = path.dirname(DRIVE_LINKS_BACKUP_PATH);
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
    fs.writeFileSync(DRIVE_LINKS_BACKUP_PATH, JSON.stringify(records, null, 2), 'utf8');
  } catch (_) {}
}

async function ensureOrderDriveLinkTable() {
  if (!dbStatus.connected) return false;
  try {
    await runQuery(`
      IF OBJECT_ID('dbo.Order_Drive_Link', 'U') IS NULL
      BEGIN
        CREATE TABLE dbo.Order_Drive_Link (
          link_id         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
          order_code      VARCHAR(40)    NOT NULL,
          user_code       VARCHAR(40)    NULL,
          recipient_email VARCHAR(150)   NULL,
          customer_name   NVARCHAR(150)  NULL,
          lab_id          VARCHAR(40)    NULL,
          drive_link      NVARCHAR(1000) NOT NULL,
          roll_code       VARCHAR(60)    NULL,
          photo_count     INT            NOT NULL DEFAULT 1,
          drive_mode      VARCHAR(40)    NULL,
          created_at      DATETIME2(0)   NOT NULL DEFAULT SYSUTCDATETIME()
        );
      END
    `);
    return true;
  } catch (_) {
    return false;
  }
}

function applyDriveLinksToStoreOrders(records) {
  records.forEach(rec => {
    const orderCode = String(rec.order_code || '').trim();
    const driveLink = String(rec.drive_link || '').trim();
    if (!orderCode || !isValidPersistedDriveLink(driveLink)) return;

    const order = store.mockOrders.find(
      o => String(o.order_id || '').toLowerCase() === orderCode.toLowerCase()
    );
    if (!order) return;

    const uid = String(rec.user_code || order.user_id || '').trim();
    const emailLower = String(rec.recipient_email || order.customer_email || '').trim().toLowerCase();

    if (!order.drive_links_by_user) order.drive_links_by_user = {};
    if (!order.drive_link_history_by_user) order.drive_link_history_by_user = {};

    if (uid) {
      if (!order.drive_links_by_user[uid]) {
        order.drive_links_by_user[uid] = driveLink;
      }
      const prev = order.drive_link_history_by_user[uid] || [];
      if (!prev.includes(driveLink)) {
        order.drive_link_history_by_user[uid] = [...prev, driveLink];
      }
    }
    if (emailLower) {
      if (!order.drive_links_by_user[emailLower]) {
        order.drive_links_by_user[emailLower] = driveLink;
      }
      const prevE = order.drive_link_history_by_user[emailLower] || [];
      if (!prevE.includes(driveLink)) {
        order.drive_link_history_by_user[emailLower] = [...prevE, driveLink];
      }
    }

    order.kanban_column = 'READY';
    if (order.status !== 'COMPLETED') {
      order.status = 'READY_FOR_DOWNLOAD';
    }
    if (Array.isArray(order.timeline)) {
      order.timeline.forEach(step => {
        step.status = 'COMPLETED';
      });
    }
  });
}

async function hydratePersistedDriveLinks() {
  const merged = [];
  const seen = new Set();

  const pushUnique = (item) => {
    if (!item || !item.order_code || !isValidPersistedDriveLink(item.drive_link)) return;
    const key = `${String(item.order_code).toLowerCase()}|${String(item.drive_link).trim()}`;
    if (seen.has(key)) return;
    seen.add(key);
    merged.push({
      order_code: String(item.order_code).trim(),
      user_code: String(item.user_code || '').trim(),
      recipient_email: String(item.recipient_email || '').trim(),
      customer_name: String(item.customer_name || '').trim(),
      lab_id: String(item.lab_id || '').trim(),
      drive_link: String(item.drive_link).trim(),
      roll_code: String(item.roll_code || '').trim(),
      photo_count: Number(item.photo_count || 1),
      drive_mode: String(item.drive_mode || 'DRIVE_FOLDER_LINK'),
      created_at: item.created_at ? safeIsoDate(item.created_at) : new Date().toISOString(),
    });
  };

  if (dbStatus.connected) {
    try {
      await ensureOrderDriveLinkTable();
      const res = await runQuery(`
        SELECT order_code, user_code, recipient_email, customer_name, lab_id, drive_link, roll_code, photo_count, drive_mode, created_at
        FROM dbo.Order_Drive_Link
        ORDER BY created_at DESC, link_id DESC
      `);
      (res.recordset || []).forEach(pushUnique);
    } catch (err) {
      console.error('[Order_Drive_Link Load Warning]:', err.message);
    }
  }

  readBackupDriveLinksFile().forEach(pushUnique);

  merged.sort((a, b) => String(b.created_at || '').localeCompare(String(a.created_at || '')));
  persistedDriveLinksCache = merged;
  writeBackupDriveLinksFile(merged);
  applyDriveLinksToStoreOrders(merged);
  return merged;
}

async function saveOrderDriveLinkRecord(entry = {}) {
  const orderCode = String(entry.order_code || entry.order_id || '').trim();
  const driveLink = String(entry.drive_link || '').trim();
  if (!orderCode || !isValidPersistedDriveLink(driveLink)) return false;

  const cleanRecord = {
    order_code: orderCode,
    user_code: String(entry.user_code || '').trim(),
    recipient_email: String(entry.recipient_email || '').trim(),
    customer_name: String(entry.customer_name || '').trim(),
    lab_id: String(entry.lab_id || '').trim(),
    drive_link: driveLink,
    roll_code: String(entry.roll_code || '').trim(),
    photo_count: Number(entry.photo_count || 1),
    drive_mode: String(entry.drive_mode || 'DRIVE_FOLDER_LINK'),
    created_at: entry.created_at || new Date().toISOString(),
  };

  persistedDriveLinksCache = [
    cleanRecord,
    ...persistedDriveLinksCache.filter(
      r => !(String(r.order_code).toLowerCase() === orderCode.toLowerCase() && r.drive_link === driveLink)
    ),
  ];
  writeBackupDriveLinksFile(persistedDriveLinksCache);

  if (dbStatus.connected) {
    try {
      await ensureOrderDriveLinkTable();
      const esc = (v) => String(v || '').replace(/'/g, "''");
      await runQuery(`
        INSERT INTO dbo.Order_Drive_Link (order_code, user_code, recipient_email, customer_name, lab_id, drive_link, roll_code, photo_count, drive_mode)
        VALUES ('${esc(cleanRecord.order_code)}', '${esc(cleanRecord.user_code)}', '${esc(cleanRecord.recipient_email)}', N'${esc(cleanRecord.customer_name)}', '${esc(cleanRecord.lab_id)}', N'${esc(cleanRecord.drive_link)}', '${esc(cleanRecord.roll_code)}', ${cleanRecord.photo_count}, '${esc(cleanRecord.drive_mode)}');
      `);
    } catch (err) {
      console.error('[Order_Drive_Link Save Warning]:', err.message);
    }
  }
  return true;
}

function getPersistedSentDriveLinks(filterLabId = '') {
  return persistedDriveLinksCache
    .filter(rec => {
      if (!filterLabId) return true;
      if (rec.lab_id && rec.lab_id === filterLabId) return true;
      const ord = store.mockOrders.find(
        o => String(o.order_id || '').toLowerCase() === String(rec.order_code || '').toLowerCase()
      );
      return Boolean(ord && ord.lab_id === filterLabId);
    })
    .map(rec => ({
      order_id: rec.order_code,
      user_id: rec.user_code,
      recipient_email: rec.recipient_email,
      customer_name: rec.customer_name || 'Khách hàng',
      lab_id: rec.lab_id,
      drive_link: rec.drive_link,
      roll_code: rec.roll_code,
      photo_count: rec.photo_count,
      drive_mode: rec.drive_mode,
      created_at: rec.created_at,
    }));
}

async function ensureLabPaymentQrTable() {
  if (!dbStatus.connected) return;
  try {
    await runQuery(`
      IF OBJECT_ID('dbo.Lab_Payment_Qr', 'U') IS NULL
      BEGIN
        CREATE TABLE dbo.Lab_Payment_Qr (
          lab_code     VARCHAR(30)   NOT NULL PRIMARY KEY,
          qr_image_url NVARCHAR(MAX) NULL,
          bank_name    NVARCHAR(100) NULL,
          account_no   VARCHAR(50)   NULL,
          account_name NVARCHAR(150) NULL,
          updated_at   DATETIME2(0)  NOT NULL CONSTRAINT DF_LPQ_Updated DEFAULT SYSUTCDATETIME()
        );
      END
    `);
  } catch (err) {
    console.error('[Lab_Payment_Qr Ensure Warning]:', err.message);
  }
}

async function saveLabPaymentQrRecord({ lab_code, qr_image_url, bank_name, account_no, account_name }) {
  if (!dbStatus.connected || !lab_code) return false;
  try {
    await ensureLabPaymentQrTable();
    const esc = (v) => String(v || '').replace(/'/g, "''");
    await runQuery(`
      IF EXISTS (SELECT 1 FROM dbo.Lab_Payment_Qr WHERE lab_code = '${esc(lab_code)}')
      BEGIN
        UPDATE dbo.Lab_Payment_Qr
        SET qr_image_url = N'${esc(qr_image_url)}',
            bank_name = N'${esc(bank_name)}',
            account_no = '${esc(account_no)}',
            account_name = N'${esc(account_name)}',
            updated_at = SYSUTCDATETIME()
        WHERE lab_code = '${esc(lab_code)}';
      END
      ELSE
      BEGIN
        INSERT INTO dbo.Lab_Payment_Qr (lab_code, qr_image_url, bank_name, account_no, account_name)
        VALUES ('${esc(lab_code)}', N'${esc(qr_image_url)}', N'${esc(bank_name)}', '${esc(account_no)}', N'${esc(account_name)}');
      END
    `);
    return true;
  } catch (err) {
    console.error('[Lab_Payment_Qr Save Warning]:', err.message);
    return false;
  }
}

async function upsertShipmentRecord(shipment) {
  if (!dbStatus.connected || !shipment || !shipment.order_code) return false;
  try {
    const esc = (v) => String(v || '').replace(/'/g, "''");
    const ordCode = esc(shipment.order_code);
    const direction = esc(shipment.direction || 'PICKUP_TO_LAB');
    const provider = esc(shipment.provider || 'AHAMOVE');
    const extId = esc(shipment.external_order_id || '');
    const trackCode = esc(shipment.shared_link || shipment.tracking_code || extId);
    const sName = esc(shipment.sender_name || 'Khách hàng');
    const sPhone = esc(shipment.sender_phone || '0901234567');
    const sAddr = esc(shipment.sender_address || 'Hà Nội');
    const rName = esc(shipment.receiver_name || 'Film Lab');
    const rPhone = esc(shipment.receiver_phone || '0904567890');
    const rAddr = esc(shipment.receiver_address || 'Film Lab');
    const fee = Math.max(0, Number(shipment.shipping_fee) || 0);
    const status = esc(shipment.status || 'PENDING');

    await runQuery(`
      DECLARE @ordId BIGINT = (SELECT TOP 1 order_id FROM Orders WHERE order_code = '${ordCode}');
      IF @ordId IS NOT NULL
      BEGIN
        IF EXISTS (SELECT 1 FROM Shipment WHERE order_id = @ordId AND direction = '${direction}')
        BEGIN
          UPDATE Shipment
          SET provider = '${provider}',
              external_order_id = '${extId}',
              tracking_code = '${trackCode}',
              sender_name = N'${sName}',
              sender_phone = '${sPhone}',
              sender_address = N'${sAddr}',
              receiver_name = N'${rName}',
              receiver_phone = '${rPhone}',
              receiver_address = N'${rAddr}',
              shipping_fee = ${fee},
              status = '${status}'
          WHERE order_id = @ordId AND direction = '${direction}';
        END
        ELSE
        BEGIN
          INSERT INTO Shipment (order_id, direction, provider, external_order_id, tracking_code, sender_name, sender_phone, sender_address, receiver_name, receiver_phone, receiver_address, shipping_fee, status)
          VALUES (@ordId, '${direction}', '${provider}', '${extId}', '${trackCode}', N'${sName}', '${sPhone}', N'${sAddr}', N'${rName}', '${rPhone}', N'${rAddr}', ${fee}, '${status}');
        END
      END
    `);
    return true;
  } catch (err) {
    console.error('[Shipment Upsert Warning]:', err.message);
    return false;
  }
}

function getDbStatus() {
  return dbStatus;
}

function getPool() {
  return pool;
}

module.exports = {
  initDatabase,
  syncStoreFromSqlServer,
  runQuery,
  getDbStatus,
  getPool,
  saveOrderDriveLinkRecord,
  getPersistedSentDriveLinks,
  hydratePersistedDriveLinks,
  saveLabPaymentQrRecord,
  upsertShipmentRecord,
};
