USE FilmLabPlatform_Test;
GO

-- 1. Hàm sinh mã lô mẻ tráng chuẩn hóa từ tham số truyền vào
CREATE OR ALTER FUNCTION dbo.fn_BuildLabBatchCode (
    @process_code VARCHAR(15),
    @batch_date   DATE,
    @shift_no     INT
)
RETURNS VARCHAR(40)
AS
BEGIN
    DECLARE @clean_proc VARCHAR(15) = UPPER(ISNULL(NULLIF(LTRIM(RTRIM(@process_code)), ''), 'C41'));
    SET @clean_proc = REPLACE(@clean_proc, '-', '');

    DECLARE @safe_date DATE = ISNULL(@batch_date, CAST(SYSUTCDATETIME() AS DATE));
    DECLARE @safe_shift INT = CASE WHEN ISNULL(@shift_no, 1) < 1 THEN 1 ELSE @shift_no END;

    RETURN CONCAT(
        'BATCH-',
        @clean_proc,
        '-',
        CONVERT(CHAR(8), @safe_date, 112),
        '-S',
        RIGHT('00' + CAST(@safe_shift AS VARCHAR(5)), 2)
    );
END;
GO

-- 2. Hàm tính tiền quyết toán cho Film Lab sau khi trừ phí vận chuyển & phí nền tảng
CREATE OR ALTER FUNCTION dbo.fn_CalculateNetLabPayout (
    @gross_amount    DECIMAL(18, 2),
    @shipping_fee    DECIMAL(18, 2),
    @commission_rate DECIMAL(5, 4)
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @gross DECIMAL(18, 2) = CASE WHEN ISNULL(@gross_amount, 0) < 0 THEN 0 ELSE @gross_amount END;
    DECLARE @ship  DECIMAL(18, 2) = CASE WHEN ISNULL(@shipping_fee, 0) < 0 THEN 0 ELSE @shipping_fee END;
    DECLARE @rate  DECIMAL(5, 4)  = CASE
        WHEN ISNULL(@commission_rate, 0) < 0 THEN 0
        WHEN @commission_rate > 1 THEN 1
        ELSE @commission_rate
    END;

    DECLARE @service_base DECIMAL(18, 2) = CASE WHEN @gross > @ship THEN @gross - @ship ELSE 0 END;
    DECLARE @platform_fee DECIMAL(18, 2) = ROUND(@service_base * @rate, 0);

    RETURN CASE WHEN @service_base > @platform_fee THEN @service_base - @platform_fee ELSE 0 END;
END;
GO

-- 3. Hàm ước tính tổng số phút xử lý buồng tối theo quy trình tráng phim
CREATE OR ALTER FUNCTION dbo.fn_EstimateDarkroomMinutes (
    @process_code VARCHAR(20),
    @roll_count   INT,
    @is_push_pull BIT
)
RETURNS INT
AS
BEGIN
    DECLARE @rolls INT = CASE WHEN ISNULL(@roll_count, 0) <= 0 THEN 1 ELSE @roll_count END;
    DECLARE @proc  VARCHAR(20) = UPPER(ISNULL(@process_code, 'C-41'));

    DECLARE @minutes_per_roll INT = CASE
        WHEN @proc IN ('ECN-2', 'ECN2') THEN 22
        WHEN @proc IN ('BW', 'B&W')     THEN 28
        ELSE 15
    END;

    DECLARE @extra_minutes INT = CASE WHEN ISNULL(@is_push_pull, 0) = 1 THEN 8 * @rolls ELSE 0 END;
    RETURN (@rolls * @minutes_per_roll) + @extra_minutes;
END;
GO
