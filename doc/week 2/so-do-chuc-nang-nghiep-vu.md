# Week 2 – Sơ đồ chức năng & nghiệp vụ


---

## 1. Use Case tổng quát

```mermaid
flowchart LR
    classDef actor fill:#fff,stroke:#333,stroke-width:2px,font-weight:bold
    classDef uc fill:#eef4ff,stroke:#3b6ea5

    CUS(["👤 Customer"]):::actor
    EXP(["👤 Photography Expert"]):::actor
    LAB(["👤 Film Lab Owner"]):::actor
    DEL(["👤 Delivery Partner"]):::actor
    ADM(["👤 System Administrator"]):::actor

    subgraph SYS["Hệ thống Quản lý Cộng đồng & Dịch vụ Film Lab"]
        %% Customer
        C1(["Đăng ký/Đăng nhập"]):::uc
        C2(["Tìm kiếm & So sánh Lab"]):::uc
        C3(["Đặt dịch vụ tráng/scan"]):::uc
        C4(["Thanh toán đơn hàng"]):::uc
        C5(["Quản lý Digital Film Archive"]):::uc
        C6(["Review Film Lab"]):::uc
        C7(["Khiếu nại"]):::uc
        C8(["Đăng tin Marketplace"]):::uc
        C9(["Đăng bài viết cộng đồng"]):::uc
        %% Film Lab Owner
        L1(["Quản lý hồ sơ Lab"]):::uc
        L2(["Xác nhận đơn hàng"]):::uc
        L3(["Upload file scan lên Cloud"]):::uc
        L4(["Xem báo cáo vận hành"]):::uc
        L5(["Cập nhật công đoạn tráng/scan"]):::uc
        L6(["Cấu hình gói dịch vụ & bảng giá"]):::uc
        L7(["Thương lượng khiếu nại"]):::uc
        %% Delivery Partner
        D1(["Nhận đơn pickup"]):::uc
        D2(["Giao nhận film 2 chiều"]):::uc
        %% Photography Expert
        E1(["Đăng bài viết chuyên môn"]):::uc
        E2(["Tổ chức Workshop & Photowalk"]):::uc
        %% System Administrator
        A1(["Kiểm duyệt tiền kiểm Marketplace"]):::uc
        A2(["Duyệt hồ sơ đối tác"]):::uc
        A3(["Quản lý tài khoản"]):::uc
        A4(["Xử lý khiếu nại & Hoàn tiền"]):::uc
        A5(["Hậu kiểm bài viết"]):::uc
        A6(["Xem Dashboard"]):::uc
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
    classDef actor fill:#fff,stroke:#333,stroke-width:2px,font-weight:bold
    classDef uc fill:#eef4ff,stroke:#3b6ea5
    classDef sub fill:#f6f6f6,stroke:#888

    CUS(["👤 Customer"]):::actor
    LAB(["👤 Film Lab Owner"]):::actor
    DEL(["👤 Delivery Partner"]):::actor

    subgraph SYS["Phân hệ Đặt & Xử lý dịch vụ Tráng/Scan"]
        %% Customer
        S1(["Tìm kiếm & So sánh Film Lab"]):::uc
        S1a(["Lọc theo gói dịch vụ & khổ film"]):::sub
        S2(["Đặt dịch vụ tráng/scan"]):::uc
        S2a(["Chọn khổ film & số lượng cuộn"]):::sub
        S2b(["Chọn phương thức gửi film"]):::sub
        S2c(["Chọn gói dịch vụ & độ phân giải scan"]):::sub
        S3(["Thanh toán đơn hàng"]):::uc
        S3a(["Thanh toán trực tuyến"]):::sub
        S3b(["Thanh toán COD"]):::sub
        S3c(["Thanh toán lại khi lỗi giao dịch"]):::sub
        S4(["Quản lý Digital Film Archive"]):::uc
        S4a(["Xem & Tải ảnh gốc chất lượng cao"]):::sub

        %% Film Lab Owner
        L1(["Xác nhận đơn hàng"]):::uc
        L1a(["Chụp ảnh QC khi nhận film"]):::sub
        L1b(["Đề xuất phụ phí"]):::sub
        L2(["Cập nhật công đoạn tráng/scan"]):::uc
        L2a(["Cập nhật trạng thái tiến độ"]):::sub
        L3(["Upload file scan lên Cloud"]):::uc
        L3a(["Đồng bộ Digital Film Archive"]):::sub

        %% Delivery Partner
        D1(["Nhận đơn pickup"]):::uc
        D1a(["Lấy film & giao về Lab"]):::sub
        D2(["Giao nhận film 2 chiều"]):::uc
        D2a(["Cập nhật trạng thái lấy/giao film"]):::sub
        D2b(["Xử lý giao thất bại"]):::sub
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
    classDef actor fill:#fff,stroke:#333,stroke-width:2px,font-weight:bold
    classDef uc fill:#eef4ff,stroke:#3b6ea5
    classDef sub fill:#f6f6f6,stroke:#888

    CUS(["👤 Customer"]):::actor
    EXP(["👤 Photography Expert"]):::actor
    ADM(["👤 System Administrator"]):::actor

    subgraph SYS["Phân hệ Marketplace & Quản lý thiết bị"]
        M1(["Đăng tin Marketplace"]):::uc
        M1a(["Nhập thông tin máy & ảnh chụp thật"]):::sub
        M2(["Đăng bài viết cộng đồng"]):::uc
        M2a(["Đính kèm bộ ảnh phim & thông số"]):::sub
        M3(["Tổ chức Workshop & Photowalk"]):::uc
        M3a(["Tạo sự kiện & quản lý đăng ký"]):::sub

        K1(["Kiểm duyệt tiền kiểm Marketplace"]):::uc
        K1a(["Phê duyệt hiển thị"]):::sub
        K1b(["Từ chối tin đăng"]):::sub
        K2(["Kiểm duyệt bài viết cộng đồng"]):::uc
        K2a(["Ẩn hoặc gỡ bài viết vi phạm"]):::sub
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
    classDef actor fill:#fff,stroke:#333,stroke-width:2px,font-weight:bold
    classDef uc fill:#eef4ff,stroke:#3b6ea5
    classDef sub fill:#f6f6f6,stroke:#888

    ADM(["👤 System Administrator"]):::actor

    subgraph SYS["Phân hệ Quản trị hệ thống & Kiểm duyệt"]
        Q1(["Quản lý tài khoản"]):::uc
        Q1a(["Lọc danh sách tài khoản"]):::sub
        Q1b(["Khóa tài khoản vi phạm"]):::sub

        Q2(["Duyệt hồ sơ đối tác"]):::uc
        Q2a(["Duyệt Film Lab"]):::sub
        Q2b(["Duyệt Expert"]):::sub
        Q2c(["Duyệt Shipper"]):::sub

        Q3(["Xử lý khiếu nại & Hoàn tiền"]):::uc
        Q3a(["Đối soát chứng cứ"]):::sub
        Q3b(["Phê duyệt hoàn tiền"]):::sub
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
    classDef cus fill:#dbeafe,stroke:#1d4ed8,color:#111
    classDef pay fill:#fef3c7,stroke:#b45309,color:#111
    classDef del fill:#dcfce7,stroke:#15803d,color:#111
    classDef lab fill:#fce7f3,stroke:#be185d,color:#111
    classDef dec fill:#fff,stroke:#111,color:#111
    classDef term fill:#222,stroke:#222,color:#fff

    subgraph LEG["Chú thích (làn = màu)"]
        direction LR
        K1("Customer"):::cus
        K2("Payment Gateway"):::pay
        K3("Delivery Partner"):::del
        K4("Film Lab Owner"):::lab
    end

    S((" ")):::term
    C1("Tìm kiếm & chọn Film Lab"):::cus
    C2("Chọn gói dịch vụ<br/>(Khổ film, quy trình, độ phân giải)"):::cus
    C3("Chọn phương thức gửi film"):::cus
    C4("Xác nhận đặt đơn hàng"):::cus
    P1("Khởi tạo giao dịch thanh toán"):::pay
    C5("Thực hiện thanh toán trực tuyến / COD"):::cus
    P2{"Thanh toán thành công?"}:::dec
    P3("Trả về báo lỗi giao dịch"):::pay
    P4("Cập nhật trạng thái đơn<br/>(thanh toán thất bại)"):::pay
    E2(((" "))):::term
    P5("Cập nhật PaymentStatus"):::pay
    P6("Tạo vận đơn và gửi thông báo pickup"):::pay
    D1("Tiếp nhận vận đơn"):::del
    D2("Đến địa chỉ Khách hàng để lấy cuộn film"):::del
    D3("Vận chuyển cuộn film đến Film Lab"):::del
    D4("Cập nhật trạng thái<br/>Đã giao film cho Lab"):::del
    L1("Tiếp nhận film &<br/>Chụp ảnh QC tình trạng cuộn film"):::lab
    L2("Xác nhận đơn trên hệ thống"):::lab
    L3("Tiến hành tráng & scan film"):::lab
    L4("Tải file scan lên hệ thống"):::lab
    P7("Lưu file scan lên Cloud Storage"):::pay
    P8("Đồng bộ ảnh vào Digital Film Archive<br/>của Khách hàng"):::pay
    P9("Cập nhật trạng thái đơn"):::pay
    C6("Nhận thông báo Push trên ứng dụng"):::cus
    C7("Truy cập Digital Film Archive<br/>xem & tải ảnh gốc"):::cus
    C8("Đánh giá Lab & Xác nhận hoàn tất"):::cus
    E1(((" "))):::term

    LEG ~~~ S
    S --> C1 --> C2 --> C3 --> C4 --> P1 --> C5 --> P2
    P2 -->|Thất bại| P3 --> P4 --> E2
    P2 -->|Thành công| P5 --> P6 --> D1 --> D2 --> D3 --> D4
    D4 --> L1 --> L2 --> L3 --> L4 --> P7 --> P8 --> P9
    P9 --> C6 --> C7 --> C8 --> E1
```

---

## 6. Activity Diagram – Quy trình khiếu nại & hoàn tiền

```mermaid
flowchart TB
    classDef cus fill:#dbeafe,stroke:#1d4ed8,color:#111
    classDef lab fill:#fce7f3,stroke:#be185d,color:#111
    classDef adm fill:#ede9fe,stroke:#6d28d9,color:#111
    classDef pay fill:#fef3c7,stroke:#b45309,color:#111
    classDef dec fill:#fff,stroke:#111,color:#111
    classDef term fill:#222,stroke:#222,color:#fff

    subgraph LEG["Chú thích (làn = màu)"]
        direction LR
        K1("Customer"):::cus
        K2("Film Lab Owner"):::lab
        K3("System Administrator"):::adm
        K4("Payment Gateway"):::pay
    end

    S((" ")):::term
    C1("Phát hiện sự cố đơn hàng"):::cus
    C2("Chọn Tạo khiếu nại<br/>trên chi tiết đơn hàng"):::cus
    C3("Nhập lý do và đính kèm ảnh bằng chứng"):::cus
    C4("Gửi yêu cầu khiếu nại"):::cus
    L1("Nhận thông báo khiếu nại từ hệ thống"):::lab
    L2("Xem nội dung khiếu nại và hình ảnh bằng chứng"):::lab
    L3("Thương lượng trực tiếp<br/>phương án đền bù với khách"):::lab
    C5{"Hai bên tự thương lượng<br/>thành công?"}:::dec
    C6("Nhấn Xác nhận thỏa thuận"):::cus
    C7("Đóng khiếu nại"):::cus
    E1(((" "))):::term
    C8("Nhấn Yêu cầu Admin phân xử"):::cus
    A1("Tiếp nhận hồ sơ tranh chấp khiếu nại"):::adm
    A2("Đối soát nhật ký đơn hàng<br/>và ảnh QC lúc Lab nhận film"):::adm
    A3("Xem xét bằng chứng từ hai bên"):::adm
    A4{"Quyết định phân xử?"}:::dec
    A5("Nhập lý do từ chối"):::adm
    C9("Nhận thông báo lý do từ chối"):::cus
    C10("Đóng khiếu nại"):::cus
    E2(((" "))):::term
    A6("Quyết định tỷ lệ hoàn tiền"):::adm
    A7("Bấm Phê duyệt hoàn tiền"):::adm
    P1("Gọi API xử lý hoàn tiền tự động"):::pay
    P2("Hoàn tiền về tài khoản ban đầu của khách"):::pay
    C11("Nhận tiền hoàn và thông báo kết quả"):::cus
    C12("Đóng khiếu nại"):::cus
    E3(((" "))):::term

    LEG ~~~ S
    S --> C1 --> C2 --> C3 --> C4 --> L1 --> L2 --> L3 --> C5
    C5 -->|Thành công| C6 --> C7 --> E1
    C5 -->|Thất bại| C8 --> A1 --> A2 --> A3 --> A4
    A4 -->|Từ chối khiếu nại| A5 --> C9 --> C10 --> E2
    A4 -->|Chấp nhận| A6 --> A7 --> P1 --> P2 --> C11 --> C12 --> E3
```
