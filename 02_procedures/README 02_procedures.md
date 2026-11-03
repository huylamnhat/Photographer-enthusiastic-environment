# 02_procedures – FilmLabPlatform

Các stored procedure xây dựng từ tài liệu thiết kế CSDL Week 2. Tài liệu gốc mô tả quy tắc nghiệp vụ, không quy định tên hay số lượng stored procedure; đây là phần hiện thực đề xuất.

1. `01_order_status.sql`: Chuyển trạng thái đơn hàng theo sơ đồ 9.1 và ghi `Order_Status_History` cùng transaction. Chỉ kiểm tra trạng thái và phương thức nhận/trả, chưa thay thế xác thực vai trò ở backend hay xác nhận thanh toán/giao nhận.
2. `02_event_registration.sql`: Đăng ký sự kiện, khóa dòng Event bằng UPDLOCK/HOLDLOCK để kiểm soát sức chứa R7. Chỉ cho user ACTIVE đăng ký sự kiện OPEN.
3. `03_approved_labs.sql`: Danh sách Lab APPROVED theo R2, cập nhật procedure minh họa đã tạo trước đó.

## Thứ tự chạy
Chọn database `FilmLabPlatform`, chạy lần lượt ba file bằng SSMS (F5). Không chạy lại script tạo bảng hay seed. Các file dùng CREATE OR ALTER.

## Kiểm tra không thay đổi dữ liệu
```sql
USE FilmLabPlatform;
GO
SELECT name FROM sys.procedures WHERE name IN
('sp_ChangeOrderStatus','sp_RegisterEvent','sp_GetApprovedLabs');
EXEC dbo.sp_GetApprovedLabs;
```

Hai procedure ghi dữ liệu chỉ được chạy thử với ID hợp lệ trên database thử nghiệm. Trước khi dùng trong sản phẩm cần kiểm thử giao dịch đồng thời, phân quyền và các điều kiện nghiệp vụ do backend quản lý.
