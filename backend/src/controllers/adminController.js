const { 
  mockUsers, 
  mockLabs, 
  mockPendingLabs, 
  mockOrders, 
  mockListings, 
  mockCommunityPosts, 
  mockDisputes 
} = require('../data/mockStore');

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
      recent_orders: mockOrders.slice(0, 5)
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
  const user = mockUsers.find(u => u.user_id === id);
  if (!user) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
  }

  if (status) user.status = status;
  if (role) user.role = role;

  return res.json({
    success: true,
    message: 'Cập nhật tài khoản thành công',
    data: user
  });
};

exports.getPendingLabs = (req, res) => {
  return res.json({
    success: true,
    data: mockPendingLabs
  });
};

exports.reviewLabApplication = (req, res) => {
  const { id } = req.params;
  const { action, note } = req.body; // action: 'APPROVE' or 'REJECT'
  const appIndex = mockPendingLabs.findIndex(l => l.application_id === id);

  if (appIndex === -1) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy hồ sơ lab' });
  }

  const app = mockPendingLabs[appIndex];
  if (action === 'APPROVE') {
    app.status = 'APPROVED';
    // Add to approved labs
    const newLab = {
      lab_id: `lab-${Date.now().toString().slice(-4)}`,
      owner_id: `usr-lab-${Date.now().toString().slice(-4)}`,
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
      price_range: '50.000đ - 100.000đ',
      description: 'Tiệm lab đã qua thẩm định điều kiện cơ sở vật chất phòng tối và quy trình xử lý an toàn môi trường.',
      created_at: new Date().toISOString()
    };
    mockLabs.push(newLab);
  } else {
    app.status = 'REJECTED';
    app.inspection_note = note || 'Chưa đạt yêu cầu thẩm định giấy phép / thiết bị.';
  }

  return res.json({
    success: true,
    message: action === 'APPROVE' ? 'Đã phê duyệt mở tiệm Film Lab thành công' : 'Đã từ chối hồ sơ lab',
    data: app
  });
};

exports.getPendingMarketplace = (req, res) => {
  const pending = mockListings.filter(l => l.status === 'PENDING_REVIEW' || l.moderation_status === 'PENDING');
  return res.json({
    success: true,
    data: pending
  });
};

exports.moderateMarketplace = (req, res) => {
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

  return res.json({
    success: true,
    message: action === 'APPROVE' ? 'Đã duyệt tin đăng lên sàn' : 'Đã từ chối tin đăng',
    data: item
  });
};

exports.getReportedContent = (req, res) => {
  const reported = mockCommunityPosts.filter(p => p.status === 'REPORTED');
  return res.json({
    success: true,
    data: reported
  });
};

exports.moderateCommunityPost = (req, res) => {
  const { id } = req.params;
  const { action } = req.body; // 'HIDE' or 'DISMISS'
  const post = mockCommunityPosts.find(p => p.post_id === id);

  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  if (action === 'HIDE') {
    post.status = 'HIDDEN';
  } else {
    post.status = 'ACTIVE';
    post.report_count = 0;
  }

  return res.json({
    success: true,
    message: action === 'HIDE' ? 'Đã ẩn bài viết vi phạm khỏi diễn đàn' : 'Đã bỏ qua báo cáo',
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
  } else {
    dispute.status = 'RESOLVED';
    dispute.resolved_at = new Date().toISOString();
  }

  return res.json({
    success: true,
    message: resolution === 'APPROVE_REFUND' ? 'Đã duyệt hoàn tiền nội bộ thành công' : 'Đã đóng khiếu nại',
    data: dispute
  });
};

