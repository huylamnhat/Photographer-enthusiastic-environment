USE FilmLabPlatform_Test;
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
