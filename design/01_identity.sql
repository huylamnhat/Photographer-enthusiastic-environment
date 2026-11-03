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
    email          NVARCHAR(255)  NOT NULL,
    phone          VARCHAR(20)    NULL,
    password_hash  VARCHAR(255)   NOT NULL,           -- bcrypt/argon2, KHÔNG lưu mật khẩu thô
    full_name      NVARCHAR(150)  NOT NULL,
    avatar_url     VARCHAR(500)   NULL,
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
