USE FilmLabPlatform_Test;
GO

-- 1. Hàm tách chuỗi thẻ phim (VD: N'Kodak Portra 400;Fujifilm C200;35mm') thành bảng trên RAM
CREATE OR ALTER FUNCTION dbo.fn_SplitFilmTags (
    @raw_tags  NVARCHAR(1000),
    @delimiter NCHAR(1) = N';'
)
RETURNS @parsed_tags TABLE (
    seq_no    INT IDENTITY(1, 1) PRIMARY KEY,
    tag_value NVARCHAR(100) NOT NULL
)
AS
BEGIN
    IF @raw_tags IS NULL OR LTRIM(RTRIM(@raw_tags)) = N''
        RETURN;

    DECLARE @sep NCHAR(1) = ISNULL(@delimiter, N';');
    DECLARE @working NVARCHAR(1002) = @raw_tags + @sep;
    DECLARE @pos INT = CHARINDEX(@sep, @working);
    DECLARE @piece NVARCHAR(100);

    WHILE @pos > 0
    BEGIN
        SET @piece = LTRIM(RTRIM(LEFT(@working, @pos - 1)));
        IF @piece <> N'' AND NOT EXISTS (
            SELECT 1 FROM @parsed_tags WHERE LOWER(tag_value) = LOWER(@piece)
        )
        BEGIN
            INSERT INTO @parsed_tags (tag_value) VALUES (@piece);
        END;

        SET @working = SUBSTRING(@working, @pos + 1, LEN(@working));
        SET @pos = CHARINDEX(@sep, @working);
    END;

    RETURN;
END;
GO

-- 2. Hàm sinh khung lịch ca tráng phim tiêu chuẩn theo khoảng ngày vào biến bảng @slots
CREATE OR ALTER FUNCTION dbo.fn_GenerateLabShiftCalendar (
    @start_date          DATE,
    @days_count          INT,
    @max_rolls_per_shift INT
)
RETURNS @slots TABLE (
    work_date       DATE         NOT NULL,
    shift_code      VARCHAR(15)  NOT NULL,
    shift_window    NVARCHAR(40) NOT NULL,
    capacity_rolls  INT          NOT NULL
)
AS
BEGIN
    DECLARE @base_date DATE = ISNULL(@start_date, CAST(SYSUTCDATETIME() AS DATE));
    DECLARE @total_days INT = CASE
        WHEN ISNULL(@days_count, 7) < 1 THEN 1
        WHEN @days_count > 31 THEN 31
        ELSE @days_count
    END;
    DECLARE @cap INT = CASE WHEN ISNULL(@max_rolls_per_shift, 25) < 1 THEN 25 ELSE @max_rolls_per_shift END;

    DECLARE @idx INT = 0;
    WHILE @idx < @total_days
    BEGIN
        DECLARE @curr_date DATE = DATEADD(DAY, @idx, @base_date);

        INSERT INTO @slots (work_date, shift_code, shift_window, capacity_rolls)
        VALUES
            (@curr_date, 'MORNING',   N'08:30 - 12:00 (Tráng C-41)', @cap),
            (@curr_date, 'AFTERNOON', N'13:30 - 17:30 (Tráng ECN-2 / B&W & Scan)', @cap);

        SET @idx += 1;
    END;

    RETURN;
END;
GO
