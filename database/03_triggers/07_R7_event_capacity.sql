USE FilmLabPlatform_Test;
GO
-- Phong ve bo sung cho R7; backend van can transaction + UPDLOCK.
CREATE OR ALTER TRIGGER dbo.trg_R7_EventCapacity
ON dbo.Event_Registration AFTER INSERT,UPDATE
AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(
   SELECT 1 FROM dbo.Event e WITH (UPDLOCK, HOLDLOCK)
   JOIN (SELECT event_id FROM inserted UNION SELECT event_id FROM deleted) a
     ON a.event_id=e.event_id
   CROSS APPLY (
     SELECT COUNT_BIG(*) AS n FROM dbo.Event_Registration er
     WHERE er.event_id=e.event_id AND er.status IN ('REGISTERED','ATTENDED')
   ) c
   WHERE c.n>e.capacity
 )
 THROW 51007,'R7: So dang ky vuot suc chua su kien.',1;
END;
GO
