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
        
        UC9(Xác nhận đơn hàng)
        UC10(Quản lý hồ sơ Lab)
        UC11(Cập nhật công đoạn tráng/scan)
        UC12(Upload file scan lên Cloud)
        UC13(Xem báo cáo vận hành)
        UC14(Cấu hình gói dịch vụ & bảng giá)
        UC15(Thương lượng khiếu nại)

        UC16(Đăng bài viết chuyên môn)
        UC17(Tổ chức Workshop & Photowalk)

        UC18(Nhận đơn pickup)
        UC19(Giao nhận film 2 chiều)

        UC20(Duyệt hồ sơ đối tác)
        UC21(Kiểm duyệt tiền kiểm Marketplace)
        UC22(Quản lý tài khoản)
        UC23(Xử lý khiếu nại & Hoàn tiền)
        UC24(Hậu kiểm bài viết)
        UC25(Xem Dashboard)
    end

    Customer --> UC1
    Customer --> UC2
    Customer --> UC3
    Customer --> UC4
    Customer --> UC5
    Customer --> UC6
    Customer --> UC7
    Customer --> UC8

    Lab --> UC9
    Lab --> UC10
    Lab --> UC11
    Lab --> UC12
    Lab --> UC13
    Lab --> UC14
    Lab --> UC15

    Expert --> UC16
    Expert --> UC17

    Shipper --> UC18
    Shipper --> UC19

    Admin --> UC20
    Admin --> UC21
    Admin --> UC22
    Admin --> UC23
    Admin --> UC24
    Admin --> UC25
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
    Customer --> UC_Pay
    UC_PayOnline --|> UC_Pay
    UC_PayCOD --|> UC_Pay
    UC_PayRetry -.->|extend| UC_PayOnline
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
        A1[Tìm & chọn Film Lab] --> A2[Chọn gói dịch vụ & phương thức gửi film]
        A2 --> A3[Xác nhận đặt đơn hàng]
        A4[Thực hiện thanh toán online / COD]
        A5[Nhận thông báo & Xem/Tải ảnh từ Digital Archive] --> A6[Đánh giá Lab & Hoàn thành đơn hàng]
    end

    subgraph Payment ["Payment Gateway"]
        A3 --> B1[Khởi tạo giao dịch thanh toán]
        B1 --> A4
        B2{Thanh toán thành công?}
        B2 -- Thất bại / Hủy --> B3[Báo lỗi giao dịch & Hủy đơn]
        B2 -- Thành công --> B4[Cập nhật trạng thái Đã thanh toán]
        B5[Lưu file scan lên Cloud & Đồng bộ Digital Archive] --> A5
    end

    subgraph Shipper ["Delivery Partner"]
        B4 --> C1[Tiếp nhận vận đơn lấy film]
        C1 --> C2[Đến lấy film từ Khách hàng]
        C2 --> C3[Vận chuyển & Giao film đến Film Lab]
    end

    subgraph Lab ["Film Lab Owner"]
        C3 --> D1[Tiếp nhận film & Chụp ảnh kiểm tra QC]
        D1 --> D2[Xác nhận đơn hàng trên hệ thống]
        D2 --> D3[Tiến hành tráng & scan film]
        D3 --> D4[Tải file scan lên hệ thống]
        D4 --> B5
    end

    A4 --> B2
```

### 3.2. Quy trình khiếu nại & hoàn tiền

```mermaid
graph TD
    subgraph Customer ["Customer"]
        E1[Phát hiện sự cố đơn hàng] --> E2[Chọn Tạo khiếu nại & Tải ảnh bằng chứng]
        E2 --> E3[Gửi yêu cầu khiếu nại]
        E5{Hai bên tự thương lượng?}
        E5 -- Thành công --> E6[Xác nhận thỏa thuận & Đóng khiếu nại]
        E5 -- Thất bại --> E7[Yêu cầu Admin phân xử]
        E9[Nhận thông báo từ chối & Đóng khiếu nại]
        E12[Nhận tiền hoàn & Đóng khiếu nại]
    end

    subgraph Lab ["Film Lab Owner"]
        E3 --> E4[Xem thông tin khiếu nại & Thương lượng trực tiếp với Customer]
        E4 --> E5
    end

    subgraph Admin ["System Administrator"]
        E7 --> E8[Tiếp nhận tranh chấp & Đối soát chứng cứ kiểm tra QC]
        E8 --> E10{Quyết định phân xử}
        E10 -- Từ chối --> E9
        E10 -- Chấp nhận hoàn tiền --> E11[Phê duyệt tỷ lệ hoàn tiền]
    end

    subgraph Payment ["Payment Gateway"]
        E11 --> F1[Gọi API thực hiện hoàn tiền tự động]
        F1 --> E12
    end
```
