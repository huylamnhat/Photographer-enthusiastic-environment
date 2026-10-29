# Week 2 – Sơ đồ chức năng & Nghiệp vụ (Phân tích hệ thống)
> Dự án: Nền tảng kết nối cộng đồng nhiếp ảnh phim & dịch vụ Film Lab (MiniLab) — Nhóm 8

---

## 1. Use Case tổng quát (Overall Use Case Diagram)

Sơ đồ thể hiện toàn bộ ranh giới hệ thống với **5 Actor chính** theo đúng quy định phân quyền hệ thống (RBAC):
* **Customer:** Khách hàng / Nhiếp ảnh gia cá nhân.
* **Film Lab Owner:** Chủ tiệm Film Lab.
* **Photography Expert:** Chuyên gia nhiếp ảnh được cấp huy hiệu chứng nhận.
* **Delivery Partner:** Đối tác vận chuyển (Ahamove, Lalamove hoặc shipper nội bộ).
* **System Administrator:** Quản trị viên vận hành hệ thống.

```mermaid
flowchart LR

    CUS(["👤 Customer"])
    EXP(["👤 Photography Expert"])
    LAB(["👤 Film Lab Owner"])
    DEL(["👤 Delivery Partner"])
    ADM(["👤 System Administrator"])

    subgraph SYS["Hệ thống Quản lý Cộng đồng & Dịch vụ Film Lab"]
        direction LR
        %% Chức năng dùng chung
        AUTH(["Đăng ký / Đăng nhập / Quản lý tài khoản"])
        
        %% Customer
        C1(["Tìm kiếm & So sánh Lab"])
        C2(["Đặt dịch vụ tráng/scan & In ảnh"])
        C3(["Thanh toán đơn hàng & Hủy đơn"])
        C4(["Quản lý Digital Film Archive"])
        C5(["Review & Đánh giá Film Lab"])
        C6(["Gửi khiếu nại & Thương lượng"])
        C7(["Mua bán thiết bị Marketplace"])
        C8(["Tham gia thảo luận cộng đồng & Workshop"])

        %% Film Lab Owner
        L1(["Cấu hình hồ sơ tiệm & bảng giá dịch vụ"])
        L2(["Tiếp nhận đơn & Chụp ảnh QC"])
        L3(["Cập nhật công đoạn tráng/scan"])
        L4(["Upload file scan lên Cloud Archive"])
        L5(["Xem báo cáo vận hành & SLA"])
        L6(["Thương lượng bồi thường khiếu nại"])
        L7(["Đăng bán sản phẩm B2C (Film/Hóa chất)"])

        %% Photography Expert
        E1(["Đăng bài chia sẻ kỹ thuật chuyên môn"])
        E2(["Tổ chức Workshop & Photowalk"])
        E3(["Đăng bán thiết bị kiểm định"])

        %% Delivery Partner
        D1(["Nhận đơn pickup (Chiều 1)"])
        D2(["Giao trả film/ảnh in (Chiều 2)"])
        D3(["Cập nhật trạng thái giao vận"])

        %% System Administrator
        A1(["Thẩm định duyệt đối tác (Lab/Expert/Shipper)"])
        A2(["Tiền kiểm 100% tin Marketplace"])
        A3(["Hậu kiểm bài viết cộng đồng"])
        A4(["Phán quyết khiếu nại & Duyệt hoàn tiền"])
        A5(["Quản trị tài khoản & Khóa vi phạm"])
        A6(["Xem Dashboard vận hành & Audit Log"])
    end

    CUS --- AUTH & C1 & C2 & C3 & C4 & C5 & C6 & C7 & C8
    LAB --- AUTH & L1 & L2 & L3 & L4 & L5 & L6 & L7
    EXP --- AUTH & E1 & E2 & E3
    DEL --- AUTH & D1 & D2 & D3
    ADM --- AUTH & A1 & A2 & A3 & A4 & A5 & A6
```

---

## 2. Use Case phân rã – Đặt & xử lý dịch vụ tráng/scan

Chi tiết hóa quy trình dịch vụ cốt lõi: từ tìm kiếm tiệm, cấu hình đơn hàng (gói tráng, scan hi-res, in ảnh, chọn hình thức giao nhận), quy trình xác nhận kèm ảnh QC của Lab, xử lý phụ phí phát sinh, hủy đơn hợp lệ, lưu trữ Digital Film Archive cho đến đánh giá Lab.

```mermaid
flowchart LR

    CUS(["👤 Customer"])
    LAB(["👤 Film Lab Owner"])
    DEL(["👤 Delivery Partner"])

    subgraph SYS["Phân hệ Đặt & Xử lý dịch vụ Tráng/Scan"]
        direction LR
        %% Customer
        S1(["Tìm kiếm & So sánh Film Lab"])
        S1a(["Lọc theo khổ film, quy trình C41/BW/ECN2/E6 & SLA"])
        
        S2(["Đặt dịch vụ tráng/scan"])
        S2a(["Chọn khổ film & số lượng cuộn"])
        S2b(["Chọn gói tráng/scan & độ phân giải"])
        S2c(["Tùy chọn in ảnh vật lý & Push/Pull"])
        S2d(["Chọn phương thức gửi film (Pickup / Drop-off)"])
        
        S3(["Thanh toán đơn hàng"])
        S3a(["Thanh toán trực tuyến (VNPAY/Momo/QR)"])
        S3b(["Thanh toán tiền mặt COD (tại quầy)"])
        S3c(["Thanh toán lại khi giao dịch lỗi"])
        
        S4(["Hủy đơn hàng (khi Chờ xác nhận)"])
        
        S5(["Quản lý Digital Film Archive"])
        S5a(["Xem & Tải ảnh gốc chất lượng cao"])
        S5b(["Quản lý Metadata (máy, lens, film) & Album"])
        S5c(["Chia sẻ Album qua liên kết"])
        
        S6(["Đánh giá & Review Film Lab"])

        %% Film Lab Owner
        L1(["Tiếp nhận & Xác nhận đơn hàng"])
        L1a(["Chụp ảnh QC tình trạng film lúc nhận"])
        L1b(["Đề xuất phụ phí phát sinh (Cine/Push)"])
        
        L2(["Cập nhật công đoạn tráng/scan"])
        L2a(["Cập nhật tiến độ: Nhận - Tráng - Sấy - Scan - QC"])
        
        L3(["Upload file scan lên Cloud & Trả kết quả"])
        L3a(["Tự động đồng bộ Digital Film Archive"])
        L3b(["Thu hồi & Ghi đè file scan (trong 24h)"])

        %% Delivery Partner
        D1(["Nhận đơn pickup (Chiều 1)"])
        D1a(["Lấy film từ khách giao về Lab"])
        
        D2(["Giao trả film/ảnh in (Chiều 2)"])
        D2a(["Cập nhật trạng thái lấy / giao film"])
        D2b(["Xử lý sự cố giao nhận thất bại"])
    end

    %% Actor - Use Case
    CUS --- S1 & S2 & S3 & S4 & S5 & S6
    LAB --- L1 & L2 & L3
    DEL --- D1 & D2

    %% Customer Relationships
    S1a -.->|«extend»| S1
    S2 -.->|«include»| S2a
    S2 -.->|«include»| S2b
    S2 -.->|«extend»| S2c
    S2 -.->|«include»| S2d
    S2 -.->|«include»| S3
    
    S3a -->|kế thừa| S3
    S3b -->|kế thừa| S3
    S3c -.->|«extend»| S3
    
    S4 -.->|«extend»| S2
    
    S5 -.->|«include»| S5a
    S5 -.->|«extend»| S5b
    S5 -.->|«extend»| S5c

    %% Film Lab Relationships
    L1 -.->|«include»| L1a
    L1b -.->|«extend»| L1
    L2 -.->|«include»| L2a
    L3 -.->|«include»| L3a
    L3b -.->|«extend»| L3

    %% Delivery Relationships
    D1 -.->|«include»| D1a
    D2 -.->|«include»| D2a
    D2b -.->|«extend»| D2
```

---

## 3. Use Case phân rã – Marketplace & Quản lý thiết bị

Đặc tả chi tiết sàn trao đổi thiết bị máy ảnh phim (C2C và B2C), cơ chế tiền kiểm 100% của Admin, kiểm tra thông số cơ học và liên hệ trực tiếp người bán.

```mermaid
flowchart LR

    CUS(["👤 Customer (Buyer / Seller)"])
    LAB(["👤 Film Lab Owner"])
    EXP(["👤 Photography Expert"])
    ADM(["👤 System Administrator"])

    subgraph SYS["Phân hệ Marketplace & Quản lý thiết bị"]
        direction LR
        %% Buyer
        M1(["Tìm kiếm & Lọc thiết bị"])
        M1a(["Lọc theo khoảng giá, dòng máy, khu vực"])
        M2(["Xem chi tiết & Thông số cơ học"])
        M2a(["Xem đánh giá đo sáng, màn trập, thấu kính"])
        M3(["Liên hệ người bán qua SĐT / Zalo"])

        %% Seller
        M4(["Đăng tin bán thiết bị / phụ kiện"])
        M4a(["Nhập mô tả chi tiết & Tối thiểu 3 ảnh thật"])
        M5(["Quản lý tin đăng cá nhân"])
        M5a(["Chỉnh sửa / Xóa tin đăng"])
        M5b(["Đánh dấu thiết bị đã bán"])

        %% Admin
        K1(["Kiểm duyệt tiền kiểm 100% tin đăng"])
        K1a(["Phê duyệt hiển thị lên sàn"])
        K1b(["Từ chối tin đăng & Nêu rõ lý do"])
        K1c(["Gỡ tin đăng vi phạm"])
    end

    CUS --- M1 & M2 & M3 & M4 & M5
    LAB --- M4 & M5
    EXP --- M4 & M5
    ADM --- K1

    M1a -.->|«extend»| M1
    M2 -.->|«include»| M2a
    M4 -.->|«include»| M4a
    M5 -.->|«extend»| M5a
    M5 -.->|«extend»| M5b

    K1a -.->|«extend»| K1
    K1b -.->|«extend»| K1
    K1c -.->|«extend»| K1
```

> **Phân hệ bổ trợ: Chuyên gia & Hoạt động Cộng đồng (Community & Expert)**  
> Để đảm bảo tính phân tách hệ thống sạch sẽ, các nghiệp vụ thảo luận và sự kiện của Chuyên gia được chuẩn hóa như sau:
> * **Photography Expert / Customer:** Đăng bài chia sẻ kỹ thuật kèm ảnh phim («include» thông số chụp), Tương tác (Like, Follow tác giả), Báo cáo vi phạm nội dung.
> * **Tổ chức sự kiện:** Expert khởi tạo Workshop & Photowalk («include» quản lý danh sách đăng ký); Customer tham gia đăng ký và thảo luận.
> * **Admin:** Hậu kiểm bài viết bị người dùng báo cáo (Ẩn / Gỡ bài) và Thẩm định cấp huy hiệu Chuyên gia (Verified Badge).

---

## 4. Use Case phân rã – Quản trị hệ thống & Kiểm duyệt

Đặc tả các quyền hạn và trách nhiệm của Quản trị viên (System Administrator): quản lý tài khoản (RBAC), thẩm định 3 nhóm đối tác, xử lý tranh chấp khiếu nại, giới hạn quyền can thiệp và bảng điều khiển Dashboard báo cáo vận hành kèm Audit Log.

```mermaid
flowchart LR

    ADM(["👤 System Administrator"])

    subgraph SYS["Phân hệ Quản trị hệ thống & Kiểm duyệt"]
        direction LR
        %% Quản lý tài khoản
        Q1(["Quản lý tài khoản người dùng"])
        Q1a(["Tìm kiếm & Lọc theo vai trò, trạng thái"])
        Q1b(["Khóa tài khoản vi phạm"])
        Q1c(["Phúc thẩm xem xét lại tài khoản"])

        %% Duyệt đối tác
        Q2(["Thẩm định duyệt hồ sơ đối tác"])
        Q2a(["Duyệt Film Lab (CCCD, địa chỉ, máy móc)"])
        Q2b(["Duyệt Chuyên gia (Hồ sơ, Portfolio)"])
        Q2c(["Duyệt Đối tác vận chuyển (Logistics)"])

        %% Khiếu nại
        Q3(["Xử lý khiếu nại & Phán quyết bồi thường"])
        Q3a(["Đối soát ảnh QC lúc nhận film & Nhật ký SLA"])
        Q3b(["Phê duyệt hoàn tiền qua Cổng thanh toán"])

        %% Quản lý danh mục & Kiểm duyệt
        Q4(["Kiểm duyệt nội dung & Giới hạn quyền"])
        Q4a(["Tiền kiểm tin Marketplace"])
        Q4b(["Hậu kiểm bài viết cộng đồng bị báo cáo"])
        Q4c(["Ẩn dịch vụ Film Lab vi phạm"])

        %% Dashboard & Audit
        Q5(["Xem Dashboard báo cáo vận hành tinh gọn"])
        Q5a(["Thống kê User, Đơn hàng, Tỷ lệ SLA"])
        Q5b(["Tra cứu Nhật ký kiểm toán (Audit Log)"])
    end

    ADM --- Q1 & Q2 & Q3 & Q4 & Q5

    Q1 -.->|«include»| Q1a
    Q1b -.->|«extend»| Q1
    Q1c -.->|«extend»| Q1

    Q2a -->|kế thừa| Q2
    Q2b -->|kế thừa| Q2
    Q2c -->|kế thừa| Q2

    Q3 -.->|«include»| Q3a
    Q3 -.->|«include»| Q3b

    Q4a -.->|«extend»| Q4
    Q4b -.->|«extend»| Q4
    Q4c -.->|«extend»| Q4

    Q5 -.->|«include»| Q5a
    Q5 -.->|«include»| Q5b
```

---

## 5. Activity Diagram – Quy trình đơn hàng tráng/scan

Sơ đồ phân làn (Swimlane Diagram - 4 làn) chuẩn hóa theo đúng yêu cầu đề bài:
1. **Khách hàng (Customer)**
2. **Cổng thanh toán & Hệ thống (Payment & System Platform)**
3. **Đối tác vận chuyển (Delivery Partner)**
4. **Chủ Film Lab (Film Lab Owner)**

Sơ đồ xử lý đầy đủ các nhánh nghiệp vụ thực tế:
* Thanh toán thất bại $\rightarrow$ Cho phép khách bấm **"Thanh toán lại"** hoặc tự hủy sau 24h.
* Giao nhận film 2 chiều: Chiều 1 lấy film (Shipper Pickup hoặc Khách tự mang Drop-off); Chiều 2 giao trả vật lý (âm bản / ảnh in) nếu khách đăng ký.
* Xử lý phụ phí phát sinh (Cine ECN-2, film outdate Push sáng).
* Tự động lưu Cloud Storage và đồng bộ ảnh vào Digital Film Archive.

```mermaid
flowchart TB
    classDef term fill:#222,stroke:#222,color:#fff

    subgraph CUS["Khách hàng (Customer)"]
        direction TB
        S((" ")):::term
        C1("Tìm kiếm & chọn Film Lab")
        C2("Chọn gói dịch vụ tráng/scan<br/>& Tùy chọn in ảnh")
        C3("Chọn phương thức gửi film<br/>(Pickup hoặc Drop-off)")
        C4("Xác nhận đặt đơn hàng")
        C5("Thực hiện thanh toán")
        C_RETRY{"Xử lý lỗi?"}
        C_RETRY_PAY("Bấm Thanh toán lại")
        C_CANCEL("Hủy đơn / Quá 24h tự hủy")
        E_CANCEL(((" "))):::term
        C_DROPOFF("Tự mang cuộn film đến tiệm Lab")
        C6("Nhận thông báo Push trên ứng dụng")
        C7("Truy cập Digital Film Archive<br/>xem & tải ảnh gốc")
        C8("Đánh giá Lab & Hoàn tất đơn hàng")
        E1(((" "))):::term
    end

    subgraph SYS["Cổng thanh toán & Hệ thống (Payment & System)"]
        direction TB
        P1("Khởi tạo giao dịch thanh toán")
        P2{"Thanh toán thành công?"}
        P3("Báo lỗi giao dịch thanh toán")
        P5("Cập nhật PaymentStatus = Paid<br/>Chuyển đơn sang Chờ Lab xác nhận")
        P_CHECK_SHIP{"Phương thức gửi film?"}
        P6("Tạo vận đơn Chiều 1 & Điều phối Shipper")
        P7("Lưu file scan lên Cloud Storage")
        P8("Tự động đồng bộ ảnh vào<br/>Digital Film Archive của khách")
        P_CHECK_RETURN{"Khách yêu cầu trả<br/>âm bản / ảnh in?"}
        P10("Tạo vận đơn Chiều 2 giao trả vật lý")
        P9("Cập nhật trạng thái Đơn hoàn tất")
    end

    subgraph DEL["Đối tác vận chuyển (Delivery Partner)"]
        direction TB
        D1("Tiếp nhận vận đơn Chiều 1")
        D2("Đến địa chỉ khách lấy cuộn film")
        D3("Vận chuyển film giao tận tay Lab")
        D4("Cập nhật trạng thái: Đã nhận film tại Lab")
        D5("Tiếp nhận vận đơn Chiều 2")
        D6("Lấy gói film/ảnh in từ Lab")
        D7("Giao trả tận tay khách hàng")
        D8("Cập nhật trạng thái: Giao hàng thành công")
    end

    subgraph LAB["Chủ Film Lab (Film Lab Owner)"]
        direction TB
        L1("Xác nhận tiếp nhận đơn trên hệ thống")
        L2("Nhận film thực tế & Chụp ảnh QC")
        L_SURCHARGE{"Phát sinh phụ phí<br/>(Cine/Push)?"}
        L_SUR_REQ("Gửi đề xuất phụ phí cho khách")
        L3("Chuyển trạng thái: Đang xử lý<br/>(Tráng - Sấy - Scan - QC)")
        L4("Tải file scan chất lượng cao lên hệ thống")
        L5("Đóng gói film âm bản & ảnh in")
    end

    %% Bắt đầu và đặt hàng
    S --> C1 --> C2 --> C3 --> C4
    C4 --> P1 --> C5 --> P2

    %% Thanh toán thất bại và retry
    P2 -->|Thất bại| P3 --> C_RETRY
    C_RETRY -->|Thử lại| C_RETRY_PAY --> C5
    C_RETRY -->|Bỏ qua| C_CANCEL --> E_CANCEL

    %% Thanh toán thành công
    P2 -->|Thành công| P5 --> L1 --> P_CHECK_SHIP

    %% Phân nhánh gửi film
    P_CHECK_SHIP -->|Shipper Pickup| P6 --> D1 --> D2 --> D3 --> D4 --> L2
    P_CHECK_SHIP -->|Khách tự mang Drop-off| C_DROPOFF --> L2

    %% Xử lý tại Lab
    L2 --> L_SURCHARGE
    L_SURCHARGE -->|Có| L_SUR_REQ --> L3
    L_SURCHARGE -->|Không| L3

    L3 --> L4 --> P7 --> P8 --> P_CHECK_RETURN

    %% Phân nhánh trả hàng vật lý
    P_CHECK_RETURN -->|Có ship trả film/ảnh| P10 --> L5 --> D5 --> D6 --> D7 --> D8 --> P9
    P_CHECK_RETURN -->|Chỉ nhận file số| P9

    %% Kết thúc
    P9 --> C6 --> C7 --> C8 --> E1
```

---

## 6. Activity Diagram – Quy trình khiếu nại & hoàn tiền

Quy trình chuẩn hóa 3 bước giải quyết tranh chấp:
1. **Bước 1 (Khách gửi khiếu nại):** Khách hàng phát hiện sự cố (film hỏng, trầy xước, scan mờ), tạo khiếu nại kèm hình ảnh bằng chứng.
2. **Bước 2 (Hai bên tự thương lượng):** Hệ thống thông báo cho Film Lab để chủ động trao đổi giải pháp đền bù (voucher, tặng cuộn film mới, chụp đền). Nếu khách đồng thuận $\rightarrow$ Đóng khiếu nại.
3. **Bước 3 (Admin can thiệp & Hoàn tiền tự động):** Nếu thương lượng bất thành, Admin vào cuộc đối soát ảnh QC lúc nhận film và nhật ký SLA. Admin ra phán quyết tỷ lệ hoàn tiền $\rightarrow$ Kích hoạt Cổng thanh toán hoàn tiền tự động về tài khoản/ví của khách hàng $\rightarrow$ Cập nhật thông báo cho cả Khách hàng và Film Lab.

```mermaid
flowchart TB
    classDef term fill:#222,stroke:#222,color:#fff

    subgraph CUS["Khách hàng (Customer)"]
        direction TB
        S((" ")):::term
        C1("Phát hiện sự cố đơn hàng (mất/hỏng film, lỗi scan)")
        C2("Chọn Tạo khiếu nại trên chi tiết đơn hàng")
        C3("Nhập lý do và đính kèm ảnh bằng chứng")
        C4("Gửi yêu cầu khiếu nại")
        C5{"Hai bên tự thương lượng<br/>thành công?"}
        C6("Nhấn Xác nhận thỏa thuận")
        C7("Đóng khiếu nại")
        E1(((" "))):::term
        C8("Bấm Yêu cầu Admin phân xử")
        C9("Nhận thông báo lý do từ chối")
        C10("Đóng khiếu nại")
        E2(((" "))):::term
        C11("Nhận tiền hoàn và thông báo kết quả")
        C12("Đóng khiếu nại")
        E3(((" "))):::term
    end

    subgraph LAB["Chủ Film Lab (Film Lab Owner)"]
        direction TB
        L1("Nhận thông báo khiếu nại từ hệ thống")
        L2("Xem nội dung khiếu nại & ảnh bằng chứng")
        L3("Thương lượng trực tiếp phương án đền bù<br/>(voucher, tặng cuộn film, chụp bù)")
        L4("Nhận thông báo kết quả phân xử từ Admin")
    end

    subgraph ADM["Quản trị viên (System Administrator)"]
        direction TB
        A1("Tiếp nhận hồ sơ tranh chấp khiếu nại")
        A2("Đối soát dòng thời gian SLA<br/>& Ảnh QC lúc Lab nhận film")
        A3("Xem xét giải trình và bằng chứng từ hai bên")
        A4{"Quyết định phân xử?"}
        A5("Nhập lý do từ chối khiếu nại")
        A6("Quyết định tỷ lệ hoàn tiền<br/>(100% nếu hỏng film, 100% scan nếu blank)")
        A7("Bấm Phê duyệt hoàn tiền")
    end

    subgraph PAY["Cổng thanh toán (Payment Gateway)"]
        direction TB
        P1("Gọi API xử lý hoàn tiền tự động")
        P2("Hoàn tiền về tài khoản / ví ban đầu của khách")
    end

    %% Luồng gửi khiếu nại và tự thương lượng
    S --> C1 --> C2 --> C3 --> C4
    C4 --> L1 --> L2 --> L3 --> C5

    %% Thương lượng thành công
    C5 -->|Thành công| C6 --> C7 --> E1

    %% Chuyển Admin phân xử
    C5 -->|Thất bại| C8 --> A1
    A1 --> A2 --> A3 --> A4

    %% Phán quyết của Admin
    A4 -->|Từ chối khiếu nại| A5
    A5 --> C9 --> C10 --> E2
    A5 --> L4

    A4 -->|Chấp nhận bồi thường| A6 --> A7
    A7 --> L4
    A7 --> P1 --> P2
    P2 --> C11 --> C12 --> E3
```
