HƯỚNG DẪN TẠO DATABASE SQL SERVER & KẾT NỐI DỰ ÁN MINILAB
=========================================================

I. TẠO CƠ SỞ DỮ LIỆU TRÊN SQL SERVER (SSMS)
-------------------------------------------
Dự án cung cấp 2 bộ script chạy 1 lần (F5) trong SQL Server Management Studio (SSMS):

1. Khởi tạo CSDL chính cho dự án (`FilmLabPlatform`):
   - Mở file: `database/init_database.sql` trong SSMS.
   - Nhấn F5 một lần.
   - Kết quả: Tạo database `FilmLabPlatform` gồm đúng:
     + 44 bảng (chuẩn 3NF + mở rộng đầy đủ trường đồng bộ với Backend & Flutter App)
     + 80 khóa ngoại (Foreign Keys)
     + 3 Stored Procedures (`sp_ChangeOrderStatus`, `sp_RegisterEvent`, `sp_GetApprovedLabs`)
     + 12 Triggers kiểm tra ràng buộc nghiệp vụ R1 - R11
     + Toàn bộ dữ liệu mẫu (Seed Data) khớp 100% với ứng dụng (`usr-001`, `lab-001`, `pkg-001`, `ORD-2026-8801`, `pho-001`, `mkt-001`, `post-001`, `evt-001`, `DSP-2026-001`, `rev-001`).

2. Khởi tạo CSDL kiểm thử độc lập (`FilmLabPlatform_Test` - Issue #21):
   - Mở file: `database/run_all_TEST.sql` trong SSMS.
   - Nhấn F5 một lần để kiểm tra 44 bảng, 80 FK, 3 procedures, 12 triggers mà không ảnh hưởng DB chính.

II. KẾT NỐI BACKEND NODE.JS VỚI SQL SERVER
------------------------------------------
1. Mở terminal tại thư mục `backend` và cài đặt driver SQL Server (nếu chưa cài):
   npm install mssql

2. Chỉnh thông tin tài khoản SQL Server của bạn trong file `backend/.env`:
   DB_SERVER=localhost
   DB_PORT=1433
   DB_DATABASE=FilmLabPlatform
   DB_USER=sa
   DB_PASSWORD=YourStrong@Password123
   DB_ENCRYPT=false
   DB_TRUST_SERVER_CERT=true

3. Khởi động Backend:
   npm start
   - Khi SQL Server đang chạy: Backend tự động kết nối qua `backend/src/config/db.js` và đồng bộ dữ liệu từ `FilmLabPlatform`.
   - Kiểm tra trạng thái kết nối tại: http://localhost:5000/api/health
