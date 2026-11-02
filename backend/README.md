# MiniLab Backend API & Web Portal

Hệ thống máy chủ dịch vụ (Backend) và cổng quản trị vận hành phòng tối (Web Lab Portal) phục vụ đồ án MiniLab - Hệ sinh thái kết nối cộng đồng nhiếp ảnh phim và các Film Lab.

## 🚀 Khởi chạy nhanh

### 1. Cài đặt thư viện (nếu chưa có)
```bash
cd backend
npm install
```

### 2. Khởi động máy chủ
```bash
npm start
# hoặc
node server.js
```

Máy chủ sẽ chạy tại:
- **Base URL:** `http://localhost:3000`
- **RESTful API:** `http://localhost:3000/api`
- **Web Lab Portal:** `http://localhost:3000/web_lab_02.html`

---

## 📡 Danh sách REST API Endpoints

### 1. Định danh & Xác thực (Auth & KYC)
- `POST /api/auth/register-lab`: Đăng ký mở tiệm Film Lab mới (Hồ sơ 4 bước: Cơ sở, CCCD, Máy móc & Hóa chất, Hiện trường).
- `POST /api/auth/login`: Đăng nhập Kỹ thuật viên / Chủ Lab theo chi nhánh.
- `GET /api/auth/me`: Lấy thông tin phiên làm việc và trạng thái ca trực hiện tại.

### 2. Quản lý Đơn hàng & Kanban Vận hành (Orders & Kanban)
- `GET /api/orders/kanban`: Lấy danh sách cuộn phim theo 5 công đoạn (Tiếp nhận, Chờ tráng, Đang tráng, Đang scan, QC).
- `GET /api/orders/:id`: Lấy chi tiết đơn hàng và lô file scan.
- `PUT /api/orders/:id/stage`: Cập nhật chuyển tiếp công đoạn xử lý cuộn phim.
- `POST /api/orders/scan-barcode`: Tiếp nhận cuộn phim mới tại quầy hoặc buồng tối qua máy quét barcode.

### 3. Tải File Scan & Kiểm định QC (Scan & QC)
- `GET /api/scans/:orderId`: Lấy dữ liệu lô file scan gồm 72 khung hình (frames) và thống kê lỗi.
- `PUT /api/scans/:orderId/frames/:frameId/qc`: Cập nhật trạng thái kiểm định frame (Đạt / Gắn cờ lỗi xước, bụi quang học, sai màu).
- `POST /api/scans/:orderId/release`: Phê duyệt kiểm định, ký số hoàn tất và nạp file gốc vào **Digital Film Archive** của khách hàng.

### 4. Danh mục Dịch vụ & Bảng giá (Services & Pricing)
- `GET /api/services`: Danh mục các gói dịch vụ niêm yết (C-41, B&W, ECN-2, Slide E-6).
- `POST /api/services`: Tạo gói dịch vụ mới niêm yết.
- `PUT /api/services/:id`: Điều chỉnh giá dịch vụ (tự động ghi log vào nhật ký kiểm toán).
- `PATCH /api/services/:id/toggle`: Tạm ngừng (PAUSED) hoặc kích hoạt lại (ACTIVE) dịch vụ.
- `GET /api/services/price-history`: Xem nhật ký kiểm toán biến động giá (Audit Trail).

### 5. Hồ sơ Tiệm Lab Công khai (Lab Profile)
- `GET /api/lab/profile`: Lấy thông tin công khai của tiệm (Bio, cơ sở vật chất, giờ mở cửa, vị trí dropbox 24/7).
- `PUT /api/lab/profile`: Cập nhật thông tin tiệm và đồng bộ thời gian thực đến app khách.

### 6. Xử lý Khiếu nại & Thương lượng (Disputes)
- `GET /api/disputes`: Danh sách các ca khiếu nại đang thương lượng.
- `GET /api/disputes/:id`: Chi tiết bằng chứng và luồng hội thoại thương lượng.
- `POST /api/disputes/:id/message`: Lab gửi tin nhắn phản hồi / đề xuất đền bù cho khách hàng.
- `POST /api/disputes/:id/settle`: Thống nhất phán quyết hòa giải, giải ngân đền bù từ Quỹ tự quản và đóng khiếu nại.

### 7. Báo cáo Hiệu suất & Đo lường SLA (SLA Reports)
- `GET /api/reports/sla`: Báo cáo tỷ lệ đúng hạn SLA, thời gian xoay vòng hóa chất trung bình và biểu đồ năng lực sản xuất 7 ngày.
- `GET /api/reports/history`: Tra cứu toàn bộ lịch sử đơn hàng đã xử lý.

