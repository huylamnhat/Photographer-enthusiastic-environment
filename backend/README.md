# Web Lab Internal Backend & API Service

Phân hệ quản trị vận hành nội bộ dành cho Film Lab (MiniLab), tuân thủ đặc tả tại `doc/week 1/film-lab-workflow.md` và `doc/week2-state-sequence.md`.

## 1. Cài đặt và Chạy

```bash
cd backend
npm install
npm start
```

Server sẽ lắng nghe tại `http://localhost:5000`. Khi truy cập trực tiếp URL này trên trình duyệt, hệ thống sẽ tự động phục vụ giao diện Web Lab Portal từ thư mục `frontend/`.

## 2. Danh sách API nội bộ

### Hồ sơ Lab (Lab Profile)
- `GET /api/lab/profile`: Lấy thông tin hồ sơ tiệm Lab, chính sách SLA và lưu trữ âm bản/file scan.
- `PUT /api/lab/profile`: Cập nhật hồ sơ tiệm (Yêu cầu quyền Lab Owner).

### Quản lý Dịch vụ & Ghi log đổi giá
- `GET /api/lab/services`: Danh sách gói dịch vụ (lọc `status=ACTIVE|PAUSED`, `process=C-41|B&W|...`).
- `GET /api/lab/services/:id`: Chi tiết gói dịch vụ.
- `POST /api/lab/services`: Thêm mới gói dịch vụ.
- `PUT /api/lab/services/:id`: Chỉnh sửa gói dịch vụ. **Bắt buộc nhập trường `reason` nếu thay đổi giá để lưu vào Audit Trail**.
- `PATCH /api/lab/services/:id/toggle-pause`: Tạm ngưng (`PAUSED`) hoặc kích hoạt lại gói dịch vụ, bảo lưu toàn bộ dữ liệu và đơn cũ.
- `GET /api/lab/services/:id/price-logs`: Xem lịch sử kiểm toán thay đổi giá (Audit Trail).

### Quản lý Đơn hàng & Vòng đời cuộn film
- `GET /api/lab/orders`: Danh sách đơn hàng (hỗ trợ query `status`, `search`).
- `GET /api/lab/orders/:id`: Chi tiết đơn hàng kèm Price Snapshotting nguyên vẹn của từng cuộn film.
- `PATCH /api/lab/orders/:id/status`: Cập nhật trạng thái tổng đơn (`PROCESSING`, `SCANS_UPLOADED`, `READY_FOR_PICKUP`, `CLOSED`...).
- `PATCH /api/lab/orders/:orderId/rolls/:rollId/process`: Cập nhật công đoạn cuộn (`RECEIVED` -> `DEVELOPING` -> `SCANNING` -> `SCANS_UPLOADED`).
- `PATCH /api/lab/orders/:orderId/rolls/:rollId/bin-code`: Gán vị trí khay lưu trữ âm bản vật lý (`binCode`, `expiryDays`).
- `PATCH /api/lab/orders/:orderId/rolls/:rollId/blank-film`: Đánh dấu cuộn phim trắng (`BLANK_FILM`), ảnh bằng chứng và lý do hoàn phí scan/in.

### Quản lý File Scan trả khách
- `POST /api/lab/orders/:orderId/rolls/:rollId/scan-metadata`: Lưu metadata file scan (`fileName`, `fileSizeMb`, `totalFrames`, `resolution`, `scannerModel`).
- `POST /api/lab/orders/:orderId/rolls/:rollId/revoke-scan`: Thu hồi & Ghi đè file scan trong 24 giờ kèm lý do và ghi nhận audit.
