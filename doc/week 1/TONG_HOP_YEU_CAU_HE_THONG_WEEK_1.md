# TỔNG HỢP ĐẶC TẢ YÊU CẦU HỆ THỐNG
> **Nền tảng kết nối cộng đồng nhiếp ảnh phim và các Film Lab (MiniLab)**  
> *Đồ án Term Project — Nhóm 8*

---

## MỤC LỤC

1. [Phân hệ Khách hàng / Nhiếp ảnh gia (Photographer / Customer)](#1-phân-hệ-khách-hàng--nhiếp-ảnh-gia-photographer--customer)
2. [Phân hệ Quản trị vận hành Film Lab (Film Lab Owner)](#2-phân-hệ-quản-trị-vận-hành-film-lab-film-lab-owner)
3. [Phân hệ Chuyên gia nhiếp ảnh & Cộng đồng (Photography Expert & Community)](#3-phân-hệ-chuyên-gia-nhiếp-ảnh--cộng-đồng-photography-expert--community)
4. [Phân hệ Đối tác vận chuyển (Delivery Partner)](#4-phân-hệ-đối-tác-vận-chuyển-delivery-partner)
5. [Phân hệ Quản trị hệ thống (System Administrator)](#5-phân-hệ-quản-trị-hệ-thống-system-administrator)
6. [Sàn trao đổi thiết bị (Marketplace)](#6-sàn-trao-đổi-thiết-bị-marketplace)
7. [Ma trận phân quyền hệ thống (RBAC)](#7-ma-trận-phân-quyền-hệ-thống-rbac)

---

## 1. PHÂN HỆ KHÁCH HÀNG / NHIẾP ẢNH GIA (PHOTOGRAPHER / CUSTOMER)

### 1.1 Đăng ký, Đăng nhập, Validation & Quản lý tài khoản
* **Thông tin đăng ký:**
  * Bắt buộc: Họ tên, Email, Số điện thoại, Mật khẩu.
  * Tùy chọn (bổ sung sau): Ảnh đại diện, địa chỉ nhận/gửi film mặc định, sở thích nhiếp ảnh (dòng máy cơ, loại film hay dùng).
* **Quy tắc kiểm tra hợp lệ (Validation):**
  * Mật khẩu tối thiểu 8 ký tự, bao gồm cả chữ và số.
  * Email đúng định dạng tiêu chuẩn.
  * Số điện thoại đúng định dạng 10 chữ số.
* **Xử lý tài khoản đã tồn tại:** Nếu Email đã tồn tại trong hệ thống, báo lỗi ngay: *"Email này đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng chức năng Quên mật khẩu."*
* **Quên mật khẩu:** Khách nhập Email/SĐT đã đăng ký -> Hệ thống gửi liên kết đặt lại mật khẩu (có thời hạn 15 phút) hoặc mã OTP để tạo mật khẩu mới.
* **Quy định chỉnh sửa thông tin:**
  * Khách hàng được tự sửa: Họ tên, Mật khẩu, Ảnh đại diện, Địa chỉ nhận hàng, Số điện thoại (đổi SĐT phải xác thực lại OTP).
  * Email là định danh duy nhất của tài khoản: Khách hàng không được tự sửa trên ứng dụng; nếu muốn đổi phải liên hệ Quản trị viên để hỗ trợ.

### 1.2 Tìm kiếm và So sánh Film Lab
* **Tiêu chí tìm kiếm:**
  * Theo tên: Thanh tìm kiếm (Search Bar) theo tên tiệm Lab.
  * Theo vị trí: Tìm theo Tỉnh/Thành phố, Quận/Huyện.
  * Theo dịch vụ: Tráng film màu (C-41), tráng đen trắng (B&W), film điện ảnh (ECN-2), film slide (E-6), scan độ phân giải cao, in ảnh, hỗ trợ film 135 (35mm), 120 (Medium Format), 110.
* **Tiêu chí so sánh:**
  * Giá cả dịch vụ (sắp xếp từ thấp đến cao).
  * Điểm đánh giá (Rating) và số lượng nhận xét từ cộng đồng.
  * Thời gian xử lý dự kiến theo cam kết SLA (VD: 24h, 48h, 72h, 15 ngày cho film slide).
  * Chất lượng scan và có hỗ trợ lấy film tận nơi (Pickup) hay không.
* **Bảng giá công khai:** Trang chi tiết của Film Lab hiển thị đầy đủ bảng giá các gói và phụ phí để khách hàng tham khảo trước khi đặt đơn.
* **Xử lý khi không tìm thấy Lab:** Hiển thị thông báo *"Không tìm thấy Lab phù hợp"* kèm gợi ý mở rộng phạm vi tìm kiếm hoặc hiển thị danh sách các Film Lab uy tín toàn quốc hỗ trợ nhận đơn bưu điện.

### 1.3 Đặt dịch vụ trực tuyến & Công thức tính giá
* **Thông tin đầu vào khi đặt dịch vụ:**
  * Chọn khổ film (135, 120, 110) và số lượng cuộn.
  * Gói dịch vụ: Tráng + Scan (mặc định), hoặc Chỉ tráng (không scan).
  * Tùy chọn nâng cao: Độ phân giải scan (Standard JPG, High-Res JPG, TIFF 16-bit), xử lý đẩy/kéo sáng (Push/Pull).
  * Yêu cầu in ảnh: Kích thước ảnh in (10x15, 13x18, 20x30), số lượng bản in.
  * Phương thức gửi film: Tự mang đến tiệm (Drop-off) hoặc Shipper đến lấy tận nơi (Pickup).
  * Ghi chú đơn hàng cho Lab.
* **Công thức tính giá minh bạch:**
  ```
  Tổng tiền = (Giá gói cơ bản × Số cuộn)
            + (Phụ phí Scan Hi-res/Push × Số cuộn)
            + (Giá in ảnh × Số ảnh in)
            + Phí giao nhận (nếu có)
  ```

### 1.4 Thanh toán, Chuỗi trạng thái đơn hàng & Hoàn tiền
* **Phương thức thanh toán:**
  * Online (bắt buộc với đơn từ xa/giao nhận): Cổng thanh toán (VNPAY / Momo / Thẻ ngân hàng / QR Code).
  * COD (Tiền mặt): Chỉ áp dụng khi khách tự mang film đến gửi và nhận/thanh toán trực tiếp tại quầy của Film Lab.
* **Xử lý sự cố thanh toán:**
  * Nếu thanh toán thất bại, hệ thống báo lỗi giao dịch cụ thể.
  * Đơn hàng được giữ ở trạng thái `Chờ thanh toán (Pending Payment)`; khách có thể vào lại mục đơn hàng bấm **"Thanh toán lại"**.
  * Hệ thống tự động hủy đơn rác nếu quá **24 giờ** không hoàn tất thanh toán.
* **Theo dõi trạng thái đơn hàng thời gian thực:**
  * Khách theo dõi tại mục **"Đơn hàng của tôi"** trên ứng dụng và nhận thông báo đẩy (Push Notification) theo từng bước.
  * **Chuỗi trạng thái đơn hàng đầy đủ phản ánh đúng thực tế vận chuyển:**  
    `Chờ thanh toán (Pending Payment)` -> `Chờ Lab xác nhận (Pending Confirmation)` -> `[Đang lấy film (Pickup In Progress - nếu chọn shipper)]` -> `Đã nhận film tại Lab (Received at Lab)` -> `Đang xử lý (Processing - Tráng & Scan)` -> `Hoàn thành (Completed - Đã nạp file scan vào Archive)` -> `[Đang giao hàng (Delivering - nếu có ship film/ảnh)]` -> `Đã nhận / Đóng đơn (Delivered)` (hoặc `Đã hủy - Cancelled`).
* **Quy định hủy đơn:**
  * Khách hàng **chỉ được phép hủy đơn** (và nhận lại 100% tiền) khi đơn ở trạng thái `Chờ Lab xác nhận` — tức khi shipper chưa đến lấy và Lab chưa nhận film thực tế.
  * Khi đơn đã chuyển sang `Đang lấy film` hoặc `Đã nhận film tại Lab`, khách không thể tự ý hủy đơn thông thường.
* **Chính sách hoàn tiền & Nơi tra cứu:**
  * *Điều kiện hoàn tiền:* Hủy đơn hợp lệ khi Chờ xác nhận; Lab từ chối hoặc hủy đơn do sự cố máy móc; Lab làm thất lạc/hư hỏng film do lỗi kỹ thuật; cuộn film bị trắng (Blank Film - hoàn 100% phí scan/in, giữ lại phí tráng); trừ tiền trùng lặp qua cổng thanh toán.
  * *Tiến độ hoàn tiền:* Sau khi được phê duyệt, tiền hoàn thẳng về tài khoản/ví ban đầu trong vòng **3–5 ngày làm việc**.
  * *Tra cứu giao dịch hoàn tiền:* Khách hàng và Film Lab có thể tra cứu chi tiết tiến trình tại mục chi tiết đơn hàng hoặc lịch sử giao dịch tại **`Refund_Transactions`** (các trạng thái: `Refund_Requested` -> `Refund_Approved` / `Refund_Rejected` -> `Refund_Processing` -> `Refund_Success` / `Refund_Failed`).

### 1.5 Tải và Quản lý kho lưu trữ số (Digital Film Archive)
* **Nguyên tắc cốt lõi:** Kết quả chính của dịch vụ là **File scan số** chất lượng cao được tải lên Cloud Storage an toàn và tự động nạp vào **Digital Film Archive** của khách hàng; việc giao nhận vật lý chỉ phát sinh khi khách có nhu cầu.
* **Nhận file scan:** Lab upload file scan lên cloud storage, hệ thống tự động đồng bộ vào Archive và gửi thông báo đẩy để khách xem, tải file gốc chất lượng cao không nén.
* **Quyền riêng tư mặc định:** Kho ảnh mặc định ở chế độ riêng tư, chỉ chủ tài khoản mới xem được ảnh. Quản trị viên không có quyền truy cập ảnh của khách trừ khi có khiếu nại tranh chấp.
* **Hệ thống Metadata đi kèm ảnh:**
  * Khách hàng tự bổ sung: Loại cuộn film (VD: Kodak Portra 400), máy ảnh (VD: Canon AE-1), ống kính, ngày chụp, địa điểm, cách xử lý (Push/Pull), ghi chú cá nhân.
* **Chức năng quản lý Archive:**
  * Xem ảnh dạng lưới (Gallery View) hoặc toàn màn hình.
  * Tìm kiếm và lọc ảnh: Theo ngày chụp, loại film, tên tiệm Lab, máy ảnh sử dụng.
  * Tạo Album/Bộ sưu tập theo dự án, chuyến đi.
  * Chia sẻ Album qua liên kết (chế độ công khai hoặc riêng tư có mật khẩu bảo vệ).
  * Chỉnh sửa: Sửa thông tin metadata, tải file gốc, hoặc xóa ảnh khỏi kho cá nhân.

### 1.6 Đánh giá Film Lab
* Sau khi đơn hàng hoàn tất, khách hàng được chấm điểm (1–5 sao) và viết nhận xét công khai về chất lượng màu sắc, độ sạch bụi và thái độ phục vụ của Lab.

---

## 2. PHÂN HỆ QUẢN TRỊ VẬN HÀNH FILM LAB (FILM LAB OWNER)

### 2.1 Quản lý hồ sơ tiệm (Lab Profile)
* Cấu hình hồ sơ công khai: Tên tiệm, logo, địa chỉ các chi nhánh, giờ mở cửa, số điện thoại, email, mô tả tiệm.
* Danh mục kỹ thuật hỗ trợ: Khổ film (135, 120, 110, APS), quy trình xử lý (C-41, BW, E-6, ECN-2), chính sách lưu trữ file và âm bản gốc.

### 2.2 Quản lý danh mục và bảng giá dịch vụ
* **Quyền quản trị dịch vụ:** Tài khoản Film Lab (Lab Owner) toàn quyền cấu hình, cập nhật bảng giá và các gói dịch vụ của tiệm.
* **Quy tắc thay đổi giá:** Mọi thay đổi giá đều được hệ thống tự động ghi nhật ký (Audit Trail: Tên dịch vụ, Giá cũ -> Giá mới, Thời gian thay đổi, Lý do).
* **Cơ chế tạm ngưng dịch vụ:** Sử dụng trạng thái `PAUSED` (tạm ẩn khỏi danh sách tìm kiếm) khi tiệm quá tải hoặc tạm thiếu hóa chất; không xóa dịch vụ để đảm bảo dữ liệu và lịch sử các đơn hàng cũ không bị gián đoạn.
* **Bảo lưu giá đơn cũ (Price Snapshotting):** Giá dịch vụ và phụ phí được ghi nhận nguyên trạng theo thời điểm khách tạo đơn; việc thay đổi giá sau đó của Lab không làm thay đổi giá trị của đơn hàng đã đặt.
* **Xử lý phụ phí phát sinh thực tế:** Nếu nhận film thực tế phát hiện cần xử lý thêm (film Cine ECN-2 tẩy muội than, film outdate cần Push +2 stop) -> Lab gửi yêu cầu *"Đề xuất phụ phí"*, khách xác nhận đồng ý thanh toán thêm thì Lab mới bắt đầu xử lý.

### 2.3 Nhận, xác nhận và cập nhật đơn hàng
* **Nhận thông báo đơn mới:** Đơn trực tuyến được đưa vào danh sách xử lý đơn hàng tức thời của tiệm; đơn gửi từ xa được quét mã tiếp nhận.
* **Xác nhận đơn qua 2 bước:**
  1. *Bước 1 (Tiếp nhận thông tin):* Xác nhận đơn trên hệ thống khi khách đặt online.
  2. *Bước 2 (Tiếp nhận phim thực tế + thanh toán):* Nhận phim thực tế và xác nhận thanh toán hoàn tất -> Chuyển đơn sang `Đang xử lý (Processing)`.
* **Thông tin cần ghi nhận khi nhận film thực tế:** Mã đơn (Order ID), tình trạng cuộn film (nguyên vẹn, cắt dở, ẩm ướt, móp méo), ghi chú kỹ thuật từ khách, số lượng cuộn thực tế, người giao film, ảnh chụp tình trạng film làm bằng chứng.
* **Xử lý các ca bất thường khi nhận film:**
  * Lệch số lượng hoặc film ẩm ướt/hư hại: Chụp ảnh lưu bằng chứng, báo khách xác nhận trước khi xử lý.
  * Film tự chiết không an toàn: Từ chối nhận và nêu rõ lý do.
  * Chưa thanh toán: Giữ ở trạng thái chờ thanh toán, không đưa vào xử lý hóa chất.
* **Cập nhật công đoạn theo thời gian thực:** Tiếp nhận film -> Tráng -> Rửa & Sấy -> Scan -> Kiểm tra chất lượng (QC). Tiến độ từng bước được đồng bộ tự động lên ứng dụng của khách.

### 2.4 Tải file scan và trả kết quả
* **Thời điểm tải file scan:** Diễn ra sau khi hoàn tất công đoạn Scan và Kiểm tra chất lượng (QC) đạt chuẩn (không lệch frame, không sọc sensor, đủ số kiểu, đúng chuẩn JPG/TIFF).
* **Cơ chế tải file và bảo mật:** File scan chất lượng cao được tải lên Cloud Storage an toàn và tự động nạp thẳng vào Digital Film Archive của khách hàng; hệ thống tự động gửi thông báo đẩy (Push Notification) và Email cho khách.
* **Xử lý tình huống bất thường khi tải file:**
  * *Upload thất bại / rớt mạng:* Áp dụng cơ chế **Resumable Upload**; nhân viên bấm "Thử lại" để tải tiếp đoạn bị gián đoạn.
  * *Tải nhầm file scan của khách khác:* Cơ chế **Thu hồi & Ghi đè (Revoke & Replace)** trong vòng 24 giờ; thu hồi link cũ trong Archive của khách bị nhầm, cập nhật bản đúng, ghi Audit Log và gửi thông báo đính chính cho khách.

### 2.5 Lịch sử đơn hàng và Báo cáo vận hành
* **Dữ liệu Lab xem lại ở đơn đã hoàn thành:**
  * Thông tin khách hàng và liên hệ.
  * Quy cách kỹ thuật cuộn film (khổ film, quy trình tráng, mức push/pull, máy scan sử dụng).
  * Dòng thời gian nhật ký xử lý (Timeline SLA: giờ nhận, giờ tráng, giờ scan, giờ tải file).
  * Doanh thu thực nhận của đơn hàng.
  * Bằng chứng ảnh QC lúc nhận film và đánh giá sao, nhận xét của khách.
* **Báo cáo vận hành:** Thống kê số lượng cuộn film đã xử lý theo ngày/tuần/tháng, tỷ lệ hoàn thành đúng cam kết SLA.

---

## 3. PHÂN HỆ CHUYÊN GIA NHIẾP ẢNH & CỘNG ĐỒNG (PHOTOGRAPHY EXPERT & COMMUNITY)

### 3.1 Đăng bài hướng dẫn và Chia sẻ kỹ thuật
* **Đối tượng đăng bài:** Người dùng đã xác thực (Customer, Photography Expert, Film Lab Owner) đều có quyền đăng bài chia sẻ và bình luận tương tác.
* **Quyền tác giả:** Tác giả có toàn quyền chỉnh sửa hoặc xóa bài viết, bình luận do mình tạo.
* **Chuyên gia nhiếp ảnh (Photography Expert):** Được Admin thẩm định và cấp huy hiệu chứng nhận (Verified Badge); bài viết chuyên môn được ưu tiên hiển thị (kỹ thuật đo sáng film slide, kinh nghiệm chụp đêm, review các dòng film/ống kính và đánh giá chất lượng Film Lab).

### 3.2 Tổ chức sự kiện Workshop & Photowalk
* Chuyên gia có thể tạo và quản lý sự kiện: Buổi chụp ảnh thực tế ngoài trời (Photowalk), buổi hướng dẫn tự tráng film đen trắng tại nhà (Workshop).
* Thành viên cộng đồng xem thông tin chi tiết, đăng ký tham gia và thảo luận trực tiếp trong trang sự kiện.

### 3.3 Tương tác cộng đồng & Báo cáo vi phạm
* **Tính năng tương tác:**
  * **Like:** Bày tỏ yêu thích đối với bài viết, hình ảnh chia sẻ của thành viên khác.
  * **Follow:** Theo dõi các Chuyên gia nhiếp ảnh hoặc Film Lab yêu thích để nhận thông báo sớm nhất khi có bài viết hoặc sự kiện mới.
* **Báo cáo vi phạm phía người dùng:** Mỗi bài viết và bình luận đều có nút **"Báo cáo vi phạm"** để người dùng báo cáo các nội dung spam, ngôn từ xúc phạm, thông tin sai lệch kỹ thuật hoặc vi phạm quy định cộng đồng.

---

## 4. PHÂN HỆ ĐỐI TÁC VẬN CHUYỂN (DELIVERY PARTNER)

### 4.1 Quy trình giao nhận film hai chiều
* **Chiều 1 (Pickup film từ khách đến Lab):**
  * Khách đặt đơn chọn yêu cầu giao nhận -> Hệ thống điều phối đơn vị vận chuyển đối tác (Ahamove, Lalamove hoặc shipper của tiệm).
  * Shipper đến địa chỉ của khách nhận cuộn film -> Giao film đến tận tay Film Lab. Trạng thái đơn cập nhật: `Đang lấy film` -> `Đã nhận film tại Lab`.
* **Chiều 2 (Trả film đã xử lý cho khách):**
  * Diễn ra khi khách có nhu cầu nhận lại cuộn film đã tráng (âm bản) hoặc các bản ảnh in vật lý.
  * Lab đóng gói film/ảnh -> Bàn giao cho Shipper giao trả về địa chỉ của khách. Trạng thái đơn cập nhật: `Đang giao hàng` -> `Đã nhận`.
* **Dữ liệu vận chuyển lưu trữ:** Địa chỉ lấy và giao hàng, số điện thoại người gửi/nhận, phí vận chuyển, thời gian hẹn lấy và thời gian giao dự kiến, mã vận đơn (Tracking Code), trạng thái vận chuyển thời gian thực.

### 4.2 Xử lý các tình huống giao hàng thất bại
* **Lấy film thất bại:** Shipper không liên lạc được với khách lấy film -> Hệ thống hẹn lại lịch lấy, tối đa **2 lần thử lại**. Nếu quá 2 lần không thành công -> Hệ thống tự động hủy yêu cầu pickup, đơn chuyển sang hình thức khách tự mang phim đến tiệm.
* **Giao trả film/ảnh in thất bại:** Gói hàng được chuyển hoàn về lưu giữ an toàn tại Film Lab; khách hàng có thể đến tiệm lấy trực tiếp hoặc thanh toán thêm phí ship để đặt lịch giao lại.

---

## 5. PHÂN HỆ QUẢN TRỊ HỆ THỐNG (SYSTEM ADMINISTRATOR)

### 5.1 Quản lý tài khoản và Phân quyền (RBAC)
* **Tiêu chí tìm kiếm và lọc tài khoản:**
  * Lọc theo vai trò: Khách hàng, Film Lab, Chuyên gia nhiếp ảnh, Đối tác vận chuyển.
  * Lọc theo trạng thái: Chờ duyệt (Pending), Hoạt động (Active), Bị khóa (Banned).
  * Tìm kiếm nhanh: Theo Email, Số điện thoại hoặc Tên người dùng / Tên tiệm Lab.
* **Các trạng thái tài khoản:**
  * `Chờ duyệt (Pending)`: Áp dụng cho tài khoản Film Lab mới đăng ký tiệm, hoặc Chuyên gia / Đơn vị vận chuyển đang chờ thẩm định.
  * `Hoạt động (Active)`: Hoạt động bình thường theo đúng phân quyền.
  * `Bị khóa (Banned)`: Bị chặn đăng nhập và ngừng mọi giao dịch.
* **Lý do khóa tài khoản cụ thể:**
  * *Khách hàng:* Đặt đơn trêu đùa (đặt rồi không gửi film), spam bình luận xúc phạm, đăng tin lừa đảo trên sàn giao dịch.
  * *Film Lab:* Làm mất/hỏng film của khách nhiều lần mà không đền bù, dịch vụ bị khiếu nại quá kém, hoặc có hành vi gian lận.
* **Thông báo và xem xét lại:** Người dùng bị khóa nhận email nêu rõ lý do; màn hình đăng nhập hiển thị thông báo kèm nút **"Gửi yêu cầu xem xét lại"** để Admin phúc thẩm nếu có nhầm lẫn.

### 5.2 Thẩm định và Duyệt đối tác (Film Lab, Chuyên gia, Đơn vị vận chuyển)
* **Thẩm định Film Lab:**
  * Kiểm tra hồ sơ: Tên tiệm, địa chỉ cụ thể, số điện thoại liên hệ, Fanpage/Website, họ tên chủ tiệm & ảnh chụp CCCD, danh mục film nhận tráng, hình ảnh không gian tiệm và hệ thống máy móc tráng/scan.
  * Admin kiểm tra tính có thật để phòng ngừa lab "ma". Hợp lệ -> Bấm "Duyệt" (chuyển sang `Active`); chưa đạt -> Bấm "Từ chối" kèm ghi chú ngắn nêu rõ lý do.
* **Thẩm định Chuyên gia nhiếp ảnh (Photography Expert):** Admin kiểm tra hồ sơ năng lực, kinh nghiệm thực tế, portfolio tác phẩm hoặc các chứng chỉ nhiếp ảnh để duyệt cấp huy hiệu **Verified Badge**.
* **Thẩm định Đối tác vận chuyển (Delivery Partner):** Admin kiểm tra thông tin định danh cá nhân/doanh nghiệp, giấy tờ xe hoặc thỏa thuận hợp tác logistics (Ahamove/Lalamove) trước khi cấp quyền tiếp nhận đơn giao nhận trên hệ thống.

### 5.3 Quản lý danh mục dịch vụ và Giới hạn quyền hạn Admin
* Quản lý danh mục kỹ thuật chuẩn toàn hệ thống (chuẩn khổ film 135/120, quy trình C41, BW, ECN2, E6).
* **Giới hạn quyền hạn Admin đối với dịch vụ của Lab:**
  * Admin **không được tự ý sửa giá hoặc tên dịch vụ** của Film Lab (Lab tự chủ kinh doanh).
  * Admin **chỉ có quyền bấm "Ẩn dịch vụ này"** khi phát hiện nội dung dịch vụ sai lệch kỹ thuật, phản cảm hoặc lừa đảo.
* **Giới hạn quyền hạn Admin đối với nội dung cộng đồng:**
  * Admin áp dụng cơ chế **Hậu kiểm**: Xem danh sách bài viết bị người dùng báo cáo vi phạm, có quyền **ẩn hoặc gỡ** bài vi phạm.
  * Admin **tuyệt đối không được tự ý sửa nội dung** bài viết của người dùng.

### 5.4 Dashboard báo cáo vận hành tinh gọn
Bảng điều khiển hiển thị các số liệu vận hành cốt lõi của đồ án, không xây dựng báo cáo tài chính phức tạp:
* Số lượng người dùng: Tổng số Khách hàng, số Film Lab đang hoạt động, số Chuyên gia và Đối tác vận chuyển.
* Số lượng đơn hàng: Đơn hoàn thành, đơn đang xử lý, đơn bị hủy.
* Tỷ lệ hoàn thành đúng hạn cam kết SLA của từng Film Lab.
* Danh sách công việc chờ xử lý: Số tin bán máy chờ duyệt tiền kiểm, số hồ sơ đối tác chờ duyệt, số vụ khiếu nại chưa giải quyết.

### 5.5 Phân quyền xem đơn, Quy trình khiếu nại & Thẩm quyền hoàn tiền
* **Quyền xem thông tin đơn hàng:** Chỉ Khách hàng sở hữu đơn và Film Lab phụ trách mới xem được chi tiết đơn. Admin **tuyệt đối không tự ý xem ảnh riêng tư** trong kho của khách, trừ khi phát sinh khiếu nại tranh chấp chính thức và hai bên đồng thuận mở ảnh làm chứng cứ.
* **Quy trình xử lý khiếu nại 3 bước:**
  1. *Khách hàng gửi khiếu nại:* Khách bấm "Khiếu nại" trên ứng dụng khi film bị hỏng hoặc file scan bị mờ/lỗi nặng.
  2. *Bước tự thương lượng:* Hệ thống chuyển thông báo để Film Lab và Khách hàng tự thương lượng giải pháp đền bù trước (đền cuộn film mới, voucher giảm giá).
  3. *Admin can thiệp phán quyết:* Nếu hai bên không thống nhất sau thương lượng, Admin vào cuộc xem xét chứng cứ ảnh chụp lúc nhận film và ảnh scan, đưa ra phán quyết đền bù; nếu Lab cố tình từ chối đền bù thỏa đáng, Admin tiến hành khóa tài khoản Lab.
* **Thẩm quyền phê duyệt hoàn tiền:**
  * Hệ thống tự động duyệt hoàn tiền khi khách hủy đơn hợp lệ lúc đơn còn ở `Chờ Lab xác nhận`.
  * Admin phê duyệt hoàn tiền sau khi giải quyết tranh chấp hoặc khi Lab xác nhận cuộn phim bị trắng (Blank Film).
* **Nhật ký thao tác kiểm toán (Audit Log):** Hệ thống bắt buộc ghi lại mọi thao tác của Admin: *Ai làm – Lúc mấy giờ – Làm việc gì – Với đối tượng nào – Lý do.*

---

## 6. SÀN TRAO ĐỔI THIẾT BỊ (MARKETPLACE)
### 6.1 Đối tượng được bán sản phẩm
* **Cá nhân (Customer/Photographer) - Giao dịch C2C:** Tài khoản đã xác thực Email và Số điện thoại; được đăng bán máy ảnh cơ cá nhân, ống kính đã qua sử dụng.
* **Film Lab Owner & Chuyên gia - Giao dịch B2C:** Đăng bán cuộn film mới/outdate, hóa chất tráng, phụ kiện nhiếp ảnh, máy ảnh đã qua kiểm định kỹ thuật.

### 6.2 Danh mục sản phẩm & Quy chuẩn tin đăng (Tiền kiểm 100%)
* **Danh mục cho phép:** Máy ảnh analog (SLR, Rangefinder, Point & Shoot, Medium Format), ống kính máy ảnh, cuộn film, phụ kiện (filter, dây đeo, bao da, flash).
* **Quy chuẩn thông tin tin đăng:**
  * Tên thiết bị, phân loại danh mục, giá bán niêm yết, địa điểm giao dịch.
  * Mô tả tình trạng cơ học chi tiết: Hoạt động đo sáng, tốc độ màn trập, buồng film có kín sáng không, thấu kính có trầy xước/mốc rễ tre hay không.
  * Hình ảnh thực tế: Bắt buộc cung cấp tối thiểu **3 ảnh chụp thật** rõ nét các góc cạnh của thiết bị.
* **Cơ chế tiền kiểm 100%:** Tin đăng sau khi tạo sẽ chuyển vào hàng đợi `Chờ duyệt (Pending Approval)`. Admin kiểm duyệt hình ảnh thật và nội dung mô tả đạt chuẩn thì mới bấm duyệt cho hiển thị lên sàn.
* **Tìm kiếm nâng cao:** Khách hàng tìm kiếm theo từ khóa, lọc theo tầm giá, danh mục thiết bị, khu vực địa lý.

### 6.3 Nhắn tin trao đổi và Quy trình mua bán (MVP)
*  Liên hệ trực tiếp giữa người mua và người bán qua Số điện thoại / Zalo (không tích hợp hệ thống chat riêng).

---

## 7. MA TRẬN PHÂN QUYỀN HỆ THỐNG (RBAC)

| Chức năng chính | Customer | Film Lab | Expert | Delivery Partner | System Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| Đăng ký, quản lý tài khoản cá nhân | Có | Có (Chờ duyệt) | Có (Chờ duyệt) | Có (Chờ duyệt) | Có |
| Tìm kiếm, so sánh & Đặt dịch vụ tráng/scan | Có | - | Có | - | - |
| Cấu hình gói dịch vụ & Đổi giá Lab | - | Có (Chỉ Owner) | - | - | Chỉ ẩn dịch vụ vi phạm |
| Tiếp nhận đơn & Cập nhật tiến độ tráng/scan | - | Có | - | - | Xem / Can thiệp khiếu nại |
| Upload file scan trả khách lên Cloud | - | Có | - | - | Không (Bảo mật riêng tư) |
| Quản lý Digital Film Archive cá nhân | Toàn quyền kho mình | - | Toàn quyền kho mình | - | Không (Chỉ xem khi mở khiếu nại) |
| Nhận đơn pickup & Cập nhật vị trí vận chuyển | - | - | - | Có | Tra cứu sự cố |
| Đăng tin mua bán trên Marketplace | Có (Chờ duyệt) | Có (Chờ duyệt) | Có (Chờ duyệt) | - | Duyệt tiền kiểm / Gỡ tin |
| Nhắn tin mua bán & Đánh giá người bán | Có | Có | Có | - | - |
| Đăng bài viết chia sẻ, thảo luận cộng đồng | Có (Đã xác thực) | Có (Đã xác thực) | Có (Ưu tiên hiển thị) | - | Kiểm duyệt hậu kiểm (Ẩn/Gỡ) |
| Tương tác Like, Bookmark, Follow tác giả | Có | Có | Có | - | - |
| Tổ chức Workshop & Photowalk | Thảo luận | Thảo luận | Có (Tạo / Quản lý) | - | Kiểm duyệt nội dung |
| Duyệt đối tác (Lab, Expert, Delivery), Audit Log | - | - | - | - | Có (Theo quy định) |
| Phán quyết đền bù & Phê duyệt hoàn tiền | - | Tự thương lượng trước | - | - | Phán quyết & Phê duyệt |
