USE FilmLabPlatform;
GO
CREATE OR ALTER PROCEDURE dbo.sp_RegisterEvent
    @event_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @capacity SMALLINT, @status VARCHAR(20), @active_count INT, @registration_id BIGINT;
    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @capacity = capacity, @status = status
        FROM dbo.Event WITH (UPDLOCK, HOLDLOCK) WHERE event_id = @event_id;
        IF @status IS NULL THROW 51101, 'Event not found.', 1;
        IF @status <> 'OPEN' THROW 51102, 'Event is not open.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE user_id = @user_id AND status = 'ACTIVE')
            THROW 51103, 'Active user not found.', 1;
        SELECT TOP (1) @registration_id = registration_id
        FROM dbo.Event_Registration WITH (UPDLOCK, HOLDLOCK)
        WHERE event_id = @event_id AND user_id = @user_id AND status IN ('REGISTERED','ATTENDED');
        IF @registration_id IS NOT NULL THROW 51104, 'User already registered.', 1;
        SELECT @active_count = COUNT(*) FROM dbo.Event_Registration
        WHERE event_id = @event_id AND status IN ('REGISTERED','ATTENDED');
        IF @capacity IS NOT NULL AND @active_count >= @capacity THROW 51105, 'Event is full.', 1;
        -- Reuse a cancelled registration if present; otherwise create a new one.
        SET @registration_id = NULL;
        SELECT TOP (1) @registration_id = registration_id
        FROM dbo.Event_Registration WITH (UPDLOCK, HOLDLOCK)
        WHERE event_id = @event_id AND user_id = @user_id AND status = 'CANCELLED'
        ORDER BY registration_id DESC;
        IF @registration_id IS NULL
        BEGIN
            INSERT INTO dbo.Event_Registration(event_id, user_id, status)
            VALUES (@event_id, @user_id, 'REGISTERED');
            SET @registration_id = SCOPE_IDENTITY();
        END
        ELSE
            UPDATE dbo.Event_Registration SET status = 'REGISTERED', registered_at = SYSUTCDATETIME()
            WHERE registration_id = @registration_id;
        COMMIT TRANSACTION;
        SELECT registration_id, event_id, user_id, status
        FROM dbo.Event_Registration WHERE registration_id = @registration_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
