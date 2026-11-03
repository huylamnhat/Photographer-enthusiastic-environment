-- Issue #21 | SQL Server | Source: Week 2

-- 18. Dispute_Complaint (tạo trước Refund vì Refund tham chiếu)
CREATE TABLE Dispute_Complaint (
    dispute_id             BIGINT IDENTITY(1,1) NOT NULL,
    dispute_code           VARCHAR(20)   NOT NULL,
    order_id               BIGINT        NOT NULL,
    complainant_id         INT           NOT NULL,
    reason_type            VARCHAR(20)   NOT NULL,
    description            NVARCHAR(2000) NOT NULL,
    requested_amount       DECIMAL(15,2) NULL,
    status                 VARCHAR(20)   NOT NULL CONSTRAINT DF_Disp_Status DEFAULT 'OPEN',
    negotiation_deadline   DATETIME2(0)  NULL,
    assigned_admin_id      INT           NULL,
    approved_refund_amount DECIMAL(15,2) NULL,
    decision_note          NVARCHAR(1000) NULL,
    created_at             DATETIME2(0)  NOT NULL CONSTRAINT DF_Disp_Created DEFAULT SYSUTCDATETIME(),
    escalated_at           DATETIME2(0)  NULL,
    resolved_at            DATETIME2(0)  NULL,
    CONSTRAINT PK_Dispute_Complaint PRIMARY KEY (dispute_id),
    CONSTRAINT UQ_Dispute_Code UNIQUE (dispute_code),
    CONSTRAINT FK_Disp_Order FOREIGN KEY (order_id)          REFERENCES Orders(order_id),
    CONSTRAINT FK_Disp_User  FOREIGN KEY (complainant_id)    REFERENCES Users(user_id),
    CONSTRAINT FK_Disp_Admin FOREIGN KEY (assigned_admin_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Disp_Reason CHECK (reason_type IN
        ('QUALITY','LOST_FILM','DAMAGED_FILM','LATE','WRONG_SERVICE','OTHER')),
    CONSTRAINT CK_Disp_Status CHECK (status IN
        ('OPEN','NEGOTIATING','ESCALATED','RESOLVED_REFUNDED','RESOLVED_REJECTED','WITHDRAWN','CLOSED')),
    CONSTRAINT CK_Disp_Amount CHECK (requested_amount IS NULL OR requested_amount >= 0),
    CONSTRAINT CK_Disp_Approved CHECK (approved_refund_amount IS NULL OR approved_refund_amount >= 0),
    CONSTRAINT CK_Disp_Escalate CHECK (status <> 'ESCALATED' OR escalated_at IS NOT NULL)
);

-- 19. Refund
CREATE TABLE Refund (
    refund_id          BIGINT IDENTITY(1,1) NOT NULL,
    payment_id         BIGINT        NOT NULL,
    dispute_id         BIGINT        NULL,            -- NULL khi hoàn tiền do hủy đơn
    amount             DECIMAL(15,2) NOT NULL,
    reason             NVARCHAR(500) NULL,
    status             VARCHAR(15)   NOT NULL CONSTRAINT DF_Refund_Status DEFAULT 'PENDING',
    approved_by        INT           NULL,
    gateway_refund_ref VARCHAR(64)   NULL,
    created_at         DATETIME2(0)  NOT NULL CONSTRAINT DF_Refund_Created DEFAULT SYSUTCDATETIME(),
    processed_at       DATETIME2(0)  NULL,
    CONSTRAINT PK_Refund PRIMARY KEY (refund_id),
    CONSTRAINT FK_Refund_Payment FOREIGN KEY (payment_id)  REFERENCES Payment(payment_id),
    CONSTRAINT FK_Refund_Dispute FOREIGN KEY (dispute_id)  REFERENCES Dispute_Complaint(dispute_id),
    CONSTRAINT FK_Refund_Admin   FOREIGN KEY (approved_by) REFERENCES Users(user_id),
    CONSTRAINT CK_Refund_Amount  CHECK (amount > 0),
    CONSTRAINT CK_Refund_Status  CHECK (status IN ('PENDING','APPROVED','PROCESSING','COMPLETED','REJECTED','FAILED')),
    CONSTRAINT CK_Refund_Approve CHECK (status IN ('PENDING','REJECTED') OR approved_by IS NOT NULL)
);

-- 20. Shipment (giao nhận film 2 chiều)
CREATE TABLE Shipment (
    shipment_id       BIGINT IDENTITY(1,1) NOT NULL,
    order_id          BIGINT        NOT NULL,
    partner_id        INT           NULL,             -- NULL cho đến khi có người nhận đơn
    direction         VARCHAR(25)   NOT NULL,
    provider          VARCHAR(15)   NOT NULL,
    external_order_id VARCHAR(64)   NULL,             -- mã đơn phía Ahamove/Lalamove
    tracking_code     VARCHAR(64)   NULL,
    sender_name       NVARCHAR(150) NOT NULL,
    sender_phone      VARCHAR(20)   NOT NULL,
    sender_address    NVARCHAR(500) NOT NULL,         -- snapshot địa chỉ tại thời điểm tạo
    receiver_name     NVARCHAR(150) NOT NULL,
    receiver_phone    VARCHAR(20)   NOT NULL,
    receiver_address  NVARCHAR(500) NOT NULL,
    shipping_fee      DECIMAL(15,2) NOT NULL CONSTRAINT DF_Ship_Fee DEFAULT 0,
    status            VARCHAR(15)   NOT NULL CONSTRAINT DF_Ship_Status DEFAULT 'PENDING',
    proof_image_url   VARCHAR(500)  NULL,
    assigned_at       DATETIME2(0)  NULL,
    picked_up_at      DATETIME2(0)  NULL,
    delivered_at      DATETIME2(0)  NULL,
    created_at        DATETIME2(0)  NOT NULL CONSTRAINT DF_Ship_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Shipment PRIMARY KEY (shipment_id),
    CONSTRAINT UQ_Shipment_OrderDir UNIQUE (order_id, direction),   -- mỗi chiều tối đa 1 vận đơn
    CONSTRAINT FK_Ship_Order   FOREIGN KEY (order_id)   REFERENCES Orders(order_id),
    CONSTRAINT FK_Ship_Partner FOREIGN KEY (partner_id) REFERENCES Delivery_Partner_Profile(partner_id),
    CONSTRAINT CK_Ship_Dir      CHECK (direction IN ('PICKUP_TO_LAB','RETURN_TO_CUSTOMER')),
    CONSTRAINT CK_Ship_Provider CHECK (provider  IN ('AHAMOVE','LALAMOVE','INTERNAL')),
    CONSTRAINT CK_Ship_Status   CHECK (status IN
        ('PENDING','ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED','CANCELLED')),
    CONSTRAINT CK_Ship_Fee      CHECK (shipping_fee >= 0),
    CONSTRAINT CK_Ship_Time     CHECK (delivered_at IS NULL OR picked_up_at IS NULL OR delivered_at >= picked_up_at)
);

-- 39. Dispute_Message (Khách <-> Lab thương lượng, Admin can thiệp)
CREATE TABLE Dispute_Message (
    message_id BIGINT IDENTITY(1,1) NOT NULL,
    dispute_id BIGINT         NOT NULL,
    sender_id  INT            NOT NULL,
    content    NVARCHAR(2000) NOT NULL,
    created_at DATETIME2(0)   NOT NULL CONSTRAINT DF_DM_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Dispute_Message PRIMARY KEY (message_id),
    CONSTRAINT FK_DM_Dispute FOREIGN KEY (dispute_id) REFERENCES Dispute_Complaint(dispute_id) ON DELETE CASCADE,
    CONSTRAINT FK_DM_Sender  FOREIGN KEY (sender_id)  REFERENCES Users(user_id)
);

-- 40. Dispute_Evidence (ảnh/tài liệu minh chứng)
CREATE TABLE Dispute_Evidence (
    evidence_id BIGINT IDENTITY(1,1) NOT NULL,
    dispute_id  BIGINT       NOT NULL,
    message_id  BIGINT       NULL,
    uploaded_by INT          NOT NULL,
    file_url    VARCHAR(500) NOT NULL,
    mime_type   VARCHAR(50)  NOT NULL,
    uploaded_at DATETIME2(0) NOT NULL CONSTRAINT DF_DE_At DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Dispute_Evidence PRIMARY KEY (evidence_id),
    CONSTRAINT FK_DE_Dispute FOREIGN KEY (dispute_id)  REFERENCES Dispute_Complaint(dispute_id) ON DELETE CASCADE,
    CONSTRAINT FK_DE_Message FOREIGN KEY (message_id)  REFERENCES Dispute_Message(message_id),
    CONSTRAINT FK_DE_User    FOREIGN KEY (uploaded_by) REFERENCES Users(user_id)
);

-- 43. Audit_Log (nhật ký thao tác nhạy cảm: khóa tài khoản, duyệt lab, hoàn tiền...)
CREATE TABLE Audit_Log (
    log_id      BIGINT IDENTITY(1,1) NOT NULL,
    user_id     INT           NULL,
    action      VARCHAR(50)   NOT NULL,
    entity_name VARCHAR(50)   NOT NULL,
    entity_id   VARCHAR(50)   NULL,
    old_value   NVARCHAR(MAX) NULL,
    new_value   NVARCHAR(MAX) NULL,
    ip_address  VARCHAR(45)   NULL,
    created_at  DATETIME2(0)  NOT NULL CONSTRAINT DF_Audit_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Audit_Log PRIMARY KEY (log_id),
    CONSTRAINT FK_Audit_User FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Audit_Old CHECK (old_value IS NULL OR ISJSON(old_value) = 1),
    CONSTRAINT CK_Audit_New CHECK (new_value IS NULL OR ISJSON(new_value) = 1)
);

-- 41. Notification (đẩy thông báo: scan xong, đổi trạng thái đơn...)
CREATE TABLE Notification (
    notification_id BIGINT IDENTITY(1,1) NOT NULL,
    user_id         INT           NOT NULL,
    notif_type      VARCHAR(30)   NOT NULL,        -- ORDER_STATUS, SCAN_READY, DISPUTE_UPDATE...
    title           NVARCHAR(200) NOT NULL,
    body            NVARCHAR(500) NULL,
    ref_type        VARCHAR(30)   NULL,            -- ORDER, DISPUTE, LISTING, POST...
    ref_id          BIGINT        NULL,
    is_read         BIT           NOT NULL CONSTRAINT DF_Notif_Read DEFAULT 0,
    created_at      DATETIME2(0)  NOT NULL CONSTRAINT DF_Notif_Created DEFAULT SYSUTCDATETIME(),
    read_at         DATETIME2(0)  NULL,
    CONSTRAINT PK_Notification PRIMARY KEY (notification_id),
    CONSTRAINT FK_Notif_User FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- 42. Device_Token (FCM push)
CREATE TABLE Device_Token (
    device_token_id INT IDENTITY(1,1) NOT NULL,
    user_id         INT          NOT NULL,
    fcm_token       VARCHAR(512) NOT NULL,
    platform        VARCHAR(10)  NOT NULL,
    last_used_at    DATETIME2(0) NOT NULL CONSTRAINT DF_DT_Used DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Device_Token PRIMARY KEY (device_token_id),
    CONSTRAINT UQ_DT_Token UNIQUE (fcm_token),
    CONSTRAINT FK_DT_User FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT CK_DT_Platform CHECK (platform IN ('ANDROID','IOS','WEB'))
);

-- 44. System_Config (cấu hình phí giao dịch, thời hạn...)
CREATE TABLE System_Config (
    config_key   VARCHAR(100)  NOT NULL,
    config_value NVARCHAR(500) NOT NULL,
    description  NVARCHAR(255) NULL,
    updated_by   INT           NULL,
    updated_at   DATETIME2(0)  NOT NULL CONSTRAINT DF_SC_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_System_Config PRIMARY KEY (config_key),
    CONSTRAINT FK_SC_User FOREIGN KEY (updated_by) REFERENCES Users(user_id)
);
