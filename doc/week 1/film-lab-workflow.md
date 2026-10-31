# Quy trình vận hành Film Lab trên nền tảng

> **Mục tiêu:** Nắm quy trình vận hành thực tế của Film Lab: quản lý dịch vụ, nhận đơn, xử lý phim, tải file scan, quản lý giá và lịch sử đơn.

## Mục lục

1. [Quản lý thông tin và dịch vụ](#1-quản-lý-thông-tin-và-dịch-vụ)
2. [Nhận, xác nhận và cập nhật đơn](#2-nhận-xác-nhận-và-cập-nhật-đơn)
3. [Tải file scan và trả kết quả](#3-tải-file-scan-và-trả-kết-quả)
4. [Quản lý giá và lịch sử đơn hàng](#4-quản-lý-giá-và-lịch-sử-đơn-hàng)

---

## 1. Quản lý thông tin và dịch vụ

### 1.1 Thông tin Film Lab cần cung cấp

Lab duy trì một **hồ sơ lab (Lab Profile)** đầy đủ làm "mặt tiền" trên nền tảng, giúp khách tìm kiếm, so sánh và đặt dịch vụ.

| Nhóm thông tin | Nội dung |
|---|---|
| Định danh | Tên lab, địa chỉ các cơ sở, giờ mở cửa, số điện thoại, email, logo, mô tả ngắn |
| Loại film nhận xử lý | 35mm, 120, APS (240), 110, 4×5, 8×10 |
| Quy trình xử lý | C-41 (màu), BW (đen trắng), E-6 (slide), Cross E6→C41, Reversal, Cine/Vision (ECN-2) |
| Thời gian trả file dự kiến | Cam kết SLA cho từng loại film |
| Biểu phí công khai | Giá theo cuộn hoặc sheet, kèm phụ phí |
| Chính sách lưu trữ | Thời gian giữ file scan, thời gian giữ âm bản |
| Phương thức nhận/trả phim | Khách mang đến, gửi bưu điện hoặc pickup |

**Ví dụ thực tế (LLab):**
- Giờ làm việc: 08:00 – 21:00
- Film màu / BW / Vision: tối đa 72 giờ
- Film Slide E-6: tối đa 15 ngày
- Slide BW / reversal: trong vòng 30 ngày
- File scan lưu trên Google Drive 60 ngày, âm bản giữ 15 ngày

**Người thực hiện:** Chủ lab (Lab Owner). **Kết quả:** Lab Profile hoàn chỉnh, hiển thị công khai.

### 1.2 Phân quyền thêm/sửa dịch vụ

| Vai trò | Quyền hạn |
|---|---|
| Chủ lab (Lab Owner) | Toàn quyền: thêm, sửa, xóa, pause dịch vụ; đổi giá; cấu hình chính sách |
| Quản lý lab (Lab Manager) | Được chủ lab ủy quyền: sửa dịch vụ nhưng không xóa vĩnh viễn |
| Nhân viên vận hành (Lab Operator) | **Không** được sửa giá hoặc danh mục dịch vụ; chỉ cập nhật trạng thái đơn và nghiệp vụ hằng ngày |

**Lý do phân quyền chặt:**
- Giá và dịch vụ là cam kết công khai với khách, cần một đầu mối chịu trách nhiệm.
- Tránh nhân viên vô tình sửa giá gây sai lệch hàng loạt đơn.
- Mọi thay đổi giá/dịch vụ phải ghi log: ai sửa, lúc nào, nội dung gì, lý do gì.

**Kết quả:** Danh mục dịch vụ được cập nhật, có audit trail đầy đủ.

### 1.3 Thông tin của một dịch vụ (gói/package)

| Thuộc tính | Nội dung | Ví dụ từ LLab |
|---|---|---|
| Tên dịch vụ | Rõ ràng, dễ hiểu | "Tráng + Scan Standard - Film màu 135" |
| Loại / khổ film | Film được áp dụng | Film màu 135, 120, 110, APS |
| Quy trình | C-41 / BW / E-6 / Cross / ECN-2 | Film màu C41; Slide E-6 |
| Giá cơ bản | Theo cuộn hoặc sheet | Màu 135: 80.000đ/cuộn; màu 120: 85.000đ/cuộn; Slide 135/120: 260.000đ/cuộn |
| Phụ phí | Push/Pull, xử lý nhanh, scan nâng cao | Push/Pull màu +25.000đ/stop; BW +30.000đ/stop; xử lý nhanh +20.000đ/cuộn; Scan Hi-Res +25.000đ/cuộn |
| Định dạng đầu ra | JPEG / TIFF / BMP | TIFF +25.000đ/cuộn; BMP +25.000đ/cuộn |
| Thời gian xử lý (SLA) | Tối đa, tính từ lúc nhận film + thanh toán | 72 giờ (màu/BW/Vision); 15 ngày (Slide E-6) |
| Mô tả chi tiết | Quy trình và kết quả khách nhận | "Tráng bằng máy C41, scan Standard, trả file JPEG qua Google Drive" |

**Lưu ý về SLA:**
- Mốc 72 giờ / 15 ngày áp dụng khi lượng film bình thường hoặc mùa thấp điểm.
- Mùa cao điểm (lễ, Tết) có thể kéo dài; lab xác nhận lại timeline khi nhận film.
- Trường `SLA` là giá trị tham chiếu, không phải cam kết tuyệt đối.

**Kết quả:** Mỗi dịch vụ là một bản ghi hoàn chỉnh, sẵn sàng cho khách đặt.

### 1.4 Khi Film Lab tạm ngừng dịch vụ

**Cơ chế đúng: `PAUSED` (tạm ẩn), KHÔNG xóa.**

| Hạng mục | Hành vi |
|---|---|
| Hiển thị | Biến mất khỏi marketplace/danh sách công khai, khách không tìm thấy hoặc đặt mới được |
| Dữ liệu | Giữ nguyên toàn bộ cài đặt, đánh giá và lịch sử đơn cũ |
| Đơn đã đặt | Vẫn xử lý bình thường (giá và điều khoản lúc đặt là ràng buộc) |
| Ghi log | Ai pause, lúc nào, lý do gì |
| Thông báo | Nếu khách đang xem dịch vụ, hiển thị "tạm ngừng nhận đơn mới" |

**Tình huống thực tế:** LLab quy định film Slide cần đủ số cuộn mới tráng một lần. Lab có thể tạm ngừng nhận đơn slide mới nhưng không được hủy các đơn slide đã gửi trước đó, vì vậy cần `PAUSED` thay vì `DELETE`.

**Trường hợp bất thường:**
- Lab pause dịch vụ nhưng có đơn đang `PENDING_PAYMENT` → vẫn xử lý bình thường sau khi thanh toán.
- Muốn xóa vĩnh viễn dịch vụ → chỉ được khi không còn đơn nào tham chiếu đến dịch vụ đó.

---

## 2. Nhận, xác nhận và cập nhật đơn

### 2.1 Cách Lab nhận thông báo đơn mới

**Nguồn 1: Đơn từ nền tảng / storefront**
- Đơn vào **hàng đợi sản xuất (production queue)** gần như tức thời (vài giây sau khi khách đặt).
- Hiển thị trên **bảng Kanban sản xuất**, phân loại theo quy trình (film processing, printing, v.v.).
- Thông báo nội bộ: chuông âm thanh, badge số đơn mới chưa xử lý, email nội bộ cho nhân viên trực ca.

**Nguồn 2: Đơn gửi bưu điện / từ xa**
- Khi bưu kiện đến, nhân viên mở và **quét đơn vào hệ thống**.
- Hệ thống **tự động gửi email xác nhận đã nhận film** cho khách.
- Khách từ xa lần đầu (theo LLab) cần đính kèm giấy ghi số điện thoại, tên, email để lab tạo đơn và gửi biên nhận điện tử.

**Kết quả:** Đơn xuất hiện trong hàng đợi của lab; khách đơn từ xa nhận xác nhận điện tử.

### 2.2 Ai xác nhận đơn?

**Nhân viên vận hành (Lab Operator)** xác nhận qua **hai bước độc lập**:

| Bước | Nội dung | Điều kiện |
|---|---|---|
| 1. Xác nhận tiếp nhận thông tin | Đơn đã vào hệ thống, thông tin khách và dịch vụ đúng | Ngay khi đơn xuất hiện trong hàng đợi |
| 2. Xác nhận nhận film thực tế + thanh toán | Đã cầm film trên tay và tiền đã vào | Khi film đến lab và thanh toán hoàn tất |

- Bước 2 là điều kiện để đơn chuyển sang `PROCESSING`. LLab quy định với khách gửi bưu điện: đơn chỉ được xử lý và chia sẻ sau khi thanh toán.
- Hệ thống ghi lại: `confirmed_by`, `confirmed_at`, `payment_confirmed_at` (nếu khác thời điểm xác nhận).

### 2.3 Thông tin cần ghi nhận khi nhận film thực tế

| Trường thông tin | Mục đích | Bắt buộc |
|---|---|---|
| Mã đơn / order ID | Đối chiếu với đơn đã đặt | ✅ |
| Tình trạng film | Còn nguyên cuộn / đã cắt / ẩm ướt / ghi chú đặc biệt | ✅ |
| Ghi chú đặc biệt từ khách | Push/pull, giữ âm bản, tráng nhanh | ✅ (nếu có) |
| Số lượng thực tế | So với số khai báo; lệch thì ghi nhận và báo khách | ✅ |
| Người giao film | Khách trực tiếp hay đối tác vận chuyển | ✅ |
| Thời điểm nhận | Tính SLA xử lý | ✅ |
| Trạng thái thanh toán | Đã thanh toán hay chưa | ✅ |
| Ảnh chụp tình trạng film | Bằng chứng nếu có tranh chấp | Khuyến khích |

**Trường hợp bất thường khi nhận film:**

| Tình huống | Cách xử lý |
|---|---|
| Số lượng lệch so với khai báo | Ghi nhận, báo khách qua app/email, chờ xác nhận trước khi xử lý |
| Film hư hỏng / ẩm ướt | Chụp ảnh, ghi chú, báo khách, thỏa thuận trước khi tráng |
| Film tự chiết không an toàn | Từ chối nhận, ghi lý do, báo khách |
| Khách chưa thanh toán | Giữ ở `PENDING_PAYMENT`, không chuyển sang xử lý |

### 2.4 Các trạng thái đơn

| Trạng thái | Ý nghĩa | Điều kiện chuyển | Người chuyển |
|---|---|---|---|
| `PENDING_PAYMENT` | Đơn đã tạo, chờ thanh toán | Khách đặt đơn từ xa/online | Hệ thống |
| `RECEIVED_AT_LAB` | Lab đã nhận film thực tế | Nhân viên quét mã / xác nhận | Lab Operator |
| `PROCESSING` | Đang tráng / scan | Đã thanh toán + film đã nhận | Lab Operator |
| `DEVELOPING` (tùy chọn) | Đang tráng | Bắt đầu công đoạn tráng | Lab Operator |
| `SCANNING` (tùy chọn) | Đang scan | Bắt đầu công đoạn scan | Lab Operator |
| `SCANS_UPLOADED` | File scan đã upload và gắn đúng đơn | Upload thành công + đã associate order | Lab Operator |
| `READY_FOR_PICKUP` | Film gốc / bản in sẵn sàng trả tại lab | Hoàn tất QC | Lab Operator |
| `READY_FOR_DELIVERY` | Sẵn sàng giao cho shipper | Hoàn tất QC | Lab Operator |
| `DELIVERED` | Đã giao cho khách / shipper | Có xác nhận giao | Lab Operator / Delivery Partner |
| `CLOSED` | Đơn kết thúc, mở đánh giá | Tất cả dịch vụ (kể cả in ấn) hoàn tất | Hệ thống |

---

## 3. Tải file scan và trả kết quả

### 3.1 Thời điểm tải file scan lên hệ thống

File scan được tải lên ngay sau khi hoàn thành hai công đoạn kỹ thuật: **Scan** và **Kiểm tra chất lượng (QC - Quality Check)**.

```
[Tráng phim (Developing)] 
         ↓
[Sấy khô phim (Drying)] 
         ↓
[Scan phim (Scanning)] 
         ↓
[Kiểm tra chất lượng (QC)] ── (Lỗi kỹ thuật) ──> Scan lại
         ↓ (Đạt chuẩn)
[Tải file scan lên Cloud Storage]
         ↓
[Hệ thống cập nhật trạng thái SCANS_UPLOADED & Bắn thông báo cho khách]
```

* **Tiêu chuẩn QC trước khi tải:**
  * File không bị đứt đoạn, không bị lệch frame (mất nửa khung hình).
  * Kiểm tra bụi bẩn, vệt xước lạ do máy scan (sọc sensor).
  * Đầy đủ số lượng khung hình tương ứng với độ dài cuộn (ví dụ: cuộn 35mm đủ 36–38 frames, cuộn 120 đủ 12–16 frames tùy format).
  * Đúng định dạng và độ phân giải khách đã đặt (Standard JPG, High-Res JPG hoặc TIFF 16-bit).

* **Người thực hiện:** Nhân viên vận hành (Lab Operator) hoặc Kỹ thuật viên scan (Scanner Tech).
* **Kết quả:** Thư mục file hoàn chỉnh đạt chuẩn xuất ra máy tính làm việc của Lab.

---

### 3.2 Gắn file scan với khách hàng và đơn hàng

Để tránh nhầm lẫn giữa hàng chục đơn xử lý mỗi ngày, quá trình gắn file tuân theo cơ chế định danh tự động và bảo mật:

* **Cấu trúc đặt tên chuẩn hóa:**
  * File/Thư mục scan được xuất ra theo cú pháp:  
    `{OrderID}_{RollID}_{CustomerPhone}_{LoaiFilm}`  
    *Ví dụ:* `ORD24101801_R01_0912345678_KodakGold200.zip`
* **Quy trình tải lên trên Web Portal của Lab:**
  1. Nhân viên mở giao diện đơn hàng tương ứng trên Web Portal.
  2. Kéo thả file nén (ZIP) hoặc chọn cả thư mục ảnh scan vào khu vực Upload của đơn.
  3. Hệ thống tự động băm nhỏ và tải trực tiếp lên **Cloud Storage** (AWS S3 / Google Cloud Storage) thông qua **Pre-signed URL** được sinh từ Backend.
  4. Sau khi tải xong, hệ thống lưu danh sách đường dẫn file gắn chặt với `OrderID` và `CustomerID` trong cơ sở dữ liệu.
* **Bảo mật truy cập:**
  * File ảnh lưu trữ trên Cloud Storage không để ở chế độ công khai (Public).
  * Chỉ tài khoản khách hàng sở hữu đơn hàng (dựa trên token xác thực) mới được cấp quyền sinh URL tải xuống tạm thời.

---

### 3.3 Thông báo cho khách hàng khi file sẵn sàng

Ngay khi hệ thống nhận tín hiệu upload thành công 100%:

1. **Chuyển đổi trạng thái:** Đơn hàng tự động chuyển sang trạng thái `SCANS_UPLOADED`.
2. **Push Notification trên Mobile App:** Gửi thông báo đẩy đến điện thoại của khách:  
   *“🎉 Cuộn phim [Tên film] của bạn đã tráng & scan xong! Chạm để xem và lưu trữ ngay.”*
3. **Email thông báo:** Gửi email tự động có kèm tóm tắt đơn hàng, thông số kỹ thuật scan và liên kết dẫn thẳng vào ứng dụng/web.
4. **Tích hợp kho cá nhân (Digital Film Archive):** Ảnh scan tự động xuất hiện trong mục **Digital Film Archive** trên app của khách cùng với metadata cơ bản do Lab cung cấp (Tên lab, ngày scan, máy scan, độ phân giải).
5. **Tải file gốc:** Khách hàng có thể bấm "Tải toàn bộ file gốc (.ZIP)" hoặc tải từng tấm về điện thoại/máy tính không giới hạn trong thời hạn lưu trữ.

---

### 3.4 Xử lý các tình huống bất thường

| Tình huống | Nguyên nhân | Cách xử lý kỹ thuật và vận hành |
|---|---|---|
| **Tải lên thất bại / Đứt kết nối giữa chừng** | File TIFF dung lượng lớn (1–2GB/cuộn), mạng chập chờn | Hệ thống áp dụng cơ chế **Chunked Upload / Resumable Upload**. Nhân viên có thể bấm "Thử lại" (Retry) để tải tiếp đoạn bị gián đoạn mà không cần upload lại từ đầu. Trạng thái đơn vẫn giữ ở `PROCESSING`. |
| **Tải nhầm file scan của khách khác** | Nhân viên chọn nhầm thư mục hoặc nhập sai Order ID | • **Cơ chế Thu hồi / Ghi đè (Revoke & Replace):** Lab Operator có nút *"Cập nhật lại file scan"* trước khi đơn hoàn tất hoặc trong vòng 24 giờ. Hệ thống thu hồi ngay link cũ và vô hiệu hóa trong Archive của khách bị nhầm.<br>• Gửi thông báo đính chính cho khách hàng: *"Lab đã cập nhật bản scan chính xác nhất cho đơn hàng của bạn."*<br>• Ghi nhật ký hệ thống (Audit Log): Ai thay đổi, thời gian và lý do. |
| **Film bị trắng hoàn toàn (Blank Film)** | Máy ảnh hỏng màn trập, lắp film không kéo, film để quá hạn lâu | • Nhân viên chụp ảnh thực tế cuộn phim trắng làm bằng chứng.<br>• Tải ảnh chụp bằng chứng lên đơn hàng, chọn lý do: `FILM_BLANK`.<br>• Hệ thống kích hoạt quy trình hoàn tiền tự động phần phí scan/in (theo chính sách của phân hệ Dịch vụ bổ trợ) và thông báo cho khách. |
| **Hết hạn lưu trữ file trên Cloud của Lab** | Quá thời hạn cam kết lưu trữ (VD: 60 ngày theo chính sách) | Sau thời hạn cam kết, file scan trên bộ nhớ tạm của Lab có thể được chuyển sang dạng lưu trữ lạnh (Cold Storage) hoặc giải phóng; khách được nhắc nhở tải về trước ngày thứ 50 và ngày thứ 57. |

---

## 4. Quản lý giá và lịch sử đơn hàng

### 4.1 Quy tắc thay đổi giá của Film Lab

* **Quyền hạn:** Chỉ có **Chủ lab (Lab Owner)** mới được phép chỉnh sửa bảng giá gói dịch vụ và các mục phụ phí (Push/Pull, Scan TIFF/Hi-Res, in ấn).
* **Thời điểm áp dụng:**
  * Giá mới có hiệu lực **ngay lập tức** cho các đơn hàng mới phát sinh từ thời điểm bấm "Lưu thay đổi".
  * Không làm gián đoạn các khách hàng đang truy cập hệ thống.
* **Quy tắc ghi log (Audit Trail):** Mọi hành động sửa giá đều phải lưu lại bản ghi:
  * `service_id`: Dịch vụ nào.
  * `old_price` $\rightarrow$ `new_price`: Giá cũ và giá mới.
  * `updated_by`: Ai thực hiện.
  * `updated_at`: Thời điểm cập nhật chính xác đến từng giây.
  * `reason`: Lý do cập nhật (ví dụ: "Tăng giá hóa chất tráng ECN-2", "Khuyến mãi mùa hè").

---

### 4.2 Nguyên tắc bảo lưu giá cho đơn cũ (Price Snapshotting)

> **Nguyên tắc bất biến:** Giá của đơn hàng là giá cam kết tại thời điểm khách đặt hàng. Lab tuyệt đối không được tự ý đổi giá hoặc áp dụng giá mới cho đơn hàng cũ đã tạo.

* **Cơ chế Snapshot trên cơ sở dữ liệu:**
  * Khi khách hàng bấm tạo đơn thành công, hệ thống không chỉ lưu `service_id` mà sẽ sao chép nguyên trạng (Snapshot) toàn bộ thông tin giá vào bảng chi tiết đơn hàng (`Order_Items`):
    * `unit_price_at_order`: Đơn giá dịch vụ tại thời điểm đặt.
    * `push_pull_surcharge`: Phụ phí bù sáng tại thời điểm đặt.
    * `scan_option_surcharge`: Phụ phí định dạng scan tại thời điểm đặt.
    * `discount_applied`: Mã giảm giá đã áp dụng (nếu có).
  * Do đó, dù sau đó Lab có tăng giá dịch vụ từ 80.000đ lên 100.000đ thì đơn cũ vẫn thanh toán đúng 80.000đ.

* **Xử lý tình huống phát sinh thực tế:**
  * *Tình huống:* Khi nhận film thực tế tại tiệm, phát hiện film đòi hỏi dịch vụ khác (ví dụ: Khách khai báo film màu C41 nhưng cuộn film gửi đến thực chất là film Cine Vision ECN-2 cần tẩy muội than phức tạp hơn, hoặc film để lâu năm bắt buộc phải Push +2 stop).
  * *Cách xử lý:*
    1. Lab Operator chọn chức năng *"Đề xuất phụ phí phát sinh"* trên Web Portal, nhập lý do kỹ thuật và số tiền chênh lệch.
    2. Hệ thống gửi thông báo cho khách hàng xác nhận phụ phí.
    3. Chỉ khi khách đồng ý và thanh toán phần phụ phí phát sinh, Lab mới tiến hành công đoạn xử lý. Nếu khách không đồng ý, Lab hủy đơn và gửi trả lại film nguyên vẹn cho khách.

---

### 4.3 Tra cứu và khai thác thông tin đơn hàng đã hoàn thành

Film Lab có khu vực **"Lịch sử đơn hàng" (Order History)** và **"Báo cáo vận hành"** trên Web Portal để tra cứu các đơn đã ở trạng thái `CLOSED` hoặc `DELIVERED`.

#### Thông tin Lab cần xem lại khi tra cứu đơn cũ:

| Nhóm thông tin | Chi tiết dữ liệu cần xem lại | Mục đích sử dụng |
|---|---|---|
| **Khách hàng & Liên hệ** | Họ tên, số điện thoại, email, địa chỉ nhận trả film/ảnh in | Chăm sóc khách hàng cũ, đối chiếu thông tin khi khách hỏi lại |
| **Quy cách kỹ thuật đơn** | Loại film, khổ film (135/120), quy trình tráng, mức push/pull, máy scan sử dụng | Tham chiếu lại thông số kỹ thuật nếu khách muốn tráng tương tự cho cuộn sau |
| **Nhật ký thời gian (Timeline)** | • Thời điểm tạo đơn<br>• Thời điểm nhận film thực tế<br>• Thời điểm tráng xong & scan xong<br>• Thời điểm bàn giao file & trả film gốc | Đánh giá hiệu suất SLA của Lab, xác định nhân viên phụ trách ca làm việc |
| **Doanh thu & Tài chính** | Tổng tiền đơn, các khoản phụ thu, phí nền tảng đã khấu trừ, doanh thu thực nhận, trạng thái đối soát | Kế toán, tổng kết doanh thu theo ngày/tháng, đối soát tài khoản |
| **Bằng chứng & Đánh giá (QC & Review)** | Ảnh chụp tình trạng film lúc nhận (nếu có), đánh giá sao (Rating), bình luận phản hồi của khách | Rút kinh nghiệm vận hành, bảo vệ Lab nếu có khiếu nại phát sinh sau này |
| **Tình trạng âm bản gốc (Negatives)** | • Trạng thái: *Đã trả khách / Đang giữ tại lab / Đã tiêu hủy theo thỏa thuận*<br>• Vị trí ngăn lưu trữ (Folder/Bin Code): ví dụ `BIN-A12`<br>• Ngày hết hạn giữ âm bản (ví dụ sau 15 hoặc 30 ngày) | Quản lý kho phim vật lý, tránh thất lạc âm bản của khách khi khách đến nhận muộn |