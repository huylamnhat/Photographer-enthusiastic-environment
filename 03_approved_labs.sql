USE FilmLabPlatform;
GO
CREATE OR ALTER PROCEDURE dbo.sp_GetApprovedLabs
AS
BEGIN
    SET NOCOUNT ON;
    SELECT lab_id, owner_id, lab_name, slug, province, district, avg_rating, review_count
    FROM dbo.Lab_Profile
    WHERE approval_status = 'APPROVED';
END;
GO
