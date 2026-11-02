# MiniLab Web Portal (Flutter Web)

Giao diện quản lý vận hành phòng tráng & quét phim MiniLab (Film Lab Management Web Portal) được phát triển hoàn toàn bằng **Flutter Web**, tuân thủ hệ thống thiết kế **Warm Paper Lab Design System** và bám sát toàn diện 8 màn hình thiết kế từ tệp HTML gốc.

## 📁 Cấu trúc thư mục Flutter

```
frontend_flutter/
├── pubspec.yaml                 # Cấu hình dự án & thư viện dependencies
├── web/
│   └── index.html               # Entrypoint HTML cho Flutter Web
└── lib/
    ├── main.dart                # Điểm khởi chạy ứng dụng & điều hướng Shell
    ├── constants/
    │   └── theme.dart           # Bảng màu Warm Paper (#8A3A03, #446557, #FFF8F3) & typography
    ├── models/
    │   └── models.dart          # Data models: User, Order, QCBatch, Service, Profile, Dispute, SLA
    ├── services/
    │   └── api_service.dart     # Service kết nối HTTP RESTful API đến Node.js Backend (port 3000)
    ├── widgets/
    │   ├── lab_sidebar.dart     # Thanh điều hướng bên trái (Navigation Drawer) 6 phân hệ chuẩn
    │   └── lab_header.dart      # Thanh Header trên cùng (Chi nhánh, tìm kiếm, thông tin ca trực)
    └── screens/
        ├── screen_01_lab_register.dart       # WEB-LAB-01: Đăng ký thẩm định mở tiệm Film Lab (4 bước)
        ├── screen_02_lab_login.dart          # WEB-LAB-02: Đăng nhập trạm kỹ thuật viên Film Lab
        ├── screen_03_kanban_board.dart       # WEB-LAB-03: Bảng Kanban tiếp nhận & vận hành (5 công đoạn)
        ├── screen_04_scan_qc.dart            # WEB-LAB-04: Tải file scan & kiểm định QC (Lưới 72 frames)
        ├── screen_05_services_pricing.dart   # WEB-LAB-05: Danh mục dịch vụ, bảng giá & lịch sử đổi giá
        ├── screen_06_public_profile.dart     # WEB-LAB-06: Cấu hình hồ sơ tiệm lab công khai & xem trước app
        ├── screen_07_disputes.dart           # WEB-LAB-07: Xử lý khiếu nại & thương lượng đền bù tự chủ
        └── screen_08_sla_reports.dart        # WEB-LAB-08: Báo cáo hiệu suất vận hành & đo lường SLA
```

## 🚀 Hướng dẫn chạy Flutter Web

### Yêu cầu:
- Flutter SDK (>= 3.0.0)

### Các bước chạy:
```bash
cd frontend_flutter

# 1. Cài đặt các gói thư viện
flutter pub get

# 2. Khởi chạy ứng dụng trên trình duyệt Chrome
flutter run -d chrome

# Hoặc build bản web production:
flutter build web
```

---

## 🔗 Liên kết với Backend Node.js
- Ứng dụng tự động kết nối đến Node.js REST API tại địa chỉ: `http://localhost:3000/api`
- Khi backend hoạt động, toàn bộ dữ liệu (trạng thái Kanban, tải file QC, đổi giá, thương lượng khiếu nại, hồ sơ tiệm) sẽ được đồng bộ trực tiếp.
- Khi backend offline, ứng dụng có cơ chế tự động nạp Mock Data dự phòng để đảm bảo trải nghiệm người dùng liền mạch.

