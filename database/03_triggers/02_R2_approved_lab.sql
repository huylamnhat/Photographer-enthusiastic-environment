USE FilmLabPlatform_Test;
GO
-- R2: Chan don hang moi/doi Lab sang Lab chua duoc duyet.
CREATE OR ALTER TRIGGER dbo.trg_R2_ApprovedLabOrder
ON dbo.Orders
AFTER INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS (
   SELECT 1 FROM inserted i
   JOIN dbo.Lab_Profile l ON l.lab_id=i.lab_id
   LEFT JOIN deleted d ON d.order_id=i.order_id
   WHERE (d.order_id IS NULL OR i.lab_id<>d.lab_id)
     AND l.approval_status<>'APPROVED'
 )
 THROW 51002, 'R2: Chi Lab APPROVED moi duoc nhan don moi.', 1;
END;
GO
CREATE OR ALTER VIEW dbo.vw_ActiveLabs
AS SELECT * FROM dbo.Lab_Profile WHERE approval_status='APPROVED';
GO
