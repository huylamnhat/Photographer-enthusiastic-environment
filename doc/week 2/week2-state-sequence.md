# WEEK 2 – SƠ ĐỒ TRẠNG THÁI VÀ TƯƠNG TÁC ĐỘNG

> **Dự án:** MiniLab – Nền tảng kết nối cộng đồng nhiếp ảnh phim và các Film Lab  
> **Nhóm thực hiện:** Nhóm 8 (Nhóm 3: Sơ đồ trạng thái & Tương tác động)  
> **Phiên bản:** 2.0 (Đồng bộ hóa 100% với Nghiệp vụ Week 1, Kiến trúc triển khai & Thiết kế CSDL)

---

## 1. Mục tiêu và phạm vi

Tài liệu này đặc tả các khía cạnh hành vi động (Dynamic Behavioral Modeling) của hệ thống MiniLab, bao gồm:
1. **Sơ đồ máy trạng thái (State Machine Diagram):**
   * Vòng tuần hoàn chuyển giao trạng thái của **Đơn hàng tráng/scan (Order Lifecycle)**.
   * Vòng tuần hoàn kiểm duyệt của **Tin đăng thiết bị Marketplace**.
2. **Sơ đồ tuần tự (Sequence Diagram) – 3 kịch bản tương tác quan trọng nhất:**
   * **Kịch bản 1:** Đặt dịch vụ & Thanh toán trực tuyến (tích hợp snapshot giá và xử lý Webhook IPN).
   * **Kịch bản 2:** Lab hoàn thành scan và trả kết quả vào Digital Film Archive (mô hình File Storage trên máy chủ, lưu `storage_key`, phục vụ qua Express Static Files).
   * **Kịch bản 3:** Xử lý khiếu nại & Hoàn tiền tự động (quy trình 3 bước: Tự thương lượng $\rightarrow$ Admin phân xử $\rightarrow$ Hoàn tiền tự động qua Cổng thanh toán).

---

## 2. Máy trạng thái đơn hàng (State Machine – Order)

Sơ đồ mô tả toàn diện chu kỳ sống của một đơn hàng dịch vụ tráng/scan film, từ khi khách khởi tạo đến khi đóng đơn hoặc hủy đơn. Sơ đồ xử lý đầy đủ các nhánh nghiệp vụ thực tế: Pickup thất bại tối đa 2 lần, đề xuất phụ phí phát sinh (Cine ECN-2, Push sáng), trạng thái phức hợp công đoạn tráng/scan, giao nhận 2 chiều và giải quyết tranh chấp.

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

    [*] --> PP : Khách tạo đơn (chọn thanh toán online)
    [*] --> PC : Khách tạo đơn (chọn COD tại quầy khi tự mang)
    PP --> PC : Thanh toán online thành công
    PP --> CA : Quá 24h không thanh toán hoặc khách chủ động hủy
    PC --> CA : Khách hủy hợp lệ (hoàn 100%) hoặc Lab từ chối
    PC --> PK : Lab xác nhận đơn (khách chọn Shipper pickup)
    PC --> AW : Lab xác nhận đơn (khách chọn tự mang đến)
    PK --> PK : Lấy thất bại, hẹn lại (tối đa 2 lần)
    PK --> AW : Thất bại quá 2 lần, chuyển sang tự mang film
    PK --> RC : Shipper bàn giao film an toàn tại Lab
    AW --> RC : Khách mang cuộn film đến gửi tại tiệm Lab
    RC --> SU : Lệch số lượng, film outdate cần Push, film Cine ECN-2
    RC --> CA : Film ẩm mốc/không an toàn, tiệm từ chối nhận
    RC --> PR : Film đạt chuẩn kỹ thuật và đã thanh toán đủ
    SU --> PR : Khách xác nhận đồng ý & thanh toán phụ phí
    SU --> CA : Khách từ chối phụ phí, tiệm hoàn trả lại cuộn film

    state PR {
        direction LR
        [*] --> DV
        state "Tráng, rửa, sấy (Developing)" as DV
        state "Scanning" as SC
        state "Quality_Check" as QC
        state "Blank_Film_Detected" as BF
        DV --> SC : Tráng và sấy film hoàn tất
        SC --> QC : Scan hoàn tất
        QC --> SC : QC lỗi lệch frame/bụi sọc, vệ sinh scan lại
        DV --> BF : Phát hiện cuộn film trắng (không lên hình)
        QC --> [*] : QC đạt chuẩn chất lượng
        BF --> [*] : Hoàn 100% phí scan/in, giữ lại phí tráng
    }

    PR --> CO : Lab tải ảnh scan lên File Storage & nạp vào Archive
    CO --> DE : Khách có yêu cầu nhận lại film âm bản / ảnh in vật lý
    CO --> CL : Khách chỉ nhận file số (tự đóng sau hạn khiếu nại)
    CO --> DI : Khách khiếu nại kết quả số (ảnh scan bị mờ, lỗi màu)
    DE --> DD : Shipper giao hàng vật lý thành công
    DE --> HL : Giao hàng thất bại (khách không nghe máy)
    HL --> DE : Đặt lịch giao lại (khách thanh toán thêm phí ship)
    HL --> DD : Khách đến tiệm Lab nhận trực tiếp
    DD --> CL : Khách xác nhận hài lòng hoặc tự đóng sau 3 ngày
    DD --> DI : Khách khiếu nại hàng vật lý (film trầy xước, thiếu ảnh in)
    DI --> RF : Admin phán quyết chấp nhận bồi thường hoàn tiền
    DI --> CL : Hai bên tự thương lượng thành công hoặc Admin bác khiếu nại
    RF --> CL : Hoàn tất chuyển tiền hoàn qua Cổng thanh toán
    CL --> [*]
    CA --> [*]
```

---

## 3. Máy trạng thái tin đăng Marketplace (State Machine – Marketplace Listing)

Sơ đồ thể hiện quy trình **tiền kiểm 100%** đối với tin đăng bán máy ảnh, ống kính và phụ kiện nhiếp ảnh phim nhằm ngăn chặn tình trạng lừa đảo hoặc thông tin sai lệch:

```mermaid
stateDiagram-v2
    state "Chờ duyệt (Pending_Approval)" as PA
    state "Đang hiển thị (Active)" as AC
    state "Bị từ chối (Rejected)" as RJ
    state "Đã bán (Sold)" as SO
    state "Đã gỡ (Removed)" as RM

    [*] --> PA : Người bán đăng tin (bắt buộc tối thiểu 3 ảnh thật & mô tả cơ học)
    PA --> AC : Admin tiền kiểm đạt chuẩn (duyệt hiển thị lên sàn)
    PA --> RJ : Admin từ chối (ảnh mờ, thiếu thông số, nội dung vi phạm) kèm lý do
    RJ --> PA : Người bán chỉnh sửa bổ sung thông tin & gửi duyệt lại
    AC --> PA : Người bán sửa đổi thông tin trọng yếu (giá, ảnh, tình trạng máy)
    AC --> SO : Người bán đánh dấu thiết bị đã bán thành công
    AC --> RM : Admin gỡ bỏ khi bị người dùng báo cáo vi phạm hoặc người bán chủ động xóa
    SO --> [*]
    RM --> [*]
```

---

## 4. Sequence 1 – Đặt dịch vụ và thanh toán trực tuyến

Kịch bản mô tả sự phối hợp giữa Khách hàng, Ứng dụng Flutter, Backend Node.js, Đối tác giao vận (Ahamove/Lalamove), Cổng thanh toán (VNPAY/MoMo) và Cơ sở dữ liệu SQL Server. Kịch bản làm rõ cơ chế **Price Snapshotting** và xử lý **Webhook IPN** đa nhánh:

```mermaid
sequenceDiagram
    autonumber
    actor KH as Khách hàng
    participant APP as Customer App (Flutter)
    participant BE as Backend API (Node.js)
    participant SH as API vận chuyển (Ahamove/Lalamove)
    participant PG as Cổng thanh toán (VNPAY/MoMo)
    participant DB as SQL Server

    KH->>APP: Chọn Lab, gói dịch vụ, số cuộn, cách gửi film & in ảnh
    APP->>BE: POST /api/orders (JWT, chi tiết đơn hàng)
    BE->>DB: Truy vấn bảng giá niêm yết hiện hành của Film Lab
    DB-->>BE: Giá gói cơ bản, phụ phí push/scan, đơn giá in ảnh
    BE->>BE: Tính tổng tiền dịch vụ = (Đơn giá x Số cuộn) + Phụ phí + Tiền in
    opt Khách chọn phương thức Shipper Pickup
        BE->>SH: Tính phí giao vận (theo tọa độ/địa chỉ khách và Lab)
        SH-->>BE: Cước phí vận chuyển ước tính
    end
    BE->>DB: Lưu Orders + Order_Items (Price Snapshotting), trạng thái PENDING_PAYMENT
    DB-->>BE: Trả về Order_ID và Mã đơn hàng
    alt Thanh toán COD (chỉ áp dụng khi khách tự mang film đến gửi tại quầy)
        BE->>DB: Cập nhật Order = PENDING_CONFIRMATION
        BE-->>APP: Đặt đơn thành công, gửi film và thanh toán tại tiệm
    else Thanh toán trực tuyến (Online qua Ví/Thẻ/QR)
        BE->>PG: Khởi tạo giao dịch (Order_ID, Total_Amount, Chữ ký số HMAC)
        PG-->>BE: Trả về Payment_URL
        BE-->>APP: Chuyển tiếp Payment_URL cho ứng dụng
        APP-->>KH: Điều hướng sang trang thanh toán VNPAY / MoMo
        KH->>PG: Nhập OTP / Quét mã QR xác thực thanh toán
        alt Thanh toán thành công
            PG->>BE: Webhook IPN (Order_ID, Transaction_ID, SUCCESS, Checksum)
            BE->>BE: Kiểm tra chữ ký Checksum, đối soát số tiền thanh toán
            BE->>DB: Lưu Payment (COMPLETED), Order = PENDING_CONFIRMATION
            BE-->>PG: Phản hồi IPN: 200 OK
            BE-->>APP: Push Notification: Đặt đơn thành công, chờ Lab tiếp nhận
            APP-->>KH: Hiển thị màn hình theo dõi đơn hàng thời gian thực
        else Thanh toán thất bại / Người dùng hủy
            PG->>BE: Webhook IPN (FAILED / CANCELLED)
            BE->>DB: Lưu Payment (FAILED), giữ nguyên trạng thái PENDING_PAYMENT
            BE-->>APP: Báo lỗi giao dịch, hiển thị nút "Thanh toán lại"
            Note over BE,DB: Quá 24 giờ không thanh toán, Cron Job tự động hủy đơn (CANCELLED)
        end
    end
```

---

## 5. Sequence 2 – Lab hoàn thành scan và trả kết quả vào Archive (Mô hình File Storage)

Kịch bản mô tả quy trình sau khi hoàn thành tráng và kiểm tra chất lượng (QC). Film Lab tải tệp ảnh scan gốc (.JPG chất lượng cao, .TIFF 16-bit) lên hệ thống lưu trữ tệp (**File Storage trên Server** qua Multer). Hệ thống tự động ghi nhận đường dẫn `storage_key` vào SQL Server, nạp ảnh vào Digital Film Archive của khách hàng và hỗ trợ cơ chế **Thu hồi & Ghi đè (Revoke & Replace)** trong 24 giờ nếu tải nhầm file:

```mermaid
sequenceDiagram
    autonumber
    actor LS as Lab Staff / Owner
    participant WP as Lab Web Portal (Flutter Web)
    participant BE as Backend API (Node.js)
    participant FS as File Storage (Server /uploads/)
    participant DB as SQL Server (Digital Archive)
    participant FB as Firebase Push & Email
    participant CA as Customer App

    LS->>WP: Chọn Order_ID (đã QC đạt), chọn tệp scan (.JPG/.TIFF)
    WP->>BE: POST /api/lab/orders/{id}/upload-scans (Multipart/Form-Data)
    BE->>BE: Kiểm tra JWT, vai trò Lab Owner, đơn thuộc tiệm, trạng thái PROCESSING
    BE->>FS: Multer stream & lưu tệp vật lý vào /uploads/scans/order_{id}/
    Note over WP,BE: Hỗ trợ upload nhiều file đồng thời, tạo relative storage_key
    FS-->>BE: Lưu tệp thành công (trả về storage_key, size_bytes, width, height)
    BE->>DB: Lưu Scan_File, Digital_Film_Archive, Archive_Photo, Photo_Metadata
    BE->>DB: Cập nhật Order = COMPLETED (đã nạp file scan vào Archive)
    BE->>FB: Kích hoạt gửi Push Notification & Email thông báo kết quả
    FB-->>CA: Thông báo đẩy: "Cuộn film của bạn đã được tráng và nạp vào Archive!"
    BE-->>WP: 200 OK, hiển thị giao kết quả thành công

    Note over LS,CA: Khách mở Digital Film Archive trên Customer App
    CA->>BE: GET /api/archive/photos (JWT Token)
    BE->>BE: Xác thực JWT và kiểm tra quyền sở hữu ảnh (owner_id = user_id)
    BE->>DB: Truy vấn danh sách ảnh và thông số metadata (máy, lens, ISO, film)
    DB-->>BE: Danh sách ảnh (storage_key, thumbnail_key, metadata)
    BE-->>CA: Trả về danh sách ảnh dạng lưới (Gallery View) + đường dẫn tải
    CA->>FS: Tải ảnh xem trước / tải file gốc qua Express Static Files
    FS-->>CA: Trả về dữ liệu ảnh (.JPG độ phân giải cao / .TIFF 16-bit)

    opt Lab phát hiện upload nhầm file của khách khác (trong vòng 24 giờ)
        LS->>WP: Bấm "Thu hồi & Cập nhật lại file scan" (chọn tệp đúng)
        WP->>BE: PUT /api/lab/orders/{id}/revoke-and-replace (Multipart New Files)
        BE->>FS: Ghi đè file đúng vào /uploads/scans/order_{id}/
        BE->>DB: Thu hồi link cũ, cập nhật storage_key mới trong Archive, ghi Audit Log
        BE->>FB: Gửi thông báo đính chính cho khách hàng
        FB-->>CA: Push notification: "Lab đã cập nhật bản scan đính chính cho bạn"
    end
```

---

## 6. Sequence 3 – Xử lý khiếu nại và hoàn tiền tự động

Kịch bản mô tả quy trình 3 bước giải quyết tranh chấp theo đúng quy định phân quyền hệ thống (RBAC):
1. **Bước 1:** Khách hàng gửi khiếu nại kèm hình ảnh bằng chứng lỗi.
2. **Bước 2 (Tự thương lượng):** Khách hàng và Film Lab trực tiếp trao đổi phương án đền bù (voucher, tặng cuộn film mới, chụp bù). Nếu khách đồng ý $\rightarrow$ Đóng khiếu nại thỏa thuận.
3. **Bước 3 (Admin can thiệp phân xử):** Nếu hai bên bất đồng $\rightarrow$ Chuyển Admin phân xử $\rightarrow$ Admin xin quyền đồng thuận mở ảnh QC lúc nhận film và ảnh scan làm chứng cứ $\rightarrow$ Ra phán quyết bồi thường $\rightarrow$ Kích hoạt Cổng thanh toán (VNPay/MoMo) hoàn tiền tự động về tài khoản khách hàng trong 3–5 ngày làm việc $\rightarrow$ Ghi Audit Log toàn bộ thao tác:

```mermaid
sequenceDiagram
    autonumber
    actor KH as Khách hàng (Customer App)
    actor LAB as Chủ Film Lab (Film Lab Owner)
    participant BE as Backend API (Node.js)
    participant DB as SQL Server
    actor AD as Quản trị viên (System Administrator)
    participant PG as Cổng thanh toán (Payment API)

    KH->>BE: POST /api/orders/{id}/disputes (Lý do, hình ảnh bằng chứng)
    BE->>BE: Kiểm tra đơn thuộc khách, trạng thái COMPLETED/DELIVERED, còn trong hạn
    BE->>DB: Tạo Dispute_Complaint (NEGOTIATING), cập nhật Order = DISPUTED
    BE->>LAB: Gửi thông báo: Có khiếu nại mới phát sinh trên đơn hàng
    Note over KH,LAB: Bước 1: Tự thương lượng - Lab chủ động trao đổi giải pháp đền bù
    LAB->>BE: Đề xuất phương án đền bù (voucher giảm giá / đền cuộn film mới / chụp bù)
    BE-->>KH: Thông báo đề xuất đền bù của Film Lab
    alt Khách hàng chấp nhận giải pháp tự thương lượng
        KH->>BE: Xác nhận đồng ý thỏa thuận
        BE->>DB: Cập nhật Dispute = RESOLVED (Thỏa thuận thành công), Order = CLOSED
        BE-->>KH: Đóng khiếu nại, thông báo hoàn tất cho hai bên
    else Hai bên bất đồng, không đạt thỏa thuận
        KH->>BE: Bấm "Yêu cầu Admin can thiệp phân xử"
        BE->>DB: Cập nhật Dispute = ESCALATED
        BE->>AD: Hiển thị hồ sơ tranh chấp trên Admin Dashboard
        AD->>BE: Yêu cầu mở ảnh QC lúc Lab nhận film và ảnh scan làm chứng cứ
        BE-->>KH: Gửi yêu cầu xác nhận mở ảnh làm chứng cứ
        BE-->>LAB: Gửi yêu cầu xác nhận mở ảnh làm chứng cứ
        KH->>BE: Đồng ý mở ảnh
        LAB->>BE: Đồng ý mở ảnh
        BE->>DB: Cấp quyền xem tạm thời hồ sơ chứng cứ cho Admin (ghi Audit Log)
        BE-->>AD: Trả về hồ sơ đối soát: Dòng thời gian SLA, ảnh QC lúc nhận, ảnh scan
        AD->>AD: Đánh giá lỗi kỹ thuật có thuộc trách nhiệm của Film Lab không
        alt Lỗi thuộc trách nhiệm Film Lab (hỏng film, mất kiểu, lỗi hóa chất)
            AD->>BE: Phán quyết bồi thường & Phê duyệt tỷ lệ hoàn tiền
            BE->>DB: Lưu phán quyết, ghi Audit Log, cập nhật Refund = APPROVED
            BE->>DB: Tạo bản ghi Refund_Transactions (trạng thái REFUND_PROCESSING)
            BE->>PG: Gọi API hoàn tiền tự động (Gateway_Transaction_ID, Amount)
            alt Cổng thanh toán xử lý hoàn tiền thành công
                PG-->>BE: REFUND_SUCCESS (Mã giao dịch hoàn tiền)
                BE->>DB: Cập nhật Refund = COMPLETED, Order = REFUNDED, Dispute = RESOLVED
                BE-->>KH: Tiền hoàn về tài khoản/ví ban đầu trong 3-5 ngày làm việc
                BE-->>LAB: Thông báo kết quả phân xử và khấu trừ tiền hoàn
            else Giao dịch hoàn tiền lỗi
                PG-->>BE: REFUND_FAILED
                BE->>DB: Cập nhật Refund = FAILED, cảnh báo Admin xử lý thủ công
            end
        else Lỗi không thuộc Film Lab (film outdate, máy khách hỏng cơ, đo sáng sai)
            AD->>BE: Bác khiếu nại kèm văn bản giải thích lý do
            BE->>DB: Cập nhật Dispute = RESOLVED (Bác khiếu nại), ghi Audit Log
            BE-->>KH: Thông báo từ chối khiếu nại và lý do phân xử
            BE-->>LAB: Thông báo kết quả giải quyết tranh chấp
        end
    end
    Note over LAB,AD: Nếu Film Lab cố tình từ chối đền bù thỏa đáng, Admin tiến hành khóa tài khoản Lab
```

---

## 7. Kết luận và Ma trận đồng bộ với CSDL & Kiến trúc

| Kịch bản / Trạng thái | Bảng CSDL SQL Server tương ứng | Thành phần hạ tầng thực thi |
| --- | --- | --- |
| **Pending_Payment $\rightarrow$ Pending_Confirmation** | `Orders.status`, `Payment` (lưu mã giao dịch và trạng thái) | Frontend App $\rightarrow$ Express API $\rightarrow$ VNPay/MoMo Webhook $\rightarrow$ SQL Server |
| **Pickup $\rightarrow$ Received_at_Lab** | `Shipment` (chiều 1), `Order_Process_Step` (step `RECEIVE` kèm `evidence_photo_url`) | Ahamove/Lalamove API $\rightarrow$ Shipper Mobile $\rightarrow$ Web Portal của Lab |
| **Processing (Tráng, Sấy, Scan, QC)** | `Order_Process_Step` (lưu tiến độ chi tiết và thời gian hoàn thành từng bước) | Lab Web Portal $\rightarrow$ Express API $\rightarrow$ SQL Server |
| **Upload scan $\rightarrow$ Archive** | `Scan_File`, `Digital_Film_Archive`, `Archive_Photo` (`storage_key`), `Photo_Metadata` | Lab Web Portal $\rightarrow$ Multer $\rightarrow$ Thư mục `/uploads/scans/` trên Server $\rightarrow$ SQL Server $\rightarrow$ FCM Push |
| **Giao trả vật lý (Delivering $\rightarrow$ Delivered)** | `Shipment` (chiều 2), `Orders.return_method` | Express API $\rightarrow$ Ahamove/Lalamove $\rightarrow$ Khách nhận hàng |
| **Tranh chấp & Hoàn tiền** | `Dispute_Complaint`, `Dispute_Message`, `Dispute_Evidence`, `Refund`, `Audit_Log` | Admin Web Portal $\rightarrow$ Express API $\rightarrow$ Payment Refund API $\rightarrow$ SQL Server |
