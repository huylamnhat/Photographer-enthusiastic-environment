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
        suggested_file    NVARCHAR(400) NOT NULL
    );

    DECLARE @i INT = 0;
    WHILE @i < 7
    BEGIN
        DECLARE @d DATE = DATEADD(DAY, @i, @base_date);
        -- Chủ nhật chạy FULL Backup, các ngày còn lại chạy DIFFERENTIAL Backup
        DECLARE @is_sunday BIT = CASE WHEN DATEDIFF(DAY, '19000107', @d) % 7 = 0 THEN 1 ELSE 0 END;
        DECLARE @btype VARCHAR(20) = CASE WHEN @is_sunday = 1 THEN 'FULL' ELSE 'DIFFERENTIAL' END;
        DECLARE @ext VARCHAR(10) = CASE WHEN @is_sunday = 1 THEN 'FULL.bak' ELSE 'DIFF.bak' END;

        INSERT INTO @plan (day_offset, scheduled_date, backup_type, retention_days, suggested_file)
        VALUES (
            @i,
            @d,
            @btype,
            CASE WHEN @is_sunday = 1 THEN 30 ELSE 14 END,
            CONCAT(@clean_folder, N'\', @database_name, N'_', CONVERT(CHAR(8), @d, 112), N'_', @ext)
        );

        SET @i += 1;
    END;

    SELECT
        scheduled_date,
        backup_type,
        retention_days,
        suggested_file
    FROM @plan
    ORDER BY day_offset ASC;
END;
GO
