const { 
  mockUsers, 
  mockLabs, 
  mockPendingLabs, 
  mockExpertApplications,
  mockServicePackages,
  mockProcessStandards,
  mockOrders, 
  mockListings, 
  mockCommunityPosts, 
  mockDisputes,
  mockAuditLogs,
  mockNotifications
} = require('../data/mockStore');
const { runQuery } = require('../config/db');

exports.getDashboardStats = (req, res) => {
  const totalOrders = mockOrders.length;
  const totalRevenue = mockOrders.reduce((sum, o) => sum + (o.total_amount || 0), 0);
  const platformFeeCommission = totalRevenue * 0.10; // 10% hoa hồng nền tảng
  const activeLabsCount = mockLabs.filter(l => l.status === 'APPROVED').length;
  const pendingLabsCount = mockPendingLabs.filter(l => l.status === 'PENDING').length;
  const pendingMarketplaceCount = mockListings.filter(l => l.status === 'PENDING_REVIEW').length;
  const openDisputesCount = mockDisputes.filter(d => d.status !== 'RESOLVED' && d.status !== 'REFUNDED').length;

  return res.json({
    success: true,
    data: {
      total_orders: totalOrders,
      total_revenue: totalRevenue,
      platform_commission: platformFeeCommission,
      active_labs: activeLabsCount,
      pending_labs: pendingLabsCount,
      pending_marketplace: pendingMarketplaceCount,
      open_disputes: openDisputesCount,
      sla_on_time_rate: '98.4%',
      recent_orders: mockOrders.slice(0, 5),
      labs: [...mockLabs, ...mockPendingLabs]
    }
  });
};

exports.getUsers = (req, res) => {
  return res.json({
    success: true,
    data: mockUsers
  });
};

exports.updateUserStatus = (req, res) => {
  const { id } = req.params;
  const { status, role } = req.body;
  const user = mockUsers.find(u => u.user_id === id || String(u.db_user_id) === String(id));
  if (!user) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
  }

  if (status) user.status = status;
  if (role) user.role = role;

  // Cập nhật ngay lập tức các bài viết trên cộng đồng của tác giả này
  if (status) {
    const isLocked = user.status === 'LOCKED';
    mockCommunityPosts.forEach(p => {
      if (
        p.author_id === user.user_id || 
        p.author_id === `usr-${user.db_user_id}` || 
        String(p.author_id) === String(user.db_user_id)
      ) {
        p.author_name = isLocked ? 'Người dùng vi phạm' : user.full_name;
        p.author_badge = isLocked ? 'NGƯỜI DÙNG VI PHẠM' : (user.role === 'Expert' ? 'Chuyên gia nhiếp ảnh' : 'Thành viên cộng đồng');
        p.author_status = status;
        p.is_author_locked = isLocked;
      }
    });
  }

  const safeUserCode = String(user.user_id || '').replace(/'/g, "''");
  if (status) {
    runQuery(`
      UPDATE Users
      SET status = '${status}',
          locked_reason = ${status === 'LOCKED' ? "N'Khóa bởi Admin do vi phạm chính sách'" : 'NULL'},
          locked_by = ${status === 'LOCKED' ? '1' : 'NULL'},
          locked_at = ${status === 'LOCKED' ? 'SYSUTCDATETIME()' : 'NULL'}
      WHERE user_code = '${safeUserCode}' OR user_id = ${Number(user.db_user_id) || 0};
    `).catch(() => {});
  }

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19),
    actor: 'Admin Tuấn (ADMIN)',
    action: status === 'LOCKED' ? 'LOCK_USER' : 'UNLOCK_USER',
    entity: `Users #${user.user_id}`,
    entity_name: 'Users',
    entity_id: user.user_id,
    ip: req.ip || '127.0.0.1',
    oldVal: JSON.stringify({ status: user.status === 'LOCKED' ? 'ACTIVE' : 'LOCKED' }),
    newVal: JSON.stringify({ status: user.status, full_name: user.full_name })
  });

  return res.json({
    success: true,
    message: status === 'ACTIVE' 
      ? `Đã mở khóa tài khoản ${user.full_name}. Tên người dùng đã được khôi phục trên cộng đồng!` 
      : `Đã khóa tài khoản ${user.full_name}!`,
    data: user
  });
};

exports.getPendingLabs = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const pending = mockPendingLabs.filter(
    l => l.status === 'PENDING' || l.status === 'PENDING_REVIEW'
  );
  return res.json({
    success: true,
    data: pending
  });
};

exports.reviewLabApplication = async (req, res) => {
  const { id } = req.params;
  const { action, note } = req.body; // action: 'APPROVE' or 'REJECT'
  const appIndex = mockPendingLabs.findIndex(l => l.application_id === id);

  if (appIndex === -1) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy hồ sơ lab' });
  }

  const app = mockPendingLabs[appIndex];
  const pkgCode = `pkg-${Date.now().toString().slice(-4)}`;
  if (action === 'APPROVE') {
    app.status = 'APPROVED';
    const newLab = {
      lab_id: app.application_id,
      owner_id: app.owner_id || `usr-lab-${Date.now().toString().slice(-4)}`,
      name: app.name,
      tagline: 'Tiệm Film Lab mới được Admin chứng nhận',
      address: app.address,
      city: app.city,
      phone: app.phone,
      email: app.email,
      rating: 5.0,
      review_count: 0,
      turnaround_hours: 12,
      scanner_models: app.scanner_models,
      supported_formats: ['135', '120'],
      supported_processes: app.supported_processes,
      cover_image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
      logo_url: 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200',
      is_verified: true,
      status: 'APPROVED',
      price_range: '60.000đ - 110.000đ',
      description: 'Tiệm lab đã qua thẩm định điều kiện cơ sở vật chất phòng tối và quy trình xử lý an toàn môi trường.',
      created_at: new Date().toISOString()
    };
    if (!mockLabs.some(l => l.lab_id === newLab.lab_id)) {
      mockLabs.unshift(newLab);
    }
    mockServicePackages.push({
      package_id: pkgCode,
      lab_id: newLab.lab_id,
      lab_name: newLab.name,
      name: 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
      film_format: '135',
      process_type: 'C-41',
      scan_resolution: 'M (3000x2000px)',
      price: 65000,
      estimated_hours: 12,
      status: 'ACTIVE',
      description: 'Gói tiêu chuẩn của tiệm Lab mới phê duyệt'
    });
  } else {
    app.status = 'REJECTED';
    app.inspection_note = note || 'Chưa đạt yêu cầu thẩm định giấy phép / thiết bị.';
  }

  const safeLabCode = String(app.application_id || '').replace(/'/g, "''");
  const safeRejNote = String(note || 'Chưa đạt yêu cầu thẩm định').replace(/'/g, "''");
  await runQuery(`
    UPDATE Lab_Profile
    SET approval_status = '${app.status}',
        reviewed_by = 1,
        reviewed_at = SYSUTCDATETIME(),
        reject_reason = ${app.status === 'REJECTED' ? `N'${safeRejNote}'` : 'NULL'}
    WHERE lab_code = '${safeLabCode}';
  `).catch((err) => { console.error('[reviewLabApplication SQL Error]:', err.message); });

  if (app.status === 'APPROVED') {
    await runQuery(`
      DECLARE @targetLabId INT = (SELECT TOP 1 lab_id FROM Lab_Profile WHERE lab_code = '${safeLabCode}');
      IF @targetLabId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Service_Package WHERE lab_id = @targetLabId)
      BEGIN
        INSERT INTO Service_Package (package_code, lab_id, service_type, name, description, format_id, process_type_id, scan_quality, scan_resolution, output_format, price, estimated_hours, is_active)
        VALUES ('${pkgCode}', @targetLabId, 'DEVELOP_SCAN', N'Tráng & Scan 135 Color (C-41) - Chuẩn M', N'Gói tiêu chuẩn của tiệm Lab mới phê duyệt', 1, 1, 'STANDARD', N'M (3000x2000px)', 'JPEG', 65000, 12, 1);
      END
    `).catch((err) => { console.error('[reviewLabApplication Pkg SQL Error]:', err.message); });
  }

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19),
    actor: 'Admin Tuấn (ADMIN)',
    action: action === 'APPROVE' ? 'APPROVE_LAB' : 'REJECT_LAB',
    entity: `Lab_Profile #${app.application_id}`,
    entity_name: 'Lab_Profile',
    entity_id: app.application_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{"status":"PENDING"}',
    newVal: JSON.stringify({ status: app.status, name: app.name })
  });

  return res.json({
    success: true,
    message: action === 'APPROVE' ? 'Đã phê duyệt mở tiệm Film Lab thành công' : 'Đã từ chối hồ sơ lab',
    data: app
  });
};

exports.getExpertApplications = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const pending = mockExpertApplications.filter(
    e => e.status === 'PENDING' || e.status === 'PENDING_REVIEW'
  );
  return res.json({
    success: true,
    data: pending
  });
};

exports.reviewExpertApplication = async (req, res) => {
  const { id } = req.params;
  const { action } = req.body; // 'APPROVE' or 'REJECT'
  const exp = mockExpertApplications.find(e => e.id === id);
  if (!exp) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy hồ sơ chuyên gia' });
  }
  exp.status = action === 'APPROVE' ? 'VERIFIED' : 'REJECTED';

  const safeExpId = String(exp.id || '').replace(/'/g, "''");
  const dbExpUserId = Number(exp.db_user_id) || 0;
  await runQuery(`
    UPDATE Expert_Profile
    SET verification_status = '${exp.status}',
        verified_by = 1
    WHERE ${dbExpUserId > 0 ? `user_id = ${dbExpUserId}` : `user_id = (SELECT TOP 1 user_id FROM Users WHERE user_code = '${safeExpId}')`};
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19),
    actor: 'Admin Tuấn (ADMIN)',
    action: action === 'APPROVE' ? 'APPROVE_EXPERT' : 'REJECT_EXPERT',
    entity: `Expert_Profile #${exp.id}`,
    entity_name: 'Expert_Profile',
    entity_id: exp.id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{"verification_status":"PENDING"}',
    newVal: JSON.stringify({ verification_status: exp.status, name: exp.name })
  });

  return res.json({
    success: true,
    message: action === 'APPROVE' ? 'Đã cấp huy hiệu Chuyên gia (Expert)' : 'Đã từ chối hồ sơ chuyên gia',
    data: exp
  });
};

exports.getPendingMarketplace = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const pending = mockListings
    .filter(
      l =>
        (l.status === 'PENDING_REVIEW' ||
          l.status === 'PENDING_APPROVAL' ||
          l.moderation_status === 'PENDING') &&
        l.status !== 'ACTIVE' &&
        l.status !== 'APPROVED' &&
        l.status !== 'REJECTED' &&
        l.moderation_status !== 'APPROVED' &&
        l.moderation_status !== 'REJECTED'
    )
    .sort((a, b) => String(b.created_at || '').localeCompare(String(a.created_at || '')));
  return res.json({
    success: true,
    data: pending
  });
};

exports.moderateMarketplace = async (req, res) => {
  const { id } = req.params;
  const { action, reason } = req.body; // action: 'APPROVE' or 'REJECT'
  const item = mockListings.find(l => l.listing_id === id);

  if (!item) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy tin đăng' });
  }

  if (action === 'APPROVE') {
    item.status = 'ACTIVE';
    item.moderation_status = 'APPROVED';
  } else {
    item.status = 'REJECTED';
    item.moderation_status = 'REJECTED';
    item.rejection_reason = reason || 'Thông tin thiết bị không rõ ràng hoặc vi phạm chính sách.';
  }

  const safeListingCode = String(item.listing_id || '').replace(/'/g, "''");
  const safeListingReason = String(item.rejection_reason || 'Vi phạm chính sách').replace(/'/g, "''");
  await runQuery(`
    UPDATE Equipment_Listing
    SET status = '${item.status}',
        reviewed_by = 1,
        reviewed_at = SYSUTCDATETIME(),
        reject_reason = ${item.status === 'REJECTED' ? `N'${safeListingReason}'` : 'NULL'}
    WHERE listing_code = '${safeListingCode}';
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19),
    actor: 'Admin Tuấn (ADMIN)',
    action: action === 'APPROVE' ? 'APPROVE_LISTING' : 'REJECT_LISTING',
    entity: `Equipment_Listing #${item.listing_id}`,
    entity_name: 'Equipment_Listing',
    entity_id: item.listing_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{"status":"PENDING_REVIEW"}',
    newVal: JSON.stringify({ status: item.status, title: item.title })
  });

  return res.json({
    success: true,
    message: action === 'APPROVE' ? 'Đã duyệt tin đăng lên sàn' : 'Đã từ chối tin đăng',
    data: item
  });
};

exports.getReportedContent = (req, res) => {
  res.set('Cache-Control', 'no-store');
  // Hậu kiểm cộng đồng (Post-moderation audit):
  // Trả về danh sách bài viết cần Admin xử lý bao gồm:
  // 1. Bài viết bị người dùng báo cáo vi phạm (status === 'REPORTED' hoặc report_count > 0)
  // 2. Bài viết mới người dùng đăng lên cần hậu kiểm (needs_audit === true hoặc chưa có moderated_by/moderated_at)
  const items = mockCommunityPosts.filter(p => {
    if (p.status === 'HIDDEN') return false;
    const isReported = p.status === 'REPORTED' || Number(p.report_count || 0) > 0;
    const isPendingAudit = Boolean(p.needs_audit) || (!p.moderated_by && !p.moderated_at && p.post_id !== 'post-001');
    return isReported || isPendingAudit;
  });

  const enriched = items.map(p => {
    const author = mockUsers.find(u => 
      u.user_id === p.author_id || 
      String(u.db_user_id) === String(p.author_id) || 
      `usr-${u.db_user_id}` === p.author_id
    );
    if (!author) return p;
    const isLocked = author.status === 'LOCKED';
    return {
      ...p,
      author_name: isLocked ? 'Người dùng vi phạm' : author.full_name,
      author_badge: isLocked ? 'NGƯỜI DÙNG VI PHẠM' : (author.role === 'Expert' ? 'Chuyên gia nhiếp ảnh' : 'Thành viên cộng đồng'),
      author_role: author.role,
      author_status: author.status,
    };
  });

  return res.json({
    success: true,
    data: enriched
  });
};

exports.moderateCommunityPost = async (req, res) => {
  const { id } = req.params;
  const { action, reason } = req.body; // 'HIDE', 'DISMISS', or 'APPROVE'
  const post = mockCommunityPosts.find(p => p.post_id === id);

  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  const now = new Date();
  if (action === 'HIDE') {
    post.status = 'HIDDEN';
    post.needs_audit = false;
    post.moderated_at = now.toISOString();
    post.moderated_by = 1;
  } else {
    // APPROVE (duyệt đạt chuẩn hậu kiểm) hoặc DISMISS (bỏ qua báo cáo vi phạm)
    post.status = 'ACTIVE';
    post.report_count = 0;
    post.needs_audit = false;
    post.moderated_at = now.toISOString();
    post.moderated_by = 1;
  }

  const safePostCode = String(post.post_id || '').replace(/'/g, "''");
  const safeModNote = String(reason || (action === 'HIDE' ? 'Gỡ bài viết vi phạm' : 'Đã hậu kiểm đạt chuẩn')).replace(/'/g, "''");
  await runQuery(`
    UPDATE Post_Article
    SET status = '${post.status}',
        report_count = ${Number(post.report_count) || 0},
        moderated_by = 1,
        moderation_note = N'${safeModNote}',
        updated_at = SYSUTCDATETIME()
    WHERE post_code = '${safePostCode}';
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: 'Admin Tuấn (ADMIN)',
    action: action === 'HIDE' ? 'HIDE_COMMUNITY_POST' : 'APPROVE_COMMUNITY_POST',
    entity: `Post_Article #${post.post_id}`,
    entity_name: 'Post_Article',
    entity_id: post.post_id,
    ip: req.ip || '127.0.0.1',
    oldVal: JSON.stringify({ status: 'PENDING_MODERATION' }),
    newVal: JSON.stringify({ status: post.status, action, moderated_at: now.toISOString() })
  });

  return res.json({
    success: true,
    message: action === 'HIDE'
      ? 'Đã gỡ bài viết vi phạm khỏi diễn đàn'
      : (action === 'APPROVE' ? 'Đã duyệt bài viết đạt chuẩn cộng đồng' : 'Đã bỏ qua báo cáo và giữ lại bài viết'),
    data: post
  });
};

exports.getDisputes = (req, res) => {
  return res.json({
    success: true,
    data: mockDisputes
  });
};

exports.resolveDispute = (req, res) => {
  const { id } = req.params;
  const { resolution, refund_amount } = req.body; // 'APPROVE_REFUND' or 'CLOSE'
  const dispute = mockDisputes.find(d => d.dispute_id === id);

  if (!dispute) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy khiếu nại' });
  }

  if (resolution === 'APPROVE_REFUND') {
    dispute.status = 'REFUNDED';
    dispute.refund_amount = refund_amount || dispute.amount_requested;
    dispute.resolved_at = new Date().toISOString();
    dispute.compensation_note = `Admin Tổng Sàn đã phê duyệt hoàn tiền ${dispute.refund_amount}đ cho khách hàng.`;
    dispute.messages.push({
      sender: 'Admin Tổng Sàn',
      text: `Phán quyết: Chấp thuận hoàn tiền ${dispute.refund_amount}đ vào ví khách hàng.`,
      time: new Date().toISOString().replace('T', ' ').slice(0, 16)
    });
  } else {
    dispute.status = 'RESOLVED';
    dispute.resolved_at = new Date().toISOString();
    dispute.compensation_note = 'Admin Tổng Sàn đã đóng hồ sơ khiếu nại sau khi đối chiếu quy trình Lab.';
    dispute.messages.push({
      sender: 'Admin Tổng Sàn',
      text: 'Phán quyết: Đóng hồ sơ khiếu nại sau khi đối chiếu quy trình Lab.',
      time: new Date().toISOString().replace('T', ' ').slice(0, 16)
    });
  }

  const targetOrder = mockOrders.find(o => o.order_id === dispute.order_id);
  if (targetOrder) {
    targetOrder.dispute_id = dispute.dispute_id;
    targetOrder.dispute_status = dispute.status;
    targetOrder.compensation_note = dispute.compensation_note;
  }

  mockNotifications.unshift({
    notification_id: `NTF-ADM-${Date.now()}`,
    type: resolution === 'APPROVE_REFUND' ? 'REFUND' : 'DISPUTE_RESOLVED',
    order_id: dispute.order_id,
    dispute_id: dispute.dispute_id,
    customer_id: dispute.customer_id || 'usr-001',
    title: resolution === 'APPROVE_REFUND'
      ? `💰 Đã hoàn tiền ${dispute.refund_amount}đ cho đơn #${dispute.order_id}`
      : `📋 Kết quả xử lý khiếu nại đơn #${dispute.order_id}`,
    message: dispute.compensation_note,
    created_at: new Date().toISOString(),
    is_read: false,
  });

  const safeDisputeCode = String(dispute.dispute_id || '').replace(/'/g, "''");
  runQuery(`
    UPDATE Dispute_Complaint
    SET status = '${dispute.status}',
        assigned_admin_id = 1,
        resolved_at = SYSUTCDATETIME(),
        approved_refund_amount = ${dispute.refund_amount ? Number(dispute.refund_amount) : 'NULL'}
    WHERE dispute_code = '${safeDisputeCode}';
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19),
    actor: 'Admin Tuấn (ADMIN)',
    action: resolution === 'APPROVE_REFUND' ? 'APPROVE_DISPUTE_REFUND' : 'CLOSE_DISPUTE',
    entity: `Dispute_Complaint #${dispute.dispute_id}`,
    entity_name: 'Dispute_Complaint',
    entity_id: dispute.dispute_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{"status":"IN_NEGOTIATION"}',
    newVal: JSON.stringify({ status: dispute.status, refund_amount: dispute.refund_amount })
  });

  return res.json({
    success: true,
    message: resolution === 'APPROVE_REFUND' ? 'Đã duyệt hoàn tiền nội bộ thành công' : 'Đã đóng khiếu nại',
    data: dispute
  });
};

exports.getAuditLogs = (req, res) => {
  return res.json({
    success: true,
    data: mockAuditLogs
  });
};

exports.getAdminServices = (req, res) => {
  return res.json({
    success: true,
    data: {
      standards: mockProcessStandards,
      packages: mockServicePackages
    }
  });
};

exports.getAdminNotifications = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const notifications = [];

  const pendingLabs = mockPendingLabs.filter(
    l => !l.status || l.status === 'PENDING' || l.status === 'PENDING_REVIEW'
  );
  for (const l of pendingLabs) {
    notifications.push({
      id: `ntf-lab-${l.application_id || l.lab_id}`,
      type: 'LAB_APPROVAL',
      title: `Hồ sơ Lab mới chờ duyệt: ${l.name || l.lab_name || l.application_id}`,
      subtitle: `${[l.city, l.address].filter(Boolean).join(' - ') || 'Đối tác Film Lab'} • Nhấn để tới Duyệt đối tác`,
      tab_index: 2,
      severity: 'warning',
    });
  }

  const pendingExperts = mockExpertApplications.filter(
    e => e.status === 'PENDING' || e.status === 'PENDING_REVIEW'
  );
  for (const e of pendingExperts) {
    notifications.push({
      id: `ntf-exp-${e.id}`,
      type: 'EXPERT_APPROVAL',
      title: `Hồ sơ Chuyên gia chờ duyệt: ${e.name || e.full_name || e.id}`,
      subtitle: `${e.specialty || 'Nhiếp ảnh gia'} • Nhấn để tới Duyệt đối tác`,
      tab_index: 2,
      severity: 'warning',
    });
  }

  const pendingListings = mockListings.filter(
    l =>
      (l.status === 'PENDING_REVIEW' ||
        l.status === 'PENDING_APPROVAL' ||
        l.moderation_status === 'PENDING') &&
      l.status !== 'ACTIVE' &&
      l.status !== 'APPROVED' &&
      l.status !== 'REJECTED' &&
      l.moderation_status !== 'APPROVED' &&
      l.moderation_status !== 'REJECTED'
  );
  for (const l of pendingListings) {
    notifications.push({
      id: `ntf-mkt-${l.listing_id}`,
      type: 'MARKETPLACE_APPROVAL',
      title: `Tin bán thiết bị chờ duyệt: ${l.title || l.listing_id}`,
      subtitle: `${l.seller_name || 'Thành viên'} • Nhấn để tới Duyệt bài đăng`,
      tab_index: 3,
      severity: 'info',
    });
  }

  const auditPosts = mockCommunityPosts.filter(p => {
    if (p.status === 'HIDDEN') return false;
    const isReported = p.status === 'REPORTED' || Number(p.report_count || 0) > 0;
    const isPendingAudit = Boolean(p.needs_audit) || (!p.moderated_by && !p.moderated_at && p.post_id !== 'post-001');
    return isReported || isPendingAudit;
  });
  for (const p of auditPosts) {
    const isReported = p.status === 'REPORTED' || Number(p.report_count || 0) > 0;
    notifications.push({
      id: `ntf-post-${p.post_id}`,
      type: isReported ? 'COMMUNITY_REPORT' : 'COMMUNITY_AUDIT',
      title: isReported
        ? `Bài viết bị báo cáo vi phạm (${p.report_count || 1}): ${p.title || p.post_id}`
        : `Bài viết cộng đồng cần hậu kiểm: ${p.title || p.post_id}`,
      subtitle: 'Nhấn để mở tab Kiểm duyệt cộng đồng',
      tab_index: 4,
      severity: isReported ? 'danger' : 'info',
    });
  }

  const activeDisputes = mockDisputes.filter(
    d => d.status === 'OPEN' || d.status === 'NEGOTIATING' || d.status === 'ESCALATED' || d.status === 'PENDING'
  );
  for (const d of activeDisputes) {
    const isEscalated = d.status === 'ESCALATED';
    notifications.push({
      id: `ntf-dsp-${d.dispute_id}`,
      type: 'DISPUTE',
      title: isEscalated
        ? `Khiếu nại leo thang cần Admin phân xử (#${d.order_id || d.dispute_id})`
        : `Khiếu nại đang mở (#${d.order_id || d.dispute_id})`,
      subtitle: `${d.lab_name || 'Film Lab'} • ${d.reason || 'Nhấn để xử lý khiếu nại'}`,
      tab_index: 6,
      severity: isEscalated ? 'danger' : 'warning',
    });
  }

  return res.json({
    success: true,
    data: notifications,
  });
};
