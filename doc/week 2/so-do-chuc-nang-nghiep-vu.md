# Week 2 – Sơ đồ chức năng & nghiệp vụ

---

## 1. Use Case tổng quát

```mermaid
flowchart LR

    CUS(["👤 Customer"])
    EXP(["👤 Photography Expert"])
    LAB(["👤 Film Lab Owner"])
    DEL(["👤 Delivery Partner"])
    ADM(["👤 System Administrator"])

    subgraph SYS["Hệ thống Quản lý Cộng đồng & Dịch vụ Film Lab"]
        direction LR
        %% Customer
        C1(["Đăng ký/Đăng nhập"])
        C2(["Tìm kiếm & So sánh Lab"])
        C3(["Đặt dịch vụ tráng/scan"])
        C4(["Thanh toán đơn hàng"])
        C5(["Quản lý Digital Film Archive"])
        C6(["Review Film Lab"])
        C7(["Khiếu nại"])
        C8(["Đăng tin Marketplace"])
        C9(["Đăng bài viết cộng đồng"])
        %% Film Lab Owner
        L1(["Quản lý hồ sơ Lab"])
        L2(["Xác nhận đơn hàng"])
        L3(["Upload file scan lên Cloud"])
        L4(["Xem báo cáo vận hành"])
        L5(["Cập nhật công đoạn tráng/scan"])
        L6(["Cấu hình gói dịch vụ & bảng giá"])
        L7(["Thương lượng khiếu nại"])
        %% Delivery Partner
        D1(["Nhận đơn pickup"])
        D2(["Giao nhận film 2 chiều"])
        %% Photography Expert
        E1(["Đăng bài viết chuyên môn"])
        E2(["Tổ chức Workshop & Photowalk"])
        %% System Administrator
        A1(["Kiểm duyệt tiền kiểm Marketplace"])
        A2(["Duyệt hồ sơ đối tác"])
        A3(["Quản lý tài khoản"])
        A4(["Xử lý khiếu nại & Hoàn tiền"])
        A5(["Hậu kiểm bài viết"])
        A6(["Xem Dashboard"])
    end

    CUS --- C1 & C2 & C3 & C4 & C5 & C6 & C7 & C8 & C9
    LAB --- L1 & L2 & L3 & L4 & L5 & L6 & L7
    DEL --- D1 & D2
    EXP --- E1 & E2
    ADM --- A1 & A2 & A3 & A4 & A5 & A6
```

---

## 2. Use Case phân rã – Đặt & xử lý dịch vụ tráng/scan

```mermaid
flowchart LR

    CUS(["👤 Customer"])
    LAB(["👤 Film Lab Owner"])
    DEL(["👤 Delivery Partner"])

    subgraph SYS["Phân hệ Đặt & Xử lý dịch vụ Tráng/Scan"]
        direction LR
        %% Customer
        S1(["Tìm kiếm & So sánh Film Lab"])
        S1a(["Lọc theo gói dịch vụ & khổ film"])
        S2(["Đặt dịch vụ tráng/scan"])
        S2a(["Chọn khổ film & số lượng cuộn"])
        S2b(["Chọn phương thức gửi film"])
        S2c(["Chọn gói dịch vụ & độ phân giải scan"])
        S3(["Thanh toán đơn hàng"])
        S3a(["Thanh toán trực tuyến"])
        S3b(["Thanh toán COD"])
        S3c(["Thanh toán lại khi lỗi giao dịch"])
        S4(["Quản lý Digital Film Archive"])
        S4a(["Xem & Tải ảnh gốc chất lượng cao"])

        %% Film Lab Owner
        L1(["Xác nhận đơn hàng"])
        L1a(["Chụp ảnh QC khi nhận film"])
        L1b(["Đề xuất phụ phí"])
        L2(["Cập nhật công đoạn tráng/scan"])
        L2a(["Cập nhật trạng thái tiến độ"])
        L3(["Upload file scan lên Cloud"])
        L3a(["Đồng bộ Digital Film Archive"])

        %% Delivery Partner
        D1(["Nhận đơn pickup"])
        D1a(["Lấy film & giao về Lab"])
        D2(["Giao nhận film 2 chiều"])
        D2a(["Cập nhật trạng thái lấy/giao film"])
        D2b(["Xử lý giao thất bại"])
    end

    %% Actor - use case
    CUS --- S1 & S2 & S3 & S4
    LAB --- L1 & L2 & L3
    DEL --- D1 & D2

    %% Customer: quan hệ
    S1a -.->|«extend»| S1
    S2 -.->|«include»| S2a
    S2 -.->|«include»| S2b
    S2 -.->|«include»| S2c
    S2 -.->|«include»| S3
    S3a -->|kế thừa| S3
    S3b -->|kế thừa| S3
    S3c -.->|«extend»| S3
    S4 -.->|«include»| S4a

    %% Film Lab Owner: quan hệ
    L1 -.->|«include»| L1a
    L1b -.->|«extend»| L1
    L2 -.->|«include»| L2a
    L3 -.->|«include»| L3a

    %% Delivery Partner: quan hệ
    D1 -.->|«include»| D1a
    D2 -.->|«include»| D2a
    D2b -.->|«extend»| D2
```

---

## 3. Use Case phân rã – Marketplace & Quản lý thiết bị

```mermaid
flowchart LR

    CUS(["👤 Customer"])
    EXP(["👤 Photography Expert"])
    ADM(["👤 System Administrator"])

    subgraph SYS["Phân hệ Marketplace & Quản lý thiết bị"]
        direction LR
        M1(["Đăng tin Marketplace"])
        M1a(["Nhập thông tin máy & ảnh chụp thật"])
        M2(["Đăng bài viết cộng đồng"])
        M2a(["Đính kèm bộ ảnh phim & thông số"])
        M3(["Tổ chức Workshop & Photowalk"])
        M3a(["Tạo sự kiện & quản lý đăng ký"])

        K1(["Kiểm duyệt tiền kiểm Marketplace"])
        K1a(["Phê duyệt hiển thị"])
        K1b(["Từ chối tin đăng"])
        K2(["Kiểm duyệt bài viết cộng đồng"])
        K2a(["Ẩn hoặc gỡ bài viết vi phạm"])
    end

    CUS --- M1 & M2
    EXP --- M3
    ADM --- K1 & K2

    M1 -.->|«include»| M1a
    M2 -.->|«include»| M2a
    M3 -.->|«include»| M3a

    K1a -.->|«extend»| K1
    K1b -.->|«extend»| K1
    K2a -.->|«extend»| K2
```

---

## 4. Use Case phân rã – Quản trị hệ thống & Kiểm duyệt

```mermaid
flowchart LR

    ADM(["👤 System Administrator"])

    subgraph SYS["Phân hệ Quản trị hệ thống & Kiểm duyệt"]
        direction LR
        Q1(["Quản lý tài khoản"])
        Q1a(["Lọc danh sách tài khoản"])
        Q1b(["Khóa tài khoản vi phạm"])

        Q2(["Duyệt hồ sơ đối tác"])
        Q2a(["Duyệt Film Lab"])
        Q2b(["Duyệt Expert"])
        Q2c(["Duyệt Shipper"])

        Q3(["Xử lý khiếu nại & Hoàn tiền"])
        Q3a(["Đối soát chứng cứ"])
        Q3b(["Phê duyệt hoàn tiền."])
    end

    ADM --- Q1 & Q2 & Q3

    Q1 -.->|«include»| Q1a
    Q1b -.->|«extend»| Q1

    Q2a -->|kế thừa| Q2
    Q2b -->|kế thừa| Q2
    Q2c -->|kế thừa| Q2

    Q3 -.->|«include»| Q3a
    Q3 -.->|«include»| Q3b
```

---

## 5. Activity Diagram – Quy trình đơn hàng tráng/scan

```mermaid
flowchart TB
    classDef term fill:#222,stroke:#222,color:#fff

    subgraph CUS["Customer"]
        direction TB
        S((" ")):::term
        C1("Tìm kiếm & chọn Film Lab")
        C2("Chọn gói dịch vụ<br/>(Khổ film, quy trình, độ phân giải)")
        C3("Chọn phương thức gửi film")
        C4("Xác nhận đặt đơn hàng")
        C5("Thực hiện thanh toán trực tuyến / COD")
        C6("Nhận thông báo Push trên ứng dụng")
        C7("Truy cập Digital Film Archive<br/>xem & tải ảnh gốc")
        C8("Đánh giá Lab & Xác nhận hoàn tất")
        E1(((" "))):::term
    end

    subgraph PAY["Payment Gateway"]
        direction TB
        P1("Khởi tạo giao dịch thanh toán")
        P2{"Thanh toán thành công?"}
        P3("Trả về báo lỗi giao dịch")
        P4("Cập nhật trạng thái đơn<br/>(thanh toán thất bại)")
        P5("Cập nhật PaymentStatus")
        P6("Tạo vận đơn và gửi thông báo pickup")
        P7("Lưu file scan lên Cloud Storage")
        P8("Đồng bộ ảnh vào Digital Film Archive<br/>của Khách hàng")
        P9("Cập nhật trạng thái đơn")
    end

    subgraph DEL["Delivery Partner"]
        direction TB
        D1("Tiếp nhận vận đơn")
        D2("Đến địa chỉ Khách hàng để lấy cuộn film")
        D3("Vận chuyển cuộn film đến Film Lab")
        D4("Cập nhật trạng thái<br/>Đã giao film cho Lab")
    end

    subgraph LAB["Film Lab Owner"]
        direction TB
        L1("Tiếp nhận film &<br/>Chụp ảnh QC tình trạng cuộn film")
        L2("Xác nhận đơn trên hệ thống")
        L3("Tiến hành tráng & scan film")
        L4("Tải file scan lên hệ thống")
    end

    S --> C1 --> C2 --> C3 --> C4
    C4 --> P1
    P1 --> C5
    C5 --> P2
    P2 -->|Thất bại| P3 --> P4
    P2 -->|Thành công| P5 --> P6
    P6 --> D1 --> D2 --> D3 --> D4
    D4 --> L1 --> L2 --> L3 --> L4
    L4 --> P7 --> P8 --> P9
    P9 --> C6 --> C7 --> C8 --> E1
```

---

## 6. Activity Diagram – Quy trình khiếu nại & hoàn tiền

```mermaid
flowchart TB
    classDef term fill:#222,stroke:#222,color:#fff

    subgraph CUS["Customer"]
        direction TB
        S((" ")):::term
        C1("Phát hiện sự cố đơn hàng")
        C2("Chọn Tạo khiếu nại<br/>trên chi tiết đơn hàng")
        C3("Nhập lý do và đính kèm ảnh bằng chứng")
        C4("Gửi yêu cầu khiếu nại")
        C5{"Hai bên tự thương lượng<br/>thành công?"}
        C6("Nhấn Xác nhận thỏa thuận")
        C7("Đóng khiếu nại")
        E1(((" "))):::term
        C8("Nhấn Yêu cầu Admin phân xử")
        C9("Nhận thông báo lý do từ chối")
        C10("Đóng khiếu nại")
        E2(((" "))):::term
        C11("Nhận tiền hoàn và thông báo kết quả")
        C12("Đóng khiếu nại")
        E3(((" "))):::term
    end

    subgraph LAB["Film Lab Owner"]
        direction TB
        L1("Nhận thông báo khiếu nại từ hệ thống")
        L2("Xem nội dung khiếu nại và hình ảnh bằng chứng")
        L3("Thương lượng trực tiếp<br/>phương án đền bù với khách")
    end

    subgraph ADM["System Administrator"]
        direction TB
        A1("Tiếp nhận hồ sơ tranh chấp khiếu nại")
        A2("Đối soát nhật ký đơn hàng<br/>và ảnh QC lúc Lab nhận film")
        A3("Xem xét bằng chứng từ hai bên")
        A4{"Quyết định phân xử?"}
        A5("Nhập lý do từ chối")
        A6("Quyết định tỷ lệ hoàn tiền")
        A7("Bấm Phê duyệt hoàn tiền")
    end

    subgraph PAY["Payment Gateway"]
        direction TB
        P1("Gọi API xử lý hoàn tiền tự động")
        P2("Hoàn tiền về tài khoản ban đầu của khách")
    end

    S --> C1 --> C2 --> C3 --> C4
    C4 --> L1 --> L2 --> L3 --> C5
    C5 -->|Thành công| C6 --> C7 --> E1
    C5 -->|Thất bại| C8 --> A1
    A1 --> A2 --> A3 --> A4
    A4 -->|Từ chối khiếu nại| A5 --> C9 --> C10 --> E2
    A4 -->|Chấp nhận| A6 --> A7 --> P1 --> P2
    P2 --> C11 --> C12 --> E3
```
