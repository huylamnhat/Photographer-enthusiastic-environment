# Week 2 - Sơ đồ trạng thái và tương tác động (Issue #14)

## 1. State Machine - Order

```mermaid
stateDiagram-v2
    direction TB
    state "Chờ thanh toán (Pending_Payment)" as PP
    state "Chờ Lab xác nhận (Pending_Confirmation)" as PC
    state "Đang lấy film (Pickup_In_Progress)" as PK
    state "Chờ khách mang film (Awaiting_Dropoff)" as AW
    state "Đã nhận film tại Lab (Received_at_Lab)" as RC
    state "Chờ khách duyệt phụ phí (Pending_Surcharge)" as SU
    state "Đang xử lý (Processing)" as PR
    state "Hoàn thành - đã nạp file scan (Completed)" as CO
    state "Đang giao hàng (Delivering)" as DE
    state "Giao thất bại, lưu tại Lab (Held_at_Lab)" as HL
    state "Đã giao (Delivered)" as DD
    state "Đang khiếu nại (Disputed)" as DI
    state "Đã hoàn tiền (Refunded)" as RF
    state "Đóng đơn (Closed)" as CL
    state "Đã hủy (Cancelled)" as CA

    [*] --> PP : Khách tạo đơn
    PP --> PC : Thanh toán online thành công
    PP --> CA : Quá 24h hoặc khách hủy
    PC --> CA : Khách hủy hoặc Lab từ chối
    PC --> PK : Lab xác nhận, gán shipper
    PC --> RC : Drop-off (COD thu tại quầy)
    PK --> PK : Lấy thất bại, hẹn lại (tối đa 2 lần)
    PK --> AW : Thất bại quá 2 lần
    PK --> RC : Shipper bàn giao film
    AW --> RC : Khách mang film đến
    RC --> SU : Lệch số lượng, outdate, ECN-2
    RC --> CA : Film không an toàn, từ chối nhận
    RC --> PR : Film đạt chuẩn và đã thanh toán
    SU --> PR : Khách duyệt và thanh toán phụ phí
    SU --> CA : Khách từ chối phụ phí, trả lại film

    state PR {
        direction LR
        [*] --> DV
        state "Tráng, rửa, sấy (Developing)" as DV
        state "Scanning" as SC
        state "Quality_Check" as QC
        state "Blank_Film_Detected" as BF
        DV --> SC : Tráng xong
        SC --> QC : Scan xong
        QC --> SC : QC lỗi, scan lại
        DV --> BF : Film trắng
        QC --> [*] : QC đạt
        BF --> [*] : Hoàn phí scan/in, giữ phí tráng
    }

    PR --> CO : Lab upload file scan vào Archive
    CO --> DE : Khách nhận lại âm bản / ảnh in
    CO --> CL : Chỉ lấy file scan hoặc quá hạn khiếu nại
    CO --> DI : Khiếu nại (scan lỗi, mờ)
    DE --> DD : Giao thành công
    DE --> HL : Giao thất bại
    HL --> DE : Đặt lại giao (trả phí ship)
    HL --> DD : Khách đến Lab nhận
    DD --> CL : Khách xác nhận hoặc tự đóng sau N ngày
    DD --> DI : Khiếu nại (film trầy, mất kiểu)
    DI --> RF : Admin phán quyết hoàn tiền
    DI --> CL : Thương lượng được hoặc Admin bác
    RF --> CL : Hoàn tất
    CL --> [*]
    CA --> [*]
```

## 2. State Machine - Tin đăng Marketplace (tùy chọn)

```mermaid
stateDiagram-v2
    state "Chờ duyệt (Pending_Approval)" as PA
    state "Đang hiển thị (Active)" as AC
    state "Bị từ chối (Rejected)" as RJ
    state "Đã bán (Sold)" as SO
    state "Đã gỡ (Removed)" as RM

    [*] --> PA : Người bán đăng tin (tối thiểu 3 ảnh thật)
    PA --> AC : Admin duyệt (tiền kiểm 100%)
    PA --> RJ : Admin từ chối kèm lý do
    RJ --> PA : Người bán sửa và gửi lại
    AC --> PA : Sửa thông tin quan trọng, duyệt lại
    AC --> SO : Người bán đánh dấu đã bán
    AC --> RM : Admin gỡ (vi phạm) hoặc người bán xóa
    SO --> [*]
    RM --> [*]
```

## 3. Sequence 1 - Đặt dịch vụ và thanh toán trực tuyến

```mermaid
sequenceDiagram
    autonumber
    actor KH as Khách hàng
    participant APP as Customer App (Flutter)
    participant BE as Backend API (Node.js)
    participant SH as API vận chuyển (Ahamove/Lalamove)
    participant PG as Cổng thanh toán (VNPAY/MoMo)
    participant DB as SQL Server

    KH->>APP: Chọn Lab, dịch vụ, số cuộn, cách gửi film
    APP->>BE: POST /api/orders (JWT, thông tin đơn)
    BE->>DB: Truy vấn bảng giá hiện hành của Lab
    DB-->>BE: Giá gói, phụ phí push/scan
    BE->>BE: Tính tổng tiền (giá cuộn + phụ phí + in ảnh)
    opt Khách chọn Pickup
        BE->>SH: Tính phí giao nhận (địa chỉ lấy film)
        SH-->>BE: Phí vận chuyển
    end
    BE->>DB: Lưu Order + Order_Items (snapshot giá), PENDING_PAYMENT
    DB-->>BE: Order_ID
    alt COD (chỉ khi khách tự mang film đến)
        BE->>DB: Order = PENDING_CONFIRMATION
        BE-->>APP: Đặt đơn thành công, thanh toán tại quầy
    else Thanh toán online
        BE->>PG: Tạo URL thanh toán (Order_ID, Amount, chữ ký)
        PG-->>BE: Payment_URL
        BE-->>APP: Trả về Payment_URL
        APP-->>KH: Chuyển sang trang VNPAY / MoMo
        KH->>PG: Nhập OTP, xác thực giao dịch
        alt Thanh toán thành công
            PG->>BE: Webhook IPN (Order_ID, SUCCESS, checksum)
            BE->>BE: Xác thực checksum, đối chiếu số tiền
            BE->>DB: Lưu Transaction_History, Order = PENDING_CONFIRMATION
            BE-->>PG: Phản hồi IPN 200 OK
            BE-->>APP: Push: đặt đơn thành công, chờ Lab xác nhận
            APP-->>KH: Hiển thị màn hình theo dõi đơn hàng
        else Thất bại, hủy hoặc hết hạn
            PG->>BE: Webhook IPN (FAILED)
            BE->>DB: Lưu giao dịch thất bại, giữ PENDING_PAYMENT
            BE-->>APP: Báo lỗi cụ thể, cho phép Thanh toán lại
            Note over BE,DB: Quá 24h chưa thanh toán, job tự động chuyển đơn sang CANCELLED
        end
    end
```

## 4. Sequence 2 - Lab hoàn thành scan và trả kết quả vào Archive

```mermaid
sequenceDiagram
    autonumber
    actor LS as Lab Staff / Owner
    participant WP as Lab Web Portal (Flutter Web)
    participant BE as Backend API (Node.js)
    participant CS as Cloud Storage (S3/R2)
    participant DB as SQL Server (Digital Archive)
    participant FB as Firebase Push
    participant CA as Customer App

    LS->>WP: Chọn Order_ID (đã QC đạt), bấm Upload file scan
    WP->>BE: POST /api/lab/orders/{id}/upload-request
    BE->>BE: Kiểm tra JWT, vai trò Lab, đơn thuộc Lab, đang PROCESSING
    BE->>CS: Tạo Pre-signed URL (resumable, key theo Order/Roll)
    CS-->>BE: Pre-signed Upload URL
    BE-->>WP: Trả về Pre-signed URL
    WP->>CS: Tải trực tiếp file ZIP / ảnh (chunked)
    Note over WP,CS: Mất mạng thì bấm Thử lại, tải tiếp đoạn dở (Resumable Upload)
    CS-->>WP: Upload hoàn tất (200 OK, file metadata)
    WP->>BE: POST /complete-scan (File_Keys, Roll_Info)
    BE->>CS: Kiểm tra file tồn tại, khớp dung lượng
    CS-->>BE: Xác nhận OK
    BE->>DB: Lưu Digital_Film_Archive, Photo_Metadata (Order, Customer)
    BE->>DB: Order = COMPLETED (đã nạp file scan)
    BE->>FB: Gửi push: đã có ảnh scan cho cuộn phim của bạn
    FB-->>CA: Thông báo đẩy (kèm email thông báo)
    BE-->>WP: 200 OK, hiển thị đã giao file

    Note over LS,CA: Khách mở Digital Film Archive trên Customer App
    CA->>BE: GET /api/archive/photos (JWT)
    BE->>BE: Kiểm tra JWT và quyền sở hữu ảnh
    BE->>DB: Truy vấn ảnh và metadata của khách
    DB-->>BE: Danh sách ảnh
    BE->>CS: Tạo Pre-signed View URL (hạn 30 phút)
    CS-->>BE: Signed Image URLs
    BE-->>CA: Danh sách ảnh dạng lưới + nút tải file gốc

    opt Lab tải nhầm file, trong vòng 24h
        LS->>WP: Bấm Cập nhật lại file scan
        WP->>BE: PUT /orders/{id}/revoke-and-replace
        BE->>DB: Thu hồi link cũ trong Archive, ghi Audit Log
        BE->>FB: Gửi thông báo đính chính
        FB-->>CA: Lab đã cập nhật bản scan đúng
    end
```

## 5. Sequence 3 - Xử lý khiếu nại và hoàn tiền

```mermaid
sequenceDiagram
    autonumber
    actor KH as Khách hàng (Customer App)
    actor LAB as Film Lab Owner
    participant BE as Backend API (Node.js)
    participant DB as SQL Server
    actor AD as System Administrator
    participant PG as Payment Gateway API

    KH->>BE: POST /api/orders/{id}/disputes (lý do, ảnh)
    BE->>BE: Kiểm tra đơn thuộc khách, còn trong hạn khiếu nại
    BE->>DB: Tạo Dispute_Complaint (NEGOTIATING), Order = DISPUTED
    BE->>LAB: Thông báo có khiếu nại mới
    Note over KH,LAB: Thương lượng - Lab và khách tự thỏa thuận đền bù (film mới / voucher)
    LAB->>BE: Đề xuất đền bù
    BE-->>KH: Thông báo đề xuất của Lab
    alt Khách chấp nhận
        KH->>BE: Chấp nhận đề xuất
        BE->>DB: Dispute = RESOLVED (thỏa thuận)
        BE-->>KH: Đóng khiếu nại, thông báo hai bên
    else Không đạt thỏa thuận
        KH->>BE: Yêu cầu Admin phân xử
        BE->>DB: Dispute = ESCALATED_TO_ADMIN
        BE->>AD: Hiển thị đơn tranh chấp trên Admin Dashboard
        AD->>BE: Yêu cầu mở ảnh QC lúc nhận film và ảnh scan
        BE-->>KH: Xin đồng ý mở ảnh làm chứng cứ
        BE-->>LAB: Xin đồng ý mở ảnh làm chứng cứ
        KH->>BE: Đồng ý
        LAB->>BE: Đồng ý
        BE->>DB: Cấp quyền xem tạm thời file của Order_ID
        BE-->>AD: Hồ sơ đơn và chứng cứ
        AD->>AD: Đánh giá lỗi có thuộc trách nhiệm Lab không
        alt Lỗi thuộc Lab
            AD->>BE: Phán quyết đền bù (toàn bộ / một phần)
            BE->>DB: Lưu phán quyết, Audit Log, Refund_Approved
            BE->>DB: Tạo Refund_Transactions (Refund_Processing)
            BE->>PG: Gọi API hoàn tiền (Transaction_ID, Amount)
            alt Hoàn tiền thành công
                PG-->>BE: REFUND_SUCCESS
                BE->>DB: Refund_Success, Order = REFUNDED, Dispute = RESOLVED
                BE-->>KH: Tiền hoàn về ví/thẻ trong 3-5 ngày làm việc
                BE-->>LAB: Thông báo kết quả phán quyết
            else Hoàn tiền thất bại
                PG-->>BE: REFUND_FAILED
                BE->>DB: Refund_Failed, cảnh báo Admin xử lý thủ công
            end
        else Lỗi không thuộc Lab
            AD->>BE: Bác khiếu nại kèm lý do
            BE->>DB: Dispute = RESOLVED (bác), ghi Audit Log
            BE-->>KH: Thông báo kết quả
        end
    end
    Note over LAB,AD: Lab cố tình từ chối đền bù thỏa đáng thì Admin khóa tài khoản Lab
``` 