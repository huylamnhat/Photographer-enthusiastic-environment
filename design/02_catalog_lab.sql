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
    owner_id            INT            NOT NULL,
    lab_name            NVARCHAR(200)  NOT NULL,
    slug                VARCHAR(220)   NOT NULL,
    description         NVARCHAR(2000) NULL,
    phone               VARCHAR(20)    NOT NULL,
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
    supports_pickup     BIT            NOT NULL CONSTRAINT DF_Lab_Pickup DEFAULT 0,
    avg_rating          DECIMAL(3,2)   NOT NULL CONSTRAINT DF_Lab_Rating DEFAULT 0,   -- denormalized, cập nhật bằng trigger/job
    review_count        INT            NOT NULL CONSTRAINT DF_Lab_RvCount DEFAULT 0,  -- denormalized
    approval_status     VARCHAR(20)    NOT NULL CONSTRAINT DF_Lab_Approval DEFAULT 'PENDING',
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
    lab_id               INT            NOT NULL,
    service_type         VARCHAR(20)    NOT NULL,
    name                 NVARCHAR(200)  NOT NULL,
    description          NVARCHAR(1000) NULL,
    format_id            SMALLINT       NOT NULL,
    process_type_id      SMALLINT       NULL,        -- NULL khi chỉ scan
    scan_quality         VARCHAR(20)    NULL,        -- NULL khi chỉ tráng
    scan_dpi             SMALLINT       NULL,
    output_format        VARCHAR(20)    NULL,
    price                DECIMAL(15,2)  NOT NULL,
    price_unit           VARCHAR(20)    NOT NULL CONSTRAINT DF_SP_Unit DEFAULT 'PER_ROLL',
    est_processing_days  TINYINT        NOT NULL,
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
