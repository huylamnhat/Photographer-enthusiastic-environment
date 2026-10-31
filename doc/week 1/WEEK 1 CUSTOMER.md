# Phân tích chức năng Customer (Người dùng)

## Bước 1: Đăng ký, Đăng nhập, Quản lý tài khoản (#3)

### Thông tin đăng ký

- **Bắt buộc:** Họ tên, Email (hoặc Số điện thoại), Mật khẩu.
- **Tùy chọn (bổ sung sau):** Ảnh đại diện, địa chỉ nhận/gửi film, sở thích nhiếp ảnh (dòng máy, loại film hay dùng).

### Xác thực tài khoản

Có. Hệ thống gửi **OTP qua Email hoặc SMS** để xác thực, đảm bảo bảo mật và tránh tài khoản rác. Chỉ sau khi xác thực, tài khoản mới được kích hoạt hoàn toàn.

### Quên mật khẩu

Khách nhập Email/SĐT đã đăng ký → hệ thống gửi link reset (có thời hạn, ví dụ 15 phút) hoặc mã OTP → khách tạo mật khẩu mới.

### Thông tin được phép sửa

- Họ tên, Mật khẩu, Ảnh đại diện, Địa chỉ, Số điện thoại (đổi SĐT phải xác thực lại OTP).
- **Email** (định danh tài khoản) thường không cho tự sửa; muốn đổi phải liên hệ Admin.

### Khi Email đã tồn tại

Báo lỗi ngay: *"Email này đã được đăng ký. Vui lòng đăng nhập hoặc sử dụng chức năng Quên mật khẩu."*

### Kết quả cần ghi

- **Thông tin đăng ký:** Name, Email, Phone, Password.
- **Chức năng:** Đăng ký, Đăng nhập, Đăng xuất, Quên MK, Đổi MK, Cập nhật Profile.
- **Validation:** Mật khẩu tối thiểu 8 ký tự (gồm chữ và số), email đúng định dạng, số điện thoại 10 số.

---

## Bước 2: Tìm kiếm và So sánh Film Lab (#4)

### Tiêu chí tìm kiếm

- **Theo tên:** Search bar.
- **Theo vị trí:** Tỉnh/Thành phố, Quận/Huyện (bộ lọc hoặc GPS).
- **Theo loại dịch vụ:** Tráng film màu, tráng đen trắng (B&W), scan độ phân giải cao, in ảnh, hỗ trợ film 120mm/135mm.

### Tiêu chí so sánh

- Giá cả (thấp đến cao).
- Rating sao và số lượng đánh giá.
- Thời gian xử lý dự kiến (VD: 2 ngày, 1 tuần).
- Chất lượng scan (dựa trên review/metadata).
- Có hỗ trợ giao nhận tận nơi (pickup/delivery) hay không.

### Xem bảng giá trước khi đặt

Có. Trang chi tiết Film Lab hiển thị rõ bảng giá các gói (Tráng + Scan, Chỉ tráng, In ảnh...); khách bấm xem chi tiết từng gói.

### Khi không tìm thấy Lab phù hợp

Hiển thị *"Không tìm thấy Lab phù hợp"* kèm gợi ý mở rộng khu vực tìm kiếm hoặc danh sách các Lab uy tín nhất toàn quốc.

### Kết quả cần ghi

- **Tiêu chí tìm kiếm:** Text, Vị trí, Dịch vụ.
- **Bộ lọc:** Giá, Rating, Thời gian, Giao nhận.
- **Thông tin hiển thị:** Ảnh cover, Tên Lab, Địa chỉ, Rating, Giá tham khảo, Tag dịch vụ.

---

## Bước 3: Đặt dịch vụ (#5)

### Chọn loại phim và số cuộn

Khách chọn loại film (35mm, 120mm, 110mm), nhập số cuộn (tăng/giảm); hệ thống tự tính tổng tiền.

### Tùy chọn dịch vụ (Checkbox/Radio)

- **Gói cơ bản:** Tráng + Scan (mặc định).
- **Tùy chọn thêm:** In ảnh (10x15, 13x18...), chỉ tráng không scan, scan file RAW/TIFF.

### Độ phân giải scan / kích thước in

- **Scan:** Standard (VD: 2000x3000) hoặc High-res (VD: 4000x6000, tính thêm phí).
- **In:** 10x15, 13x18, 20x30.

### Cách tính giá

```
Tổng tiền = (Giá gói cơ bản × Số cuộn)
          + (Phụ phí scan độ phân giải cao × Số cuộn)
          + (Giá in ảnh × Số lượng ảnh in)
          + Phí giao nhận (nếu có)
```

### Cách gửi phim đến Lab

- **Tự túc:** Khách tự mang đến địa chỉ Lab (hiển thị bản đồ).
- **Giao nhận:** Chọn "Yêu cầu Pickup" → nhập địa chỉ lấy hàng → hệ thống tính phí ship (qua Ahamove/Lalamove) → Delivery Partner đến lấy.

### Kết quả cần ghi

- **Đầu vào:** Loại film, Số cuộn, Gói dịch vụ, Tùy chọn thêm, Phương thức giao nhận, Ghi chú.
- **Quy trình:** Chọn Lab → Chọn dịch vụ → Nhập thông tin → Chọn giao nhận → Thanh toán → Chờ Lab xác nhận.
- **Quy tắc tính giá:** Công thức động theo các tùy chọn (cần làm rõ phí ship và phụ phí).

---

## Bước 4: Thanh toán và Theo dõi đơn hàng (#6)

### Phương thức thanh toán

- **Online:** Ví điện tử (Momo, ZaloPay), thẻ ngân hàng (ATM/Visa/Mastercard qua cổng thanh toán), chuyển khoản (mã QR).
- **COD:** Áp dụng nếu khách tự đến lấy film/ảnh tại Lab.

### Theo dõi trạng thái đơn

- Vào mục **"Đơn hàng của tôi"** trên App.
- Nhận Push Notification khi trạng thái đổi: Đã tiếp nhận → Đang tráng → Đang scan → Hoàn thành → Đang giao → Đã nhận.

### Quy tắc hủy đơn

- **Được hủy** (và hoàn tiền nếu đã thanh toán online) khi đơn ở trạng thái "Chờ Lab xác nhận".
- **Không được hủy** khi Lab đã bấm "Bắt đầu xử lý" (film đã đem đi tráng, không thể hoàn tác).

### Khi thanh toán thất bại

- Báo lỗi giao dịch (VD: "Thẻ không đủ số dư", "Quá thời gian kết nối").
- Đơn giữ ở trạng thái "Chờ thanh toán" (Pending); khách vào lại đơn bấm **"Thanh toán lại"**.
- Hệ thống tự hủy đơn nếu quá **24h** không thanh toán thành công.

### Kết quả cần ghi

- **Phương thức thanh toán:** Online (VNPay/Momo) và COD.
- **Trạng thái đơn:** Pending Payment → Pending Confirmation → Processing → Completed → Delivering → Delivered / Cancelled.
- **Quy tắc hủy:** Chỉ hủy trước khi Lab xử lý; hoàn tiền qua ví/cổng thanh toán trong 3–5 ngày làm việc.

---

## Bước 5: Quản lý Digital Film Archive (#7)

> **Mục tiêu:** Hiểu cách khách lưu trữ, quản lý và khai thác file ảnh scan sau khi nhận từ Film Lab.

### Cách nhận file scan

- Lab upload file lên Cloud Storage.
- Khách nhận Push Notification khi file sẵn sàng.
- Khách tải về thiết bị hoặc lưu thẳng vào kho trên App (Digital Film Archive).

### Metadata đi kèm ảnh

- **Từ Film Lab:** Tên Lab, ngày scan, độ phân giải, định dạng file (JPG/TIFF).
- **Từ khách (tự nhập):** Loại film (VD: Kodak Portra 400), máy ảnh (VD: Canon AE-1), ống kính, ngày chụp, địa điểm, cách xử lý (Push/Pull), ghi chú cá nhân.

### Chức năng quản lý Archive

- **Gallery View:** Xem dạng lưới hoặc toàn màn hình.
- **Sắp xếp và lọc:** Theo ngày chụp, loại film, Lab, máy ảnh.
- **Album/Bộ sưu tập:** Gom ảnh theo dự án hoặc chuyến đi.
- **Chia sẻ:** Link công khai hoặc riêng tư (có mật khẩu).
- **Chỉnh sửa:** Xóa ảnh, sửa metadata.

### Dung lượng và bảo mật

- Cần quy định giới hạn dung lượng (gói Free vs. Premium).
- Cam kết lưu file gốc chất lượng cao, không nén.
- Mặc định riêng tư: chỉ chủ tài khoản xem được ảnh.

### Kết quả cần ghi

- **Chức năng Archive:** Upload tự động, quản lý album, gắn metadata, chia sẻ, tìm kiếm nâng cao.
- **Metadata:** Các trường bắt buộc/tùy chọn.
- **Quy tắc lưu trữ:** Định dạng file hỗ trợ, giới hạn dung lượng, thời gian lưu trữ.