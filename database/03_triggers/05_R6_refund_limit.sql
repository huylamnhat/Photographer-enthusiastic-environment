USE FilmLabPlatform_Test;
GO
CREATE OR ALTER TRIGGER dbo.trg_R6_RefundLimit
ON dbo.Refund AFTER INSERT,UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(
   SELECT 1
   FROM dbo.Refund r
   JOIN dbo.Payment p ON p.payment_id=r.payment_id
   WHERE r.payment_id IN (SELECT payment_id FROM inserted)
     AND r.status NOT IN ('REJECTED','FAILED')
   GROUP BY r.payment_id,p.amount
   HAVING SUM(r.amount)>p.amount
 )
 THROW 51006,'R6: Tong tien hoan khong duoc vuot tien thanh toan.',1;
END;
GO
