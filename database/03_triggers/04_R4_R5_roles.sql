USE FilmLabPlatform_Test;
GO
-- R4: Chi ADMIN duoc dien cac truong duyet / phan cong.
CREATE OR ALTER TRIGGER dbo.trg_R4_LabReviewer ON dbo.Lab_Profile AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.reviewed_by IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM dbo.User_Roles ur JOIN dbo.Roles r ON r.role_id=ur.role_id
 WHERE ur.user_id=i.reviewed_by AND r.role_code='ADMIN'))
 THROW 51004,'R4: reviewed_by phai co vai tro ADMIN.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.trg_R4_ListingReviewer ON dbo.Equipment_Listing AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.reviewed_by IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM dbo.User_Roles ur JOIN dbo.Roles r ON r.role_id=ur.role_id
 WHERE ur.user_id=i.reviewed_by AND r.role_code='ADMIN'))
 THROW 51004,'R4: reviewed_by phai co vai tro ADMIN.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.trg_R4_ReviewModerator ON dbo.Review AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.moderated_by IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM dbo.User_Roles ur JOIN dbo.Roles r ON r.role_id=ur.role_id
 WHERE ur.user_id=i.moderated_by AND r.role_code='ADMIN'))
 THROW 51004,'R4: moderated_by phai co vai tro ADMIN.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.trg_R4_DisputeAdmin ON dbo.Dispute_Complaint AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i WHERE i.assigned_admin_id IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM dbo.User_Roles ur JOIN dbo.Roles r ON r.role_id=ur.role_id
 WHERE ur.user_id=i.assigned_admin_id AND r.role_code='ADMIN'))
 THROW 51004,'R4: assigned_admin_id phai co vai tro ADMIN.',1;
END;
GO
-- R5: Owner/host phai co vai tro phu hop.
CREATE OR ALTER TRIGGER dbo.trg_R5_LabOwner ON dbo.Lab_Profile AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i WHERE NOT EXISTS(
 SELECT 1 FROM dbo.User_Roles ur JOIN dbo.Roles r ON r.role_id=ur.role_id
 WHERE ur.user_id=i.owner_id AND r.role_code='LAB_OWNER'))
 THROW 51005,'R5: owner_id phai co vai tro LAB_OWNER.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.trg_R5_EventHost ON dbo.Event AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i WHERE NOT EXISTS(
 SELECT 1 FROM dbo.User_Roles ur JOIN dbo.Roles r ON r.role_id=ur.role_id
 WHERE ur.user_id=i.host_id AND r.role_code='EXPERT'))
 THROW 51005,'R5: host_id phai co vai tro EXPERT.',1;
END;
GO
