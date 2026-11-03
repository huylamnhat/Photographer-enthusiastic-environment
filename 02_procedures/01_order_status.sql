USE FilmLabPlatform;
GO
CREATE OR ALTER PROCEDURE dbo.sp_ChangeOrderStatus
    @order_id BIGINT,
    @new_status VARCHAR(25),
    @changed_by INT = NULL,
    @note NVARCHAR(500) = NULL,
    @cancel_reason NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @old_status VARCHAR(25), @receive_method VARCHAR(20), @return_method VARCHAR(20);
    BEGIN TRY
        BEGIN TRANSACTION;
        SELECT @old_status = status, @receive_method = receive_method, @return_method = return_method
        FROM dbo.Orders WITH (UPDLOCK, HOLDLOCK) WHERE order_id = @order_id;
        IF @old_status IS NULL THROW 51001, 'Order not found.', 1;
        IF @new_status IS NULL OR NOT (
            (@old_status = 'PENDING_PAYMENT' AND @new_status IN ('PENDING_LAB_CONFIRM','CANCELLED')) OR
            (@old_status = 'PENDING_LAB_CONFIRM' AND @new_status IN ('PICKING_UP','RECEIVED_AT_LAB','CANCELLED')) OR
            (@old_status = 'PICKING_UP' AND @new_status IN ('RECEIVED_AT_LAB','CANCELLED')) OR
            (@old_status = 'RECEIVED_AT_LAB' AND @new_status = 'PROCESSING') OR
            (@old_status = 'PROCESSING' AND @new_status = 'COMPLETED') OR
            (@old_status = 'COMPLETED' AND @new_status IN ('DELIVERING','CLOSED')) OR
            (@old_status = 'DELIVERING' AND @new_status = 'CLOSED')
        ) THROW 51002, 'Invalid order status transition.', 1;
        IF @new_status = 'PICKING_UP' AND @receive_method <> 'PICKUP'
            THROW 51003, 'Order does not use pickup.', 1;
        IF @new_status = 'DELIVERING' AND @return_method <> 'DELIVERY'
            THROW 51004, 'Order does not use delivery.', 1;
        IF @new_status = 'CANCELLED' AND (@changed_by IS NULL OR NULLIF(LTRIM(RTRIM(@cancel_reason)),N'') IS NULL)
            THROW 51005, 'Cancellation requires actor and reason.', 1;
        IF @changed_by IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Users WHERE user_id = @changed_by)
            THROW 51006, 'Actor not found.', 1;
        UPDATE dbo.Orders
        SET status = @new_status,
            updated_at = SYSUTCDATETIME(),
            confirmed_at = CASE WHEN @new_status = 'PENDING_LAB_CONFIRM' THEN SYSUTCDATETIME() ELSE confirmed_at END,
            completed_at = CASE WHEN @new_status = 'COMPLETED' THEN SYSUTCDATETIME() ELSE completed_at END,
            closed_at = CASE WHEN @new_status = 'CLOSED' THEN SYSUTCDATETIME() ELSE closed_at END,
            cancelled_by = CASE WHEN @new_status = 'CANCELLED' THEN @changed_by ELSE cancelled_by END,
            cancel_reason = CASE WHEN @new_status = 'CANCELLED' THEN @cancel_reason ELSE cancel_reason END
        WHERE order_id = @order_id;
        INSERT INTO dbo.Order_Status_History (order_id, from_status, to_status, changed_by, note)
        VALUES (@order_id, @old_status, @new_status, @changed_by, @note);
        COMMIT TRANSACTION;
        SELECT order_id, order_code, status, updated_at FROM dbo.Orders WHERE order_id = @order_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
