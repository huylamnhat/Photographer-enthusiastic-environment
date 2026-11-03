# MiniLab Mobile App (Flutter)

Ứng dụng di động Flutter dành cho Khách hàng & Nhiếp ảnh gia, được chuyển đổi và số hóa hoàn chỉnh từ 26 màn hình thiết kế HTML (Cụm A đến Cụm F).

## Cấu trúc chức năng đã hoàn thiện

| Phân hệ | Màn hình | Chức năng chính |
|---|---|---|
| **Cụm A: Onboarding & Định danh** | `login_screen`, `register_screen`, `forgot_password_screen` | Đăng nhập tài khoản, Đăng ký xác thực OTP tích hợp (`8888`), Khôi phục mật khẩu |
| **Cụm B: Khám phá & Đặt dịch vụ** | `home_screen`, `lab_search_screen`, `lab_detail_screen`, `create_order_screen`, `checkout_screen`, `payment_receipt_screen` | Tìm kiếm & so sánh Film Lab theo định dạng (135, 120, ECN-2 Cine, B&W), Bảng giá dịch vụ, Đặt cuộn phim tùy chọn Push/Pull, Cắt film, Thanh toán nội bộ và nhận biên lai điện tử |
| **Cụm C: Đơn hàng & Live SLA** | `order_list_screen`, `order_detail_screen`, `review_lab_screen` | Quản lý danh sách đơn hàng theo trạng thái, Live Timeline SLA 7 công đoạn tráng/scan/QC, Đánh giá chấm điểm Lab |
| **Cụm D: Digital Film Archive** | `archive_gallery_screen`, `album_detail_screen`, `photo_detail_screen` | Kho lưu trữ ảnh scan số chất lượng cao, Quản lý album, Xem thông số metadata EXIF chi tiết (Camera, Lens, Film stock, ISO, Khẩu độ, Tốc độ, Lab scanner) |
| **Cụm E: Sàn Marketplace** | `marketplace_screen`, `listing_detail_screen`, `create_listing_screen`, `my_listings_screen` | Sàn giao dịch máy ảnh analog cũ, lens, cuộn film; Đăng tin bán thiết bị mới; Liên hệ trực tiếp số điện thoại / Zalo người bán |
| **Cụm F: Cộng đồng & Sự kiện** | `community_feed_screen`, `post_detail_screen`, `create_post_screen`, `events_screen`, `profile_screen` | Bảng tin diễn đàn nhiếp ảnh phim, Thảo luận & bình luận bài viết, Đăng ký tham gia Photowalk & Workshop tự tráng film B&W, Quản lý hồ sơ cá nhân |

## Hướng dẫn chạy ứng dụng

### 1. Cài đặt các thư viện Flutter
```bash
cd flutter_app
flutter pub get
```

### 2. Khởi chạy trên trình duyệt (Web) hoặc thiết bị di động
```bash
# Chạy trên Chrome
flutter run -d chrome

# Chạy trên thiết bị di động / Emulator
flutter run
```

### 3. Cấu hình địa chỉ Backend
File cấu hình tại `lib/core/constants/api_constants.dart`:
- Chạy Web / iOS: `http://localhost:5000/api`
- Chạy Android Emulator: `http://10.0.2.2:5000/api`
*(Ứng dụng có sẵn bộ dữ liệu offline fallback, nếu chưa bật backend vẫn hiển thị giao diện mượt mà)*

