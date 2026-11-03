-- Issue #21 | SQL Server | Source: Week 2

-- 13. Orders
CREATE TABLE Orders (
    order_id                BIGINT IDENTITY(1,1) NOT NULL,
    order_code              VARCHAR(20)   NOT NULL,                 -- VD: FL-20261027-0001
    customer_id             INT           NOT NULL,
    lab_id                  INT           NOT NULL,
    status                  VARCHAR(25)   NOT NULL CONSTRAINT DF_Orders_Status DEFAULT 'PENDING_PAYMENT',
    receive_method          VARCHAR(20)   NOT NULL,
    return_method           VARCHAR(20)   NOT NULL,
    subtotal                DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Sub DEFAULT 0,
    shipping_fee            DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Ship DEFAULT 0,
    platform_fee            DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Fee DEFAULT 0,
    discount_amount         DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Disc DEFAULT 0,
    total_amount            DECIMAL(15,2) NOT NULL CONSTRAINT DF_Orders_Total DEFAULT 0,
    expected_completion_date DATE         NULL,
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
        'PROCESSING','COMPLETED','DELIVERING','CLOSED','CANCELLED')),
    CONSTRAINT CK_Orders_Receive CHECK (receive_method IN ('SELF_DROP_OFF','PICKUP')),
    CONSTRAINT CK_Orders_Return  CHECK (return_method  IN ('SELF_PICKUP','DELIVERY','DIGITAL_ONLY')),
    CONSTRAINT CK_Orders_Money   CHECK (subtotal >= 0 AND shipping_fee >= 0 AND platform_fee >= 0
                                        AND discount_amount >= 0 AND total_amount >= 0),
    CONSTRAINT CK_Orders_Total   CHECK (total_amount = subtotal + shipping_fee + platform_fee - discount_amount),
    CONSTRAINT CK_Orders_Cancel  CHECK (status <> 'CANCELLED' OR (cancel_reason IS NOT NULL AND cancelled_by IS NOT NULL))
);

-- 14. Order_Item
CREATE TABLE Order_Item (
    order_item_id BIGINT IDENTITY(1,1) NOT NULL,
    order_id      BIGINT        NOT NULL,
    package_id    INT           NOT NULL,
    film_stock_id INT           NULL,
    quantity      SMALLINT      NOT NULL CONSTRAINT DF_OI_Qty DEFAULT 1,   -- số cuộn
    unit_price    DECIMAL(15,2) NOT NULL,                                   -- snapshot giá tại thời điểm đặt
    line_total    DECIMAL(15,2) NOT NULL,
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
    gateway         VARCHAR(10)   NOT NULL,
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
    CONSTRAINT CK_Payment_Gateway CHECK (gateway IN ('VNPAY','MOMO')),
    CONSTRAINT CK_Payment_Status  CHECK (status IN ('PENDING','SUCCESS','FAILED','CANCELLED','REFUNDED')),
    CONSTRAINT CK_Payment_Amount  CHECK (amount > 0),
    CONSTRAINT CK_Payment_Paid    CHECK (status <> 'SUCCESS' OR paid_at IS NOT NULL)
);
