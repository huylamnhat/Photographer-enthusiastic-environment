USE FilmLabPlatform_Test;
GO

-- =====================================================================
-- 1. SEED DANH MỤC HỆ THỐNG CỐ ĐỊNH
-- =====================================================================
INSERT INTO Roles (role_id, role_code, role_name, description) VALUES
(1, 'CUSTOMER',         N'Khách hàng / Nhiếp ảnh gia', N'Đặt dịch vụ, quản lý Archive, mua bán thiết bị'),
(2, 'LAB_OWNER',        N'Chủ Film Lab',               N'Quản lý dịch vụ, đơn hàng, upload file scan'),
(3, 'EXPERT',           N'Chuyên gia nhiếp ảnh',       N'Đăng bài, tổ chức workshop/photowalk'),
(4, 'DELIVERY_PARTNER', N'Đối tác vận chuyển',         N'Nhận đơn pickup, giao nhận film'),
(5, 'ADMIN',            N'Quản trị hệ thống',          N'Duyệt lab, kiểm duyệt, xử lý khiếu nại');

INSERT INTO Film_Format (name) VALUES ('135'),('35mm'),('120'),('220'),('110'),('APS'),('4x5'),('8x10');

INSERT INTO Process_Type (code, name) VALUES
('C41',  N'C-41 (Phim màu âm bản)'),
('E6',   N'E-6 (Phim slide)'),
('BW',   N'Đen trắng (B&W)'),
('ECN2', N'ECN-2 (Phim điện ảnh)'),
('XPRO', N'Cross-process');

INSERT INTO Film_Stock (brand, name, iso, format_id, film_type) VALUES
(N'Kodak',    N'Kodak Portra 400',     400, 1, 'COLOR_NEG'),
(N'Fujifilm', N'Fujifilm Pro 400H',    400, 1, 'COLOR_NEG'),
(N'Ilford',   N'Ilford HP5 Plus 400',  400, 1, 'BW'),
(N'Kodak',    N'Kodak Ektar 100',      100, 3, 'COLOR_NEG'),
(N'Kodak',    N'Kodak Gold 200',       200, 1, 'COLOR_NEG'),
(N'Kodak',    N'Kodak Vision3 500T',   500, 1, 'CINE');

INSERT INTO Equipment_Category (parent_id, name) VALUES
(NULL, N'Máy ảnh film'),
(NULL, N'Máy ảnh Rangefinder'),
(NULL, N'Máy ảnh SLR cơ khí'),
(NULL, N'Ống kính'),
(NULL, N'Film (phim)'),
(NULL, N'Phụ kiện'),
(NULL, N'Thiết bị phòng tối / Scanner');

INSERT INTO Post_Category (name, slug) VALUES
(N'Kỹ thuật chụp',      'ky-thuat-chup'),
(N'Hướng dẫn kỹ thuật', 'huong-dan-ky-thuat'),
(N'Review thiết bị',    'review-thiet-bi'),
(N'Review Film Lab',    'review-film-lab'),
(N'Hỏi đáp cộng đồng',  'hoi-dap'),
(N'Spam',               'spam');

INSERT INTO System_Config (config_key, config_value, description) VALUES
('PLATFORM_FEE_PERCENT',        '10', N'Phí nền tảng thu trên mỗi đơn (%)'),
('NEGOTIATION_DEADLINE_DAYS',   '3',  N'Số ngày Khách & Lab tự thương lượng trước khi chuyển Admin'),
('LISTING_EXPIRE_DAYS',         '30', N'Số ngày tin Marketplace tự hết hạn'),
('PAYMENT_TIMEOUT_MINUTES',     '15', N'Thời gian chờ thanh toán trước khi tự hủy đơn'),
('ARCHIVE_FREE_STORAGE_GB',     '5',  N'Dung lượng Archive miễn phí / khách hàng');

-- =====================================================================
-- 2. SEED NGƯỜI DÙNG & PHÂN QUYỀN (Tất cả dữ liệu từ Backend & Frontend)
-- =====================================================================
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (user_id, user_code, email, phone, password_hash, full_name, avatar_url, address_text, bio, status, email_verified, locked_reason, locked_by, locked_at) VALUES
(1,  'usr-000',     N'admin@minilab.vn',       '0900000000', 'password123', N'Quản trị viên Hệ thống (System Admin)', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Văn phòng MiniLab HQ, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(2,  'usr-000b',    N'admin.tuan@minilab.vn',  '0900000001', 'password123', N'Lê Tuấn (Tổng Quản Trị MiniLab)',       'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Văn phòng MiniLab HQ, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(3,  'usr-002',     N'croplab@minilab.vn',     '0987654321', 'password123', N'CropLab Hà Nội (Lab Quản Trị)',         'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(4,  'usr-002b',    N'saigon.lab@minilab.vn',  '0987654322', 'password123', N'LLab Film Sài Gòn (Lab Manager)',       'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'40/2 Phan Văn Trị, Phường 12, Bình Thạnh, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(5,  'usr-001',     N'khachhang@minilab.vn',   '0912345678', 'password123', N'Nguyễn Hoàng Anh',                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'123 Phố Huế, Hai Bà Trưng, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(6,  'usr-003',     N'chuyengia@film.vn',      '0909123456', 'password123', N'Lê Quang Huy',                          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', N'Tây Hồ, Hà Nội', N'Nhiếp ảnh gia phim tài liệu với 12 năm kinh nghiệm chụp medium format và tráng film thủ công.', 'ACTIVE', 1, NULL, NULL, NULL),
(7,  'usr-005',     N'contact@nadarlab.com',   '0918776655', 'password123', N'Nadar Darkroom & Lab Owner',            'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=200', N'15 Tràng Tiền, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(8,  'usr-008',     N'trong.tran@minilab.vn',  '0999888777', 'password123', N'Trần Đình Trọng',                     'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Hà Nội', NULL, 'LOCKED', 1, N'Phát tán link spam tài chính cá độ trái phép trên cộng đồng', 1, '2026-03-02T11:00:00'),
(9,  'usr-901',     N'retro.hanoi@gmail.com',  '0945667788', 'password123', N'Phạm Gia Huy',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Số 22 ngõ Huyện, Hàng Trống, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(10, 'usr-902',     N'analog.saigon@gmail.com','0919334455', 'password123', N'Võ Thành Nam',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'88 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(11, 'ADM-HN-884',  N'tuan.vu@minilab.vn',     '0988776655', 'password123', N'Vũ Minh Tuấn',                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(12, 'USR-DN-099',  N'bach.hoang@gmail.com',   '0977123123', 'password123', N'Hoàng Văn Bách',                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Đà Nẵng', NULL, 'LOCKED', 1, N'Vi phạm chính sách thanh lý thiết bị & lừa đảo đặt cọc', 1, '2026-02-20T10:00:00'),
(13, 'APP-EXP-301', N'khoa.nguyen@photo.vn',   '0903445566', 'password123', N'Nguyễn Trọng Khoa',                     'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', N'Quận 3, TP.HCM', N'12 năm chụp ảnh tạp chí thời trang bằng máy Medium Format Hasselblad 500C/M. Đã xuất bản 2 photobook cá nhân.', 'ACTIVE', 1, NULL, NULL, NULL),
(14, 'usr-014',     N'nam.le@gmail.com',       '0913222333', 'password123', N'Lê Hoàng Nam',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Quận 1, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(15, 'usr-015',     N'thutrang.pham@gmail.com','0914333444', 'password123', N'Phạm Thu Trang',                         'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Đống Đa, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(16, 'usr-016',     N'khoi.pham@gmail.com',    '0915444555', 'password123', N'Phạm Hoàng Khôi',                       'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Cầu Giấy, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(17, 'usr-017',     N'nghia.do@gmail.com',     '0977889900', 'password123', N'Đỗ Hữu Nghĩa',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Đống Đa, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(18, 'usr-018',     N'songhan.lab@minilab.vn', '0905112233', 'password123', N'Sông Hàn Film Studio Owner',            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Hải Châu, Đà Nẵng', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(19, 'usr-019',     N'tayho.lab@minilab.vn',   '0904223344', 'password123', N'Tây Hồ Analog Master Owner',            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Tây Hồ, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(20, 'usr-020',     N'cholon.lab@minilab.vn',  '0908334455', 'password123', N'Chợ Lớn Film Lab Owner',                'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Quận 5, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL);
SET IDENTITY_INSERT Users OFF;

INSERT INTO User_Roles (user_id, role_id) VALUES
(1, 5),  -- usr-000: ADMIN
(2, 5),  -- usr-000b: ADMIN
(3, 2),  -- usr-002: LAB_OWNER
(4, 2),  -- usr-002b: LAB_OWNER
(5, 1),  -- usr-001: CUSTOMER
(6, 3),  -- usr-003: EXPERT
(6, 1),  -- usr-003: CUSTOMER
(7, 2),  -- usr-005: LAB_OWNER
(8, 1),  -- usr-008: CUSTOMER
(9, 2),  -- usr-901: LAB_OWNER
(10, 2), -- usr-902: LAB_OWNER
(11, 5), -- ADM-HN-884: ADMIN
(12, 1), -- USR-DN-099: CUSTOMER
(13, 3), -- APP-EXP-301: EXPERT
(13, 1), -- APP-EXP-301: CUSTOMER
(14, 1), -- usr-014: CUSTOMER
(15, 1), -- usr-015: CUSTOMER
(16, 1), -- usr-016: CUSTOMER
(17, 1), -- usr-017: CUSTOMER
(18, 2), -- usr-018: LAB_OWNER
(19, 2), -- usr-019: LAB_OWNER
(20, 2); -- usr-020: LAB_OWNER

INSERT INTO Expert_Profile (user_id, bio, specialties, portfolio_url, years_experience, verification_status, verified_by) VALUES
(6,  N'Nhiếp ảnh gia phim tài liệu với 12 năm kinh nghiệm chụp medium format và tráng film thủ công.', N'Medium Format, B&W Darkroom', 'https://behance.net/quanghuy-analog', 12, 'VERIFIED', 1),
(13, N'12 năm chụp ảnh tạp chí thời trang bằng máy Medium Format Hasselblad 500C/M. Đã xuất bản 2 photobook cá nhân.', N'Chân dung ánh sáng tự nhiên, Phim dương bản Slide (E-6), Phóng ảnh phòng tối truyền thống', 'https://behance.net/khoa-analog-archive', 12, 'PENDING', NULL);

-- =====================================================================
-- 3. SEED FILM LABS & GÓI DỊCH VỤ
-- =====================================================================
SET IDENTITY_INSERT Lab_Profile ON;
INSERT INTO Lab_Profile (
    lab_id, lab_code, owner_id, lab_name, slug, tagline, description, phone, email,
    province, district, street_address, business_license_no, logo_url, cover_url,
    turnaround_hours, price_range, scanner_models, supported_processes, supports_pickup,
    avg_rating, review_count, approval_status, inspection_note, reviewed_by, reviewed_at
) VALUES
(1, 'lab-001', 3, N'CropLab Hà Nội', 'croplab-ha-noi',
    N'Chuyên gia tráng & scan chất lượng cao từ năm 2014',
    N'CropLab cung cấp dịch vụ tráng và scan phim màu C-41, đen trắng B&W thủ công với hóa chất chuẩn Kodak & Ilford. Scan máy Noritsu HS-1800 cho độ phân giải sắc nét và dải màu trung thực.',
    '0904567890', N'hanoi@croplab.vn', N'Hà Nội', N'Tây Hồ', N'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ, Hà Nội',
    'DKKD-0101234567', 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    12, N'45.000đ - 120.000đ', N'["Noritsu HS-1800","Fuji Frontier SP-3000"]', N'["C-41","B&W","ECN-2","E-6 Slide"]', 1,
    4.90, 328, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(2, 'lab-002', 4, N'LLab Film Sài Gòn', 'llab-film-sai-gon',
    N'Màu sắc ấm áp, tốc độ siêu nhanh trong ngày',
    N'LLab là điểm đến quen thuộc của cộng đồng film Sài Gòn với phong cách chỉnh màu Frontier tươi tắn đặc trưng và dịch vụ nhận trả film tận nơi.',
    '0938112233', N'saigon@llab.vn', N'TP.HCM', N'Bình Thạnh', N'40/2 Phan Văn Trị, Phường 12, Bình Thạnh, TP.HCM',
    'DKKD-0301234568', 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=200', 'https://images.unsplash.com/photo-1452784444945-3f422708fe5e?w=800',
    8, N'50.000đ - 110.000đ', N'["Fuji Frontier SP-3000"]', N'["C-41","B&W","ECN-2"]', 1,
    4.80, 512, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(3, 'lab-003', 7, N'Nadar Darkroom & Lab', 'nadar-darkroom-lab',
    N'Phòng tối tráng phim Fine-Art & In ấn thủ công',
    N'Chuyên dòng phim đen trắng nghệ thuật, tráng tay kiểm soát từng vùng sáng tối và scan độ phân giải cực đại TIFF 16-bit.',
    '0918776655', N'contact@nadarlab.com', N'Hà Nội', N'Hoàn Kiếm', N'15 Tràng Tiền, Hoàn Kiếm, Hà Nội',
    'DKKD-0101234569', 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=200', 'https://images.unsplash.com/photo-1471341971476-ae15ff5dd4ea?w=800',
    24, N'70.000đ - 250.000đ', N'["Hasselblad Flextight X5","Noritsu HS-1800"]', N'["B&W Thủ công","C-41 Pro","E-6"]', 1,
    5.00, 145, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(4, 'app-lab-901', 9, N'Retro Hanoi Darkroom', 'retro-hanoi-darkroom',
    N'Hồ sơ đăng ký mở tiệm Film Lab',
    N'Đã nộp đầy đủ giấy phép kinh doanh hóa chất tráng ảnh và hợp đồng xử lý chất thải môi trường.',
    '0945667788', N'retro.hanoi@gmail.com', N'Hà Nội', N'Hoàn Kiếm', N'Số 22 ngõ Huyện, Hàng Trống, Hoàn Kiếm, Hà Nội',
    'DKKD-0109923481', NULL, NULL,
    12, N'50.000đ - 100.000đ', N'["Noritsu LS-600","Epson V850 Pro"]', N'["C-41","B&W"]', 0,
    0, 0, 'PENDING', N'Đã nộp đầy đủ giấy phép kinh doanh hóa chất tráng ảnh và hợp đồng xử lý chất thải môi trường.', NULL, NULL),
(5, 'app-lab-902', 10, N'Analog Saigon Space', 'analog-saigon-space',
    N'Hồ sơ đăng ký mở tiệm Film Lab',
    N'Hồ sơ chờ xác minh máy scan thực tế và phòng tối sấy buồng kín.',
    '0919334455', N'analog.saigon@gmail.com', N'TP.HCM', N'Quận 1', N'88 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM',
    'DKKD-0318829102', NULL, NULL,
    12, N'50.000đ - 100.000đ', N'["Fuji Frontier SP-3000"]', N'["C-41","ECN-2 Cine"]', 0,
    0, 0, 'PENDING', N'Hồ sơ chờ xác minh máy scan thực tế và phòng tối sấy buồng kín.', NULL, NULL),
(6, 'lab-004', 18, N'Sông Hàn Film Studio', 'song-han-film-studio',
    N'Không gian tráng và lưu trữ ảnh film miền Trung',
    N'Phục vụ cộng đồng nhiếp ảnh film Đà Nẵng - Hội An với quy trình C-41 và ECN-2 tiêu chuẩn.',
    '0905112233', N'songhan.lab@minilab.vn', N'Đà Nẵng', N'Hải Châu', N'112 Bạch Đằng, Hải Châu, Đà Nẵng',
    'DKKD-0401122334', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=200', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    16, N'45.000đ - 95.000đ', N'["Noritsu HS-1800"]', N'["C-41","ECN-2"]', 1,
    4.70, 96, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(7, 'lab-005', 19, N'Tây Hồ Analog Master', 'tay-ho-analog-master',
    N'Chuyên trị film slide E-6 và B&W thủ công',
    N'Phòng lab ven hồ Tây chuyên xử lý các dòng phim dương bản và medium format.',
    '0904223344', N'tayho.lab@minilab.vn', N'Hà Nội', N'Tây Hồ', N'45 Quảng An, Tây Hồ, Hà Nội',
    'DKKD-0105566778', 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200', 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=800',
    18, N'55.000đ - 150.000đ', N'["Fuji Frontier SP-3000","Epson V850 Pro"]', N'["C-41","B&W","E-6"]', 1,
    4.60, 82, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(8, 'app-lab-903', 20, N'Chợ Lớn Film Lab', 'cho-lon-film-lab',
    N'Hồ sơ đăng ký mở tiệm Film Lab khu vực Quận 5',
    N'Đang chờ kiểm tra hệ thống xử lý hóa chất tráng rửa định kỳ.',
    '0908334455', N'cholon.lab@minilab.vn', N'TP.HCM', N'Quận 5', N'210 Trần Hưng Đạo, Quận 5, TP.HCM',
    'DKKD-0319988776', NULL, NULL,
    12, N'45.000đ - 100.000đ', N'["Noritsu LS-600"]', N'["C-41","B&W"]', 0,
    0, 0, 'PENDING', N'Đang chờ kiểm tra hệ thống xử lý hóa chất tráng rửa định kỳ.', NULL, NULL);
SET IDENTITY_INSERT Lab_Profile OFF;

INSERT INTO Lab_Film_Format (lab_id, format_id) VALUES
(1, 1), (1, 3), (1, 4), (1, 7),
(2, 1), (2, 3),
(3, 1), (3, 3), (3, 7), (3, 8),
(6, 1), (6, 3),
(7, 1), (7, 3);

SET IDENTITY_INSERT Service_Package ON;
INSERT INTO Service_Package (
    package_id, package_code, lab_id, service_type, name, description,
    format_id, process_type_id, scan_quality, scan_resolution, output_format,
    price, est_processing_days, estimated_hours, is_active
) VALUES
-- Lab 1: CropLab Hà Nội
(1, 'pkg-001', 1, 'DEVELOP_SCAN', N'Tráng & Scan 135 Color (C-41) - Chuẩn M',
    N'Gói tráng và scan tiêu chuẩn cho cuộn film 35mm màu phổ thông (Kodak Gold, ColorPlus, Fuji C200, UltraMax).',
    1, 1, 'STANDARD', N'M (3000x2000px)', 'JPEG', 50000, 1, 12, 1),
(2, 'pkg-002', 1, 'DEVELOP_SCAN', N'Tráng & Scan 135 Color (C-41) - Scan Cao Cấp L (TIFF/JPG)',
    N'Độ phân giải lớn nhất từ Noritsu HS-1800, lưu giữ toàn bộ chi tiết hạt grain và màu sắc chân thực.',
    1, 1, 'PRO', N'L (6000x4000px TIFF)', 'TIFF', 85000, 1, 16, 1),
(3, 'pkg-003', 1, 'DEVELOP_SCAN', N'Tráng & Scan 135 B&W (Đen Trắng Thủ Công)',
    N'Tráng với thuốc Kodak D-76 hoặc Ilford ID-11, kiểm soát độ tương phản và chi tiết vùng tối.',
    1, 3, 'STANDARD', N'M (3000x2000px)', 'JPEG', 65000, 1, 24, 1),
(4, 'pkg-004', 1, 'DEVELOP_SCAN', N'Tráng & Scan Cine Film ECN-2 (Tẩy than)',
    N'Xử lý cuộn film điện ảnh Kodak Vision3 (50D, 250D, 500T), tẩy than remjet sạch sẽ.',
    1, 4, 'STANDARD', N'M (3000x2000px)', 'JPEG', 75000, 1, 24, 1),
(5, 'pkg-005', 1, 'DEVELOP_SCAN', N'Tráng & Scan Medium Format 120 (C-41)',
    N'Dành cho máy ảnh khổ vuông 6x6, 6x7, 6x4.5 (Hasselblad, Rolleiflex, Pentax 67).',
    3, 1, 'HIGH', N'L (4800x4800px)', 'JPEG', 80000, 1, 12, 1),
-- Lab 2: LLab Film Sài Gòn
(6, 'pkg-006', 2, 'DEVELOP_SCAN', N'Gói C-41 Siêu Tốc 8 Giờ (Fuji Frontier SP-3000)',
    N'Gói tráng và scan màu chất ảnh Frontier SP-3000 ấm áp, trả file trong 8 giờ tại LLab Film Sài Gòn.',
    1, 1, 'STANDARD', N'M (3000x2000px)', 'JPEG', 60000, 1, 8, 1),
(8, 'pkg-201', 2, 'DEVELOP_SCAN', N'Gói C-41 Hi-Res Medium Format 120 (Noritsu LS-600)',
    N'Tráng máy Fuji FP-363SC và scan khổ 120 (6x6, 6x7) sắc nét độ phân giải cao.',
    3, 1, 'HIGH', N'L (4800x4800px 16-bit)', 'TIFF', 95000, 1, 12, 1),
(9, 'pkg-202', 2, 'DEVELOP_SCAN', N'Gói Cine ECN-2 Sài Gòn (Vision3 250D/500T)',
    N'Quy trình tẩy than Remjet chuẩn điện ảnh bằng hóa chất Bellini, xuất profile màu Log/Rec709.',
    1, 4, 'STANDARD', N'M (3000x2000px Log)', 'JPEG', 85000, 1, 16, 1),
(10, 'pkg-203', 2, 'DEVELOP_SCAN', N'Gói B&W Street Contrast (Kodak D-76 1:1)',
    N'Tráng đen trắng kéo sáng tương phản cao cho ảnh đường phố, scan Noritsu LS-600.',
    1, 3, 'STANDARD', N'M (3000x2000px)', 'JPEG', 75000, 1, 16, 1),
-- Lab 3: Nadar Darkroom & Lab
(7, 'pkg-007', 3, 'DEVELOP_SCAN', N'Gói B&W Thủ Công Fine-Art (Hasselblad Flextight X5)',
    N'Tráng tay phòng tối Nadar Darkroom với thuốc Microphen/Pyrocat và scan Hasselblad Flextight X5 16-bit TIFF.',
    3, 3, 'PRO', N'XL (Hasselblad X5 TIFF 16-bit)', 'TIFF', 180000, 1, 24, 1),
(11, 'pkg-301', 3, 'DEVELOP_SCAN', N'Gói Tráng Tay B&W 135 (Ilford Pyrocat / XTOL)',
    N'Kiểm soát nhiệt độ chiller 20.0°C ± 0.05°C, độ mịn hạt tối đa cho phim đen trắng 35mm.',
    1, 3, 'HIGH', N'L (4000x6000px TIFF)', 'TIFF', 110000, 1, 24, 1),
(12, 'pkg-302', 3, 'DEVELOP_SCAN', N'Gói C-41 Pro One-Shot Archival (Noritsu HS-1800)',
    N'Hóa chất Kodak Flexicolor pha mới dùng 1 lần (One-Shot) không tái sử dụng cho màu sắc chuẩn mực.',
    1, 1, 'PRO', N'L (6000x4000px 16-bit)', 'TIFF', 120000, 1, 24, 1),
(13, 'pkg-303', 3, 'DEVELOP_SCAN', N'Gói Slide Dương Bản E-6 Exhibition (Flextight X5)',
    N'Tráng quy trình 6 bước Fuji Hunt Chrome E-6 cho phim dương bản Provia/Velvia.',
    3, 2, 'PRO', N'XL (5000 DPI Master TIFF)', 'TIFF', 160000, 2, 36, 1),
(14, 'pkg-304', 3, 'DEVELOP_SCAN', N'Gói Large Format 4x5 Sheet Film (B&W / C-41)',
    N'Tráng phim tấm khổ lớn 4x5 bằng trống Jobo Expert 3010 & scan drum ảo Hasselblad X5.',
    7, 3, 'PRO', N'XL (Hasselblad X5 Drum)', 'TIFF', 195000, 2, 36, 1);
SET IDENTITY_INSERT Service_Package OFF;

-- =====================================================================
-- 4. SEED ĐƠN HÀNG, CUỘN FILM, TIẾN ĐỘ & THANH TOÁN (CÔ LẬP DỮ LIỆU THEO TỪNG LAB)
-- =====================================================================
SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders (
    order_id, order_code, customer_id, lab_id, status, kanban_column,
    receive_method, return_method, pickup_address, payment_status, payment_method,
    subtotal, total_amount, sla_deadline, created_at
) VALUES
-- Lab 1: CropLab Hà Nội (Khách: Nguyễn Hoàng Anh [5], Phạm Thu Trang [15])
(1, 'ORD-2026-8801', 5,  1, 'READY_FOR_DOWNLOAD', 'READY',      'PICKUP',      'DIGITAL_ONLY', N'123 Phố Huế, Hai Bà Trưng, Hà Nội', 'PAID', 'MOMO',          135000, 135000, '2026-03-02T12:00:00', '2026-03-01T09:30:00'),
(2, 'ORD-2026-8802', 5,  1, 'PROCESSING',         'DEVELOPING', 'DROP_AT_LAB', 'DIGITAL_ONLY', N'123 Phố Huế, Hai Bà Trưng, Hà Nội', 'PAID', 'BANK_TRANSFER', 65000,  65000,  '2026-03-03T18:00:00', '2026-03-02T14:10:00'),
(7, 'ORD-2026-8835', 15, 1, 'PROCESSING',         'SCANNING',   'DROP_AT_LAB', 'DIGITAL_ONLY', N'Đống Đa, Hà Nội',                    'PAID', 'BANK_TRANSFER', 75000,  75000,  '2026-03-02T20:00:00', '2026-03-01T15:00:00'),
(8, 'ORD-2026-8819', 15, 1, 'COMPLETED',          'READY',      'PICKUP',      'DIGITAL_ONLY', N'Đống Đa, Hà Nội',                    'PAID', 'MOMO',          170000, 170000, '2026-03-02T18:00:00', '2026-03-01T11:20:00'),
-- Lab 2: LLab Film Sài Gòn (Khách: Lê Hoàng Nam [14], Đỗ Hữu Nghĩa [17])
(3, 'ORD-2026-8803', 14, 2, 'RECEIVED',           'QUEUE',      'PICKUP',      'DIGITAL_ONLY', N'Quận 1, TP.HCM',                     'PAID', 'VNPAY',         60000,  60000,  '2026-03-03T20:00:00', '2026-03-03T08:00:00'),
(4, 'ORD-2026-8841', 14, 2, 'READY_FOR_DOWNLOAD', 'READY',      'PICKUP',      'DIGITAL_ONLY', N'Quận 1, TP.HCM',                     'PAID', 'MOMO',          120000, 120000, '2026-03-04T18:00:00', '2026-03-03T09:15:00'),
(5, 'ORD-2026-8839', 17, 2, 'PROCESSING',         'DEVELOPING', 'DROP_AT_LAB', 'DIGITAL_ONLY', N'Quận 3, TP.HCM',                     'PAID', 'VNPAY',         75000,  75000,  '2026-03-04T15:00:00', '2026-03-03T07:30:00'),
-- Lab 3: Nadar Darkroom & Lab (Khách: Lê Quang Huy [6], Phạm Hoàng Khôi [16])
(6, 'ORD-2026-8838', 6,  3, 'READY_FOR_DOWNLOAD', 'READY',      'PICKUP',      'DIGITAL_ONLY', N'Tây Hồ, Hà Nội',                    'PAID', 'MOMO',          180000, 180000, '2026-03-04T12:00:00', '2026-03-02T16:45:00'),
(9, 'ORD-2026-8845', 16, 3, 'PROCESSING',         'QC',         'DROP_AT_LAB', 'DIGITAL_ONLY', N'Cầu Giấy, Hà Nội',                  'PAID', 'BANK_TRANSFER', 160000, 160000, '2026-03-05T12:00:00', '2026-03-03T10:30:00');
SET IDENTITY_INSERT Orders OFF;

SET IDENTITY_INSERT Order_Item ON;
INSERT INTO Order_Item (
    order_item_id, item_code, order_id, package_id, film_stock_id, film_name, roll_code,
    quantity, unit_price, line_total, push_pull, cut_negatives, status
) VALUES
(1,  'item-101', 1, 1,  1, N'Kodak Portra 400',     'ROLL-PORTRA400-01', 1, 50000,  50000,  N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(2,  'item-102', 1, 2,  2, N'Fujifilm Pro 400H',    'ROLL-FUJI400-02',   1, 85000,  85000,  N'+1 Stop (Push)',           N'Để nguyên cuộn không cắt', 'DONE'),
(3,  'item-103', 2, 3,  3, N'Ilford HP5 Plus 400',  'ROLL-ILFORD-03',    1, 65000,  65000,  N'+2 Stops (Push ISO 1600)', N'Cắt 6 frames/dải',         'PROCESSING'),
(4,  'item-104', 3, 6,  4, N'Kodak Ektar 100',      'ROLL-EKTAR-04',     1, 60000,  60000,  N'Normal',                   N'Cắt 4 frames/dải',         'RECEIVED'),
(5,  'item-105', 4, 6,  5, N'Kodak Gold 200 (x2)',  'ROLL-GOLD200-05',   2, 60000,  120000, N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(6,  'item-106', 5, 10, 3, N'Ilford HP5 Plus 400',  'ROLL-ILFORD-06',    1, 75000,  75000,  N'+1 Stop (Push ISO 800)',   N'Cắt 6 frames/dải',         'PROCESSING'),
(7,  'item-107', 6, 7,  3, N'Ilford Delta 100',     'ROLL-DELTA100-07',  1, 180000, 180000, N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(8,  'item-108', 7, 4,  6, N'Kodak Vision3 500T',   'ROLL-VISION3-08',   1, 75000,  75000,  N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'PROCESSING'),
(9,  'item-109', 8, 2,  1, N'Kodak Portra 400 (x2)','ROLL-PORTRA400-09', 2, 85000,  170000, N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(10, 'item-110', 9, 13, 2, N'Fuji Provia 100F',     'ROLL-PROVIA-10',    1, 160000, 160000, N'Normal (Box speed)',       N'Để nguyên cuộn không cắt', 'PROCESSING');
SET IDENTITY_INSERT Order_Item OFF;

INSERT INTO Payment (order_id, gateway, txn_ref, amount, status, paid_at) VALUES
(1, 'MOMO',          'TXN-ORD-2026-8801', 135000, 'SUCCESS', '2026-03-01T09:30:00'),
(2, 'BANK_TRANSFER', 'TXN-ORD-2026-8802', 65000,  'SUCCESS', '2026-03-02T14:10:00'),
(3, 'VNPAY',         'TXN-ORD-2026-8803', 60000,  'SUCCESS', '2026-03-03T08:00:00'),
(4, 'MOMO',          'TXN-ORD-2026-8841', 120000, 'SUCCESS', '2026-03-03T09:15:00'),
(5, 'VNPAY',         'TXN-ORD-2026-8839', 75000,  'SUCCESS', '2026-03-03T07:30:00'),
(6, 'MOMO',          'TXN-ORD-2026-8838', 180000, 'SUCCESS', '2026-03-02T16:45:00'),
(7, 'BANK_TRANSFER', 'TXN-ORD-2026-8835', 75000,  'SUCCESS', '2026-03-01T15:00:00'),
(8, 'MOMO',          'TXN-ORD-2026-8819', 170000, 'SUCCESS', '2026-03-01T11:20:00'),
(9, 'BANK_TRANSFER', 'TXN-ORD-2026-8845', 160000, 'SUCCESS', '2026-03-03T10:30:00');

-- =====================================================================
-- 5. SEED DIGITAL FILM ARCHIVE & METADATA
-- =====================================================================
SET IDENTITY_INSERT Digital_Film_Archive ON;
INSERT INTO Digital_Film_Archive (archive_id, owner_id, order_item_id, title, film_stock_id, visibility) VALUES
(1, 5, 1, N'Mùa thu Hà Nội 2026 (ORD-2026-8801)', 1, 'PRIVATE'),
(2, 5, 9, N'Phố cổ & Cà phê sáng (ORD-2026-8819)', 1, 'PRIVATE');
SET IDENTITY_INSERT Digital_Film_Archive OFF;

SET IDENTITY_INSERT Archive_Photo ON;
INSERT INTO Archive_Photo (
    photo_id, photo_code, archive_id, roll_code, title, file_name,
    storage_key, thumbnail_key, mime_type, size_bytes, width_px, height_px, is_favorite, uploaded_at
) VALUES
(1, 'pho-001', 1, 'ROLL-PORTRA400-01', N'Nắng chiều Phố Cổ Hà Nội (ORD-2026-8801)', N'pho_001.tiff',
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=1200',
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=400',
    'image/tiff', 19293798, 6048, 4032, 1, '2026-03-01T17:15:00'),
(2, 'pho-002', 1, 'ROLL-PORTRA400-01', N'Gánh hoa bên góc đường Phan Đình Phùng (ORD-2026-8801)', N'pho_002.tiff',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
    'image/tiff', 17616076, 6048, 4032, 1, '2026-03-01T17:15:00'),
(3, 'pho-003', 2, 'ROLL-PORTRA400-09', N'Ban công phố cổ Phan Huy Chú (ORD-2026-8819)', N'pho_003.tiff',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=1200',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400',
    'image/tiff', 18454937, 6048, 4032, 1, '2026-03-01T19:00:00');
SET IDENTITY_INSERT Archive_Photo OFF;

INSERT INTO Photo_Metadata (
    photo_id, camera_brand, camera_model, lens, focal_length, film_stock_id,
    iso, aperture, shutter_speed, process_type_id, scan_device, notes
) VALUES
(1, N'Leica', N'Leica M6 Classic', N'Summicron 35mm f/2 ASPH', '35mm', 1, 400, 2.8, '1/250s', 1, N'C-41 Noritsu HS-1800', N'CropLab Hà Nội | 18.4 MB TIFF'),
(2, N'Leica', N'Leica M6 Classic', N'Summicron 35mm f/2 ASPH', '35mm', 1, 400, 4.0, '1/500s', 1, N'C-41 Noritsu HS-1800', N'CropLab Hà Nội | 16.8 MB TIFF'),
(3, N'Canon', N'Canon AE-1 Program', N'FD 50mm f/1.4',         '50mm', 1, 400, 2.8, '1/250s', 1, N'C-41 Noritsu HS-1800', N'CropLab Hà Nội | 17.6 MB TIFF');

-- =====================================================================
-- 6. SEED MARKETPLACE, CỘNG ĐỒNG, SỰ KIỆN, KHIẾU NẠI, ĐÁNH GIÁ & AUDIT LOG
-- =====================================================================
SET IDENTITY_INSERT Equipment_Listing ON;
INSERT INTO Equipment_Listing (
    listing_id, listing_code, seller_id, category_id, listing_type, title, description,
    item_condition, condition_note, price, location_text, contact_phone, contact_zalo, status, reviewed_by, created_at
) VALUES
(1, 'mkt-001', 5, 2, 'SELL', N'Máy ảnh Film Canon QL17 GIII (Black Limited Edition)',
    N'Cần nhượng lại Canon QL17 GIII bản đen hiếm. Kính trong vắt, không mốc xước, đo sáng nhạy chuẩn pin PX625 adapter.',
    'LIKE_NEW', N'98% Sưu tầm, cơ tốc đo sáng hoàn hảo', 4800000, N'Hoàn Kiếm, Hà Nội', '0912345678', '0912345678', 'ACTIVE', 1, '2026-02-28T10:00:00'),
(2, 'mkt-002', 5, 3, 'SELL', N'Bộ máy ảnh Olympus OM-1 + Lens Zuiko 50mm f/1.4',
    N'Huyền thoại cơ khí OM-1 màn trập lụa êm ái. Chờ Admin kiểm duyệt tiền kiểm 100%.',
    'GOOD', N'95% Nguyên bản, view sáng rõ', 3600000, N'Hai Bà Trưng, Hà Nội', '0912345678', '0912345678', 'PENDING_REVIEW', NULL, '2026-03-02T15:30:00'),
(3, 'MKT-POST-902', 5, 2, 'SELL', N'Máy ảnh Leica M6 Classic Chrome 0.72x (Bản Wetzlar 1986)',
    N'Máy hoạt động hoàn hảo mọi tốc độ, đo sáng LED chuẩn xác, buồng phim sạch sẽ không lọt sáng. Đi kèm dây đeo da thủ công và nắp body zin.',
    'LIKE_NEW', N'Mint 98% - Đo sáng hoạt động hoàn hảo', 58500000, N'Hoàn Kiếm, Hà Nội', '0912345678', '0912345678', 'PENDING_REVIEW', NULL, '2026-03-03T10:15:00'),
(4, 'MKT-POST-903', 5, 2, 'SELL', N'Canon Canonet QL17 GIII 40mm f/1.7 (Rangefinder Nhật)',
    N'Dòng máy rangefinder quốc dân cho người mới chơi film. Đã CLA lau dầu chỉnh nét tại thợ uy tín, về chỉ việc lắp film chụp.',
    'GOOD', N'Khá 90% - Kính trong, cơ tốc chuẩn', 3800000, N'Đống Đa, Hà Nội', '0912345678', '0912345678', 'PENDING_REVIEW', NULL, '2026-03-03T11:00:00');
SET IDENTITY_INSERT Equipment_Listing OFF;

INSERT INTO Listing_Image (listing_id, image_url, sort_order) VALUES
(1, 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800', 0),
(2, 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800', 0),
(3, 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800', 0),
(4, 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=800', 0);

SET IDENTITY_INSERT Post_Article ON;
INSERT INTO Post_Article (
    post_id, post_code, author_id, post_category_id, post_type, title, slug, content,
    likes_count, comments_count, report_count, report_reason, status, moderated_by, moderated_at, published_at, created_at
) VALUES
(1, 'post-001', 6, 1, 'TUTORIAL', N'Bí quyết chọn điểm đo sáng khi chụp phim âm bản màu (Color Negative)',
    'bi-quyet-chon-diem-do-sang-color-negative',
    N'Phim âm bản màu như Kodak Portra hay Fuji Superia có khả năng giữ chi tiết vùng sáng cực tốt nhưng lại rất sợ thiếu sáng vùng tối (shadow). Hãy luôn đo sáng vào vùng tối và bù sáng +1 stop...',
    89, 14, 0, NULL, 'ACTIVE', 1, '2026-03-01T10:00:00', '2026-03-01T10:00:00', '2026-03-01T10:00:00'),
(2, 'post-002', 8, 6, 'ARTICLE', N'Rao bán hàng cấm và link spam tài chính cá độ',
    'rao-ban-hang-cam-spam',
    N'Click vào link nhận tiền thưởng ngay...',
    0, 0, 5, N'Spam quảng cáo sai quy định cộng đồng', 'REPORTED', NULL, NULL, NULL, '2026-03-02T11:00:00'),
(3, 'REP-COM-104', 12, 6, 'ARTICLE', N'Thanh lý lô máy ảnh phim giá siêu rẻ chuyển khoản cọc trước 50%',
    'thanh-ly-lo-may-anh-phim-gia-sieu-re',
    N'Mình có lô Leica M6 và Contax T2 giá chỉ 2 triệu/máy, ai mua inbox chuyển khoản cọc trước mình giữ hàng nhé, không nhận COD hay giao dịch trực tiếp...',
    0, 0, 7, N'Nghi vấn lừa đảo đặt cọc (Scam) & Spam link ngoài', 'REPORTED', NULL, NULL, NULL, '2026-03-03T08:30:00'),
(4, 'REP-COM-105', 17, 4, 'REVIEW', N'Bóc phốt lab X làm cháy cuộn phim kỷ niệm không đền bù thỏa đáng',
    'boc-phot-lab-x-lam-chay-cuon-phim',
    N'Bài viết sử dụng nhiều từ ngữ bức xúc khi chưa có kết luận kiểm tra kỹ thuật từ bộ phận phân xử của nền tảng.',
    2, 5, 3, N'Ngôn từ công kích chưa rõ bằng chứng đối soát', 'REPORTED', NULL, NULL, NULL, '2026-03-03T09:45:00');
SET IDENTITY_INSERT Post_Article OFF;

SET IDENTITY_INSERT Event ON;
INSERT INTO Event (
    event_id, event_code, host_id, event_type, title, description, venue,
    cover_image_url, start_at, end_at, capacity, fee, status
) VALUES
(1, 'evt-001', 6, 'PHOTOWALK', N'Photowalk Mùa Hoa Sưa - Dạo Phố Cùng Máy Cơ',
    N'Buổi giao lưu chụp ảnh đường phố đầu xuân, hướng dẫn đo sáng bằng mắt (Sunny 16) và bố cục đời thường.',
    N'Quanh Hồ Gươm & Phố Cổ Hà Nội',
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
    '2026-03-15T07:30:00', '2026-03-15T11:30:00', 30, 0, 'OPEN'),
(2, 'evt-002', 6, 'WORKSHOP', N'Workshop Phòng Tối: Tự Tay Tráng Cuộn Phim Đen Trắng Đầu Tiên',
    N'Trải nghiệm quy trình pha thuốc Ilford ID-11, cuốn film vào tank trong túi tối và kiểm soát thời gian tráng chuẩn xác tại Nadar Darkroom.',
    N'Nadar Darkroom - 15 Tràng Tiền, Hoàn Kiếm, Hà Nội',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    '2026-03-22T14:00:00', '2026-03-22T17:30:00', 12, 250000, 'OPEN');
SET IDENTITY_INSERT Event OFF;

INSERT INTO Event_Registration (event_id, user_id, status) VALUES
(1, 5,  'REGISTERED'),
(1, 14, 'REGISTERED'),
(1, 15, 'REGISTERED'),
(2, 5,  'REGISTERED'),
(2, 16, 'REGISTERED');

SET IDENTITY_INSERT Dispute_Complaint ON;
INSERT INTO Dispute_Complaint (
    dispute_id, dispute_code, order_id, complainant_id, reason_type, issue_title,
    description, requested_amount, status, assigned_admin_id, created_at, escalated_at
) VALUES
(1, 'DSP-2026-001', 1, 5, 'QUALITY', N'Trầy xước phim / Lỗi scan màu (Đơn ORD-2026-8801)',
    N'Cuộn Portra 400 có 2 khung hình bị vệt xước dọc, muốn thương lượng scan lại độ phân giải TIFF hoặc hoàn phí tráng 50k.',
    50000, 'NEGOTIATING', NULL, '2026-03-02T14:00:00', NULL),
(2, 'DSP-2026-002', 8, 5, 'DAMAGED_FILM', N'Lọt sáng / Cháy film cuộn Kodak Portra 400 (Đơn ORD-2026-8819)',
    N'Khách hàng Nguyễn Hoàng Anh phản ánh cuộn phim số 2 trong đơn ORD-2026-8819 có vệt hóa chất loang lổ, đề nghị Lab và Admin đối soát.',
    170000, 'ESCALATED', 1, '2026-03-02T16:30:00', '2026-03-03T09:00:00');
SET IDENTITY_INSERT Dispute_Complaint OFF;

INSERT INTO Dispute_Message (dispute_id, sender_id, content, created_at) VALUES
(1, 5, N'Chào CropLab, khung hình số 12 và 13 của đơn ORD-2026-8801 bị vệt bụi dài ở góc phải.', '2026-03-02T14:05:00'),
(1, 3, N'Dạ CropLab chào bạn Hoàng Anh! Bên mình sẽ đưa dải phim vào máy thổi khí ion và scan lại miễn phí ngay trong chiều nay nhé!', '2026-03-02T14:30:00'),
(2, 5, N'Mình gửi 2 cuộn Portra 400 đơn ORD-2026-8819 nhưng cuộn số 2 bị vệt loang hóa chất.', '2026-03-02T16:35:00'),
(2, 3, N'Bên CropLab đã kiểm tra dải âm bản, mép phim có dấu hiệu lọt sáng từ buồng máy trước khi tráng, nhờ Admin phân xử.', '2026-03-02T17:10:00');

INSERT INTO Dispute_Evidence (dispute_id, uploaded_by, file_url, mime_type, uploaded_at) VALUES
(1, 5, 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600', 'image/jpeg', '2026-03-02T14:06:00'),
(2, 5, 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=600', 'image/jpeg', '2026-03-02T16:36:00');

SET IDENTITY_INSERT Review ON;
INSERT INTO Review (review_id, review_code, reviewer_id, review_type, order_id, service_name, rating, comment, status, created_at) VALUES
(1, 'rev-001', 5, 'LAB', 1, N'Tráng & Scan 135 Color C-41', 5, N'CropLab làm cực nhanh! Màu Noritsu chuẩn không cần chỉnh.', 'VISIBLE', '2026-02-28T10:00:00');
SET IDENTITY_INSERT Review OFF;

INSERT INTO Audit_Log (user_id, action, entity_name, entity_id, old_value, new_value, ip_address, created_at) VALUES
(1, 'APPROVE_LAB',     'Lab_Profile',       'lab-003',      '{"status":"PENDING"}',                   '{"status":"APPROVED","note":"Đủ giấy phép kinh doanh & hệ thống xử lý hóa chất C-41"}', '113.190.232.14', '2026-03-01T14:22:10'),
(2, 'RESOLVE_DISPUTE', 'Dispute_Complaint', 'DSP-2026-001', '{"status":"ESCALATED"}',                 '{"status":"REFUNDED","refund_amount":150000}',                                          '113.190.232.14', '2026-03-01T11:05:44'),
(1, 'LOCK_USER',       'Users',             'USR-DN-099',   '{"status":"ACTIVE","warnings":3}',       '{"status":"LOCKED","reason":"Spam link lừa đảo trên Marketplace"}',                      '14.162.145.88',  '2026-02-28T19:40:00'),
(2, 'UPDATE_CONFIG',   'System_Config',     'SLA_CONFIG',   '{"sla_negotiation_hours":48}',           '{"sla_negotiation_hours":72}',                                                          '113.190.232.14', '2026-02-27T09:15:00'),
(3, 'UPDATE_PRICE',    'Service_Package',   'pkg-002',      '{"price":80000,"package":"Scan Pro L"}', '{"price":85000,"reason":"Điều chỉnh theo giá hóa chất Kodak Flexicolor"}',               '27.72.100.12',   '2026-02-26T16:20:00'),
(3, 'UPDATE_SLA',      'Service_Package',   'pkg-003',      '{"estimated_hours":36}',                 '{"estimated_hours":24,"reason":"Tối ưu quy trình tráng tay B&W"}',                       '27.72.100.12',   '2026-02-18T10:05:00');

-- Giữ số liệu thống kê hiển thị ban đầu cho các Film Lab đã duyệt
UPDATE Lab_Profile SET avg_rating = 4.90, review_count = 328 WHERE lab_id = 1;
UPDATE Lab_Profile SET avg_rating = 4.80, review_count = 512 WHERE lab_id = 2;
UPDATE Lab_Profile SET avg_rating = 5.00, review_count = 145 WHERE lab_id = 3;
UPDATE Lab_Profile SET avg_rating = 4.70, review_count = 96  WHERE lab_id = 6;
UPDATE Lab_Profile SET avg_rating = 4.60, review_count = 82  WHERE lab_id = 7;
GO
