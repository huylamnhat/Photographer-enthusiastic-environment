# Phân hệ dịch vụ bổ trợ và cộng đồng

## 1. Nhận phim và giao hàng

### 1.1 Ai yêu cầu lấy phim, ai giao phim?

- **Khách hàng (Customer):** Yêu cầu lấy phim khi đặt dịch vụ tráng/scan và chọn giao nhận tận nơi.
- **Đối tác vận chuyển (Delivery Partner):** Ahamove, Lalamove hoặc đội giao nhận của Film Lab; lấy phim từ khách và giao đến Lab.
- **Film Lab Owner:** Xác nhận đã nhận phim; bàn giao film hoặc ảnh in cho đơn vị vận chuyển khi giao trả khách.

### 1.2 Khách có thể tự mang phim đến Lab không?

Có, khách chọn một trong hai hình thức:
- **Tự mang đến (In-person Drop-off):** Khách tự mang film đến địa chỉ Lab.
- **Giao nhận tận nơi (Door-to-door Pickup):** Đối tác vận chuyển lấy film và giao đến Lab; xử lý xong, film/ảnh in được giao trả theo lựa chọn của khách.

### 1.3 Thông tin vận chuyển cần lưu

- Địa chỉ lấy film và địa chỉ giao trả film/ảnh in.
- Họ tên, số điện thoại người gửi và người nhận.
- Thời gian hẹn lấy film và thời gian giao dự kiến.
- Phí vận chuyển và trạng thái thanh toán phí.
- Mã vận đơn (Tracking Code), đơn vị vận chuyển, mã đơn dịch vụ liên quan.
- Trạng thái vận chuyển và lịch sử cập nhật trạng thái.

### 1.4 Xử lý khi giao hàng thất bại

- **Lấy film thất bại:** Hệ thống cập nhật trạng thái thất bại, thông báo khách để hẹn lại lịch, tối đa **2 lần thử lại** theo quy định của nhóm.
- **Giao trả thất bại:** Hàng được lưu tại Film Lab; khách đến nhận trực tiếp hoặc đặt lại giao hàng và trả phí phát sinh (nếu có).

**Phân quyền:**
- Customer: xem trạng thái và thông tin giao nhận của đơn mình.
- Delivery Partner: cập nhật trạng thái các đơn được phân công.
- Film Lab Owner: xác nhận nhận film và bàn giao hàng.
- Admin: chỉ tra cứu và can thiệp xử lý sự cố vận chuyển theo quyền được cấp; mọi thay đổi thủ công phải ghi người thực hiện, thời gian, lý do.

---

## 2. Thanh toán và hoàn tiền

### 2.1 Điều kiện được yêu cầu hoàn tiền

- Hủy đơn thành công khi đơn đang ở **Pending Confirmation** (Lab chưa bắt đầu xử lý).
- Lab từ chối nhận đơn hoặc chủ động hủy do không thể cung cấp dịch vụ.
- Film thất lạc hoặc hư hỏng hoàn toàn do lỗi xử lý của Lab.
- Film trắng hoặc lỗi kỹ thuật thuộc trách nhiệm Lab, sau khi được xác minh.
- Khách bị trừ tiền nhiều lần, hoặc thanh toán thành công nhưng dịch vụ không được thực hiện đúng quy định.

**Lưu ý:** Khách chỉ hủy đơn theo quy trình thông thường **trước khi Lab bắt đầu xử lý**. Khi đơn đã sang **Processing** thì không hủy thông thường được, nhưng vẫn có thể yêu cầu xem xét hoàn tiền nếu có lỗi dịch vụ thuộc trường hợp được chấp nhận.

### 2.2 Ai xác nhận hoàn tiền?

| Vai trò | Nhiệm vụ |
|---|---|
| Customer | Gửi yêu cầu, nêu lý do, cung cấp bằng chứng nếu cần |
| Film Lab Owner | Kiểm tra tình trạng film, xác nhận nguyên nhân kỹ thuật, gửi giải trình |
| Admin / người được phân quyền | Phê duyệt hoặc từ chối theo chính sách hệ thống |
| Hệ thống | Tự động duyệt yêu cầu hủy đơn trước khi Lab xác nhận nếu đủ điều kiện đã thống nhất |

Phê duyệt hoàn tiền và thực hiện giao dịch hoàn tiền là **hai bước riêng biệt**. Hệ thống chỉ ghi nhận hoàn tiền thành công khi có xác nhận từ cổng thanh toán hoặc phương thức hoàn tiền được hỗ trợ.

### 2.3 Hoàn toàn bộ hay một phần?

| Hình thức | Áp dụng khi |
|---|---|
| Hoàn toàn bộ | Lab từ chối đơn, hủy đơn do không thể thực hiện, hoặc làm thất lạc/hư hỏng hoàn toàn film do lỗi Lab |
| Hoàn một phần | Film trắng hoặc lỗi kỹ thuật chỉ ảnh hưởng một phần dịch vụ: hoàn phí scan/in đủ điều kiện; phí tráng được giữ lại nếu chính sách đã thống nhất quy định không hoàn |
| Hủy trước khi xử lý | Hoàn số tiền khách đủ điều kiện nhận theo chính sách hủy đơn và số tiền đã thanh toán thực tế |

Đơn chưa thanh toán thành công thì không hoàn tiền (chưa phát sinh khoản đã thu).

### 2.4 Theo dõi trạng thái hoàn tiền

- **Luồng trạng thái:** `Refund_Requested` → `Refund_Approved` / `Refund_Rejected` → `Refund_Processing` → `Refund_Success` / `Refund_Failed`.
- **Chuyển tiền:** Hoàn thẳng về tài khoản/ví thanh toán ban đầu của khách qua API cổng thanh toán, trong **3–5 ngày làm việc**.
- **Tra cứu:** Khách và Lab xem tiến độ trong chi tiết đơn hàng hoặc lịch sử giao dịch tại `Refund_Transactions`.

---

## 3. Chia sẻ kiến thức, bài viết và cộng đồng

### 3.1 Ai được đăng bài, bình luận, chỉnh sửa?

- Người dùng đã xác thực (Customer, Photography Expert, Film Lab Owner) được đăng bài theo quyền được cấp.
- Người dùng đã đăng nhập được bình luận và tương tác với bài công khai.
- Tác giả được sửa/xóa bài viết và bình luận do mình tạo.
- Photography Expert có thể đăng hướng dẫn, chia sẻ kỹ thuật, review film/máy ảnh/ống kính/Film Lab, thông tin workshop hoặc photowalk.

### 3.2 Báo cáo nội dung vi phạm

- Người dùng được báo cáo bài viết/bình luận có nội dung spam, xúc phạm, sai lệch kỹ thuật hoặc vi phạm quy định cộng đồng.
- Hệ thống lưu: mã nội dung bị báo cáo, người báo cáo, lý do, thời điểm, trạng thái xử lý.

### 3.3 Admin kiểm duyệt

- Admin/người kiểm duyệt được phân quyền xem danh sách bài viết, bình luận bị báo cáo.
- Có thể **ẩn hoặc gỡ** nội dung vi phạm, cảnh cáo tài khoản theo quy định.
- **Không** được tự ý sửa nội dung bài viết của người dùng.
- Mỗi thao tác kiểm duyệt lưu: người thực hiện, thời gian, lý do, kết quả.
- Quyền kiểm duyệt chỉ áp dụng trong phạm vi được cấp, không mặc định mọi Admin đều có toàn quyền.

### 3.4 Like, Bookmark, Follow

Đề xuất 3 chức năng, nhằm tăng tương tác trong cộng đồng nhiếp ảnh analog:
- **Like:** Thích bài viết.
- **Bookmark:** Lưu bài để xem lại; danh sách đã lưu chỉ chủ sở hữu xem được.
- **Follow:** Theo dõi tác giả để nhận bài mới.

> Nhóm cần xác nhận chức năng nào thuộc phạm vi bắt buộc của phiên bản hiện tại.

---

## 4. Marketplace

### 4.1 Phạm vi hệ thống
Hệ thống sàn giao dịch thiết bị analog kết nối thành viên cộng đồng:
- Đăng tin mua bán, trao đổi máy ảnh analog, ống kính, film và phụ kiện.
- Tiền kiểm tin đăng 100% bởi Admin trước khi hiển thị công khai.
- Tìm kiếm nâng cao theo danh mục, khu vực, tầm giá.
- Liên hệ trực tiếp giữa người mua và người bán qua Số điện thoại / Zalo (không tích hợp hệ thống chat riêng).
- Đặt mua, thỏa thuận giao nhận (trực tiếp hoặc COD) và đánh giá uy tín người bán.

### 4.2 Ai được bán sản phẩm?

| Nhóm người bán | Điều kiện / Được bán |
|---|---|
| Cá nhân (Customer/Photographer), giao dịch C2C | Xác thực tài khoản (Email, Số điện thoại); đăng bán máy ảnh cũ, ống kính |
| Film Lab Owner & Chuyên gia (Verified Sellers), giao dịch B2C | Film mới/đã hết hạn, hóa chất, phụ kiện, máy ảnh đã qua kiểm định kỹ thuật |

### 4.3 Thông tin sản phẩm, quy trình mua và liên hệ

**Thông tin sản phẩm bắt buộc:**
- Tên sản phẩm và danh mục (máy ảnh SLR / Rangefinder / Compact, ống kính, film 135 / 120, phụ kiện).
- Tình trạng vật lý: Mới 100%, Like New, Đã qua sử dụng, Hoạt động tốt / Có lỗi nhẹ (mô tả rõ đo sáng, lăng kính, buồng film).
- Hình ảnh thực tế: tối thiểu **3 ảnh** chi tiết các góc cạnh.
- Giá bán niêm yết, địa điểm giao dịch, số điện thoại / Zalo liên hệ.

**Quy trình mua và liên hệ:**
1. Người mua xem tin đăng → bấm nút **"Liên hệ qua SĐT / Zalo"** để gọi điện hoặc nhắn tin Zalo trực tiếp trao đổi tình trạng thiết bị.
2. Người mua bấm **"Đặt mua"** / liên hệ trên tin đăng.
3. Giao dịch trực tiếp (hai bên tự thỏa thuận nhận hàng trực tiếp hoặc gửi chuyển phát COD bưu điện).
4. Sau khi hoàn tất giao dịch, người mua đánh giá số sao và nhận xét uy tín người bán.