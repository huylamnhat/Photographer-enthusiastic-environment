# SƠ ĐỒ CHỨC NĂNG VÀ NGHIỆP VỤ (WEEK 2)

---

## 1. Sơ đồ Use Case Tổng quát (Overall Use Case Diagram)

```mermaid
graph LR
    Customer((Customer))
    Lab((Film Lab Owner))
    Expert((Photography Expert))
    Shipper((Delivery Partner))
    Admin((System Administrator))

    subgraph System ["Hệ thống Quản lý Cộng đồng & Dịch vụ Film Lab"]
        UC1(Tìm kiếm & So sánh Lab)
        UC2(Đặt dịch vụ tráng/scan)
        UC3(Thanh toán đơn hàng)
        UC4(Quản lý Digital Film Archive)
        UC5(Review Film Lab)
        UC6(Đăng tin Marketplace)
        UC7(Đăng bài viết cộng đồng)
        UC8(Khiếu nại)
        UC9(Đăng ký / Đăng nhập)
        
        UC10(Xác nhận đơn hàng)
        UC11(Quản lý hồ sơ Lab)
        UC12(Upload file scan lên Cloud)
        UC13(Xem báo cáo vận hành)
        UC14(Cập nhật công đoạn tráng/scan)
        UC15(Cấu hình gói dịch vụ & bảng giá)
        UC16(Thương lượng khiếu nại)

        UC17(Đăng bài viết chuyên môn)
        UC18(Tổ chức Workshop & Photowalk)

        UC19(Nhận đơn pickup)
        UC20(Giao nhận film 2 chiều)

        UC21(Duyệt hồ sơ đối tác)
        UC22(Kiểm duyệt tiền kiểm Marketplace)
        UC23(Quản lý tài khoản)
        UC24(Xử lý khiếu nại & Hoàn tiền)
        UC25(Hậu kiểm bài viết)
        UC26(Xem Dashboard)
    end

    Customer --> UC1
    Customer --> UC2
    Customer --> UC3
    Customer --> UC4
    Customer --> UC5
    Customer --> UC6
    Customer --> UC7
    Customer --> UC8
    Customer --> UC9

    Lab --> UC10
    Lab --> UC11
    Lab --> UC12
    Lab --> UC13
    Lab --> UC14
    Lab --> UC15
    Lab --> UC16

    Expert --> UC17
    Expert --> UC18

    Shipper --> UC19
    Shipper --> UC20

    Admin --> UC21
    Admin --> UC22
    Admin --> UC23
    Admin --> UC24
    Admin --> UC25
    Admin --> UC26
```

---

## 2. Các Sơ đồ Use Case Phân rã (Detailed Use Case Diagrams)

### 2.1. Phân hệ Đặt & Xử lý dịch vụ tráng/scan

```mermaid
graph LR
    Customer((Customer))
    Lab((Film Lab Owner))
    Shipper((Delivery Partner))

    subgraph Subsystem1 ["Phân hệ Đặt & Xử lý dịch vụ Tráng/Scan"]
        UC_Search(Tìm kiếm & So sánh Film Lab)
        UC_Filter(Lọc theo gói dịch vụ & khổ film)
        UC_Order(Đặt dịch vụ tráng/scan)
        UC_Opt1(Chọn khổ film & số lượng cuộn)
        UC_Opt2(Chọn phương thức gửi film)
        UC_Opt3(Chọn gói dịch vụ & độ phân giải scan)
        UC_Pay(Thanh toán đơn hàng)
        UC_PayOnline(Thanh toán trực tuyến)
        UC_PayCOD(Thanh toán COD)
        UC_PayRetry(Thanh toán lại khi lỗi giao dịch)
        UC_Archive(Quản lý Digital Film Archive)
        UC_Download(Xem & Tải ảnh gốc chất lượng cao)

        UC_Confirm(Xác nhận đơn hàng)
        UC_QC(Chụp ảnh QC khi nhận film)
        UC_Fee(Đề xuất phụ phí)
        UC_UpdateProcess(Cập nhật công đoạn tráng/scan)
        UC_UpdateStatus(Cập nhật trạng thái tiến độ)
        UC_Upload(Upload file scan lên Cloud)
        UC_Sync(Đồng bộ Digital Film Archive)

        UC_Pickup(Nhận đơn pickup)
        UC_BringLab(Lấy film & giao về Lab)
        UC_Delivery(Giao nhận film 2 chiều)
        UC_ShipStatus(Cập nhật trạng thái lấy/giao film)
        UC_ShipFail(Xử lý giao thất bại)
    end

    Customer --> UC_Search
    UC_Search -.->|extend| UC_Filter
    Customer --> UC_Order
    UC_Order -.->|include| UC_Opt1
    UC_Order -.->|include| UC_Opt2
    UC_Order -.->|include| UC_Opt3
    UC_Order -.->|include| UC_Pay
    UC_PayOnline --|> UC_Pay
    UC_PayCOD --|> UC_Pay
    UC_PayRetry -.->|extend| UC_Pay
    Customer --> UC_Archive
    UC_Archive -.->|include| UC_Download

    Lab --> UC_Confirm
    UC_Confirm -.->|include| UC_QC
    UC_Fee -.->|extend| UC_Confirm
    Lab --> UC_UpdateProcess
    UC_UpdateProcess -.->|include| UC_UpdateStatus
    Lab --> UC_Upload
    UC_Upload -.->|include| UC_Sync

    Shipper --> UC_Pickup
    UC_Pickup -.->|include| UC_BringLab
    Shipper --> UC_Delivery
    UC_Delivery -.->|include| UC_ShipStatus
    UC_ShipFail -.->|extend| UC_Delivery
```

### 2.2. Phân hệ Marketplace & Quản lý thiết bị

```mermaid
graph LR
    Customer((Customer))
    Expert((Photography Expert))
    Admin((System Administrator))

    subgraph Subsystem2 ["Phân hệ Marketplace & Quản lý thiết bị"]
        UC_PostMarket(Đăng tin Marketplace)
        UC_InputInfo(Nhập thông tin máy & ảnh chụp thật)
        UC_PreApprove(Kiểm duyệt tiền kiểm Marketplace)
        UC_Approve(Phê duyệt hiển thị)
        UC_Reject(Từ chối tin đăng)

        UC_PostCommunity(Đăng bài viết cộng đồng)
        UC_AttachPhoto(Đính kèm bộ ảnh phim & thông số)
        UC_PostCheck(Kiểm duyệt bài viết cộng đồng)
        UC_HidePost(Ẩn hoặc gỡ bài viết vi phạm)

        UC_Event(Tổ chức Workshop & Photowalk)
        UC_CreateEvent(Tạo sự kiện & quản lý đăng ký)
    end

    Customer --> UC_PostMarket
    UC_PostMarket -.->|include| UC_InputInfo
    Admin --> UC_PreApprove
    UC_Approve -.->|extend| UC_PreApprove
    UC_Reject -.->|extend| UC_PreApprove

    Customer --> UC_PostCommunity
    UC_PostCommunity -.->|include| UC_AttachPhoto
    Admin --> UC_PostCheck
    UC_HidePost -.->|extend| UC_PostCheck

    Expert --> UC_Event
    UC_Event -.->|include| UC_CreateEvent
```

### 2.3. Phân hệ Quản trị hệ thống & Kiểm duyệt

```mermaid
graph LR
    Admin((System Administrator))

    subgraph Subsystem3 ["Phân hệ Quản trị hệ thống & Kiểm duyệt"]
        UC_UserMgmt(Quản lý tài khoản)
        UC_FilterUser(Lọc danh sách tài khoản)
        UC_LockUser(Khóa tài khoản vi phạm)

        UC_ApprovePartner(Duyệt hồ sơ đối tác)
        UC_ApproveLab(Duyệt Film Lab)
        UC_ApproveExpert(Duyệt Expert)
        UC_ApproveShipper(Duyệt Shipper)

        UC_Dispute(Xử lý khiếu nại & Hoàn tiền)
        UC_Proof(Đối soát chứng cứ)
        UC_Refund(Phê duyệt hoàn tiền)
    end

    Admin --> UC_UserMgmt
    UC_UserMgmt -.->|include| UC_FilterUser
    UC_LockUser -.->|extend| UC_UserMgmt

    Admin --> UC_ApprovePartner
    UC_ApproveLab --|> UC_ApprovePartner
    UC_ApproveExpert --|> UC_ApprovePartner
    UC_ApproveShipper --|> UC_ApprovePartner

    Admin --> UC_Dispute
    UC_Dispute -.->|include| UC_Proof
    UC_Dispute -.->|include| UC_Refund
```

---

## 3. Sơ đồ Hoạt động (Activity Diagrams)

### 3.1. Quy trình đơn hàng tráng/scan (Swimlane Diagram - 4 làn)

```mermaid
graph TD
    subgraph Customer ["Customer"]
        A1[Tìm & chọn Film Lab] --> A2[Chọn gói dịch vụ tráng/scan]
        A2 --> A3[Chọn phương thức gửi film]
        A3 --> A4[Xác nhận đặt đơn hàng]
        A5[Thực hiện thanh toán online / COD]
        A6[Nhận thông báo Push & Xem/Tải ảnh từ Archive]
    end

    subgraph Payment ["Payment Gateway"]
        A4 --> B1[Khởi tạo thanh toán]
        B1 --> A5
        B2{Thanh toán thành công?}
        B2 -- Thất bại / Hủy --> B3[Báo lỗi giao dịch & Hủy đơn]
        B2 -- Thành công --> B4[Cập nhật PaymentStatus = Paid & Tạo vận đơn]
        B5[Cập nhật đơn COMPLETE & Đồng bộ Archive] --> A6
    end

    subgraph Shipper ["Delivery Partner"]
        B4 --> C1[Nhận đơn pickup]
        C1 --> C2[Đến lấy film từ Khách hàng]
        C2 --> C3[Vận chuyển film đến Film Lab]
    end

    subgraph Lab ["Film Lab Owner"]
        C3 --> D1[Nhận film & Chụp ảnh QC]
        D1 --> D2[Xác nhận đơn trên hệ thống]
        D2 --> D3[Tiến hành tráng & scan film]
        D3 --> D4[Upload file scan ZIP lên Cloud Storage]
        D4 --> B5
    end

    A5 --> B2
```

### 3.2. Quy trình khiếu nại & hoàn tiền

```mermaid
graph TD
    subgraph Customer ["Customer"]
        E1[Phát hiện sự cố đơn hàng] --> E2[Chọn Tạo khiếu nại trên đơn]
        E2 --> E3[Nhập lý do & tải ảnh bằng chứng]
        E3 --> E4[Gửi yêu cầu khiếu nại]
        E6{Hai bên tự thỏa thuận thành công?}
        E6 -- Thành công --> E7[Khách / Lab bấm Xác nhận thỏa thuận]
        E6 -- Thất bại --> E8[Yêu cầu Admin phân xử]
        E10[Nhận thông báo lý do từ chối & Đóng khiếu nại]
        E13[Nhận tiền hoàn về tài khoản & Đóng khiếu nại]
    end

    subgraph System ["System"]
        E4 --> S1[Chuyển trạng thái đơn thành DISPUTING]
        S1 --> S2[Gửi thông báo khiếu nại đến Film Lab]
        E7 --> S3[Cập nhật kết quả thỏa thuận & Đóng khiếu nại RESOLVED]
        S4[Báo lý do từ chối cho Khách] --> E10
        S5[Cập nhật đơn thành REFUNDED & Đóng khiếu nại] --> E13
    end

    subgraph Lab ["Film Lab Owner"]
        S2 --> L1[Xem chi tiết khiếu nại]
        L1 --> L2[Thương lượng đền bù trực tiếp với Khách]
        L2 --> E6
    end

    subgraph Admin ["System Administrator"]
        E8 --> A1[Tiếp nhận vụ việc khiếu nại]
        A1 --> A2[Tra cứu lịch sử đơn, SLA & ảnh QC lúc nhận film]
        A2 --> A3{Quyết định của Admin?}
        A3 -- Từ chối khiếu nại --> A4[Nhập lý do từ chối] --> S4
        A3 -- Chấp nhận hoàn tiền --> A5[Phê duyệt tỷ lệ hoàn tiền]
    end

    subgraph Payment ["Payment Gateway"]
        A5 --> P1[Gọi API Cổng thanh toán Refund Gateway]
        P1 --> P2[Hoàn tiền về tài khoản Khách hàng]
        P2 --> S5
    end
```
