USE FilmLabPlatform_Test;
GO
-- R9/R11: Chi review LAB o trang thai VISIBLE moi tinh diem.
CREATE OR ALTER TRIGGER dbo.trg_R9_R11_LabRating
ON dbo.Review AFTER INSERT,UPDATE,DELETE
AS
BEGIN
 SET NOCOUNT ON;
 ;WITH Affected AS (
   SELECT o.lab_id FROM inserted i JOIN dbo.Orders o ON o.order_id=i.order_id
   WHERE i.review_type='LAB'
   UNION
   SELECT o.lab_id FROM deleted d JOIN dbo.Orders o ON o.order_id=d.order_id
   WHERE d.review_type='LAB'
 ),
 Rating AS (
   SELECT o.lab_id, COUNT_BIG(*) AS cnt,
          CAST(AVG(CAST(r.rating AS DECIMAL(10,4))) AS DECIMAL(3,2)) AS avg_rating
   FROM dbo.Review r JOIN dbo.Orders o ON o.order_id=r.order_id
   WHERE r.review_type='LAB' AND r.status='VISIBLE'
     AND o.lab_id IN (SELECT lab_id FROM Affected)
   GROUP BY o.lab_id
 )
 UPDATE l SET l.review_count=COALESCE(CONVERT(INT,x.cnt),0),
              l.avg_rating=COALESCE(x.avg_rating,0)
 FROM dbo.Lab_Profile l JOIN Affected a ON a.lab_id=l.lab_id
 LEFT JOIN Rating x ON x.lab_id=l.lab_id;
END;
GO
