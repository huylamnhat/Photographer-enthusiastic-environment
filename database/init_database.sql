-- =====================================================================
-- FILMLAB PLATFORM (MINILAB) - SCRIPT KHOI TAO CSDL CHINH (SQL SERVER)
-- Chay file nay trong SSMS (F5) de tao moi DB FilmLabPlatform va nap du lieu
-- (Neu FilmLabPlatform da ton tai, script se tu dong xoa va tao lai sach se)
-- =====================================================================
USE master;
GO
IF DB_ID(N'FilmLabPlatform') IS NOT NULL
BEGIN
    ALTER DATABASE FilmLabPlatform SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE FilmLabPlatform;
END
GO
CREATE DATABASE FilmLabPlatform COLLATE Vietnamese_100_CI_AS;
GO
USE FilmLabPlatform;
GO

-- ===============================================
-- 01_tables/01_identity.sql
-- ===============================================
-- Issue #21 | SQL Server | Source: Week 2

-- 1. Roles
CREATE TABLE Roles (
    role_id     TINYINT       NOT NULL,
    role_code   VARCHAR(30)   NOT NULL,
    role_name   NVARCHAR(100) NOT NULL,
    description NVARCHAR(255) NULL,
    CONSTRAINT PK_Roles PRIMARY KEY (role_id),
    CONSTRAINT UQ_Roles_Code UNIQUE (role_code),
    CONSTRAINT CK_Roles_Code CHECK (role_code IN
        ('CUSTOMER','LAB_OWNER','EXPERT','DELIVERY_PARTNER','ADMIN'))
);

-- 2. Users
CREATE TABLE Users (
    user_id        INT IDENTITY(1,1) NOT NULL,
    user_code      VARCHAR(30)    NULL,               -- Mã định danh đồng bộ App/Backend (VD: usr-001)
    email          NVARCHAR(255)  NOT NULL,
    phone          VARCHAR(20)    NULL,
    password_hash  VARCHAR(255)   NOT NULL,           -- bcrypt/argon2, KHÔNG lưu mật khẩu thô
    full_name      NVARCHAR(150)  NOT NULL,
    avatar_url     VARCHAR(500)   NULL,
    address_text   NVARCHAR(500)  NULL,               -- Địa chỉ hiển thị nhanh trên hồ sơ
    bio            NVARCHAR(2000) NULL,               -- Giới thiệu ngắn của người dùng/chuyên gia
    status         VARCHAR(20)    NOT NULL CONSTRAINT DF_Users_Status DEFAULT 'PENDING_VERIFY',
    email_verified BIT            NOT NULL CONSTRAINT DF_Users_EmailVerified DEFAULT 0,
    locked_reason  NVARCHAR(500)  NULL,
    locked_by      INT            NULL,
    locked_at      DATETIME2(0)   NULL,
    last_login_at  DATETIME2(0)   NULL,
    created_at     DATETIME2(0)   NOT NULL CONSTRAINT DF_Users_Created DEFAULT SYSUTCDATETIME(),
    updated_at     DATETIME2(0)   NOT NULL CONSTRAINT DF_Users_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Users PRIMARY KEY (user_id),
    CONSTRAINT UQ_Users_Email UNIQUE (email),
    CONSTRAINT FK_Users_LockedBy FOREIGN KEY (locked_by) REFERENCES Users(user_id),
    CONSTRAINT CK_Users_Status CHECK (status IN ('ACTIVE','PENDING_VERIFY','LOCKED','DELETED')),
    CONSTRAINT CK_Users_Email CHECK (email LIKE '%_@_%._%'),
    CONSTRAINT CK_Users_Locked CHECK (status <> 'LOCKED' OR (locked_at IS NOT NULL AND locked_by IS NOT NULL))
);
CREATE UNIQUE INDEX UX_Users_Phone ON Users(phone) WHERE phone IS NOT NULL;
CREATE UNIQUE INDEX UX_Users_Code  ON Users(user_code) WHERE user_code IS NOT NULL;

-- 3. User_Roles (N-N: User <-> Role)
CREATE TABLE User_Roles (
    user_id     INT          NOT NULL,
    role_id     TINYINT      NOT NULL,
    assigned_at DATETIME2(0) NOT NULL CONSTRAINT DF_UserRoles_Assigned DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_User_Roles PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_UserRoles_User FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_UserRoles_Role FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

-- 4. User_Address
CREATE TABLE User_Address (
    address_id     INT IDENTITY(1,1) NOT NULL,
    user_id        INT           NOT NULL,
    receiver_name  NVARCHAR(150) NOT NULL,
    receiver_phone VARCHAR(20)   NOT NULL,
    province       NVARCHAR(100) NOT NULL,
    district       NVARCHAR(100) NOT NULL,
    ward           NVARCHAR(100) NULL,
    street         NVARCHAR(255) NOT NULL,
    latitude       DECIMAL(9,6)  NULL,
    longitude      DECIMAL(9,6)  NULL,
    is_default     BIT           NOT NULL CONSTRAINT DF_UserAddr_Default DEFAULT 0,
    CONSTRAINT PK_User_Address PRIMARY KEY (address_id),
    CONSTRAINT FK_UserAddr_User FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT CK_UserAddr_Lat CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT CK_UserAddr_Lng CHECK (longitude BETWEEN -180 AND 180)
);
CREATE UNIQUE INDEX UX_UserAddr_OneDefault ON User_Address(user_id) WHERE is_default = 1;

-- 11. Expert_Profile (1-1 với Users)
CREATE TABLE Expert_Profile (
    expert_id           INT IDENTITY(1,1) NOT NULL,
    user_id             INT           NOT NULL,
    bio                 NVARCHAR(2000) NULL,
    specialties         NVARCHAR(500) NULL,
    portfolio_url       VARCHAR(500)  NULL,
    years_experience    TINYINT       NULL,
    verification_status VARCHAR(20)   NOT NULL CONSTRAINT DF_Exp_Status DEFAULT 'PENDING',
    verified_by         INT           NULL,
    CONSTRAINT PK_Expert_Profile PRIMARY KEY (expert_id),
    CONSTRAINT UQ_Expert_User UNIQUE (user_id),
    CONSTRAINT FK_Expert_User     FOREIGN KEY (user_id)     REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_Expert_Verifier FOREIGN KEY (verified_by) REFERENCES Users(user_id),
    CONSTRAINT CK_Expert_Status CHECK (verification_status IN ('PENDING','VERIFIED','REJECTED'))
);

-- 12. Delivery_Partner_Profile (1-1 với Users)
CREATE TABLE Delivery_Partner_Profile (
    partner_id      INT IDENTITY(1,1) NOT NULL,
    user_id         INT           NOT NULL,
    provider        VARCHAR(20)   NOT NULL,
    company_name    NVARCHAR(150) NULL,
    vehicle_type    VARCHAR(30)   NULL,
    license_plate   VARCHAR(20)   NULL,
    service_area    NVARCHAR(255) NULL,
    approval_status VARCHAR(20)   NOT NULL CONSTRAINT DF_DP_Status DEFAULT 'PENDING',
    is_available    BIT           NOT NULL CONSTRAINT DF_DP_Avail DEFAULT 1,
    avg_rating      DECIMAL(3,2)  NOT NULL CONSTRAINT DF_DP_Rating DEFAULT 0,
    reviewed_by     INT           NULL,
    CONSTRAINT PK_Delivery_Partner PRIMARY KEY (partner_id),
    CONSTRAINT UQ_DP_User UNIQUE (user_id),
    CONSTRAINT FK_DP_User     FOREIGN KEY (user_id)     REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_DP_Reviewer FOREIGN KEY (reviewed_by) REFERENCES Users(user_id),
    CONSTRAINT CK_DP_Provider CHECK (provider IN ('AHAMOVE','LALAMOVE','INDEPENDENT')),
    CONSTRAINT CK_DP_Status   CHECK (approval_status IN ('PENDING','APPROVED','REJECTED','SUSPENDED')),
    CONSTRAINT CK_DP_Rating   CHECK (avg_rating BETWEEN 0 AND 5)
);
GO

-- ===============================================
-- 01_tables/02_catalog_lab.sql
-- ===============================================
-- Issue #21 | SQL Server | Source: Week 2

-- 5. Film_Format
CREATE TABLE Film_Format (
    format_id SMALLINT IDENTITY(1,1) NOT NULL,
    name      VARCHAR(30) NOT NULL,
    CONSTRAINT PK_Film_Format PRIMARY KEY (format_id),
    CONSTRAINT UQ_Film_Format_Name UNIQUE (name)
);

-- 6. Process_Type (quy trình tráng)
CREATE TABLE Process_Type (
    process_type_id SMALLINT IDENTITY(1,1) NOT NULL,
    code            VARCHAR(20)   NOT NULL,
    name            NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Process_Type PRIMARY KEY (process_type_id),
    CONSTRAINT UQ_Process_Type_Code UNIQUE (code)
);

-- 7. Film_Stock (danh mục loại film)
CREATE TABLE Film_Stock (
    film_stock_id INT IDENTITY(1,1) NOT NULL,
    brand         NVARCHAR(100) NOT NULL,
    name          NVARCHAR(150) NOT NULL,
    iso           SMALLINT      NULL,
    format_id     SMALLINT      NOT NULL,
    film_type     VARCHAR(20)   NOT NULL,
    CONSTRAINT PK_Film_Stock PRIMARY KEY (film_stock_id),
    CONSTRAINT FK_FilmStock_Format FOREIGN KEY (format_id) REFERENCES Film_Format(format_id),
    CONSTRAINT UQ_FilmStock UNIQUE (brand, name, format_id),
    CONSTRAINT CK_FilmStock_Type CHECK (film_type IN ('COLOR_NEG','SLIDE','BW','CINE')),
    CONSTRAINT CK_FilmStock_ISO CHECK (iso IS NULL OR iso BETWEEN 1 AND 25600)
);

-- 8. Lab_Profile
CREATE TABLE Lab_Profile (
    lab_id              INT IDENTITY(1,1) NOT NULL,
    lab_code            VARCHAR(30)    NULL,               -- Mã định danh đồng bộ App/Backend (VD: lab-001)
    owner_id            INT            NOT NULL,
    lab_name            NVARCHAR(200)  NOT NULL,
    slug                VARCHAR(220)   NOT NULL,
    tagline             NVARCHAR(300)  NULL,               -- Khẩu hiệu hiển thị trên App/Web
    description         NVARCHAR(2000) NULL,
    phone               VARCHAR(20)    NOT NULL,
    email               NVARCHAR(255)  NULL,
    province            NVARCHAR(100)  NOT NULL,
    district            NVARCHAR(100)  NOT NULL,
    street_address      NVARCHAR(255)  NOT NULL,
    latitude            DECIMAL(9,6)   NULL,
    longitude           DECIMAL(9,6)   NULL,
    business_license_no VARCHAR(50)    NULL,
    license_image_url   VARCHAR(500)   NULL,
    logo_url            VARCHAR(500)   NULL,
    cover_url           VARCHAR(500)   NULL,
    opening_time        TIME(0)        NULL,
    closing_time        TIME(0)        NULL,
    turnaround_hours    SMALLINT       NOT NULL CONSTRAINT DF_Lab_Turnaround DEFAULT 12,
    price_range         NVARCHAR(100)  NULL,
    scanner_models      NVARCHAR(500)  NULL,               -- Danh sách máy scan (JSON/text)
    supported_processes NVARCHAR(500)  NULL,               -- Danh sách quy trình tráng hỗ trợ
    supports_pickup     BIT            NOT NULL CONSTRAINT DF_Lab_Pickup DEFAULT 0,
    avg_rating          DECIMAL(3,2)   NOT NULL CONSTRAINT DF_Lab_Rating DEFAULT 0,   -- denormalized, cập nhật bằng trigger/job
    review_count        INT            NOT NULL CONSTRAINT DF_Lab_RvCount DEFAULT 0,  -- denormalized
    approval_status     VARCHAR(20)    NOT NULL CONSTRAINT DF_Lab_Approval DEFAULT 'PENDING',
    inspection_note     NVARCHAR(1000) NULL,
    reviewed_by         INT            NULL,
    reviewed_at         DATETIME2(0)   NULL,
    reject_reason       NVARCHAR(500)  NULL,
    created_at          DATETIME2(0)   NOT NULL CONSTRAINT DF_Lab_Created DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2(0)   NOT NULL CONSTRAINT DF_Lab_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Lab_Profile PRIMARY KEY (lab_id),
    CONSTRAINT UQ_Lab_Slug UNIQUE (slug),
    CONSTRAINT FK_Lab_Owner    FOREIGN KEY (owner_id)    REFERENCES Users(user_id),
    CONSTRAINT FK_Lab_Reviewer FOREIGN KEY (reviewed_by) REFERENCES Users(user_id),
    CONSTRAINT CK_Lab_Status CHECK (approval_status IN ('PENDING','APPROVED','REJECTED','SUSPENDED')),
    CONSTRAINT CK_Lab_Rating CHECK (avg_rating BETWEEN 0 AND 5),
    CONSTRAINT CK_Lab_Hours  CHECK (opening_time IS NULL OR closing_time IS NULL OR opening_time < closing_time),
    CONSTRAINT CK_Lab_Reject CHECK (approval_status <> 'REJECTED' OR reject_reason IS NOT NULL)
);
CREATE UNIQUE INDEX UX_Lab_License ON Lab_Profile(business_license_no) WHERE business_license_no IS NOT NULL;
CREATE UNIQUE INDEX UX_Lab_Code    ON Lab_Profile(lab_code) WHERE lab_code IS NOT NULL;

-- 9. Lab_Film_Format (N-N)
CREATE TABLE Lab_Film_Format (
    lab_id    INT      NOT NULL,
    format_id SMALLINT NOT NULL,
    CONSTRAINT PK_Lab_Film_Format PRIMARY KEY (lab_id, format_id),
    CONSTRAINT FK_LFF_Lab    FOREIGN KEY (lab_id)    REFERENCES Lab_Profile(lab_id) ON DELETE CASCADE,
    CONSTRAINT FK_LFF_Format FOREIGN KEY (format_id) REFERENCES Film_Format(format_id)
);

-- 10. Service_Package
CREATE TABLE Service_Package (
    package_id           INT IDENTITY(1,1) NOT NULL,
    package_code         VARCHAR(30)    NULL,        -- Mã gói đồng bộ App/Backend (VD: pkg-001)
    lab_id               INT            NOT NULL,
    service_type         VARCHAR(20)    NOT NULL,
    name                 NVARCHAR(200)  NOT NULL,
    description          NVARCHAR(1000) NULL,
    format_id            SMALLINT       NOT NULL,
    process_type_id      SMALLINT       NULL,        -- NULL khi chỉ scan
    scan_quality         VARCHAR(20)    NULL,        -- NULL khi chỉ tráng
    scan_resolution      NVARCHAR(100)  NULL,        -- VD: M (3000x2000px), L (6000x4000px TIFF)
    scan_dpi             SMALLINT       NULL,
    output_format        VARCHAR(20)    NULL,
    price                DECIMAL(15,2)  NOT NULL,
    price_unit           VARCHAR(20)    NOT NULL CONSTRAINT DF_SP_Unit DEFAULT 'PER_ROLL',
    est_processing_days  TINYINT        NOT NULL CONSTRAINT DF_SP_Days DEFAULT 1,
    estimated_hours      SMALLINT       NOT NULL CONSTRAINT DF_SP_Hours DEFAULT 12,
    is_active            BIT            NOT NULL CONSTRAINT DF_SP_Active DEFAULT 1,
    created_at           DATETIME2(0)   NOT NULL CONSTRAINT DF_SP_Created DEFAULT SYSUTCDATETIME(),
    updated_at           DATETIME2(0)   NOT NULL CONSTRAINT DF_SP_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Service_Package PRIMARY KEY (package_id),
    CONSTRAINT FK_SP_Lab     FOREIGN KEY (lab_id)          REFERENCES Lab_Profile(lab_id) ON DELETE CASCADE,
    CONSTRAINT FK_SP_Format  FOREIGN KEY (format_id)       REFERENCES Film_Format(format_id),
    CONSTRAINT FK_SP_Process FOREIGN KEY (process_type_id) REFERENCES Process_Type(process_type_id),
    CONSTRAINT UQ_SP_LabName UNIQUE (lab_id, name),
    CONSTRAINT CK_SP_Type    CHECK (service_type IN ('DEVELOP','SCAN','DEVELOP_SCAN','PRINT')),
    CONSTRAINT CK_SP_Quality CHECK (scan_quality IS NULL OR scan_quality IN ('BASIC','STANDARD','HIGH','PRO')),
    CONSTRAINT CK_SP_Output  CHECK (output_format IS NULL OR output_format IN ('JPEG','TIFF','DNG','PNG')),
    CONSTRAINT CK_SP_Unit    CHECK (price_unit IN ('PER_ROLL','PER_FRAME')),
    CONSTRAINT CK_SP_Price   CHECK (price >= 0),
    CONSTRAINT CK_SP_Days    CHECK (est_processing_days BETWEEN 1 AND 60),
    -- Ràng buộc chéo: tráng phải có process_type, scan phải có scan_quality
    CONSTRAINT CK_SP_Consistency CHECK (
        (service_type = 'DEVELOP'      AND process_type_id IS NOT NULL) OR
        (service_type = 'SCAN'         AND scan_quality   IS NOT NULL) OR
        (service_type = 'DEVELOP_SCAN' AND process_type_id IS NOT NULL AND scan_quality IS NOT NULL) OR
        (service_type = 'PRINT')
    )
);
CREATE UNIQUE INDEX UX_SP_Code ON Service_Package(package_code) WHERE package_code IS NOT NULL;
GO

-- ===============================================
-- 01_tables/03_orders_payment.sql
-- ===============================================
-- Issue #21 | SQL Server | Source: Week 2

-- 13. Orders
CREATE TABLE Orders (
    order_id                BIGINT IDENTITY(1,1) NOT NULL,
    order_code              VARCHAR(20)   NOT NULL,                 -- VD: ORD-2026-8801
    customer_id             INT           NOT NULL,
    lab_id                  INT           NOT NULL,
    status                  VARCHAR(25)   NOT NULL CONSTRAINT DF_Orders_Status DEFAULT 'PENDING_PAYMENT',
    kanban_column           VARCHAR(20)   NOT NULL CONSTRAINT DF_Orders_Kanban DEFAULT 'QUEUE',
    receive_method          VARCHAR(20)   NOT NULL,
    return_method           VARCHAR(20)   NOT NULL CONSTRAINT DF_Orders_Return DEFAULT 'DIGITAL_ONLY',
    pickup_address          NVARCHAR(500) NULL,
    payment_status          VARCHAR(20)   NOT NULL CONSTRAINT DF_Orders_PayStatus DEFAULT 'PENDING',
    payment_method          VARCHAR(20)   NULL,
    subtotal                DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Sub DEFAULT 0,
    shipping_fee            DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Ship DEFAULT 0,
    platform_fee            DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Fee DEFAULT 0,
    discount_amount         DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Disc DEFAULT 0,
    total_amount            DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Total DEFAULT 0,
    expected_completion_date DATE         NULL,
    sla_deadline            DATETIME2(0)  NULL,
    customer_note           NVARCHAR(1000) NULL,
    cancel_reason           NVARCHAR(500) NULL,
    cancelled_by            INT           NULL,
    confirmed_at            DATETIME2(0)  NULL,
    completed_at            DATETIME2(0)  NULL,
    closed_at               DATETIME2(0)  NULL,
    created_at              DATETIME2(0)  NOT NULL CONSTRAINT DF_Orders_Created DEFAULT SYSUTCDATETIME(),
    updated_at              DATETIME2(0)  NOT NULL CONSTRAINT DF_Orders_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Orders PRIMARY KEY (order_id),
    CONSTRAINT UQ_Orders_Code UNIQUE (order_code),
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (customer_id)  REFERENCES Users(user_id),
    CONSTRAINT FK_Orders_Lab      FOREIGN KEY (lab_id)       REFERENCES Lab_Profile(lab_id),
    CONSTRAINT FK_Orders_CancelBy FOREIGN KEY (cancelled_by) REFERENCES Users(user_id),
    CONSTRAINT CK_Orders_Status CHECK (status IN (
        'PENDING_PAYMENT','PENDING_LAB_CONFIRM','PICKING_UP','RECEIVED_AT_LAB',
        'PROCESSING','COMPLETED','DELIVERING','CLOSED','CANCELLED',
        'PENDING_FILM','RECEIVED','DRYING','SCANNING','QC_CHECK','READY_FOR_DOWNLOAD')),
    CONSTRAINT CK_Orders_Kanban CHECK (kanban_column IN ('QUEUE','DEVELOPING','SCANNING','QC','READY')),
    CONSTRAINT CK_Orders_Receive CHECK (receive_method IN ('SELF_DROP_OFF','DROP_AT_LAB','PICKUP')),
    CONSTRAINT CK_Orders_Return  CHECK (return_method  IN ('SELF_PICKUP','DELIVERY','DIGITAL_ONLY')),
    CONSTRAINT CK_Orders_Money   CHECK (subtotal >= 0 AND shipping_fee >= 0 AND platform_fee >= 0
                                        AND discount_amount >= 0 AND total_amount >= 0),
    CONSTRAINT CK_Orders_Total   CHECK (total_amount = subtotal + shipping_fee + platform_fee - discount_amount),
    CONSTRAINT CK_Orders_Cancel  CHECK (status <> 'CANCELLED' OR (cancel_reason IS NOT NULL AND cancelled_by IS NOT NULL))
);

-- 14. Order_Item
CREATE TABLE Order_Item (
    order_item_id BIGINT IDENTITY(1,1) NOT NULL,
    item_code     VARCHAR(30)   NULL,                                       -- VD: item-101
    order_id      BIGINT        NOT NULL,
    package_id    INT           NOT NULL,
    film_stock_id INT           NULL,
    film_name     NVARCHAR(150) NULL,                                       -- Tên film hiển thị (VD: Kodak Portra 400)
    roll_code     VARCHAR(50)   NULL,                                       -- Mã cuộn (VD: ROLL-PORTRA400-01)
    quantity      SMALLINT      NOT NULL CONSTRAINT DF_OI_Qty DEFAULT 1,   -- số cuộn
    unit_price    DECIMAL(15,2) NOT NULL,                                   -- snapshot giá tại thời điểm đặt
    line_total    DECIMAL(15,2) NOT NULL,
    push_pull     NVARCHAR(50)  NULL,                                       -- Normal / +1 Stop / +2 Stops
    cut_negatives NVARCHAR(100) NULL,                                       -- Cắt 6 frames/dải / Để nguyên cuộn
    note          NVARCHAR(500) NULL,
    status        VARCHAR(20)   NOT NULL CONSTRAINT DF_OI_Status DEFAULT 'PENDING',
    CONSTRAINT PK_Order_Item PRIMARY KEY (order_item_id),
    CONSTRAINT FK_OI_Order   FOREIGN KEY (order_id)      REFERENCES Orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_OI_Package FOREIGN KEY (package_id)    REFERENCES Service_Package(package_id),
    CONSTRAINT FK_OI_Stock   FOREIGN KEY (film_stock_id) REFERENCES Film_Stock(film_stock_id),
    CONSTRAINT CK_OI_Qty     CHECK (quantity BETWEEN 1 AND 100),
    CONSTRAINT CK_OI_Price   CHECK (unit_price >= 0 AND line_total = unit_price * quantity),
    CONSTRAINT CK_OI_Status  CHECK (status IN ('PENDING','RECEIVED','PROCESSING','DONE','FAILED'))
);

-- 15. Order_Status_History (audit vòng đời đơn)
CREATE TABLE Order_Status_History (
    history_id  BIGINT IDENTITY(1,1) NOT NULL,
    order_id    BIGINT       NOT NULL,
    from_status VARCHAR(25)  NULL,
    to_status   VARCHAR(25)  NOT NULL,
    changed_by  INT          NULL,                  -- NULL = hệ thống / webhook thanh toán
    note        NVARCHAR(500) NULL,
    changed_at  DATETIME2(0) NOT NULL CONSTRAINT DF_OSH_At DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Order_Status_History PRIMARY KEY (history_id),
    CONSTRAINT FK_OSH_Order FOREIGN KEY (order_id)   REFERENCES Orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_OSH_User  FOREIGN KEY (changed_by) REFERENCES Users(user_id)
);

-- 17. Payment
CREATE TABLE Payment (
    payment_id      BIGINT IDENTITY(1,1) NOT NULL,
    order_id        BIGINT        NOT NULL,
    gateway         VARCHAR(20)   NOT NULL,
    txn_ref         VARCHAR(64)   NOT NULL,          -- mã tham chiếu gửi sang cổng
    gateway_txn_no  VARCHAR(64)   NULL,              -- mã giao dịch phía VNPay/MoMo
    amount          DECIMAL(15,2) NOT NULL,
    currency        CHAR(3)       NOT NULL CONSTRAINT DF_Pay_Cur DEFAULT 'VND',
    status          VARCHAR(15)   NOT NULL CONSTRAINT DF_Pay_Status DEFAULT 'PENDING',
    response_code   VARCHAR(10)   NULL,
    paid_at         DATETIME2(0)  NULL,
    created_at      DATETIME2(0)  NOT NULL CONSTRAINT DF_Pay_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Payment PRIMARY KEY (payment_id),
    CONSTRAINT UQ_Payment_TxnRef UNIQUE (txn_ref),     -- chống xử lý trùng callback (idempotent)
    CONSTRAINT FK_Payment_Order FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    CONSTRAINT CK_Payment_Gateway CHECK (gateway IN ('VNPAY','MOMO','BANK_TRANSFER')),
    CONSTRAINT CK_Payment_Status  CHECK (status IN ('PENDING','SUCCESS','PAID','FAILED','CANCELLED','REFUNDED')),
    CONSTRAINT CK_Payment_Amount  CHECK (amount > 0),
    CONSTRAINT CK_Payment_Paid    CHECK (status NOT IN ('SUCCESS','PAID') OR paid_at IS NOT NULL)
);
GO

-- ===============================================
-- 01_tables/04_lab_archive.sql
-- ===============================================
-- Issue #21 | SQL Server | Source: Week 2

-- 16. Order_Process_Step (công đoạn xử lý từng cuộn film)
CREATE TABLE Order_Process_Step (
    step_id       BIGINT IDENTITY(1,1) NOT NULL,
    order_item_id BIGINT       NOT NULL,
    step_type     VARCHAR(20)  NOT NULL,
    step_seq      TINYINT      NOT NULL,
    status        VARCHAR(20)  NOT NULL CONSTRAINT DF_OPS_Status DEFAULT 'PENDING',
    started_at    DATETIME2(0) NULL,
    completed_at  DATETIME2(0) NULL,
    performed_by       INT           NULL,
    evidence_photo_url VARCHAR(500)  NULL,          -- ảnh chụp tình trạng cuộn film lúc nhận / bằng chứng QC
    note          NVARCHAR(500) NULL,
    CONSTRAINT PK_Order_Process_Step PRIMARY KEY (step_id),
    CONSTRAINT FK_OPS_Item FOREIGN KEY (order_item_id) REFERENCES Order_Item(order_item_id) ON DELETE CASCADE,
    CONSTRAINT FK_OPS_User FOREIGN KEY (performed_by)  REFERENCES Users(user_id),
    CONSTRAINT UQ_OPS_ItemStep UNIQUE (order_item_id, step_type),
    CONSTRAINT CK_OPS_Type   CHECK (step_type IN ('RECEIVE','DEVELOP','WASH','DRY','SCAN','PREPARE','QC')),
    CONSTRAINT CK_OPS_Status CHECK (status IN ('PENDING','IN_PROGRESS','DONE','SKIPPED','FAILED')),
    CONSTRAINT CK_OPS_Time   CHECK (completed_at IS NULL OR started_at IS NULL OR completed_at >= started_at)
);

-- 21. Scan_File (file Lab upload sau khi scan - lưu trong hệ thống File Storage)
CREATE TABLE Scan_File (
    scan_file_id    BIGINT IDENTITY(1,1) NOT NULL,
    order_item_id   BIGINT        NOT NULL,
    uploaded_by     INT           NOT NULL,
    file_name       NVARCHAR(255) NOT NULL,
    storage_key     VARCHAR(500)  NOT NULL,         -- đường dẫn file trong File Storage (VD: /uploads/scans/order_101/roll_01_001.jpg)
    mime_type       VARCHAR(50)   NOT NULL,
    size_bytes      BIGINT        NOT NULL,
    width_px        INT           NULL,
    height_px       INT           NULL,
    checksum_sha256 CHAR(64)      NULL,
    uploaded_at     DATETIME2(0)  NOT NULL CONSTRAINT DF_Scan_Up DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Scan_File PRIMARY KEY (scan_file_id),
    CONSTRAINT UQ_Scan_Key UNIQUE (storage_key),
    CONSTRAINT FK_Scan_Item FOREIGN KEY (order_item_id) REFERENCES Order_Item(order_item_id),
    CONSTRAINT FK_Scan_User FOREIGN KEY (uploaded_by)   REFERENCES Users(user_id),
    CONSTRAINT CK_Scan_Size CHECK (size_bytes > 0),
    CONSTRAINT CK_Scan_Mime CHECK (mime_type IN ('image/jpeg','image/png','image/tiff','image/x-adobe-dng'))
);

-- 22. Digital_Film_Archive (mỗi "cuộn film" = 1 bộ sưu tập của khách)
CREATE TABLE Digital_Film_Archive (
    archive_id      BIGINT IDENTITY(1,1) NOT NULL,
    owner_id        INT           NOT NULL,
    order_item_id   BIGINT        NULL,             -- NULL nếu khách tự upload ảnh scan riêng
    title           NVARCHAR(200) NOT NULL,
    description     NVARCHAR(1000) NULL,
    film_stock_id   INT           NULL,
    shot_start_date DATE          NULL,
    shot_end_date   DATE          NULL,
    visibility      VARCHAR(10)   NOT NULL CONSTRAINT DF_DFA_Vis DEFAULT 'PRIVATE',
    created_at      DATETIME2(0)  NOT NULL CONSTRAINT DF_DFA_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Digital_Film_Archive PRIMARY KEY (archive_id),
    CONSTRAINT FK_DFA_Owner FOREIGN KEY (owner_id)      REFERENCES Users(user_id),
    CONSTRAINT FK_DFA_Item  FOREIGN KEY (order_item_id) REFERENCES Order_Item(order_item_id),
    CONSTRAINT FK_DFA_Stock FOREIGN KEY (film_stock_id) REFERENCES Film_Stock(film_stock_id),
    CONSTRAINT CK_DFA_Vis   CHECK (visibility IN ('PRIVATE','PUBLIC')),
    CONSTRAINT CK_DFA_Dates CHECK (shot_end_date IS NULL OR shot_start_date IS NULL OR shot_end_date >= shot_start_date)
);
CREATE UNIQUE INDEX UX_DFA_OrderItem ON Digital_Film_Archive(order_item_id) WHERE order_item_id IS NOT NULL;

-- 23. Archive_Photo
CREATE TABLE Archive_Photo (
    photo_id      BIGINT IDENTITY(1,1) NOT NULL,
    photo_code    VARCHAR(30)   NULL,               -- Mã định danh đồng bộ App/Backend (VD: pho-001)
    archive_id    BIGINT        NOT NULL,
    scan_file_id  BIGINT        NULL,               -- liên kết với file gốc do Lab giao
    roll_code     VARCHAR(50)   NULL,               -- Mã cuộn film hiển thị trên App
    title         NVARCHAR(200) NULL,               -- Tiêu đề bức ảnh
    file_name     NVARCHAR(255) NOT NULL,
    storage_key   VARCHAR(500)  NOT NULL,           -- đường dẫn file scan gốc trong File Storage
    thumbnail_key VARCHAR(500)  NULL,               -- đường dẫn ảnh thu nhỏ (/uploads/thumbnails/...)
    mime_type     VARCHAR(50)   NOT NULL,
    size_bytes    BIGINT        NOT NULL,
    width_px      INT           NULL,
    height_px     INT           NULL,
    sort_order    SMALLINT      NOT NULL CONSTRAINT DF_AP_Sort DEFAULT 0,
    is_favorite   BIT           NOT NULL CONSTRAINT DF_AP_Fav DEFAULT 0,
    is_deleted    BIT           NOT NULL CONSTRAINT DF_AP_Del DEFAULT 0,   -- soft delete
    uploaded_at   DATETIME2(0)  NOT NULL CONSTRAINT DF_AP_Up DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Archive_Photo PRIMARY KEY (photo_id),
    CONSTRAINT UQ_AP_Key UNIQUE (storage_key),
    CONSTRAINT FK_AP_Archive FOREIGN KEY (archive_id)   REFERENCES Digital_Film_Archive(archive_id) ON DELETE CASCADE,
    CONSTRAINT FK_AP_Scan    FOREIGN KEY (scan_file_id) REFERENCES Scan_File(scan_file_id),
    CONSTRAINT CK_AP_Size    CHECK (size_bytes > 0)
);
CREATE UNIQUE INDEX UX_AP_ScanFile ON Archive_Photo(scan_file_id) WHERE scan_file_id IS NOT NULL;
CREATE UNIQUE INDEX UX_AP_Code     ON Archive_Photo(photo_code)   WHERE photo_code IS NOT NULL;

-- 24. Photo_Metadata (1-1 với Archive_Photo)
CREATE TABLE Photo_Metadata (
    photo_id         BIGINT        NOT NULL,        -- vừa PK vừa FK -> đảm bảo 1-1
    camera_brand     NVARCHAR(100) NULL,
    camera_model     NVARCHAR(100) NULL,
    lens             NVARCHAR(150) NULL,
    focal_length     VARCHAR(20)   NULL,            -- '35mm', '50mm'
    film_stock_id    INT           NULL,
    iso              SMALLINT      NULL,
    aperture         DECIMAL(4,1)  NULL,            -- f/1.4 .. f/32
    shutter_speed    VARCHAR(15)   NULL,            -- '1/250', '2"', 'B'
    date_taken       DATE          NULL,
    location_text    NVARCHAR(255) NULL,
    process_type_id  SMALLINT      NULL,
    push_pull_stops  DECIMAL(3,1)  NULL,            -- +1, -1, +0.5...
    scan_device      NVARCHAR(100) NULL,            -- Noritsu HS-1800, Frontier SP3000...
    scan_dpi         SMALLINT      NULL,
    notes            NVARCHAR(1000) NULL,
    CONSTRAINT PK_Photo_Metadata PRIMARY KEY (photo_id),
    CONSTRAINT FK_PM_Photo   FOREIGN KEY (photo_id)        REFERENCES Archive_Photo(photo_id) ON DELETE CASCADE,
    CONSTRAINT FK_PM_Stock   FOREIGN KEY (film_stock_id)   REFERENCES Film_Stock(film_stock_id),
    CONSTRAINT FK_PM_Process FOREIGN KEY (process_type_id) REFERENCES Process_Type(process_type_id),
    CONSTRAINT CK_PM_ISO      CHECK (iso IS NULL OR iso BETWEEN 1 AND 25600),
    CONSTRAINT CK_PM_Aperture CHECK (aperture IS NULL OR aperture BETWEEN 0.7 AND 64),
    CONSTRAINT CK_PM_PushPull CHECK (push_pull_stops IS NULL OR push_pull_stops BETWEEN -4 AND 4),
    CONSTRAINT CK_PM_Date     CHECK (date_taken IS NULL OR date_taken >= '1900-01-01')
);

-- 25. Tag (dùng chung cho ảnh & bài viết)
CREATE TABLE Tag (
    tag_id INT IDENTITY(1,1) NOT NULL,
    name   NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Tag PRIMARY KEY (tag_id),
    CONSTRAINT UQ_Tag_Name UNIQUE (name)
);

-- 26. Photo_Tag (N-N)
CREATE TABLE Photo_Tag (
    photo_id BIGINT NOT NULL,
    tag_id   INT    NOT NULL,
    CONSTRAINT PK_Photo_Tag PRIMARY KEY (photo_id, tag_id),
    CONSTRAINT FK_PT_Photo FOREIGN KEY (photo_id) REFERENCES Archive_Photo(photo_id) ON DELETE CASCADE,
    CONSTRAINT FK_PT_Tag   FOREIGN KEY (tag_id)   REFERENCES Tag(tag_id) ON DELETE CASCADE
);
GO

-- ===============================================
-- 01_tables/05_dispute_shipping.sql
-- ===============================================
-- Issue #21 | SQL Server | Source: Week 2

-- 18. Dispute_Complaint (tạo trước Refund vì Refund tham chiếu)
CREATE TABLE Dispute_Complaint (
    dispute_id             BIGINT IDENTITY(1,1) NOT NULL,
    dispute_code           VARCHAR(20)    NOT NULL,
    order_id               BIGINT         NOT NULL,
    complainant_id         INT            NOT NULL,
    reason_type            VARCHAR(20)    NOT NULL,
    issue_title            NVARCHAR(200)  NULL,
    description            NVARCHAR(2000) NOT NULL,
    requested_amount       DECIMAL(15,2)  NULL,
    status                 VARCHAR(20)    NOT NULL CONSTRAINT DF_Disp_Status DEFAULT 'OPEN',
    negotiation_deadline   DATETIME2(0)   NULL,
    assigned_admin_id      INT            NULL,
    approved_refund_amount DECIMAL(15,2)  NULL,
    decision_note          NVARCHAR(1000) NULL,
    created_at             DATETIME2(0)   NOT NULL CONSTRAINT DF_Disp_Created DEFAULT SYSUTCDATETIME(),
    escalated_at           DATETIME2(0)   NULL,
    resolved_at            DATETIME2(0)   NULL,
    CONSTRAINT PK_Dispute_Complaint PRIMARY KEY (dispute_id),
    CONSTRAINT UQ_Dispute_Code UNIQUE (dispute_code),
    CONSTRAINT FK_Disp_Order FOREIGN KEY (order_id)          REFERENCES Orders(order_id),
    CONSTRAINT FK_Disp_User  FOREIGN KEY (complainant_id)    REFERENCES Users(user_id),
    CONSTRAINT FK_Disp_Admin FOREIGN KEY (assigned_admin_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Disp_Reason CHECK (reason_type IN
        ('QUALITY','LOST_FILM','DAMAGED_FILM','LATE','WRONG_SERVICE','OTHER')),
    CONSTRAINT CK_Disp_Status CHECK (status IN
        ('OPEN','NEGOTIATING','ESCALATED','RESOLVED','REFUNDED','RESOLVED_REFUNDED','RESOLVED_REJECTED','WITHDRAWN','CLOSED')),
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
GO

-- ===============================================
-- 01_tables/06_marketplace_community.sql
-- ===============================================
-- Issue #21 | SQL Server | Source: Week 2

-- 27. Equipment_Category (phân cấp)
CREATE TABLE Equipment_Category (
    category_id INT IDENTITY(1,1) NOT NULL,
    parent_id   INT           NULL,
    name        NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Equipment_Category PRIMARY KEY (category_id),
    CONSTRAINT UQ_EqCat_Name UNIQUE (name),
    CONSTRAINT FK_EqCat_Parent FOREIGN KEY (parent_id) REFERENCES Equipment_Category(category_id)
);

-- 28. Equipment_Listing
CREATE TABLE Equipment_Listing (
    listing_id      BIGINT IDENTITY(1,1) NOT NULL,
    listing_code    VARCHAR(30)    NULL,            -- Mã tin đăng đồng bộ App/Backend (VD: mkt-001)
    seller_id       INT            NOT NULL,
    category_id     INT            NOT NULL,
    listing_type    VARCHAR(10)    NOT NULL CONSTRAINT DF_EL_Type DEFAULT 'SELL',
    title           NVARCHAR(200)  NOT NULL,
    description     NVARCHAR(4000) NULL,
    brand           NVARCHAR(100)  NULL,
    model           NVARCHAR(100)  NULL,
    item_condition  VARCHAR(15)    NOT NULL,
    condition_note  NVARCHAR(255)  NULL,            -- Mô tả tình trạng chi tiết (VD: 98% Sưu tầm)
    price           DECIMAL(15,2)  NULL,            -- NULL khi chỉ trao đổi
    is_negotiable   BIT            NOT NULL CONSTRAINT DF_EL_Neg DEFAULT 0,
    location_text   NVARCHAR(255)  NULL,
    contact_phone   VARCHAR(20)    NOT NULL,
    contact_zalo    VARCHAR(50)    NULL,
    status          VARCHAR(20)    NOT NULL CONSTRAINT DF_EL_Status DEFAULT 'PENDING_APPROVAL',
    reviewed_by     INT            NULL,
    reviewed_at     DATETIME2(0)   NULL,
    reject_reason   NVARCHAR(500)  NULL,
    view_count      INT            NOT NULL CONSTRAINT DF_EL_Views DEFAULT 0,
    expires_at      DATETIME2(0)   NULL,
    created_at      DATETIME2(0)   NOT NULL CONSTRAINT DF_EL_Created DEFAULT SYSUTCDATETIME(),
    updated_at      DATETIME2(0)   NOT NULL CONSTRAINT DF_EL_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Equipment_Listing PRIMARY KEY (listing_id),
    CONSTRAINT FK_EL_Seller   FOREIGN KEY (seller_id)   REFERENCES Users(user_id),
    CONSTRAINT FK_EL_Category FOREIGN KEY (category_id) REFERENCES Equipment_Category(category_id),
    CONSTRAINT FK_EL_Reviewer FOREIGN KEY (reviewed_by) REFERENCES Users(user_id),
    CONSTRAINT CK_EL_Type   CHECK (listing_type IN ('SELL','TRADE','BUY')),
    CONSTRAINT CK_EL_Cond   CHECK (item_condition IN ('NEW','LIKE_NEW','GOOD','FAIR','FOR_PARTS')),
    CONSTRAINT CK_EL_Status CHECK (status IN
        ('PENDING_APPROVAL','PENDING_REVIEW','ACTIVE','REJECTED','SOLD','EXPIRED','HIDDEN')),
    CONSTRAINT CK_EL_Price  CHECK (price IS NULL OR price >= 0),
    CONSTRAINT CK_EL_PriceReq CHECK (listing_type = 'TRADE' OR price IS NOT NULL),
    CONSTRAINT CK_EL_Reject CHECK (status <> 'REJECTED' OR reject_reason IS NOT NULL)
);
CREATE UNIQUE INDEX UX_EL_Code ON Equipment_Listing(listing_code) WHERE listing_code IS NOT NULL;

-- 29. Listing_Image
CREATE TABLE Listing_Image (
    image_id   BIGINT IDENTITY(1,1) NOT NULL,
    listing_id BIGINT       NOT NULL,
    image_url  VARCHAR(500) NOT NULL,
    sort_order TINYINT      NOT NULL CONSTRAINT DF_LI_Sort DEFAULT 0,
    CONSTRAINT PK_Listing_Image PRIMARY KEY (image_id),
    CONSTRAINT FK_LI_Listing FOREIGN KEY (listing_id) REFERENCES Equipment_Listing(listing_id) ON DELETE CASCADE
);

-- 30. Listing_Favorite (N-N)
CREATE TABLE Listing_Favorite (
    user_id    INT          NOT NULL,
    listing_id BIGINT       NOT NULL,
    created_at DATETIME2(0) NOT NULL CONSTRAINT DF_LF_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Listing_Favorite PRIMARY KEY (user_id, listing_id),
    CONSTRAINT FK_LF_User    FOREIGN KEY (user_id)    REFERENCES Users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_LF_Listing FOREIGN KEY (listing_id) REFERENCES Equipment_Listing(listing_id)
);

-- 31. Marketplace_Transaction (theo dõi giao dịch; thanh toán ngoài hệ thống qua SĐT/Zalo)
CREATE TABLE Marketplace_Transaction (
    txn_id       BIGINT IDENTITY(1,1) NOT NULL,
    listing_id   BIGINT        NOT NULL,
    buyer_id     INT           NOT NULL,
    agreed_price DECIMAL(15,2) NULL,
    status       VARCHAR(15)   NOT NULL CONSTRAINT DF_MT_Status DEFAULT 'CONTACTED',
    created_at   DATETIME2(0)  NOT NULL CONSTRAINT DF_MT_Created DEFAULT SYSUTCDATETIME(),
    completed_at DATETIME2(0)  NULL,
    CONSTRAINT PK_Marketplace_Transaction PRIMARY KEY (txn_id),
    CONSTRAINT FK_MT_Listing FOREIGN KEY (listing_id) REFERENCES Equipment_Listing(listing_id),
    CONSTRAINT FK_MT_Buyer   FOREIGN KEY (buyer_id)   REFERENCES Users(user_id),
    CONSTRAINT CK_MT_Status  CHECK (status IN ('CONTACTED','AGREED','COMPLETED','CANCELLED')),
    CONSTRAINT CK_MT_Price   CHECK (agreed_price IS NULL OR agreed_price >= 0),
    CONSTRAINT CK_MT_Done    CHECK (status <> 'COMPLETED' OR completed_at IS NOT NULL)
);

-- 32. Review (đánh giá Lab hoặc Người bán)
CREATE TABLE Review (
    review_id    BIGINT IDENTITY(1,1) NOT NULL,
    review_code  VARCHAR(30)    NULL,     -- VD: rev-001
    reviewer_id  INT            NOT NULL,
    review_type  VARCHAR(10)    NOT NULL,
    order_id     BIGINT         NULL,     -- khi review_type = 'LAB'
    txn_id       BIGINT         NULL,     -- khi review_type = 'SELLER'
    service_name NVARCHAR(200)  NULL,     -- Tên gói dịch vụ đã đánh giá
    rating       TINYINT        NOT NULL,
    comment      NVARCHAR(2000) NULL,
    reply_text   NVARCHAR(1000) NULL,     -- Lab/Seller phản hồi
    replied_at   DATETIME2(0)   NULL,
    status       VARCHAR(10)    NOT NULL CONSTRAINT DF_Rv_Status DEFAULT 'VISIBLE',
    moderated_by INT            NULL,
    created_at   DATETIME2(0)   NOT NULL CONSTRAINT DF_Rv_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Review PRIMARY KEY (review_id),
    CONSTRAINT FK_Rv_Reviewer  FOREIGN KEY (reviewer_id)  REFERENCES Users(user_id),
    CONSTRAINT FK_Rv_Order     FOREIGN KEY (order_id)     REFERENCES Orders(order_id),
    CONSTRAINT FK_Rv_Txn       FOREIGN KEY (txn_id)       REFERENCES Marketplace_Transaction(txn_id),
    CONSTRAINT FK_Rv_Moderator FOREIGN KEY (moderated_by) REFERENCES Users(user_id),
    CONSTRAINT CK_Rv_Rating CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT CK_Rv_Type   CHECK (review_type IN ('LAB','SELLER')),
    CONSTRAINT CK_Rv_Status CHECK (status IN ('VISIBLE','HIDDEN','REMOVED')),
    -- Đúng 1 trong 2 đối tượng được đánh giá
    CONSTRAINT CK_Rv_Target CHECK (
        (review_type = 'LAB'    AND order_id IS NOT NULL AND txn_id IS NULL) OR
        (review_type = 'SELLER' AND txn_id   IS NOT NULL AND order_id IS NULL))
);
-- Mỗi đơn / mỗi giao dịch chỉ được đánh giá 1 lần
CREATE UNIQUE INDEX UX_Review_Order ON Review(order_id) WHERE order_id IS NOT NULL;
CREATE UNIQUE INDEX UX_Review_Txn   ON Review(txn_id)   WHERE txn_id   IS NOT NULL;
CREATE UNIQUE INDEX UX_Review_Code  ON Review(review_code) WHERE review_code IS NOT NULL;

-- 33. Post_Category
CREATE TABLE Post_Category (
    post_category_id INT IDENTITY(1,1) NOT NULL,
    name             NVARCHAR(100) NOT NULL,
    slug             VARCHAR(120)  NOT NULL,
    CONSTRAINT PK_Post_Category PRIMARY KEY (post_category_id),
    CONSTRAINT UQ_PostCat_Name UNIQUE (name),
    CONSTRAINT UQ_PostCat_Slug UNIQUE (slug)
);

-- 34. Post_Article (hậu kiểm bởi Admin)
CREATE TABLE Post_Article (
    post_id          BIGINT IDENTITY(1,1) NOT NULL,
    post_code        VARCHAR(30)    NULL,            -- VD: post-001
    author_id        INT            NOT NULL,
    post_category_id INT            NULL,
    post_type        VARCHAR(10)    NOT NULL,
    title            NVARCHAR(250)  NOT NULL,
    slug             VARCHAR(280)   NOT NULL,
    summary          NVARCHAR(500)  NULL,
    content          NVARCHAR(MAX)  NOT NULL,
    cover_image_url  VARCHAR(500)   NULL,
    likes_count      INT            NOT NULL CONSTRAINT DF_Post_Likes DEFAULT 0,
    comments_count   INT            NOT NULL CONSTRAINT DF_Post_Comments DEFAULT 0,
    report_count     INT            NOT NULL CONSTRAINT DF_Post_Reports DEFAULT 0,
    report_reason    NVARCHAR(500)  NULL,
    status           VARCHAR(15)    NOT NULL CONSTRAINT DF_Post_Status DEFAULT 'DRAFT',
    moderated_by     INT            NULL,
    moderation_note  NVARCHAR(500)  NULL,
    view_count       INT            NOT NULL CONSTRAINT DF_Post_Views DEFAULT 0,
    published_at     DATETIME2(0)   NULL,
    created_at       DATETIME2(0)   NOT NULL CONSTRAINT DF_Post_Created DEFAULT SYSUTCDATETIME(),
    updated_at       DATETIME2(0)   NOT NULL CONSTRAINT DF_Post_Updated DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Post_Article PRIMARY KEY (post_id),
    CONSTRAINT UQ_Post_Slug UNIQUE (slug),
    CONSTRAINT FK_Post_Author   FOREIGN KEY (author_id)        REFERENCES Users(user_id),
    CONSTRAINT FK_Post_Category FOREIGN KEY (post_category_id) REFERENCES Post_Category(post_category_id),
    CONSTRAINT FK_Post_Mod      FOREIGN KEY (moderated_by)     REFERENCES Users(user_id),
    CONSTRAINT CK_Post_Type   CHECK (post_type IN ('ARTICLE','TUTORIAL','REVIEW','QNA')),
    CONSTRAINT CK_Post_Status CHECK (status IN ('DRAFT','PUBLISHED','ACTIVE','REPORTED','HIDDEN','REMOVED')),
    CONSTRAINT CK_Post_Pub    CHECK (status <> 'PUBLISHED' OR published_at IS NOT NULL)
);
CREATE UNIQUE INDEX UX_Post_Code ON Post_Article(post_code) WHERE post_code IS NOT NULL;

-- 35. Post_Tag (N-N)
CREATE TABLE Post_Tag (
    post_id BIGINT NOT NULL,
    tag_id  INT    NOT NULL,
    CONSTRAINT PK_Post_Tag PRIMARY KEY (post_id, tag_id),
    CONSTRAINT FK_PostTag_Post FOREIGN KEY (post_id) REFERENCES Post_Article(post_id) ON DELETE CASCADE,
    CONSTRAINT FK_PostTag_Tag  FOREIGN KEY (tag_id)  REFERENCES Tag(tag_id) ON DELETE CASCADE
);

-- 36. Post_Comment (bình luận lồng nhau)
CREATE TABLE Post_Comment (
    comment_id        BIGINT IDENTITY(1,1) NOT NULL,
    comment_code      VARCHAR(30)    NULL,
    post_id           BIGINT         NOT NULL,
    user_id           INT            NOT NULL,
    parent_comment_id BIGINT         NULL,
    content           NVARCHAR(2000) NOT NULL,
    status            VARCHAR(10)    NOT NULL CONSTRAINT DF_PC_Status DEFAULT 'VISIBLE',
    created_at        DATETIME2(0)   NOT NULL CONSTRAINT DF_PC_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Post_Comment PRIMARY KEY (comment_id),
    CONSTRAINT FK_PC_Post   FOREIGN KEY (post_id)           REFERENCES Post_Article(post_id) ON DELETE CASCADE,
    CONSTRAINT FK_PC_User   FOREIGN KEY (user_id)           REFERENCES Users(user_id),
    CONSTRAINT FK_PC_Parent FOREIGN KEY (parent_comment_id) REFERENCES Post_Comment(comment_id),
    CONSTRAINT CK_PC_Status CHECK (status IN ('VISIBLE','HIDDEN','REMOVED'))
);

-- 37. Event (Workshop / Photowalk)
CREATE TABLE Event (
    event_id        INT IDENTITY(1,1) NOT NULL,
    event_code      VARCHAR(30)    NULL,            -- VD: evt-001
    host_id         INT            NOT NULL,
    event_type      VARCHAR(10)    NOT NULL,
    title           NVARCHAR(250)  NOT NULL,
    description     NVARCHAR(4000) NULL,
    venue           NVARCHAR(255)  NOT NULL,
    cover_image_url VARCHAR(500)   NULL,
    start_at        DATETIME2(0)   NOT NULL,
    end_at          DATETIME2(0)   NOT NULL,
    capacity        SMALLINT       NOT NULL,
    fee             DECIMAL(15,2)  NOT NULL CONSTRAINT DF_Event_Fee DEFAULT 0,
    status          VARCHAR(10)    NOT NULL CONSTRAINT DF_Event_Status DEFAULT 'DRAFT',
    created_at      DATETIME2(0)   NOT NULL CONSTRAINT DF_Event_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Event PRIMARY KEY (event_id),
    CONSTRAINT FK_Event_Host FOREIGN KEY (host_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Event_Type   CHECK (event_type IN ('WORKSHOP','PHOTOWALK')),
    CONSTRAINT CK_Event_Status CHECK (status IN ('DRAFT','OPEN','FULL','ONGOING','COMPLETED','CANCELLED')),
    CONSTRAINT CK_Event_Time   CHECK (end_at > start_at),
    CONSTRAINT CK_Event_Cap    CHECK (capacity > 0),
    CONSTRAINT CK_Event_Fee    CHECK (fee >= 0)
);
CREATE UNIQUE INDEX UX_Event_Code ON Event(event_code) WHERE event_code IS NOT NULL;

-- 38. Event_Registration (N-N)
CREATE TABLE Event_Registration (
    registration_id BIGINT IDENTITY(1,1) NOT NULL,
    event_id        INT          NOT NULL,
    user_id         INT          NOT NULL,
    status          VARCHAR(12)  NOT NULL CONSTRAINT DF_ER_Status DEFAULT 'REGISTERED',
    registered_at   DATETIME2(0) NOT NULL CONSTRAINT DF_ER_At DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Event_Registration PRIMARY KEY (registration_id),
    CONSTRAINT UQ_ER_EventUser UNIQUE (event_id, user_id),
    CONSTRAINT FK_ER_Event FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE,
    CONSTRAINT FK_ER_User  FOREIGN KEY (user_id)  REFERENCES Users(user_id),
    CONSTRAINT CK_ER_Status CHECK (status IN ('REGISTERED','CANCELLED','ATTENDED'))
);
GO

-- ===============================================
-- 04_indexes.sql
-- ===============================================
USE FilmLabPlatform;
GO
-- Tìm Lab theo vị trí / trạng thái / điểm đánh giá
CREATE INDEX IX_Lab_Search      ON Lab_Profile(approval_status, province, district) INCLUDE (lab_name, avg_rating);
CREATE INDEX IX_Lab_Owner       ON Lab_Profile(owner_id);
CREATE INDEX IX_SP_Lab_Active   ON Service_Package(lab_id, is_active) INCLUDE (service_type, price, est_processing_days);

-- Đơn hàng: khách xem lịch sử, Lab xem hàng đợi
CREATE INDEX IX_Orders_Customer ON Orders(customer_id, created_at DESC);
CREATE INDEX IX_Orders_Lab      ON Orders(lab_id, status, created_at DESC);
CREATE INDEX IX_OI_Order        ON Order_Item(order_id);
CREATE INDEX IX_OSH_Order       ON Order_Status_History(order_id, changed_at);
CREATE INDEX IX_Payment_Order   ON Payment(order_id, status);
CREATE INDEX IX_Ship_Partner    ON Shipment(partner_id, status);

-- Archive
CREATE INDEX IX_DFA_Owner       ON Digital_Film_Archive(owner_id, created_at DESC);
CREATE INDEX IX_AP_Archive      ON Archive_Photo(archive_id, is_deleted, sort_order);
CREATE INDEX IX_PM_Camera       ON Photo_Metadata(camera_model, film_stock_id);
CREATE INDEX IX_Scan_Item       ON Scan_File(order_item_id);

-- Marketplace: duyệt tin & lọc
CREATE INDEX IX_EL_Browse       ON Equipment_Listing(status, category_id, created_at DESC) INCLUDE (title, price, item_condition);
CREATE INDEX IX_EL_Seller       ON Equipment_Listing(seller_id, status);
CREATE INDEX IX_EL_Pending      ON Equipment_Listing(created_at) WHERE status = 'PENDING_APPROVAL';  -- hàng đợi tiền kiểm

-- Cộng đồng
CREATE INDEX IX_Post_Feed       ON Post_Article(status, published_at DESC) INCLUDE (title, author_id);
CREATE INDEX IX_PC_Post         ON Post_Comment(post_id, created_at);
CREATE INDEX IX_Event_Upcoming  ON Event(status, start_at);

-- Khiếu nại, thông báo
CREATE INDEX IX_Disp_Status     ON Dispute_Complaint(status, created_at);
CREATE INDEX IX_Disp_Order      ON Dispute_Complaint(order_id);
CREATE INDEX IX_Notif_User      ON Notification(user_id, is_read, created_at DESC);
CREATE INDEX IX_Audit_Entity    ON Audit_Log(entity_name, entity_id, created_at DESC);
GO

-- ===============================================
-- 05_seed.sql
-- ===============================================
USE FilmLabPlatform;
GO

-- =====================================================================
-- 1. SEED DANH MỤC HỆ THỐNG CỐ ĐỊNH
-- =====================================================================
INSERT INTO Roles (role_id, role_code, role_name, description) VALUES
(1, 'CUSTOMER',         N'Khách hàng / Nhiếp ảnh gia', N'Đặt dịch vụ, quản lý Archive, mua bán thiết bị'),
(2, 'LAB_OWNER',        N'Chủ Film Lab',               N'Quản lý dịch vụ, đơn hàng, upload file scan'),
(3, 'EXPERT',           N'Chuyên gia nhiếp ảnh',       N'Đăng bài, tổ chức workshop/photowalk'),
(4, 'DELIVERY_PARTNER', N'Đối tác vận chuyển',         N'Nhận đơn pickup, giao nhận film'),
(5, 'ADMIN',            N'Quản trị hệ thống',          N'Duyệt lab, kiểm duyệt, xử lý khiếu nại');

INSERT INTO Film_Format (name) VALUES ('135'),('35mm'),('120'),('220'),('110'),('APS'),('4x5'),('8x10');

INSERT INTO Process_Type (code, name) VALUES
('C41',  N'C-41 (Phim màu âm bản)'),
('E6',   N'E-6 (Phim slide)'),
('BW',   N'Đen trắng (B&W)'),
('ECN2', N'ECN-2 (Phim điện ảnh)'),
('XPRO', N'Cross-process');

INSERT INTO Film_Stock (brand, name, iso, format_id, film_type) VALUES
(N'Kodak',    N'Kodak Portra 400',     400, 1, 'COLOR_NEG'),
(N'Fujifilm', N'Fujifilm Pro 400H',    400, 1, 'COLOR_NEG'),
(N'Ilford',   N'Ilford HP5 Plus 400',  400, 1, 'BW'),
(N'Kodak',    N'Kodak Ektar 100',      100, 3, 'COLOR_NEG'),
(N'Kodak',    N'Kodak Gold 200',       200, 1, 'COLOR_NEG'),
(N'Kodak',    N'Kodak Vision3 500T',   500, 1, 'CINE');

INSERT INTO Equipment_Category (parent_id, name) VALUES
(NULL, N'Máy ảnh film'),
(NULL, N'Máy ảnh Rangefinder'),
(NULL, N'Máy ảnh SLR cơ khí'),
(NULL, N'Ống kính'),
(NULL, N'Film (phim)'),
(NULL, N'Phụ kiện'),
(NULL, N'Thiết bị phòng tối / Scanner');

INSERT INTO Post_Category (name, slug) VALUES
(N'Kỹ thuật chụp',      'ky-thuat-chup'),
(N'Hướng dẫn kỹ thuật', 'huong-dan-ky-thuat'),
(N'Review thiết bị',    'review-thiet-bi'),
(N'Review Film Lab',    'review-film-lab'),
(N'Hỏi đáp cộng đồng',  'hoi-dap'),
(N'Spam',               'spam');

INSERT INTO System_Config (config_key, config_value, description) VALUES
('PLATFORM_FEE_PERCENT',        '10', N'Phí nền tảng thu trên mỗi đơn (%)'),
('NEGOTIATION_DEADLINE_DAYS',   '3',  N'Số ngày Khách & Lab tự thương lượng trước khi chuyển Admin'),
('LISTING_EXPIRE_DAYS',         '30', N'Số ngày tin Marketplace tự hết hạn'),
('PAYMENT_TIMEOUT_MINUTES',     '15', N'Thời gian chờ thanh toán trước khi tự hủy đơn'),
('ARCHIVE_FREE_STORAGE_GB',     '5',  N'Dung lượng Archive miễn phí / khách hàng');

-- =====================================================================
-- 2. SEED NGƯỜI DÙNG & PHÂN QUYỀN (Tất cả dữ liệu từ Backend & Frontend)
-- =====================================================================
SET IDENTITY_INSERT Users ON;
INSERT INTO Users (user_id, user_code, email, phone, password_hash, full_name, avatar_url, address_text, bio, status, email_verified, locked_reason, locked_by, locked_at) VALUES
(1,  'usr-000',     N'admin@minilab.vn',       '0900000000', 'password123', N'Quản trị viên Hệ thống (System Admin)', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Văn phòng MiniLab HQ, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(2,  'usr-000b',    N'admin.tuan@minilab.vn',  '0900000001', 'password123', N'Lê Tuấn (Tổng Quản Trị MiniLab)',       'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Văn phòng MiniLab HQ, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(3,  'usr-002',     N'croplab@minilab.vn',     '0987654321', 'password123', N'CropLab Hà Nội (Lab Quản Trị)',         'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(4,  'usr-002b',    N'saigon.lab@minilab.vn',  '0987654322', 'password123', N'LLab Film Sài Gòn (Lab Manager)',       'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'40/2 Phan Văn Trị, Phường 12, Bình Thạnh, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(5,  'usr-001',     N'khachhang@minilab.vn',   '0912345678', 'password123', N'Nguyễn Hoàng Anh',                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'123 Phố Huế, Hai Bà Trưng, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(6,  'usr-003',     N'chuyengia@film.vn',      '0909123456', 'password123', N'Lê Quang Huy',                          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', N'Tây Hồ, Hà Nội', N'Nhiếp ảnh gia phim tài liệu với 12 năm kinh nghiệm chụp medium format và tráng film thủ công.', 'ACTIVE', 1, NULL, NULL, NULL),
(7,  'usr-005',     N'contact@nadarlab.com',   '0918776655', 'password123', N'Nadar Darkroom & Lab Owner',            'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=200', N'15 Tràng Tiền, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(8,  'usr-008',     N'trong.tran@minilab.vn',  '0999888777', 'password123', N'Trần Đình Trọng',                     'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Hà Nội', NULL, 'LOCKED', 1, N'Phát tán link spam tài chính cá độ trái phép trên cộng đồng', 1, '2026-03-02T11:00:00'),
(9,  'usr-901',     N'retro.hanoi@gmail.com',  '0945667788', 'password123', N'Phạm Gia Huy',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Số 22 ngõ Huyện, Hàng Trống, Hoàn Kiếm, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(10, 'usr-902',     N'analog.saigon@gmail.com','0919334455', 'password123', N'Võ Thành Nam',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'88 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(11, 'ADM-HN-884',  N'tuan.vu@minilab.vn',     '0988776655', 'password123', N'Vũ Minh Tuấn',                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(12, 'USR-DN-099',  N'bach.hoang@gmail.com',   '0977123123', 'password123', N'Hoàng Văn Bách',                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Đà Nẵng', NULL, 'LOCKED', 1, N'Vi phạm chính sách thanh lý thiết bị & lừa đảo đặt cọc', 1, '2026-02-20T10:00:00'),
(13, 'APP-EXP-301', N'khoa.nguyen@photo.vn',   '0903445566', 'password123', N'Nguyễn Trọng Khoa',                     'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150', N'Quận 3, TP.HCM', N'12 năm chụp ảnh tạp chí thời trang bằng máy Medium Format Hasselblad 500C/M. Đã xuất bản 2 photobook cá nhân.', 'ACTIVE', 1, NULL, NULL, NULL),
(14, 'usr-014',     N'nam.le@gmail.com',       '0913222333', 'password123', N'Lê Hoàng Nam',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Quận 1, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(15, 'usr-015',     N'thutrang.pham@gmail.com','0914333444', 'password123', N'Phạm Thu Trang',                         'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150', N'Đống Đa, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(16, 'usr-016',     N'khoi.pham@gmail.com',    '0915444555', 'password123', N'Phạm Hoàng Khôi',                       'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Cầu Giấy, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(17, 'usr-017',     N'nghia.do@gmail.com',     '0977889900', 'password123', N'Đỗ Hữu Nghĩa',                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150', N'Đống Đa, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(18, 'usr-018',     N'songhan.lab@minilab.vn', '0905112233', 'password123', N'Sông Hàn Film Studio Owner',            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Hải Châu, Đà Nẵng', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(19, 'usr-019',     N'tayho.lab@minilab.vn',   '0904223344', 'password123', N'Tây Hồ Analog Master Owner',            'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Tây Hồ, Hà Nội', NULL, 'ACTIVE', 1, NULL, NULL, NULL),
(20, 'usr-020',     N'cholon.lab@minilab.vn',  '0908334455', 'password123', N'Chợ Lớn Film Lab Owner',                'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150', N'Quận 5, TP.HCM', NULL, 'ACTIVE', 1, NULL, NULL, NULL);
SET IDENTITY_INSERT Users OFF;

INSERT INTO User_Roles (user_id, role_id) VALUES
(1, 5),  -- usr-000: ADMIN
(2, 5),  -- usr-000b: ADMIN
(3, 2),  -- usr-002: LAB_OWNER
(4, 2),  -- usr-002b: LAB_OWNER
(5, 1),  -- usr-001: CUSTOMER
(6, 3),  -- usr-003: EXPERT
(6, 1),  -- usr-003: CUSTOMER
(7, 2),  -- usr-005: LAB_OWNER
(8, 1),  -- usr-008: CUSTOMER
(9, 2),  -- usr-901: LAB_OWNER
(10, 2), -- usr-902: LAB_OWNER
(11, 5), -- ADM-HN-884: ADMIN
(12, 1), -- USR-DN-099: CUSTOMER
(13, 3), -- APP-EXP-301: EXPERT
(13, 1), -- APP-EXP-301: CUSTOMER
(14, 1), -- usr-014: CUSTOMER
(15, 1), -- usr-015: CUSTOMER
(16, 1), -- usr-016: CUSTOMER
(17, 1), -- usr-017: CUSTOMER
(18, 2), -- usr-018: LAB_OWNER
(19, 2), -- usr-019: LAB_OWNER
(20, 2); -- usr-020: LAB_OWNER

INSERT INTO Expert_Profile (user_id, bio, specialties, portfolio_url, years_experience, verification_status, verified_by) VALUES
(6,  N'Nhiếp ảnh gia phim tài liệu với 12 năm kinh nghiệm chụp medium format và tráng film thủ công.', N'Medium Format, B&W Darkroom', 'https://behance.net/quanghuy-analog', 12, 'VERIFIED', 1),
(13, N'12 năm chụp ảnh tạp chí thời trang bằng máy Medium Format Hasselblad 500C/M. Đã xuất bản 2 photobook cá nhân.', N'Chân dung ánh sáng tự nhiên, Phim dương bản Slide (E-6), Phóng ảnh phòng tối truyền thống', 'https://behance.net/khoa-analog-archive', 12, 'PENDING', NULL);

-- =====================================================================
-- 3. SEED FILM LABS & GÓI DỊCH VỤ
-- =====================================================================
SET IDENTITY_INSERT Lab_Profile ON;
INSERT INTO Lab_Profile (
    lab_id, lab_code, owner_id, lab_name, slug, tagline, description, phone, email,
    province, district, street_address, business_license_no, logo_url, cover_url,
    turnaround_hours, price_range, scanner_models, supported_processes, supports_pickup,
    avg_rating, review_count, approval_status, inspection_note, reviewed_by, reviewed_at
) VALUES
(1, 'lab-001', 3, N'CropLab Hà Nội', 'croplab-ha-noi',
    N'Chuyên gia tráng & scan chất lượng cao từ năm 2014',
    N'CropLab cung cấp dịch vụ tráng và scan phim màu C-41, đen trắng B&W thủ công với hóa chất chuẩn Kodak & Ilford. Scan máy Noritsu HS-1800 cho độ phân giải sắc nét và dải màu trung thực.',
    '0904567890', N'hanoi@croplab.vn', N'Hà Nội', N'Tây Hồ', N'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ, Hà Nội',
    'DKKD-0101234567', 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    12, N'45.000đ - 120.000đ', N'["Noritsu HS-1800","Fuji Frontier SP-3000"]', N'["C-41","B&W","ECN-2","E-6 Slide"]', 1,
    4.90, 328, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(2, 'lab-002', 4, N'LLab Film Sài Gòn', 'llab-film-sai-gon',
    N'Màu sắc ấm áp, tốc độ siêu nhanh trong ngày',
    N'LLab là điểm đến quen thuộc của cộng đồng film Sài Gòn với phong cách chỉnh màu Frontier tươi tắn đặc trưng và dịch vụ nhận trả film tận nơi.',
    '0938112233', N'saigon@llab.vn', N'TP.HCM', N'Bình Thạnh', N'40/2 Phan Văn Trị, Phường 12, Bình Thạnh, TP.HCM',
    'DKKD-0301234568', 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=200', 'https://images.unsplash.com/photo-1452784444945-3f422708fe5e?w=800',
    8, N'50.000đ - 110.000đ', N'["Fuji Frontier SP-3000"]', N'["C-41","B&W","ECN-2"]', 1,
    4.80, 512, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(3, 'lab-003', 7, N'Nadar Darkroom & Lab', 'nadar-darkroom-lab',
    N'Phòng tối tráng phim Fine-Art & In ấn thủ công',
    N'Chuyên dòng phim đen trắng nghệ thuật, tráng tay kiểm soát từng vùng sáng tối và scan độ phân giải cực đại TIFF 16-bit.',
    '0918776655', N'contact@nadarlab.com', N'Hà Nội', N'Hoàn Kiếm', N'15 Tràng Tiền, Hoàn Kiếm, Hà Nội',
    'DKKD-0101234569', 'https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=200', 'https://images.unsplash.com/photo-1471341971476-ae15ff5dd4ea?w=800',
    24, N'70.000đ - 250.000đ', N'["Hasselblad Flextight X5","Noritsu HS-1800"]', N'["B&W Thủ công","C-41 Pro","E-6"]', 1,
    5.00, 145, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(4, 'app-lab-901', 9, N'Retro Hanoi Darkroom', 'retro-hanoi-darkroom',
    N'Hồ sơ đăng ký mở tiệm Film Lab',
    N'Đã nộp đầy đủ giấy phép kinh doanh hóa chất tráng ảnh và hợp đồng xử lý chất thải môi trường.',
    '0945667788', N'retro.hanoi@gmail.com', N'Hà Nội', N'Hoàn Kiếm', N'Số 22 ngõ Huyện, Hàng Trống, Hoàn Kiếm, Hà Nội',
    'DKKD-0109923481', NULL, NULL,
    12, N'50.000đ - 100.000đ', N'["Noritsu LS-600","Epson V850 Pro"]', N'["C-41","B&W"]', 0,
    0, 0, 'PENDING', N'Đã nộp đầy đủ giấy phép kinh doanh hóa chất tráng ảnh và hợp đồng xử lý chất thải môi trường.', NULL, NULL),
(5, 'app-lab-902', 10, N'Analog Saigon Space', 'analog-saigon-space',
    N'Hồ sơ đăng ký mở tiệm Film Lab',
    N'Hồ sơ chờ xác minh máy scan thực tế và phòng tối sấy buồng kín.',
    '0919334455', N'analog.saigon@gmail.com', N'TP.HCM', N'Quận 1', N'88 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM',
    'DKKD-0318829102', NULL, NULL,
    12, N'50.000đ - 100.000đ', N'["Fuji Frontier SP-3000"]', N'["C-41","ECN-2 Cine"]', 0,
    0, 0, 'PENDING', N'Hồ sơ chờ xác minh máy scan thực tế và phòng tối sấy buồng kín.', NULL, NULL),
(6, 'lab-004', 18, N'Sông Hàn Film Studio', 'song-han-film-studio',
    N'Không gian tráng và lưu trữ ảnh film miền Trung',
    N'Phục vụ cộng đồng nhiếp ảnh film Đà Nẵng - Hội An với quy trình C-41 và ECN-2 tiêu chuẩn.',
    '0905112233', N'songhan.lab@minilab.vn', N'Đà Nẵng', N'Hải Châu', N'112 Bạch Đằng, Hải Châu, Đà Nẵng',
    'DKKD-0401122334', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=200', 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    16, N'45.000đ - 95.000đ', N'["Noritsu HS-1800"]', N'["C-41","ECN-2"]', 1,
    4.70, 96, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(7, 'lab-005', 19, N'Tây Hồ Analog Master', 'tay-ho-analog-master',
    N'Chuyên trị film slide E-6 và B&W thủ công',
    N'Phòng lab ven hồ Tây chuyên xử lý các dòng phim dương bản và medium format.',
    '0904223344', N'tayho.lab@minilab.vn', N'Hà Nội', N'Tây Hồ', N'45 Quảng An, Tây Hồ, Hà Nội',
    'DKKD-0105566778', 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200', 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=800',
    18, N'55.000đ - 150.000đ', N'["Fuji Frontier SP-3000","Epson V850 Pro"]', N'["C-41","B&W","E-6"]', 1,
    4.60, 82, 'APPROVED', NULL, 1, SYSUTCDATETIME()),
(8, 'app-lab-903', 20, N'Chợ Lớn Film Lab', 'cho-lon-film-lab',
    N'Hồ sơ đăng ký mở tiệm Film Lab khu vực Quận 5',
    N'Đang chờ kiểm tra hệ thống xử lý hóa chất tráng rửa định kỳ.',
    '0908334455', N'cholon.lab@minilab.vn', N'TP.HCM', N'Quận 5', N'210 Trần Hưng Đạo, Quận 5, TP.HCM',
    'DKKD-0319988776', NULL, NULL,
    12, N'45.000đ - 100.000đ', N'["Noritsu LS-600"]', N'["C-41","B&W"]', 0,
    0, 0, 'PENDING', N'Đang chờ kiểm tra hệ thống xử lý hóa chất tráng rửa định kỳ.', NULL, NULL);
SET IDENTITY_INSERT Lab_Profile OFF;

INSERT INTO Lab_Film_Format (lab_id, format_id) VALUES
(1, 1), (1, 3), (1, 4), (1, 7),
(2, 1), (2, 3),
(3, 1), (3, 3), (3, 7), (3, 8),
(6, 1), (6, 3),
(7, 1), (7, 3);

SET IDENTITY_INSERT Service_Package ON;
INSERT INTO Service_Package (
    package_id, package_code, lab_id, service_type, name, description,
    format_id, process_type_id, scan_quality, scan_resolution, output_format,
    price, est_processing_days, estimated_hours, is_active
) VALUES
-- Lab 1: CropLab Hà Nội
(1, 'pkg-001', 1, 'DEVELOP_SCAN', N'Tráng & Scan 135 Color (C-41) - Chuẩn M',
    N'Gói tráng và scan tiêu chuẩn cho cuộn film 35mm màu phổ thông (Kodak Gold, ColorPlus, Fuji C200, UltraMax).',
    1, 1, 'STANDARD', N'M (3000x2000px)', 'JPEG', 50000, 1, 12, 1),
(2, 'pkg-002', 1, 'DEVELOP_SCAN', N'Tráng & Scan 135 Color (C-41) - Scan Cao Cấp L (TIFF/JPG)',
    N'Độ phân giải lớn nhất từ Noritsu HS-1800, lưu giữ toàn bộ chi tiết hạt grain và màu sắc chân thực.',
    1, 1, 'PRO', N'L (6000x4000px TIFF)', 'TIFF', 85000, 1, 16, 1),
(3, 'pkg-003', 1, 'DEVELOP_SCAN', N'Tráng & Scan 135 B&W (Đen Trắng Thủ Công)',
    N'Tráng với thuốc Kodak D-76 hoặc Ilford ID-11, kiểm soát độ tương phản và chi tiết vùng tối.',
    1, 3, 'STANDARD', N'M (3000x2000px)', 'JPEG', 65000, 1, 24, 1),
(4, 'pkg-004', 1, 'DEVELOP_SCAN', N'Tráng & Scan Cine Film ECN-2 (Tẩy than)',
    N'Xử lý cuộn film điện ảnh Kodak Vision3 (50D, 250D, 500T), tẩy than remjet sạch sẽ.',
    1, 4, 'STANDARD', N'M (3000x2000px)', 'JPEG', 75000, 1, 24, 1),
(5, 'pkg-005', 1, 'DEVELOP_SCAN', N'Tráng & Scan Medium Format 120 (C-41)',
    N'Dành cho máy ảnh khổ vuông 6x6, 6x7, 6x4.5 (Hasselblad, Rolleiflex, Pentax 67).',
    3, 1, 'HIGH', N'L (4800x4800px)', 'JPEG', 80000, 1, 12, 1),
-- Lab 2: LLab Film Sài Gòn
(6, 'pkg-006', 2, 'DEVELOP_SCAN', N'Gói C-41 Siêu Tốc 8 Giờ (Fuji Frontier SP-3000)',
    N'Gói tráng và scan màu chất ảnh Frontier SP-3000 ấm áp, trả file trong 8 giờ tại LLab Film Sài Gòn.',
    1, 1, 'STANDARD', N'M (3000x2000px)', 'JPEG', 60000, 1, 8, 1),
(8, 'pkg-201', 2, 'DEVELOP_SCAN', N'Gói C-41 Hi-Res Medium Format 120 (Noritsu LS-600)',
    N'Tráng máy Fuji FP-363SC và scan khổ 120 (6x6, 6x7) sắc nét độ phân giải cao.',
    3, 1, 'HIGH', N'L (4800x4800px 16-bit)', 'TIFF', 95000, 1, 12, 1),
(9, 'pkg-202', 2, 'DEVELOP_SCAN', N'Gói Cine ECN-2 Sài Gòn (Vision3 250D/500T)',
    N'Quy trình tẩy than Remjet chuẩn điện ảnh bằng hóa chất Bellini, xuất profile màu Log/Rec709.',
    1, 4, 'STANDARD', N'M (3000x2000px Log)', 'JPEG', 85000, 1, 16, 1),
(10, 'pkg-203', 2, 'DEVELOP_SCAN', N'Gói B&W Street Contrast (Kodak D-76 1:1)',
    N'Tráng đen trắng kéo sáng tương phản cao cho ảnh đường phố, scan Noritsu LS-600.',
    1, 3, 'STANDARD', N'M (3000x2000px)', 'JPEG', 75000, 1, 16, 1),
-- Lab 3: Nadar Darkroom & Lab
(7, 'pkg-007', 3, 'DEVELOP_SCAN', N'Gói B&W Thủ Công Fine-Art (Hasselblad Flextight X5)',
    N'Tráng tay phòng tối Nadar Darkroom với thuốc Microphen/Pyrocat và scan Hasselblad Flextight X5 16-bit TIFF.',
    3, 3, 'PRO', N'XL (Hasselblad X5 TIFF 16-bit)', 'TIFF', 180000, 1, 24, 1),
(11, 'pkg-301', 3, 'DEVELOP_SCAN', N'Gói Tráng Tay B&W 135 (Ilford Pyrocat / XTOL)',
    N'Kiểm soát nhiệt độ chiller 20.0°C ± 0.05°C, độ mịn hạt tối đa cho phim đen trắng 35mm.',
    1, 3, 'HIGH', N'L (4000x6000px TIFF)', 'TIFF', 110000, 1, 24, 1),
(12, 'pkg-302', 3, 'DEVELOP_SCAN', N'Gói C-41 Pro One-Shot Archival (Noritsu HS-1800)',
    N'Hóa chất Kodak Flexicolor pha mới dùng 1 lần (One-Shot) không tái sử dụng cho màu sắc chuẩn mực.',
    1, 1, 'PRO', N'L (6000x4000px 16-bit)', 'TIFF', 120000, 1, 24, 1),
(13, 'pkg-303', 3, 'DEVELOP_SCAN', N'Gói Slide Dương Bản E-6 Exhibition (Flextight X5)',
    N'Tráng quy trình 6 bước Fuji Hunt Chrome E-6 cho phim dương bản Provia/Velvia.',
    3, 2, 'PRO', N'XL (5000 DPI Master TIFF)', 'TIFF', 160000, 2, 36, 1),
(14, 'pkg-304', 3, 'DEVELOP_SCAN', N'Gói Large Format 4x5 Sheet Film (B&W / C-41)',
    N'Tráng phim tấm khổ lớn 4x5 bằng trống Jobo Expert 3010 & scan drum ảo Hasselblad X5.',
    7, 3, 'PRO', N'XL (Hasselblad X5 Drum)', 'TIFF', 195000, 2, 36, 1);
SET IDENTITY_INSERT Service_Package OFF;

-- =====================================================================
-- 4. SEED ĐƠN HÀNG, CUỘN FILM, TIẾN ĐỘ & THANH TOÁN (CÔ LẬP DỮ LIỆU THEO TỪNG LAB)
-- =====================================================================
SET IDENTITY_INSERT Orders ON;
INSERT INTO Orders (
    order_id, order_code, customer_id, lab_id, status, kanban_column,
    receive_method, return_method, pickup_address, payment_status, payment_method,
    subtotal, total_amount, sla_deadline, created_at
) VALUES
-- Lab 1: CropLab Hà Nội (Khách: Nguyễn Hoàng Anh [5], Phạm Thu Trang [15])
(1, 'ORD-2026-8801', 5,  1, 'READY_FOR_DOWNLOAD', 'READY',      'PICKUP',      'DIGITAL_ONLY', N'123 Phố Huế, Hai Bà Trưng, Hà Nội', 'PAID', 'MOMO',          135000, 135000, '2026-03-02T12:00:00', '2026-03-01T09:30:00'),
(2, 'ORD-2026-8802', 5,  1, 'PROCESSING',         'DEVELOPING', 'DROP_AT_LAB', 'DIGITAL_ONLY', N'123 Phố Huế, Hai Bà Trưng, Hà Nội', 'PAID', 'BANK_TRANSFER', 65000,  65000,  '2026-03-03T18:00:00', '2026-03-02T14:10:00'),
(7, 'ORD-2026-8835', 15, 1, 'PROCESSING',         'SCANNING',   'DROP_AT_LAB', 'DIGITAL_ONLY', N'Đống Đa, Hà Nội',                    'PAID', 'BANK_TRANSFER', 75000,  75000,  '2026-03-02T20:00:00', '2026-03-01T15:00:00'),
(8, 'ORD-2026-8819', 5,  1, 'COMPLETED',          'READY',      'PICKUP',      'DIGITAL_ONLY', N'123 Phố Huế, Hai Bà Trưng, Hà Nội',  'PAID', 'MOMO',          170000, 170000, '2026-03-02T18:00:00', '2026-03-01T11:20:00'),
-- Lab 2: LLab Film Sài Gòn (Khách: Lê Hoàng Nam [14], Đỗ Hữu Nghĩa [17])
(3, 'ORD-2026-8803', 14, 2, 'RECEIVED',           'QUEUE',      'PICKUP',      'DIGITAL_ONLY', N'Quận 1, TP.HCM',                     'PAID', 'VNPAY',         60000,  60000,  '2026-03-03T20:00:00', '2026-03-03T08:00:00'),
(4, 'ORD-2026-8841', 14, 2, 'READY_FOR_DOWNLOAD', 'READY',      'PICKUP',      'DIGITAL_ONLY', N'Quận 1, TP.HCM',                     'PAID', 'MOMO',          120000, 120000, '2026-03-04T18:00:00', '2026-03-03T09:15:00'),
(5, 'ORD-2026-8839', 17, 2, 'PROCESSING',         'DEVELOPING', 'DROP_AT_LAB', 'DIGITAL_ONLY', N'Quận 3, TP.HCM',                     'PAID', 'VNPAY',         75000,  75000,  '2026-03-04T15:00:00', '2026-03-03T07:30:00'),
-- Lab 3: Nadar Darkroom & Lab (Khách: Lê Quang Huy [6], Phạm Hoàng Khôi [16])
(6, 'ORD-2026-8838', 6,  3, 'READY_FOR_DOWNLOAD', 'READY',      'PICKUP',      'DIGITAL_ONLY', N'Tây Hồ, Hà Nội',                    'PAID', 'MOMO',          180000, 180000, '2026-03-04T12:00:00', '2026-03-02T16:45:00'),
(9, 'ORD-2026-8845', 16, 3, 'PROCESSING',         'QC',         'DROP_AT_LAB', 'DIGITAL_ONLY', N'Cầu Giấy, Hà Nội',                  'PAID', 'BANK_TRANSFER', 160000, 160000, '2026-03-05T12:00:00', '2026-03-03T10:30:00');
SET IDENTITY_INSERT Orders OFF;

SET IDENTITY_INSERT Order_Item ON;
INSERT INTO Order_Item (
    order_item_id, item_code, order_id, package_id, film_stock_id, film_name, roll_code,
    quantity, unit_price, line_total, push_pull, cut_negatives, status
) VALUES
(1,  'item-101', 1, 1,  1, N'Kodak Portra 400',     'ROLL-PORTRA400-01', 1, 50000,  50000,  N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(2,  'item-102', 1, 2,  2, N'Fujifilm Pro 400H',    'ROLL-FUJI400-02',   1, 85000,  85000,  N'+1 Stop (Push)',           N'Để nguyên cuộn không cắt', 'DONE'),
(3,  'item-103', 2, 3,  3, N'Ilford HP5 Plus 400',  'ROLL-ILFORD-03',    1, 65000,  65000,  N'+2 Stops (Push ISO 1600)', N'Cắt 6 frames/dải',         'PROCESSING'),
(4,  'item-104', 3, 6,  4, N'Kodak Ektar 100',      'ROLL-EKTAR-04',     1, 60000,  60000,  N'Normal',                   N'Cắt 4 frames/dải',         'RECEIVED'),
(5,  'item-105', 4, 6,  5, N'Kodak Gold 200 (x2)',  'ROLL-GOLD200-05',   2, 60000,  120000, N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(6,  'item-106', 5, 10, 3, N'Ilford HP5 Plus 400',  'ROLL-ILFORD-06',    1, 75000,  75000,  N'+1 Stop (Push ISO 800)',   N'Cắt 6 frames/dải',         'PROCESSING'),
(7,  'item-107', 6, 7,  3, N'Ilford Delta 100',     'ROLL-DELTA100-07',  1, 180000, 180000, N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(8,  'item-108', 7, 4,  6, N'Kodak Vision3 500T',   'ROLL-VISION3-08',   1, 75000,  75000,  N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'PROCESSING'),
(9,  'item-109', 8, 2,  1, N'Kodak Portra 400 (x2)','ROLL-PORTRA400-09', 2, 85000,  170000, N'Normal (Box speed)',       N'Cắt 6 frames/dải',         'DONE'),
(10, 'item-110', 9, 13, 2, N'Fuji Provia 100F',     'ROLL-PROVIA-10',    1, 160000, 160000, N'Normal (Box speed)',       N'Để nguyên cuộn không cắt', 'PROCESSING');
SET IDENTITY_INSERT Order_Item OFF;

INSERT INTO Payment (order_id, gateway, txn_ref, amount, status, paid_at) VALUES
(1, 'MOMO',          'TXN-ORD-2026-8801', 135000, 'SUCCESS', '2026-03-01T09:30:00'),
(2, 'BANK_TRANSFER', 'TXN-ORD-2026-8802', 65000,  'SUCCESS', '2026-03-02T14:10:00'),
(3, 'VNPAY',         'TXN-ORD-2026-8803', 60000,  'SUCCESS', '2026-03-03T08:00:00'),
(4, 'MOMO',          'TXN-ORD-2026-8841', 120000, 'SUCCESS', '2026-03-03T09:15:00'),
(5, 'VNPAY',         'TXN-ORD-2026-8839', 75000,  'SUCCESS', '2026-03-03T07:30:00'),
(6, 'MOMO',          'TXN-ORD-2026-8838', 180000, 'SUCCESS', '2026-03-02T16:45:00'),
(7, 'BANK_TRANSFER', 'TXN-ORD-2026-8835', 75000,  'SUCCESS', '2026-03-01T15:00:00'),
(8, 'MOMO',          'TXN-ORD-2026-8819', 170000, 'SUCCESS', '2026-03-01T11:20:00'),
(9, 'BANK_TRANSFER', 'TXN-ORD-2026-8845', 160000, 'SUCCESS', '2026-03-03T10:30:00');

-- =====================================================================
-- 5. SEED DIGITAL FILM ARCHIVE & METADATA
-- =====================================================================
SET IDENTITY_INSERT Digital_Film_Archive ON;
INSERT INTO Digital_Film_Archive (archive_id, owner_id, order_item_id, title, film_stock_id, visibility) VALUES
(1, 5, 1, N'Mùa thu Hà Nội 2026 (ORD-2026-8801)', 1, 'PRIVATE'),
(2, 5, 9, N'Phố cổ & Cà phê sáng (ORD-2026-8819)', 1, 'PRIVATE');
SET IDENTITY_INSERT Digital_Film_Archive OFF;

SET IDENTITY_INSERT Archive_Photo ON;
INSERT INTO Archive_Photo (
    photo_id, photo_code, archive_id, roll_code, title, file_name,
    storage_key, thumbnail_key, mime_type, size_bytes, width_px, height_px, is_favorite, uploaded_at
) VALUES
(1, 'pho-001', 1, 'ROLL-PORTRA400-01', N'Nắng chiều Phố Cổ Hà Nội (ORD-2026-8801)', N'pho_001.tiff',
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=1200',
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=400',
    'image/tiff', 19293798, 6048, 4032, 1, '2026-03-01T17:15:00'),
(2, 'pho-002', 1, 'ROLL-PORTRA400-01', N'Gánh hoa bên góc đường Phan Đình Phùng (ORD-2026-8801)', N'pho_002.tiff',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
    'image/tiff', 17616076, 6048, 4032, 1, '2026-03-01T17:15:00'),
(3, 'pho-003', 2, 'ROLL-PORTRA400-09', N'Ban công phố cổ Phan Huy Chú (ORD-2026-8819)', N'pho_003.tiff',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=1200',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400',
    'image/tiff', 18454937, 6048, 4032, 1, '2026-03-01T19:00:00');
SET IDENTITY_INSERT Archive_Photo OFF;

INSERT INTO Photo_Metadata (
    photo_id, camera_brand, camera_model, lens, focal_length, film_stock_id,
    iso, aperture, shutter_speed, process_type_id, scan_device, notes
) VALUES
(1, N'Leica', N'Leica M6 Classic', N'Summicron 35mm f/2 ASPH', '35mm', 1, 400, 2.8, '1/250s', 1, N'C-41 Noritsu HS-1800', N'CropLab Hà Nội | 18.4 MB TIFF'),
(2, N'Leica', N'Leica M6 Classic', N'Summicron 35mm f/2 ASPH', '35mm', 1, 400, 4.0, '1/500s', 1, N'C-41 Noritsu HS-1800', N'CropLab Hà Nội | 16.8 MB TIFF'),
(3, N'Canon', N'Canon AE-1 Program', N'FD 50mm f/1.4',         '50mm', 1, 400, 2.8, '1/250s', 1, N'C-41 Noritsu HS-1800', N'CropLab Hà Nội | 17.6 MB TIFF');

-- =====================================================================
-- 6. SEED MARKETPLACE, CỘNG ĐỒNG, SỰ KIỆN, KHIẾU NẠI, ĐÁNH GIÁ & AUDIT LOG
-- =====================================================================
SET IDENTITY_INSERT Equipment_Listing ON;
INSERT INTO Equipment_Listing (
    listing_id, listing_code, seller_id, category_id, listing_type, title, description,
    item_condition, condition_note, price, location_text, contact_phone, contact_zalo, status, reviewed_by, created_at
) VALUES
(1, 'mkt-001', 5, 2, 'SELL', N'Máy ảnh Film Canon QL17 GIII (Black Limited Edition)',
    N'Cần nhượng lại Canon QL17 GIII bản đen hiếm. Kính trong vắt, không mốc xước, đo sáng nhạy chuẩn pin PX625 adapter.',
    'LIKE_NEW', N'98% Sưu tầm, cơ tốc đo sáng hoàn hảo', 4800000, N'Hoàn Kiếm, Hà Nội', '0912345678', '0912345678', 'ACTIVE', 1, '2026-02-28T10:00:00'),
(2, 'mkt-002', 5, 3, 'SELL', N'Bộ máy ảnh Olympus OM-1 + Lens Zuiko 50mm f/1.4',
    N'Huyền thoại cơ khí OM-1 màn trập lụa êm ái. Chờ Admin kiểm duyệt tiền kiểm 100%.',
    'GOOD', N'95% Nguyên bản, view sáng rõ', 3600000, N'Hai Bà Trưng, Hà Nội', '0912345678', '0912345678', 'PENDING_REVIEW', NULL, '2026-03-02T15:30:00'),
(3, 'MKT-POST-902', 5, 2, 'SELL', N'Máy ảnh Leica M6 Classic Chrome 0.72x (Bản Wetzlar 1986)',
    N'Máy hoạt động hoàn hảo mọi tốc độ, đo sáng LED chuẩn xác, buồng phim sạch sẽ không lọt sáng. Đi kèm dây đeo da thủ công và nắp body zin.',
    'LIKE_NEW', N'Mint 98% - Đo sáng hoạt động hoàn hảo', 58500000, N'Hoàn Kiếm, Hà Nội', '0912345678', '0912345678', 'PENDING_REVIEW', NULL, '2026-03-03T10:15:00'),
(4, 'MKT-POST-903', 5, 2, 'SELL', N'Canon Canonet QL17 GIII 40mm f/1.7 (Rangefinder Nhật)',
    N'Dòng máy rangefinder quốc dân cho người mới chơi film. Đã CLA lau dầu chỉnh nét tại thợ uy tín, về chỉ việc lắp film chụp.',
    'GOOD', N'Khá 90% - Kính trong, cơ tốc chuẩn', 3800000, N'Đống Đa, Hà Nội', '0912345678', '0912345678', 'PENDING_REVIEW', NULL, '2026-03-03T11:00:00');
SET IDENTITY_INSERT Equipment_Listing OFF;

INSERT INTO Listing_Image (listing_id, image_url, sort_order) VALUES
(1, 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800', 0),
(2, 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800', 0),
(3, 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800', 0),
(4, 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=800', 0);

SET IDENTITY_INSERT Post_Article ON;
INSERT INTO Post_Article (
    post_id, post_code, author_id, post_category_id, post_type, title, slug, content,
    likes_count, comments_count, report_count, report_reason, status, moderated_by, moderated_at, published_at, created_at
) VALUES
(1, 'post-001', 6, 1, 'TUTORIAL', N'Bí quyết chọn điểm đo sáng khi chụp phim âm bản màu (Color Negative)',
    'bi-quyet-chon-diem-do-sang-color-negative',
    N'Phim âm bản màu như Kodak Portra hay Fuji Superia có khả năng giữ chi tiết vùng sáng cực tốt nhưng lại rất sợ thiếu sáng vùng tối (shadow). Hãy luôn đo sáng vào vùng tối và bù sáng +1 stop...',
    89, 14, 0, NULL, 'ACTIVE', 1, '2026-03-01T10:00:00', '2026-03-01T10:00:00', '2026-03-01T10:00:00'),
(2, 'post-002', 8, 6, 'ARTICLE', N'Rao bán hàng cấm và link spam tài chính cá độ',
    'rao-ban-hang-cam-spam',
    N'Click vào link nhận tiền thưởng ngay...',
    0, 0, 5, N'Spam quảng cáo sai quy định cộng đồng', 'REPORTED', NULL, NULL, NULL, '2026-03-02T11:00:00'),
(3, 'REP-COM-104', 12, 6, 'ARTICLE', N'Thanh lý lô máy ảnh phim giá siêu rẻ chuyển khoản cọc trước 50%',
    'thanh-ly-lo-may-anh-phim-gia-sieu-re',
    N'Mình có lô Leica M6 và Contax T2 giá chỉ 2 triệu/máy, ai mua inbox chuyển khoản cọc trước mình giữ hàng nhé, không nhận COD hay giao dịch trực tiếp...',
    0, 0, 7, N'Nghi vấn lừa đảo đặt cọc (Scam) & Spam link ngoài', 'REPORTED', NULL, NULL, NULL, '2026-03-03T08:30:00'),
(4, 'REP-COM-105', 17, 4, 'REVIEW', N'Bóc phốt lab X làm cháy cuộn phim kỷ niệm không đền bù thỏa đáng',
    'boc-phot-lab-x-lam-chay-cuon-phim',
    N'Bài viết sử dụng nhiều từ ngữ bức xúc khi chưa có kết luận kiểm tra kỹ thuật từ bộ phận phân xử của nền tảng.',
    2, 5, 3, N'Ngôn từ công kích chưa rõ bằng chứng đối soát', 'REPORTED', NULL, NULL, NULL, '2026-03-03T09:45:00');
SET IDENTITY_INSERT Post_Article OFF;

SET IDENTITY_INSERT Event ON;
INSERT INTO Event (
    event_id, event_code, host_id, event_type, title, description, venue,
    cover_image_url, start_at, end_at, capacity, fee, status
) VALUES
(1, 'evt-001', 6, 'PHOTOWALK', N'Photowalk Mùa Hoa Sưa - Dạo Phố Cùng Máy Cơ',
    N'Buổi giao lưu chụp ảnh đường phố đầu xuân, hướng dẫn đo sáng bằng mắt (Sunny 16) và bố cục đời thường.',
    N'Quanh Hồ Gươm & Phố Cổ Hà Nội',
    'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
    '2026-03-15T07:30:00', '2026-03-15T11:30:00', 30, 0, 'OPEN'),
(2, 'evt-002', 6, 'WORKSHOP', N'Workshop Phòng Tối: Tự Tay Tráng Cuộn Phim Đen Trắng Đầu Tiên',
    N'Trải nghiệm quy trình pha thuốc Ilford ID-11, cuốn film vào tank trong túi tối và kiểm soát thời gian tráng chuẩn xác tại Nadar Darkroom.',
    N'Nadar Darkroom - 15 Tràng Tiền, Hoàn Kiếm, Hà Nội',
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    '2026-03-22T14:00:00', '2026-03-22T17:30:00', 12, 250000, 'OPEN');
SET IDENTITY_INSERT Event OFF;

INSERT INTO Event_Registration (event_id, user_id, status) VALUES
(1, 5,  'REGISTERED'),
(1, 14, 'REGISTERED'),
(1, 15, 'REGISTERED'),
(2, 5,  'REGISTERED'),
(2, 16, 'REGISTERED');

SET IDENTITY_INSERT Dispute_Complaint ON;
INSERT INTO Dispute_Complaint (
    dispute_id, dispute_code, order_id, complainant_id, reason_type, issue_title,
    description, requested_amount, status, assigned_admin_id, created_at, escalated_at
) VALUES
(1, 'DSP-2026-001', 1, 5, 'QUALITY', N'Trầy xước phim / Lỗi scan màu (Đơn ORD-2026-8801)',
    N'Cuộn Portra 400 có 2 khung hình bị vệt xước dọc, muốn thương lượng scan lại độ phân giải TIFF hoặc hoàn phí tráng 50k.',
    50000, 'NEGOTIATING', NULL, '2026-03-02T14:00:00', NULL),
(2, 'DSP-2026-002', 8, 5, 'DAMAGED_FILM', N'Lọt sáng / Cháy film cuộn Kodak Portra 400 (Đơn ORD-2026-8819)',
    N'Khách hàng Nguyễn Hoàng Anh phản ánh cuộn phim số 2 trong đơn ORD-2026-8819 có vệt hóa chất loang lổ, đề nghị Lab và Admin đối soát.',
    170000, 'ESCALATED', 1, '2026-03-02T16:30:00', '2026-03-03T09:00:00');
SET IDENTITY_INSERT Dispute_Complaint OFF;

INSERT INTO Dispute_Message (dispute_id, sender_id, content, created_at) VALUES
(1, 5, N'Chào CropLab, khung hình số 12 và 13 của đơn ORD-2026-8801 bị vệt bụi dài ở góc phải.', '2026-03-02T14:05:00'),
(1, 3, N'Dạ CropLab chào bạn Hoàng Anh! Bên mình sẽ đưa dải phim vào máy thổi khí ion và scan lại miễn phí ngay trong chiều nay nhé!', '2026-03-02T14:30:00'),
(2, 5, N'Mình gửi 2 cuộn Portra 400 đơn ORD-2026-8819 nhưng cuộn số 2 bị vệt loang hóa chất.', '2026-03-02T16:35:00'),
(2, 3, N'Bên CropLab đã kiểm tra dải âm bản, mép phim có dấu hiệu lọt sáng từ buồng máy trước khi tráng, nhờ Admin phân xử.', '2026-03-02T17:10:00');

INSERT INTO Dispute_Evidence (dispute_id, uploaded_by, file_url, mime_type, uploaded_at) VALUES
(1, 5, 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600', 'image/jpeg', '2026-03-02T14:06:00'),
(2, 5, 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=600', 'image/jpeg', '2026-03-02T16:36:00');

SET IDENTITY_INSERT Review ON;
INSERT INTO Review (review_id, review_code, reviewer_id, review_type, order_id, service_name, rating, comment, status, created_at) VALUES
(1, 'rev-001', 5, 'LAB', 1, N'Tráng & Scan 135 Color C-41', 5, N'CropLab làm cực nhanh! Màu Noritsu chuẩn không cần chỉnh.', 'VISIBLE', '2026-02-28T10:00:00');
SET IDENTITY_INSERT Review OFF;

INSERT INTO Audit_Log (user_id, action, entity_name, entity_id, old_value, new_value, ip_address, created_at) VALUES
(1, 'APPROVE_LAB',     'Lab_Profile',       'lab-003',      '{"status":"PENDING"}',                   '{"status":"APPROVED","note":"Đủ giấy phép kinh doanh & hệ thống xử lý hóa chất C-41"}', '113.190.232.14', '2026-03-01T14:22:10'),
(2, 'RESOLVE_DISPUTE', 'Dispute_Complaint', 'DSP-2026-001', '{"status":"ESCALATED"}',                 '{"status":"REFUNDED","refund_amount":150000}',                                          '113.190.232.14', '2026-03-01T11:05:44'),
(1, 'LOCK_USER',       'Users',             'USR-DN-099',   '{"status":"ACTIVE","warnings":3}',       '{"status":"LOCKED","reason":"Spam link lừa đảo trên Marketplace"}',                      '14.162.145.88',  '2026-02-28T19:40:00'),
(2, 'UPDATE_CONFIG',   'System_Config',     'SLA_CONFIG',   '{"sla_negotiation_hours":48}',           '{"sla_negotiation_hours":72}',                                                          '113.190.232.14', '2026-02-27T09:15:00'),
(3, 'UPDATE_PRICE',    'Service_Package',   'pkg-002',      '{"price":80000,"package":"Scan Pro L"}', '{"price":85000,"reason":"Điều chỉnh theo giá hóa chất Kodak Flexicolor"}',               '27.72.100.12',   '2026-02-26T16:20:00'),
(3, 'UPDATE_SLA',      'Service_Package',   'pkg-003',      '{"estimated_hours":36}',                 '{"estimated_hours":24,"reason":"Tối ưu quy trình tráng tay B&W"}',                       '27.72.100.12',   '2026-02-18T10:05:00');

-- Giữ số liệu thống kê hiển thị ban đầu cho các Film Lab đã duyệt
UPDATE Lab_Profile SET avg_rating = 4.90, review_count = 328 WHERE lab_id = 1;
UPDATE Lab_Profile SET avg_rating = 4.80, review_count = 512 WHERE lab_id = 2;
UPDATE Lab_Profile SET avg_rating = 5.00, review_count = 145 WHERE lab_id = 3;
UPDATE Lab_Profile SET avg_rating = 4.70, review_count = 96  WHERE lab_id = 6;
UPDATE Lab_Profile SET avg_rating = 4.60, review_count = 82  WHERE lab_id = 7;
GO

-- ===============================================
-- 02_procedures/01_order_status.sql
-- ===============================================
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
            (@old_status = 'PENDING_PAYMENT' AND @new_status IN ('PENDING_LAB_CONFIRM','RECEIVED','CANCELLED')) OR
            (@old_status = 'PENDING_LAB_CONFIRM' AND @new_status IN ('PICKING_UP','RECEIVED_AT_LAB','RECEIVED','CANCELLED')) OR
            (@old_status = 'PICKING_UP' AND @new_status IN ('RECEIVED_AT_LAB','RECEIVED','CANCELLED')) OR
            (@old_status IN ('RECEIVED_AT_LAB','RECEIVED','PENDING_FILM') AND @new_status IN ('PROCESSING','CANCELLED')) OR
            (@old_status = 'PROCESSING' AND @new_status IN ('DRYING','SCANNING','QC_CHECK','READY_FOR_DOWNLOAD','COMPLETED')) OR
            (@old_status IN ('DRYING','SCANNING','QC_CHECK') AND @new_status IN ('SCANNING','QC_CHECK','READY_FOR_DOWNLOAD','COMPLETED')) OR
            (@old_status IN ('READY_FOR_DOWNLOAD','COMPLETED') AND @new_status IN ('COMPLETED','DELIVERING','CLOSED')) OR
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

-- ===============================================
-- 02_procedures/02_event_registration.sql
-- ===============================================
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

-- ===============================================
-- 02_procedures/03_approved_labs.sql
-- ===============================================
USE FilmLabPlatform;
GO
CREATE OR ALTER PROCEDURE dbo.sp_GetApprovedLabs
AS
BEGIN
    SET NOCOUNT ON;
    SELECT lab_id, owner_id, lab_name, slug, province, district, avg_rating, review_count
    FROM dbo.Lab_Profile
    WHERE approval_status = 'APPROVED';
END;
GO

-- ===============================================
-- 03_triggers/01_R1_order_item_lab.sql
-- ===============================================
USE FilmLabPlatform;
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
 THROW 51001, 'R1: Goi dich vu phai thuoc Lab cua don hang.', 1;
END;
GO

-- ===============================================
-- 03_triggers/02_R2_approved_lab.sql
-- ===============================================
USE FilmLabPlatform;
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

-- ===============================================
-- 03_triggers/03_R3_review_eligibility.sql
-- ===============================================
USE FilmLabPlatform;
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
            (o.status NOT IN ('CLOSED','COMPLETED','READY_FOR_DOWNLOAD') OR o.customer_id<>i.reviewer_id))
     OR (i.review_type='SELLER' AND
            (t.status<>'COMPLETED' OR t.buyer_id<>i.reviewer_id))
 )
 THROW 51003, 'R3: Nguoi danh gia phai la khach/mua hang da hoan tat.', 1;
END;
GO

-- ===============================================
-- 03_triggers/04_R4_R5_roles.sql
-- ===============================================
USE FilmLabPlatform;
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

-- ===============================================
-- 03_triggers/05_R6_refund_limit.sql
-- ===============================================
USE FilmLabPlatform;
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

-- ===============================================
-- 03_triggers/06_R9_R11_lab_rating.sql
-- ===============================================
USE FilmLabPlatform;
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

-- ===============================================
-- 03_triggers/07_R7_event_capacity.sql
-- ===============================================
USE FilmLabPlatform;
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

-- VERIFY
USE FilmLabPlatform;
GO
SELECT DB_NAME() AS DatabaseName, (SELECT COUNT(*) FROM sys.tables) AS SoBang, (SELECT COUNT(*) FROM sys.foreign_keys) AS SoKhoaNgoai, (SELECT COUNT(*) FROM sys.procedures) AS SoProcedure, (SELECT COUNT(*) FROM sys.triggers WHERE parent_class=1) AS SoTrigger;
GO
