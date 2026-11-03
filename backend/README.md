# MiniLab Backend API Server

Backend REST API phục vụ nền tảng MiniLab kết nối cộng đồng nhiếp ảnh phim và các Film Lab.

## Đặc điểm nổi bật
- **Công nghệ:** Node.js (Express), JWT Authentication, Multer File Storage, CORS.
- **Tuân thủ yêu cầu:** Chưa gọi các API bên ngoài (VNPay/MoMo gateway thật, Ahamove/Lalamove thật, FCM, SMTP thật). Mọi giao dịch thanh toán, sinh mã vận đơn, tạo mã OTP (mặc định `8888`) và quy trình xử lý đều được thực hiện mô phỏng nội bộ tự động (Self-contained Internal Simulation).
- **Hỗ trợ CSDL:** Sẵn sàng 44 bảng chuẩn 3NF từ thiết kế Week 2 (SQL Server DDL), tích hợp sẵn In-Memory Datastore phong phú để chạy demo ngay lập tức không cần cài đặt SQL Server.

## Hướng dẫn cài đặt & khởi động

### 1. Cài đặt thư viện
```bash
cd backend
npm install
```

### 2. Khởi chạy Server
```bash
npm start
# hoặc
node server.js
```

Server sẽ lắng nghe tại: `http://localhost:5000`

### 3. Kiểm tra trạng thái API
- **Health Check:** `GET http://localhost:5000/api/health`
- **Danh sách Lab:** `GET http://localhost:5000/api/labs`
- **Danh sách Đơn hàng:** `GET http://localhost:5000/api/orders`
- **Kho ảnh số cá nhân (Archive):** `GET http://localhost:5000/api/archive/photos`
- **Sàn thiết bị:** `GET http://localhost:5000/api/marketplace/listings`
- **Cộng đồng & Diễn đàn:** `GET http://localhost:5000/api/community/posts`
- **Sự kiện Photowalk:** `GET http://localhost:5000/api/community/events`

### 4. Tài khoản kiểm thử có sẵn
- **Khách hàng:** `khachhang@minilab.vn` / mật khẩu: `password123`
- **Chủ Film Lab (CropLab):** `labowner@croplab.vn` / mật khẩu: `password123`
- **Chuyên gia nhiếp ảnh:** `chuyengia@film.vn` / mật khẩu: `password123`
- **Mã OTP mô phỏng khi đăng ký mới:** `8888`

