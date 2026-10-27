# NHÓM 1: SƠ ĐỒ THIẾT KẾ CƠ SỞ DỮ LIỆU

**Dự án:** MiniLab – Nền tảng kết nối cộng đồng nhiếp ảnh phim và các Film Lab  
**Hệ quản trị cơ sở dữ liệu:** Microsoft SQL Server  
**Backend:** Node.js (Express)  
**Mục tiêu thiết kế:** Xác định thực thể, mối quan hệ và lược đồ quan hệ; bảo đảm tính toàn vẹn, hạn chế dư thừa dữ liệu và hướng đến chuẩn hóa 3NF.

---

## 1. Sơ đồ ERD quan niệm (Conceptual ERD)

### 1.1. Mục đích

Sơ đồ ERD quan niệm mô tả các thực thể chính trong hệ thống MiniLab, những thuộc tính tiêu biểu và mối quan hệ giữa chúng. Ở giai đoạn này, sơ đồ tập trung vào ý nghĩa nghiệp vụ, chưa đi sâu vào kiểu dữ liệu SQL Server hay chi tiết cài đặt khóa ngoại.

Các thực thể chính bao gồm:

- **Users:** Người dùng hệ thống, có thể mang các vai trò Customer, Lab Owner, Expert, Delivery Partner hoặc Admin.
- **Lab_Profile:** Hồ sơ và thông tin hoạt động của Film Lab.
- **Service_Package:** Các gói dịch vụ tráng, scan và in ảnh của Lab.
- **Orders:** Đơn hàng khách hàng gửi đến Lab.
- **Order_Item:** Các hạng mục dịch vụ trong đơn hàng.
- **Digital_Film_Archive:** Kho lưu trữ ảnh phim kỹ thuật số của người dùng.
- **Archive_Photo:** Ảnh cụ thể nằm trong kho lưu trữ.
- **Photo_Metadata:** Thông tin kỹ thuật của ảnh như máy ảnh, ống kính, ISO và thông số tráng phim.
- **Equipment_Listing:** Tin đăng mua bán, trao đổi thiết bị nhiếp ảnh.
- **Review:** Đánh giá dịch vụ Lab hoặc người bán.
- **Post_Article:** Bài viết, hướng dẫn và nội dung cộng đồng.
- **Dispute_Complaint:** Khiếu nại phát sinh từ đơn hàng.

Ngoài ra, hệ thống có các thực thể hỗ trợ như `Roles`, `User_Roles`, `Film_Format`, `Payment`, `Tag`, `Marketplace_Transaction` và các bảng trung gian nhằm thể hiện đầy đủ những mối quan hệ N–N.

### 1.2. Sơ đồ ERD quan niệm tổng thể


### 1.3. Các mối quan hệ chính

| Thực thể A | Quan hệ | Thực thể B | Loại quan hệ | Cách triển khai |
|---|---|---|---|---|
| Users | Có vai trò | Roles | N–N | `User_Roles` |
| Users | Sở hữu hồ sơ | Lab_Profile | 1–N hoặc 1–1 theo quy tắc nghiệp vụ | `Lab_Profile.owner_id` |
| Lab_Profile | Cung cấp | Service_Package | 1–N | `Service_Package.lab_id` |
| Lab_Profile | Hỗ trợ định dạng phim | Film_Format | N–N | `Lab_Film_Format` |
| Users | Tạo | Orders | 1–N | `Orders.customer_id` |
| Lab_Profile | Nhận | Orders | 1–N | `Orders.lab_id` |
| Orders | Chứa | Order_Item | 1–N | `Order_Item.order_id` |
| Service_Package | Được chọn trong | Order_Item | 1–N | `Order_Item.package_id` |
| Users | Sở hữu | Digital_Film_Archive | 1–N | `Digital_Film_Archive.owner_id` |
| Order_Item | Tạo ra | Digital_Film_Archive | 1–1 tùy chọn | `Digital_Film_Archive.order_item_id` và `UNIQUE` |
| Digital_Film_Archive | Chứa | Archive_Photo | 1–N | `Archive_Photo.archive_id` |
| Archive_Photo | Có thông tin kỹ thuật | Photo_Metadata | 1–1 tùy chọn | `Photo_Metadata.photo_id` |
| Archive_Photo | Được gắn thẻ | Tag | N–N | `Photo_Tag` |
| Users | Đăng bán thiết bị | Equipment_Listing | 1–N | `Equipment_Listing.seller_id` |
| Users | Lưu tin yêu thích | Equipment_Listing | N–N | `Listing_Favorite` |
| Users | Viết đánh giá | Review | 1–N | `Review.reviewer_id` |
| Users | Đăng bài | Post_Article | 1–N | `Post_Article.author_id` |
| Post_Article | Được gắn thẻ | Tag | N–N | `Post_Tag` |
| Orders | Phát sinh khiếu nại | Dispute_Complaint | 1–N | `Dispute_Complaint.order_id` |

**Lưu ý:** `Lab_Profile` được thiết kế với khóa chính riêng `lab_id`. Trong lược đồ hiện tại, `owner_id` là khóa ngoại nhưng chưa bắt buộc duy nhất, vì vậy một người dùng có thể sở hữu nhiều hồ sơ Lab. Nếu nghiệp vụ quy định mỗi người dùng chỉ được sở hữu tối đa một Lab, cần bổ sung ràng buộc `UNIQUE` trên `owner_id`.

---

## 2. Lược đồ quan hệ và ERD vật lý (Physical Relational Schema / Physical ERD)

### 2.1. Mục đích

ERD vật lý chuyển mô hình quan niệm thành cấu trúc bảng cụ thể trong Microsoft SQL Server. Mỗi bảng được xác định bằng:

- **PK (Primary Key):** Khóa chính, định danh duy nhất từng bản ghi.
- **FK (Foreign Key):** Khóa ngoại, liên kết bản ghi với bảng khác.
- **NOT NULL:** Bắt buộc có giá trị.
- **UNIQUE:** Không cho phép giá trị trùng lặp theo phạm vi ràng buộc.
- **CHECK:** Kiểm tra điều kiện hợp lệ của dữ liệu.
- **DEFAULT:** Giá trị mặc định khi không truyền giá trị.
- **3NF:** Chuẩn hóa dữ liệu nhằm hạn chế dư thừa và các bất thường khi thêm, sửa hoặc xóa dữ liệu.

Quy ước kiểu dữ liệu chính:

| Kiểu dữ liệu | Mục đích sử dụng |
|---|---|
| `INT`, `BIGINT` | Mã định danh và số lượng lớn bản ghi |
| `TINYINT`, `SMALLINT` | Mã danh mục, số lượng nhỏ hoặc giá trị có phạm vi giới hạn |
| `VARCHAR(n)` | Mã, trạng thái, URL hoặc chuỗi không yêu cầu Unicode |
| `NVARCHAR(n)` | Tên, mô tả và nội dung tiếng Việt |
| `BIT` | Giá trị đúng/sai |
| `DECIMAL(p,s)` | Giá tiền, tọa độ và các số thập phân cần độ chính xác |
| `DATE` | Ngày không bao gồm giờ |
| `DATETIME2` | Ngày và giờ, phù hợp lưu thời điểm theo UTC |
| `TIME` | Giờ mở cửa, đóng cửa hoặc thời lượng theo giờ |

### 2.2. Sơ đồ ERD vật lý theo các phân hệ chính


### 2.3. Đặc tả các bảng chính

Các bảng dưới đây là phần lược đồ quan hệ cốt lõi phục vụ yêu cầu Nhóm 1. Tên bảng và các trường được chọn theo thiết kế MiniLab. Các bảng hỗ trợ nghiệp vụ như `Payment`, `Refund`, `Shipment`, `Listing_Image`, `Marketplace_Transaction`, `Tag`, `Photo_Tag` và `Post_Tag` cũng cần tồn tại để các khóa ngoại và quan hệ trong ERD được triển khai đầy đủ.

#### Bảng `Users` – Người dùng

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `user_id` | `INT IDENTITY(1,1)` | PK, NOT NULL | Mã người dùng |
| `email` | `NVARCHAR(255)` | NOT NULL, UNIQUE | Email đăng nhập |
| `phone` | `VARCHAR(20)` | NULL, UNIQUE có điều kiện | Số điện thoại |
| `password_hash` | `VARCHAR(255)` | NOT NULL | Mật khẩu đã băm |
| `full_name` | `NVARCHAR(150)` | NOT NULL | Họ tên |
| `avatar_url` | `VARCHAR(500)` | NULL | Đường dẫn ảnh đại diện |
| `status` | `VARCHAR(20)` | NOT NULL, DEFAULT, CHECK | Trạng thái tài khoản |
| `email_verified` | `BIT` | NOT NULL, DEFAULT | Đã xác minh email hay chưa |
| `created_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm tạo |
| `updated_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm cập nhật |

Ràng buộc trạng thái `status` chỉ chấp nhận các giá trị: `ACTIVE`, `PENDING_VERIFY`, `LOCKED`, `DELETED`.

Các vai trò được lưu ở `Roles` và bảng trung gian `User_Roles`, thay vì tạo một cột riêng cho từng vai trò trong `Users`.

#### Bảng `Lab_Profile` – Hồ sơ Film Lab

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `lab_id` | `INT IDENTITY(1,1)` | PK, NOT NULL | Mã Lab |
| `owner_id` | `INT` | FK → `Users.user_id`, NOT NULL | Chủ sở hữu |
| `lab_name` | `NVARCHAR(200)` | NOT NULL | Tên Lab |
| `slug` | `VARCHAR(220)` | NOT NULL, UNIQUE | Định danh URL |
| `description` | `NVARCHAR(2000)` | NULL | Mô tả Lab |
| `phone` | `VARCHAR(20)` | NOT NULL | Số liên hệ |
| `province` | `NVARCHAR(100)` | NOT NULL | Tỉnh/thành |
| `district` | `NVARCHAR(100)` | NOT NULL | Quận/huyện |
| `street_address` | `NVARCHAR(255)` | NOT NULL | Địa chỉ |
| `latitude` | `DECIMAL(9,6)` | NULL, CHECK | Vĩ độ |
| `longitude` | `DECIMAL(9,6)` | NULL, CHECK | Kinh độ |
| `business_license_no` | `VARCHAR(50)` | NULL, UNIQUE có điều kiện | Số giấy phép kinh doanh |
| `avg_rating` | `DECIMAL(3,2)` | NOT NULL, DEFAULT, CHECK | Điểm đánh giá trung bình |
| `review_count` | `INT` | NOT NULL, DEFAULT | Số lượt đánh giá |
| `approval_status` | `VARCHAR(20)` | NOT NULL, DEFAULT, CHECK | Trạng thái duyệt |
| `created_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm tạo |

`approval_status` chấp nhận `PENDING`, `APPROVED`, `REJECTED`, `SUSPENDED`. `avg_rating` nằm trong khoảng từ 0 đến 5; vĩ độ từ -90 đến 90 và kinh độ từ -180 đến 180.

#### Bảng `Service_Package` – Gói dịch vụ

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `package_id` | `INT IDENTITY(1,1)` | PK, NOT NULL | Mã gói dịch vụ |
| `lab_id` | `INT` | FK → `Lab_Profile.lab_id`, NOT NULL | Lab cung cấp |
| `service_type` | `VARCHAR(20)` | NOT NULL, CHECK | Loại dịch vụ |
| `name` | `NVARCHAR(200)` | NOT NULL | Tên gói |
| `description` | `NVARCHAR(1000)` | NULL | Mô tả |
| `format_id` | `SMALLINT` | FK → `Film_Format.format_id`, NOT NULL | Định dạng phim |
| `process_type_id` | `SMALLINT` | FK → `Process_Type.process_type_id`, NULL | Quy trình tráng |
| `scan_quality` | `VARCHAR(20)` | NULL, CHECK | Chất lượng scan |
| `scan_dpi` | `SMALLINT` | NULL | Độ phân giải scan |
| `output_format` | `VARCHAR(10)` | NULL, CHECK | Định dạng ảnh đầu ra |
| `price` | `DECIMAL(15,2)` | NOT NULL, CHECK | Giá dịch vụ |
| `price_unit` | `VARCHAR(20)` | NOT NULL, CHECK | Đơn vị tính giá |
| `est_processing_days` | `TINYINT` | NOT NULL | Số ngày xử lý dự kiến |
| `is_active` | `BIT` | NOT NULL, DEFAULT | Gói có đang hoạt động hay không |

`service_type` gồm `DEVELOP`, `SCAN`, `DEVELOP_SCAN`, `PRINT`. `price` phải lớn hơn hoặc bằng 0. Các giá trị cho phép của `scan_quality`, `output_format` và `price_unit` cần được giới hạn bằng `CHECK` tương ứng với danh mục nghiệp vụ.

#### Bảng `Orders` – Đơn hàng

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `order_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã đơn hàng |
| `order_code` | `VARCHAR(50)` | NOT NULL, UNIQUE | Mã đơn hiển thị |
| `customer_id` | `INT` | FK → `Users.user_id`, NOT NULL | Khách hàng |
| `lab_id` | `INT` | FK → `Lab_Profile.lab_id`, NOT NULL | Lab tiếp nhận |
| `status` | `VARCHAR(30)` | NOT NULL, CHECK | Trạng thái đơn |
| `receive_method` | `VARCHAR(30)` | NOT NULL, CHECK | Phương thức gửi film |
| `return_method` | `VARCHAR(30)` | NOT NULL, CHECK | Phương thức nhận lại |
| `subtotal` | `DECIMAL(15,2)` | NOT NULL, CHECK | Tiền dịch vụ |
| `shipping_fee` | `DECIMAL(15,2)` | NOT NULL, DEFAULT, CHECK | Phí vận chuyển |
| `platform_fee` | `DECIMAL(15,2)` | NOT NULL, DEFAULT, CHECK | Phí nền tảng |
| `discount_amount` | `DECIMAL(15,2)` | NOT NULL, DEFAULT, CHECK | Tiền giảm giá |
| `total_amount` | `DECIMAL(15,2)` | NOT NULL, CHECK | Tổng tiền |
| `expected_completion_date` | `DATE` | NULL | Ngày hoàn thành dự kiến |
| `created_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm tạo |
| `updated_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm cập nhật |

Các trường tiền tệ cần có `CHECK` không âm. `total_amount` cần nhất quán với các thành phần giá theo công thức nghiệp vụ đã thống nhất của dự án.

#### Bảng `Order_Item` – Hạng mục đơn hàng

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `order_item_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã hạng mục |
| `order_id` | `BIGINT` | FK → `Orders.order_id`, NOT NULL | Đơn hàng |
| `package_id` | `INT` | FK → `Service_Package.package_id`, NOT NULL | Gói dịch vụ |
| `film_stock_id` | `INT` | FK → `Film_Stock.film_stock_id`, NULL | Loại film |
| `quantity` | `SMALLINT` | NOT NULL, CHECK | Số lượng |
| `unit_price` | `DECIMAL(15,2)` | NOT NULL, CHECK | Đơn giá tại thời điểm đặt |
| `line_total` | `DECIMAL(15,2)` | NOT NULL, CHECK | Thành tiền |
| `note` | `NVARCHAR(1000)` | NULL | Ghi chú |
| `status` | `VARCHAR(30)` | NOT NULL | Trạng thái xử lý |

`quantity` phải lớn hơn 0. `unit_price` và `line_total` không được âm. `unit_price` lưu lại giá tại thời điểm đặt hàng để lịch sử đơn không thay đổi khi Lab cập nhật giá gói dịch vụ.

#### Bảng `Digital_Film_Archive` – Kho ảnh phim kỹ thuật số

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `archive_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã kho ảnh |
| `owner_id` | `INT` | FK → `Users.user_id`, NOT NULL | Chủ kho ảnh |
| `order_item_id` | `BIGINT` | FK → `Order_Item.order_item_id`, UNIQUE, NULL | Hạng mục tạo ra kho |
| `title` | `NVARCHAR(200)` | NOT NULL | Tên kho |
| `description` | `NVARCHAR(1000)` | NULL | Mô tả |
| `film_stock_id` | `INT` | FK → `Film_Stock.film_stock_id`, NULL | Loại film |
| `shot_start_date` | `DATE` | NULL | Ngày chụp bắt đầu |
| `shot_end_date` | `DATE` | NULL | Ngày chụp kết thúc |
| `visibility` | `VARCHAR(10)` | NOT NULL, DEFAULT, CHECK | Chế độ hiển thị |
| `created_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm tạo |

`visibility` chỉ nhận `PRIVATE` hoặc `PUBLIC`. `order_item_id` có thể để trống nếu kho không được tạo trực tiếp từ một hạng mục đơn hàng; khi có giá trị, `UNIQUE` bảo đảm một hạng mục không liên kết với nhiều kho.

#### Bảng `Archive_Photo` – Ảnh trong kho

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `photo_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã ảnh |
| `archive_id` | `BIGINT` | FK → `Digital_Film_Archive.archive_id`, NOT NULL | Kho chứa ảnh |
| `scan_file_id` | `BIGINT` | FK → `Scan_File.scan_file_id`, UNIQUE, NULL | File scan nguồn |
| `file_name` | `NVARCHAR(255)` | NOT NULL | Tên file |
| `storage_key` | `VARCHAR(500)` | NOT NULL, UNIQUE | Khóa lưu trữ |
| `thumbnail_key` | `VARCHAR(500)` | NULL | Khóa ảnh thu nhỏ |
| `mime_type` | `VARCHAR(100)` | NOT NULL | Kiểu file |
| `size_bytes` | `BIGINT` | NOT NULL, CHECK | Dung lượng byte |
| `width_px` | `INT` | NULL, CHECK | Chiều rộng ảnh |
| `height_px` | `INT` | NULL, CHECK | Chiều cao ảnh |
| `sort_order` | `SMALLINT` | NOT NULL, DEFAULT | Thứ tự hiển thị |
| `is_favorite` | `BIT` | NOT NULL, DEFAULT | Ảnh yêu thích |
| `uploaded_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm tải lên |
| `is_deleted` | `BIT` | NOT NULL, DEFAULT | Cờ xóa mềm |

`size_bytes` không được âm; `width_px` và `height_px`, nếu có, phải lớn hơn 0. Nếu triển khai xóa mềm, có thể bổ sung `deleted_at DATETIME2(0) NULL` để ghi thời điểm xóa.

#### Bảng `Photo_Metadata` – Metadata ảnh

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `photo_id` | `BIGINT` | PK đồng thời FK → `Archive_Photo.photo_id` | Ảnh được mô tả |
| `camera_brand` | `NVARCHAR(100)` | NULL | Hãng máy ảnh |
| `camera_model` | `NVARCHAR(150)` | NULL | Model máy ảnh |
| `lens` | `NVARCHAR(150)` | NULL | Ống kính |
| `film_stock_id` | `INT` | FK → `Film_Stock.film_stock_id`, NULL | Loại film |
| `iso` | `SMALLINT` | NULL, CHECK | ISO |
| `aperture` | `DECIMAL(4,1)` | NULL, CHECK | Khẩu độ |
| `shutter_speed` | `VARCHAR(30)` | NULL | Tốc độ màn trập |
| `date_taken` | `DATE` | NULL | Ngày chụp |
| `location_text` | `NVARCHAR(255)` | NULL | Địa điểm |
| `process_type_id` | `SMALLINT` | FK → `Process_Type.process_type_id`, NULL | Quy trình tráng |
| `push_pull_stops` | `DECIMAL(3,1)` | NULL | Giá trị push/pull |
| `scan_device` | `NVARCHAR(150)` | NULL | Thiết bị scan |
| `scan_dpi` | `SMALLINT` | NULL, CHECK | Độ phân giải scan |
| `notes` | `NVARCHAR(1000)` | NULL | Ghi chú |

Sử dụng `photo_id` làm PK đồng thời FK bảo đảm mỗi bản ghi metadata gắn với tối đa một ảnh và không thể tồn tại metadata cho ảnh không tồn tại.

#### Bảng `Equipment_Listing` – Tin đăng thiết bị

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `listing_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã tin đăng |
| `seller_id` | `INT` | FK → `Users.user_id`, NOT NULL | Người đăng |
| `category_id` | `INT` | FK → `Equipment_Category.category_id`, NOT NULL | Danh mục thiết bị |
| `listing_type` | `VARCHAR(10)` | NOT NULL, CHECK | Bán, đổi hoặc mua |
| `title` | `NVARCHAR(200)` | NOT NULL | Tiêu đề |
| `description` | `NVARCHAR(2000)` | NULL | Mô tả |
| `brand` | `NVARCHAR(100)` | NULL | Thương hiệu |
| `model` | `NVARCHAR(150)` | NULL | Model |
| `item_condition` | `VARCHAR(20)` | NOT NULL, CHECK | Tình trạng |
| `price` | `DECIMAL(15,2)` | NOT NULL, CHECK | Giá đăng |
| `is_negotiable` | `BIT` | NOT NULL, DEFAULT | Cho phép thương lượng |
| `location_text` | `NVARCHAR(255)` | NULL | Địa điểm |
| `status` | `VARCHAR(30)` | NOT NULL, CHECK | Trạng thái tin |
| `created_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm đăng |
| `expires_at` | `DATETIME2(0)` | NULL | Thời điểm hết hạn |

`listing_type` gồm `SELL`, `TRADE`, `BUY`. `item_condition` gồm `NEW`, `LIKE_NEW`, `GOOD`, `FAIR`, `FOR_PARTS`. `price` không được âm.

#### Bảng `Review` – Đánh giá

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `review_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã đánh giá |
| `reviewer_id` | `INT` | FK → `Users.user_id`, NOT NULL | Người đánh giá |
| `review_type` | `VARCHAR(10)` | NOT NULL, CHECK | Đối tượng đánh giá |
| `order_id` | `BIGINT` | FK → `Orders.order_id`, UNIQUE, NULL | Đơn hàng được đánh giá |
| `txn_id` | `BIGINT` | FK → `Marketplace_Transaction.txn_id`, UNIQUE, NULL | Giao dịch marketplace |
| `rating` | `TINYINT` | NOT NULL, CHECK | Điểm từ 1 đến 5 |
| `comment` | `NVARCHAR(2000)` | NULL | Nội dung đánh giá |
| `reply_text` | `NVARCHAR(2000)` | NULL | Phản hồi |
| `status` | `VARCHAR(20)` | NOT NULL, DEFAULT, CHECK | Trạng thái đánh giá |
| `created_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm tạo |

`rating` phải từ 1 đến 5. Mỗi đánh giá chỉ được gắn với một trong hai đối tượng: đơn hàng Lab hoặc giao dịch Marketplace. Cần bổ sung `CHECK` bảo đảm **chính xác một trong hai cột `order_id` và `txn_id` có giá trị**; đồng thời kiểm tra `review_type` phù hợp với đối tượng được đánh giá.

#### Bảng `Post_Article` – Bài viết cộng đồng

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `post_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã bài viết |
| `author_id` | `INT` | FK → `Users.user_id`, NOT NULL | Tác giả |
| `post_category_id` | `INT` | FK → `Post_Category.post_category_id`, NULL | Danh mục bài |
| `post_type` | `VARCHAR(20)` | NOT NULL, CHECK | Loại bài viết |
| `title` | `NVARCHAR(250)` | NOT NULL | Tiêu đề |
| `slug` | `VARCHAR(250)` | NOT NULL, UNIQUE | Định danh URL |
| `summary` | `NVARCHAR(500)` | NULL | Tóm tắt |
| `content` | `NVARCHAR(MAX)` | NOT NULL | Nội dung |
| `cover_image_url` | `VARCHAR(500)` | NULL | Ảnh bìa |
| `status` | `VARCHAR(20)` | NOT NULL, CHECK | Trạng thái bài |
| `view_count` | `INT` | NOT NULL, DEFAULT, CHECK | Lượt xem |
| `published_at` | `DATETIME2(0)` | NULL | Thời điểm xuất bản |

`post_type` gồm `ARTICLE`, `TUTORIAL`, `REVIEW`, `QNA`. `status` gồm `DRAFT`, `PUBLISHED`, `HIDDEN`, `REMOVED`. `view_count` không được âm.

#### Bảng `Dispute_Complaint` – Khiếu nại

| Cột | Kiểu dữ liệu | Ràng buộc | Mô tả |
|---|---|---|---|
| `dispute_id` | `BIGINT IDENTITY(1,1)` | PK, NOT NULL | Mã khiếu nại |
| `dispute_code` | `VARCHAR(50)` | NOT NULL, UNIQUE | Mã khiếu nại |
| `order_id` | `BIGINT` | FK → `Orders.order_id`, NOT NULL | Đơn hàng liên quan |
| `complainant_id` | `INT` | FK → `Users.user_id`, NOT NULL | Người gửi khiếu nại |
| `reason_type` | `VARCHAR(30)` | NOT NULL, CHECK | Loại lý do |
| `description` | `NVARCHAR(2000)` | NOT NULL | Nội dung khiếu nại |
| `requested_amount` | `DECIMAL(15,2)` | NOT NULL, CHECK | Số tiền yêu cầu |
| `status` | `VARCHAR(30)` | NOT NULL, CHECK | Trạng thái xử lý |
| `negotiation_deadline` | `DATETIME2(0)` | NULL | Hạn thương lượng |
| `assigned_admin_id` | `INT` | FK → `Users.user_id`, NULL | Quản trị viên phụ trách |
| `approved_refund_amount` | `DECIMAL(15,2)` | NULL, CHECK | Số tiền hoàn được duyệt |
| `decision_note` | `NVARCHAR(2000)` | NULL | Ghi chú quyết định |
| `created_at` | `DATETIME2(0)` | NOT NULL, DEFAULT | Thời điểm tạo |
| `resolved_at` | `DATETIME2(0)` | NULL | Thời điểm giải quyết |

`requested_amount` và `approved_refund_amount`, nếu có, không được âm. `reason_type` và `status` cần được giới hạn bằng `CHECK` theo danh mục trạng thái của dự án.

### 2.4. Các bảng trung gian phục vụ quan hệ N–N

Quan hệ N–N được tách thành bảng trung gian để có thể biểu diễn bằng khóa ngoại và bảo đảm tính toàn vẹn tham chiếu.

| Bảng trung gian | Khóa chính | Khóa ngoại | Mục đích |
|---|---|---|---|
| `User_Roles` | (`user_id`, `role_id`) | `Users.user_id`, `Roles.role_id` | Một người dùng có nhiều vai trò và một vai trò có nhiều người dùng |
| `Lab_Film_Format` | (`lab_id`, `format_id`) | `Lab_Profile.lab_id`, `Film_Format.format_id` | Các định dạng phim mà mỗi Lab hỗ trợ |
| `Photo_Tag` | (`photo_id`, `tag_id`) | `Archive_Photo.photo_id`, `Tag.tag_id` | Gắn nhiều thẻ cho một ảnh |
| `Listing_Favorite` | (`user_id`, `listing_id`) | `Users.user_id`, `Equipment_Listing.listing_id` | Lưu tin đăng yêu thích |
| `Post_Tag` | (`post_id`, `tag_id`) | `Post_Article.post_id`, `Tag.tag_id` | Gắn nhiều thẻ cho một bài viết |
| `Event_Registration` | Theo thiết kế bảng | `Event.event_id`, `Users.user_id` | Đăng ký tham gia sự kiện |

Với các bảng trung gian, khóa chính ghép ngăn một cặp đối tượng xuất hiện trùng lặp. Ví dụ, cùng một người dùng không thể yêu thích cùng một tin đăng nhiều lần nếu cặp (`user_id`, `listing_id`) là PK.

---

## 3. Ràng buộc toàn vẹn dữ liệu

Các ràng buộc được áp dụng để bảo đảm dữ liệu hợp lệ trong SQL Server.

### 3.1. Khóa chính và khóa ngoại

- Mỗi bảng phải có khóa chính để định danh duy nhất bản ghi.
- Khóa ngoại phải tham chiếu đến khóa chính hoặc cột có ràng buộc `UNIQUE` ở bảng đích.
- Không cho phép tạo `Order_Item` tham chiếu đến đơn hàng không tồn tại.
- Không cho phép tạo `Photo_Metadata` cho ảnh không tồn tại.
- Không xóa dây chuyền những dữ liệu lịch sử quan trọng như đơn hàng, thanh toán, hoàn tiền và khiếu nại nếu việc đó làm mất dấu vết nghiệp vụ.

### 3.2. UNIQUE và CHECK

Một số ràng buộc quan trọng:

- `Users.email`: duy nhất.
- `Lab_Profile.slug`: duy nhất.
- `Orders.order_code`: duy nhất.
- `Digital_Film_Archive.order_item_id`: duy nhất khi có giá trị.
- `Archive_Photo.storage_key`: duy nhất.
- `Review.rating`: từ 1 đến 5.
- `Lab_Profile.avg_rating`: từ 0 đến 5.
- Các trường tiền tệ như `price`, `total_amount`, `requested_amount`: không âm.
- `Users.status`, `Orders.status`, `Equipment_Listing.status`: chỉ nhận các giá trị được quy định trong nghiệp vụ.

### 3.3. Ví dụ ràng buộc SQL Server

```sql
-- Ví dụ CHECK cho giá dịch vụ
ALTER TABLE Service_Package
ADD CONSTRAINT CK_Service_Package_Price
CHECK (price >= 0);

-- Ví dụ CHECK cho điểm đánh giá
ALTER TABLE Review
ADD CONSTRAINT CK_Review_Rating
CHECK (rating BETWEEN 1 AND 5);

-- Ví dụ CHECK cho số lượng hạng mục đơn hàng
ALTER TABLE Order_Item
ADD CONSTRAINT CK_Order_Item_Quantity
CHECK (quantity > 0);

-- Ví dụ CHECK cho giá trị tọa độ của Lab
ALTER TABLE Lab_Profile
ADD CONSTRAINT CK_Lab_Latitude
CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90);

ALTER TABLE Lab_Profile
ADD CONSTRAINT CK_Lab_Longitude
CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);
```

> **Lưu ý:** Các câu lệnh trên là ví dụ minh họa cho ràng buộc. Trước khi chạy, cần kiểm tra bảng và tên constraint đã tồn tại hay chưa, sau đó tích hợp vào script tạo bảng hoặc migration của dự án để tránh tạo trùng.

---

## 4. Chuẩn hóa dữ liệu (3NF)

### 4.1. Mục đích

Chuẩn hóa dữ liệu giúp giảm dư thừa, hạn chế lỗi cập nhật và bảo đảm mỗi nhóm thông tin được lưu ở vị trí phù hợp. Thiết kế MiniLab hướng đến chuẩn 3NF (Third Normal Form).

### 4.2. Chuẩn 1NF – First Normal Form

Một bảng đạt 1NF khi mỗi ô chứa một giá trị đơn, không lưu danh sách nhiều giá trị trong cùng một trường và mỗi bản ghi được định danh duy nhất.

Ví dụ:

- Vai trò người dùng không được lưu thành chuỗi `"CUSTOMER,EXPERT,ADMIN"` trong một cột của `Users`.
- Thay vào đó, lưu các vai trò trong `Roles` và mối quan hệ trong `User_Roles`.
- Danh sách ảnh của một kho không được gộp thành một chuỗi duy nhất; mỗi ảnh được lưu thành một bản ghi trong `Archive_Photo`.

### 4.3. Chuẩn 2NF – Second Normal Form

Một bảng đạt 2NF khi đạt 1NF và mọi thuộc tính không khóa phụ thuộc đầy đủ vào toàn bộ khóa chính, không chỉ phụ thuộc vào một phần khóa ghép.

Ví dụ:

- `User_Roles` có khóa chính ghép (`user_id`, `role_id`).
- `assigned_at` ghi nhận thời điểm gán của chính cặp người dùng–vai trò.
- Thông tin tên người dùng được lưu trong `Users`; tên vai trò được lưu trong `Roles`, không lặp lại trong `User_Roles`.

Tương tự, `Photo_Tag` sử dụng khóa ghép (`photo_id`, `tag_id`) để xác định duy nhất quan hệ giữa ảnh và thẻ.

### 4.4. Chuẩn 3NF – Third Normal Form

Một bảng đạt 3NF khi đạt 2NF và các thuộc tính không khóa không phụ thuộc bắc cầu vào khóa chính thông qua một thuộc tính không khóa khác.

Ví dụ:

- Thông tin Lab như tên, địa chỉ và trạng thái duyệt được lưu trong `Lab_Profile`, không lặp lại trong mọi bản ghi `Service_Package`.
- Thông tin gói dịch vụ được lưu trong `Service_Package`; `Order_Item` chỉ tham chiếu `package_id` và lưu lại `unit_price` tại thời điểm đặt hàng để giữ lịch sử giá.
- Thông tin kỹ thuật của ảnh được lưu trong `Photo_Metadata`, liên kết bằng `photo_id`.
- Tên danh mục thiết bị được lưu trong `Equipment_Category`, còn `Equipment_Listing` lưu `category_id`.
- Vai trò được tách thành `Roles` và `User_Roles`, tránh lặp thông tin vai trò trong bảng người dùng.

### 4.5. Lưu ý về dữ liệu tính toán

Một số trường như `Lab_Profile.avg_rating`, `Lab_Profile.review_count` hoặc `Orders.total_amount` có thể là dữ liệu tổng hợp hoặc dữ liệu tính toán. Nếu lưu vật lý để tăng hiệu năng, chúng cần được cập nhật bằng transaction, trigger hoặc quy trình đồng bộ phù hợp để tránh sai lệch với dữ liệu nguồn.

Ví dụ, điểm trung bình của Lab phải nhất quán với các đánh giá hợp lệ. Việc lưu giá trị tổng hợp là quyết định tối ưu hóa có chủ đích; không được để dữ liệu tổng hợp trở thành nguồn thông tin mâu thuẫn với dữ liệu gốc.

---

## 5. Kết luận

Thiết kế cơ sở dữ liệu MiniLab gồm hai lớp chính:

1. **Conceptual ERD:** xác định các thực thể nghiệp vụ, thuộc tính tiêu biểu và quan hệ 1–1, 1–N, N–N.
2. **Physical Relational Schema / Physical ERD:** triển khai các thực thể thành bảng SQL Server với PK, FK, kiểu dữ liệu, ràng buộc toàn vẹn và bảng trung gian.

Thiết kế sử dụng khóa ngoại để bảo đảm tính toàn vẹn tham chiếu, `UNIQUE` để ngăn dữ liệu trùng lặp, `CHECK` để kiểm tra điều kiện nghiệp vụ và chuẩn hóa 3NF để giảm dư thừa dữ liệu. Các bảng hỗ trợ được bổ sung theo nhu cầu thực tế nhằm bảo đảm các mối quan hệ và nghiệp vụ của hệ thống có thể triển khai đầy đủ.
