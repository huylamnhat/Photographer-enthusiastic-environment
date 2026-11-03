USE FilmLabPlatform_Test;
GO
CREATE OR ALTER TRIGGER dbo.trg_R1_OrderItemLab
ON dbo.Order_Item
AFTER INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS (
   SELECT 1 FROM inserted i
   JOIN dbo.Orders o ON o.order_id=i.order_id
   JOIN dbo.Service_Package p ON p.package_id=i.package_id
   WHERE o.lab_id<>p.lab_id
 )
 BEGIN
   THROW 51001, 'R1: Goi dich vu phai thuoc Lab cua don hang.', 1;
 END
END;
GO
