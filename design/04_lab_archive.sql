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
    archive_id    BIGINT        NOT NULL,
    scan_file_id  BIGINT        NULL,               -- liên kết với file gốc do Lab giao
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

-- 24. Photo_Metadata (1-1 với Archive_Photo)
CREATE TABLE Photo_Metadata (
    photo_id         BIGINT        NOT NULL,        -- vừa PK vừa FK -> đảm bảo 1-1
    camera_brand     NVARCHAR(100) NULL,
    camera_model     NVARCHAR(100) NULL,
    lens             NVARCHAR(150) NULL,
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
