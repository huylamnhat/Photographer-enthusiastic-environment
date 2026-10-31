# Chức năng Admin – Nền tảng Film Lab

## Phần 1: Quản lý người dùng và Film Lab

### 1.1 Tìm kiếm và xem danh sách tài khoản (Web Admin)

- **Lọc theo vai trò:** Khách hàng, Film Lab, Chuyên gia.
- **Lọc theo trạng thái:** Đang hoạt động, Đang bị khóa, Đang chờ duyệt (chỉ áp dụng cho Lab).
- **Tìm nhanh:** Nhập Email, Số điện thoại hoặc Tên người dùng / Tên Lab.
- **Hiển thị:** Dạng bảng gồm Tên, Email, Số điện thoại, Vai trò (Khách / Lab), Ngày tạo, nút Xem chi tiết hoặc Khóa.

### 1.2 Thông tin Film Lab cần điền khi đăng ký

| Thông tin | Mục đích |
|---|---|
| Tên Lab và địa chỉ cụ thể | Để khách hoặc shipper biết nơi mang phim đến |
| Số điện thoại, Fanpage/Website (nếu có) | Liên hệ |
| Họ tên chủ Lab và ảnh CCCD | Xác định người chịu trách nhiệm pháp lý nếu xảy ra lừa đảo |
| Các loại phim nhận tráng | Ví dụ: film màu 35mm, 120, film điện ảnh (ECN-2), film đen trắng (B&W) |
| Ảnh không gian tiệm hoặc máy tráng/scan | Chứng minh là tiệm thật, không phải Lab "ma" |

### 1.3 Admin kiểm tra gì trước khi bấm "Duyệt"?

- Địa chỉ và số điện thoại có thật không.
- Các loại dịch vụ đăng ký có phù hợp không.

**Cách xử lý:**
- **Hợp lệ:** Bấm "Duyệt" → Lab chính thức xuất hiện trên ứng dụng của khách.
- **Chưa đạt:** Bấm "Từ chối" kèm ghi chú ngắn (ví dụ: "Vui lòng bổ sung địa chỉ chính xác và số điện thoại liên hệ").

---

## Phần 2: Duyệt hoặc Khóa tài khoản

### 2.1 Các trạng thái tài khoản

| Trạng thái | Ý nghĩa |
|---|---|
| Chờ duyệt (Pending) | Chỉ áp dụng cho Lab mới đăng ký |
| Hoạt động bình thường (Active) | Dùng được đầy đủ tính năng |
| Bị khóa (Banned) | Bị chặn, không cho đăng nhập |

### 2.2 Lý do khóa tài khoản

- **Khách hàng:** Đặt đơn trêu đùa (đặt rồi không gửi phim), spam bình luận tục tĩu, đăng tin lừa đảo trên chợ.
- **Film Lab:** Làm mất/làm hỏng phim của khách nhiều lần mà không đền bù, bị khiếu nại dịch vụ quá tệ, hoặc có thái độ gian lận.

### 2.3 Thông báo và khiếu nại khi bị khóa

- **Thông báo:** Hệ thống gửi ngay email nêu rõ lý do: *"Tài khoản của bạn bị khóa vì lý do: [Lý do Admin nhập]"*.
- **Xin xem xét lại:** Màn hình đăng nhập hiện thông báo bị khóa kèm nút **"Liên hệ hỗ trợ / Khiếu nại"**. Người dùng gửi tin nhắn giải thích để Admin xem xét mở lại nếu bị khóa oan.

---

## Phần 3: Quản lý dịch vụ, nội dung và báo cáo

### 3.1 Quyền của Admin với dịch vụ của Lab

- **Không được** tự ý sửa tên dịch vụ hoặc đổi giá (Lab tự kinh doanh dịch vụ của mình).
- **Chỉ được** bấm **"Ẩn dịch vụ này"** khi tên dịch vụ bậy bạ hoặc có dấu hiệu lừa đảo, đồng thời yêu cầu Lab sửa lại.

### 3.2 Nội dung Admin phải kiểm duyệt

**Tin đăng bán máy/phim trên Marketplace (tiền kiểm):**
- Tin đăng chưa hiện lên sàn ngay mà vào danh sách "Chờ duyệt".
- Admin xem: ảnh máy có rõ ràng không, giá có hợp lý không (tránh rao giá ảo, lừa đảo).
- Ổn thì bấm "Duyệt" → tin hiện lên chợ.

**Bài viết diễn đàn / Đánh giá của khách (hậu kiểm):**
- Được đăng tự do để cộng đồng chia sẻ.
- Khi có người bấm "Báo cáo vi phạm" (nói tục, xúc phạm người khác), Admin xem và bấm "Xóa bài".

### 3.3 Dashboard của Admin

Dự án phi lợi nhuận nên không cần biểu đồ tài chính phức tạp, chỉ cần các số liệu giúp hệ thống vận hành trơn tru:

- **Số lượng người dùng:** Số Khách hàng, số Film Lab.
- **Số lượng đơn hàng:** Tổng đơn hoàn thành, đơn đang tráng, đơn bị hủy.
- **Tỷ lệ hoàn thành:** Lab nào làm nhanh, Lab nào hay trễ hạn.
- **Chờ xử lý:** Số tin bán máy đang chờ duyệt, số đơn khiếu nại chưa giải quyết.

---

## Phần 4: Phân quyền và Xử lý khiếu nại

### 4.1 Phân quyền

| Vai trò | Quyền hạn |
|---|---|
| Khách hàng | Tìm Lab, đặt đơn tráng/scan, xem ảnh, đăng tin bán máy (chờ duyệt), viết review |
| Film Lab | Cài đặt giá dịch vụ, nhận phim, cập nhật trạng thái (đang tráng / đang scan), upload ảnh trả khách |
| Admin | Duyệt Lab mới, duyệt tin bán máy, khóa tài khoản vi phạm, giải quyết tranh chấp giữa khách và Lab |

> **Lưu ý quan trọng:** Admin không tự ý xem ảnh riêng tư của khách, trừ khi hai bên có khiếu nại và đồng ý mở ảnh làm bằng chứng.

### 4.2 Quy trình khách khiếu nại Film Lab

Ví dụ: Lab làm cháy hết ảnh, hoặc file scan bị mờ.

1. Khách bấm nút **"Khiếu nại"** trên Mobile App.
2. Hệ thống báo cho Lab để Lab tự thương lượng đền bù với khách (ví dụ: đền cuộn phim mới).
3. Nếu hai bên không thống nhất, **Admin vào cuộc**: xem bằng chứng của cả hai bên và đưa ra phán quyết (ví dụ: yêu cầu Lab đền bù; nếu Lab từ chối thì khóa tài khoản Lab).

### 4.3 Nhật ký thao tác (Log)

Hệ thống tự động ghi lại mỗi thao tác của Admin để đảm bảo công bằng, minh bạch. Mỗi bản ghi gồm: **Ai làm – Lúc mấy giờ – Làm việc gì – Với ai – Lý do.**

Ví dụ: *"Admin Nam đã khóa tài khoản của Lab X lúc 14:00 ngày 18/10, lý do: Không đền bù phim hỏng cho khách."*