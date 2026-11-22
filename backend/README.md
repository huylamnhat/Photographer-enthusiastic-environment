# MiniLab Backend API Server

Backend REST API phục vụ nền tảng MiniLab kết nối cộng đồng nhiếp ảnh phim và các Film Lab.

## Đặc điểm nổi bật
- **Công nghệ:** Node.js (Express), JWT Authentication, Multer, CORS.
- **Tích hợp thực tế:**
  - **Kho ảnh (Archive):** **Google Drive API v3 (OAuth2)** tự tạo thư mục theo từng đơn hàng và trả link chia sẻ.
  - **Thanh toán:** **VNPAY Sandbox v2.1.0** và **QR chuyển khoản** riêng của từng Film Lab (`Lab_Payment_Qr`).
  - **Vận chuyển:** **AhaMove Open API v3 (Staging)** ước tính phí, đặt tài xế lấy film và đồng bộ trạng thái.
- **CSDL & Triển khai Local Server:** Kết nối trực tiếp **SQL Server Local** (`localhost\SQLEXPRESS` -> `FilmLabPlatform`), chạy trên máy cá nhân và mở endpoint HTTPS cố định qua **Tailscale Funnel** để phục vụ Frontend trên **Netlify** và **Android APK**.

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

