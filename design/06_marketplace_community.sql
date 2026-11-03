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
    seller_id       INT            NOT NULL,
    category_id     INT            NOT NULL,
    listing_type    VARCHAR(10)    NOT NULL CONSTRAINT DF_EL_Type DEFAULT 'SELL',
    title           NVARCHAR(200)  NOT NULL,
    description     NVARCHAR(4000) NULL,
    brand           NVARCHAR(100)  NULL,
    model           NVARCHAR(100)  NULL,
    item_condition  VARCHAR(15)    NOT NULL,
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
        ('PENDING_APPROVAL','ACTIVE','REJECTED','SOLD','EXPIRED','HIDDEN')),
    CONSTRAINT CK_EL_Price  CHECK (price IS NULL OR price >= 0),
    CONSTRAINT CK_EL_PriceReq CHECK (listing_type = 'TRADE' OR price IS NOT NULL),
    CONSTRAINT CK_EL_Reject CHECK (status <> 'REJECTED' OR reject_reason IS NOT NULL)
);

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
    reviewer_id  INT            NOT NULL,
    review_type  VARCHAR(10)    NOT NULL,
    order_id     BIGINT         NULL,     -- khi review_type = 'LAB'
    txn_id       BIGINT         NULL,     -- khi review_type = 'SELLER'
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
    author_id        INT            NOT NULL,
    post_category_id INT            NULL,
    post_type        VARCHAR(10)    NOT NULL,
    title            NVARCHAR(250)  NOT NULL,
    slug             VARCHAR(280)   NOT NULL,
    summary          NVARCHAR(500)  NULL,
    content          NVARCHAR(MAX)  NOT NULL,
    cover_image_url  VARCHAR(500)   NULL,
    status           VARCHAR(10)    NOT NULL CONSTRAINT DF_Post_Status DEFAULT 'DRAFT',
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
    CONSTRAINT CK_Post_Status CHECK (status IN ('DRAFT','PUBLISHED','HIDDEN','REMOVED')),
    CONSTRAINT CK_Post_Pub    CHECK (status <> 'PUBLISHED' OR published_at IS NOT NULL)
);

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
    event_id    INT IDENTITY(1,1) NOT NULL,
    host_id     INT            NOT NULL,
    event_type  VARCHAR(10)    NOT NULL,
    title       NVARCHAR(250)  NOT NULL,
    description NVARCHAR(4000) NULL,
    venue       NVARCHAR(255)  NOT NULL,
    start_at    DATETIME2(0)   NOT NULL,
    end_at      DATETIME2(0)   NOT NULL,
    capacity    SMALLINT       NOT NULL,
    fee         DECIMAL(15,2)  NOT NULL CONSTRAINT DF_Event_Fee DEFAULT 0,
    status      VARCHAR(10)    NOT NULL CONSTRAINT DF_Event_Status DEFAULT 'DRAFT',
    created_at  DATETIME2(0)   NOT NULL CONSTRAINT DF_Event_Created DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Event PRIMARY KEY (event_id),
    CONSTRAINT FK_Event_Host FOREIGN KEY (host_id) REFERENCES Users(user_id),
    CONSTRAINT CK_Event_Type   CHECK (event_type IN ('WORKSHOP','PHOTOWALK')),
    CONSTRAINT CK_Event_Status CHECK (status IN ('DRAFT','OPEN','FULL','ONGOING','COMPLETED','CANCELLED')),
    CONSTRAINT CK_Event_Time   CHECK (end_at > start_at),
    CONSTRAINT CK_Event_Cap    CHECK (capacity > 0),
    CONSTRAINT CK_Event_Fee    CHECK (fee >= 0)
);

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
