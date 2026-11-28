USE FilmLabPlatform_Test;
GO

-- Thủ tục sinh bảng kế hoạch sao lưu 7 ngày (FULL / DIFFERENTIAL) trên biến RAM,
-- không ghi file ra đĩa và không truy xuất bất kỳ bảng dữ liệu nào.
CREATE OR ALTER PROCEDURE dbo.sp_PreviewBackupSchedule
    @database_name NVARCHAR(128) = N'FilmLabPlatform_Test',
    @backup_folder NVARCHAR(260) = N'D:\SQLBackups\MiniLab',
    @start_date    DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @base_date DATE = ISNULL(@start_date, CAST(SYSUTCDATETIME() AS DATE));
    DECLARE @clean_folder NVARCHAR(260) = LTRIM(RTRIM(ISNULL(@backup_folder, N'D:\SQLBackups\MiniLab')));

    DECLARE @plan TABLE (
        day_offset        INT           NOT NULL PRIMARY KEY,
        scheduled_date    DATE          NOT NULL,
        backup_type       VARCHAR(20)   NOT NULL,
        retention_days    INT           NOT NULL,

