USE FilmLabPlatform_Test;
GO
INSERT INTO Roles (role_id, role_code, role_name, description) VALUES
(1, 'CUSTOMER',         N'Khách hàng / Nhiếp ảnh gia', N'Đặt dịch vụ, quản lý Archive, mua bán thiết bị'),
(2, 'LAB_OWNER',        N'Chủ Film Lab',               N'Quản lý dịch vụ, đơn hàng, upload file scan'),
(3, 'EXPERT',           N'Chuyên gia nhiếp ảnh',       N'Đăng bài, tổ chức workshop/photowalk'),
(4, 'DELIVERY_PARTNER', N'Đối tác vận chuyển',         N'Nhận đơn pickup, giao nhận film'),
(5, 'ADMIN',            N'Quản trị hệ thống',          N'Duyệt lab, kiểm duyệt, xử lý khiếu nại');

INSERT INTO Film_Format (name) VALUES ('35mm'),('120'),('110'),('APS'),('4x5'),('8x10');

INSERT INTO Process_Type (code, name) VALUES
('C41',  N'C-41 (Phim màu âm bản)'),
('E6',   N'E-6 (Phim slide)'),
('BW',   N'Đen trắng (B&W)'),
('ECN2', N'ECN-2 (Phim điện ảnh)'),
('XPRO', N'Cross-process');

INSERT INTO Equipment_Category (parent_id, name) VALUES
(NULL, N'Máy ảnh film'), (NULL, N'Ống kính'), (NULL, N'Film (phim)'),
(NULL, N'Phụ kiện'),     (NULL, N'Thiết bị phòng tối / Scanner');

INSERT INTO Post_Category (name, slug) VALUES
(N'Hướng dẫn kỹ thuật', 'huong-dan-ky-thuat'),
(N'Review thiết bị',    'review-thiet-bi'),
(N'Review Film Lab',    'review-film-lab'),
(N'Hỏi đáp cộng đồng',  'hoi-dap');

INSERT INTO System_Config (config_key, config_value, description) VALUES
('PLATFORM_FEE_PERCENT',        '5',  N'Phí nền tảng thu trên mỗi đơn (%)'),
('NEGOTIATION_DEADLINE_DAYS',   '3',  N'Số ngày Khách & Lab tự thương lượng trước khi chuyển Admin'),
('LISTING_EXPIRE_DAYS',         '30', N'Số ngày tin Marketplace tự hết hạn'),
('PAYMENT_TIMEOUT_MINUTES',     '15', N'Thời gian chờ thanh toán trước khi tự hủy đơn'),
('ARCHIVE_FREE_STORAGE_GB',     '5',  N'Dung lượng Archive miễn phí / khách hàng');
