# FilmLabPlatform database — Issue #21

SQL table definitions, indexes and seed extracted from Week 2 document. Procedures and triggers are not yet implemented.

## Chạy
1. Mở SSMS và kết nối SQL Server.
2. Mở `database/run_all.sql`, bật Query > SQLCMD Mode, kiểm tra working directory của các đường dẫn `:r`.
3. Hoặc chạy từng file theo thứ tự trong `run_all.sql` (đảm bảo đang dùng database FilmLabPlatform).
4. Kiểm tra: `USE FilmLabPlatform; SELECT COUNT(*) AS table_count FROM sys.tables;`

**Lưu ý:** Đây là bản chia file theo tài liệu, chưa kiểm thử thực thi trên SQL Server. Một số FK/CASCADE hoặc thứ tự bảng có thể cần điều chỉnh sau khi chạy thử. Không chạy lại các file CREATE TABLE trên DB đã có bảng.
