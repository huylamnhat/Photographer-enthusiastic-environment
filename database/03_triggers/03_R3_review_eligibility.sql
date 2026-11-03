USE FilmLabPlatform_Test;
GO
CREATE OR ALTER TRIGGER dbo.trg_R3_ReviewEligibility
ON dbo.Review
AFTER INSERT, UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS (
  SELECT 1 FROM inserted i
  LEFT JOIN dbo.Orders o ON o.order_id=i.order_id
  LEFT JOIN dbo.Marketplace_Transaction t ON t.txn_id=i.txn_id
  WHERE (i.review_type='LAB' AND
            (o.status<>'CLOSED' OR o.customer_id<>i.reviewer_id))
     OR (i.review_type='SELLER' AND
            (t.status<>'COMPLETED' OR t.buyer_id<>i.reviewer_id))
 )
 THROW 51003, 'R3: Nguoi danh gia phai la khach/mua hang da hoan tat.', 1;
END;
GO
