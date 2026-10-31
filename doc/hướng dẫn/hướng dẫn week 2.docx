

ĐỌC FILE TỔNG HỢP YÊU CÂU HỆ THỐNG TRONG TỆP WEEK 1 VÀ LÀM THEO ISSUE CHỌN




Nhóm 1: Sơ đồ thiết kế Cơ sở dữ liệu 
Sơ đồ ERD quan niệm (Conceptual ERD):

Mục đích: Xác định các thực thể chính, thuộc tính và mối quan hệ (1-1, 1-N, N-N).
Các thực thể chính: User (Khách hàng, Lab, Expert, Shipper, Admin), Lab_Profile, Service_Package, Order, Order_Item, Digital_Film_Archive, Photo_Metadata, Equipment_Listing (Marketplace), Review, Post_Article, Dispute_Complaint.
Lược đồ quan hệ / Sơ đồ ERD vật lý (Physical Relational Schema / Relational Model):

Mục đích: Đặc tả chi tiết từng bảng trong SQL Server gồm: Khóa chính (PK), khóa ngoại (FK), kiểu dữ liệu (VARCHAR, INT, DATETIME, DECIMAL), ràng buộc toàn vẹn (NOT NULL, CHECK, UNIQUE) và chuẩn hóa dữ liệu (3NF).





Nhóm 2: Sơ đồ chức năng & Nghiệp vụ (Phân tích hệ thống)
Sơ đồ Use Case tổng quát (Overall Use Case Diagram):

Mục đích: Thể hiện toàn bộ hệ thống với 5 Actor:
Customer (Tìm kiếm Lab, Đặt đơn, Thanh toán, Quản lý Archive, Đăng tin bán máy, Review).
Film Lab Owner (Cấu hình dịch vụ & giá, Tiếp nhận đơn, Cập nhật công đoạn, Upload file scan, Báo cáo).
Photography Expert (Đăng bài chia sẻ, Tạo Workshop/Photowalk).
Delivery Partner (Nhận đơn pickup, Giao nhận film 2 chiều, Cập nhật trạng thái giao vận).
System Administrator (Duyệt Lab/Đối tác, Tiền kiểm tin Marketplace, Hậu kiểm bài viết, Xử lý khiếu nại, Khóa tài khoản).
Sơ đồ phân rã Use Case (Detailed Use Case Diagrams):

Phân hệ Đặt & Xử lý dịch vụ tráng/scan.
Phân hệ Marketplace & Quản lý thiết bị.
Phân hệ Quản trị hệ thống & Kiểm duyệt.
Sơ đồ hoạt động (Activity Diagram):

Quy trình đơn hàng tráng/scan (Swimlane Diagram - 4 làn): Khách hàng -> Cổng thanh toán -> Đối tác vận chuyển -> Film Lab.
Quy trình khiếu nại & hoàn tiền: Khách gửi khiếu nại -> Hai bên tự thương lượng -> Admin phân xử & phê duyệt hoàn tiền.








Nhóm 3: Sơ đồ trạng thái & Tương tác động
Sơ đồ máy trạng thái đơn hàng (State Machine Diagram for Order):

Mục đích: Thể hiện vòng tuần hoàn chuyển giao trạng thái đơn hàng:
Chờ thanh toán $\rightarrow$ Chờ Lab xác nhận $\rightarrow$ [Đang lấy film] $\rightarrow$ Đã nhận film tại Lab $\rightarrow$ Đang xử lý (Tráng & Scan) $\rightarrow$ Hoàn thành (Đã trả file scan) $\rightarrow$ [Đang giao hàng] $\rightarrow$ Đã nhận / Đóng đơn (hoặc Đã hủy).
(Tùy chọn) Trạng thái tin đăng Marketplace: Chờ duyệt (Pending Approval) $\rightarrow$ Đang hiển thị (Active) / Từ chối (Rejected).
Sơ đồ tuần tự (Sequence Diagram) — 3 kịch bản quan trọng nhất:

Kịch bản 1: Đặt dịch vụ & Thanh toán trực tuyến: Customer $\rightarrow$ Frontend (App) $\rightarrow$ Backend API $\rightarrow$ Payment Gateway $\rightarrow$ Database.
Kịch bản 2: Lab hoàn thành scan và trả kết quả vào Archive: Lab Owner $\rightarrow$ Web Portal $\rightarrow$ Backend $\rightarrow$ Cloud Storage $\rightarrow$ Digital Archive DB $\rightarrow$ Push Notification $\rightarrow$ Customer App.
Kịch bản 3: Xử lý khiếu nại & Hoàn tiền: Customer $\rightarrow$ Film Lab $\rightarrow$ Admin $\rightarrow$ Payment API.











Nhóm 4: Sơ đồ kiến trúc & Triển khai
Sơ đồ kiến trúc hệ thống (System Architecture Diagram):
Phân tầng:
Client Layer: Flutter Mobile App (Khách hàng) & Flutter Web (Film Lab, Admin).
API / Backend Layer: Node.js (Express), xác thực JWT, định tuyến RBAC.
Data & Storage Layer: Database SQL Server và Cloud Storage (lưu ảnh scan gốc).
External Services: Cổng thanh toán (VNPay/Momo), Đơn vị vận chuyển (Ahamove/Lalamove).