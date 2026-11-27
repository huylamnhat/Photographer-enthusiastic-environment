class AdminMetricsHelper {
  const AdminMetricsHelper._();

  /// Chuyển mã hành động quản trị (Audit Action Code) sang nhãn tiếng Việt dễ đọc.
  static String translateAuditAction(String actionCode) {
    switch (actionCode.trim().toUpperCase()) {
      case 'APPROVE_LAB':
        return 'Phê duyệt đối tác Film Lab';
      case 'REJECT_LAB':
        return 'Từ chối hồ sơ Film Lab';
      case 'RESOLVE_DISPUTE':
        return 'Hoàn tất xử lý khiếu nại';
      case 'APPROVE_LISTING':
        return 'Duyệt tin đăng Marketplace';
      case 'HIDE_POST':
        return 'Ẩn bài viết vi phạm cộng đồng';
      case 'LOCK_USER':
        return 'Tạm khóa tài khoản người dùng';
      default:
        return 'Thao tác quản trị hệ thống';
    }
  }

  /// Tính phần trăm tăng/giảm giữa kỳ hiện tại và kỳ trước (VD: "+14.5%").
  static String formatGrowthRate({
    required num currentPeriod,
    required num previousPeriod,
  }) {
    if (previousPeriod <= 0) {
      return currentPeriod > 0 ? '+100.0%' : '0.0%';
    }
    final deltaPercent = ((currentPeriod - previousPeriod) / previousPeriod) * 100;
    final prefix = deltaPercent > 0 ? '+' : '';
    return '$prefix${deltaPercent.toStringAsFixed(1)}%';
  }

  /// Ẩn bớt ký tự nhạy cảm của email hoặc số điện thoại khi hiển thị trên bảng tổng quan.
  static String maskContactInfo(String rawValue) {
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return '—';

    if (trimmed.contains('@')) {
      final parts = trimmed.split('@');
      final name = parts.first;
      if (name.length <= 2) return '***@${parts.last}';
      return '${name.substring(0, 2)}***@${parts.last}';
    }

    if (trimmed.length >= 9) {
      final start = trimmed.substring(0, 3);
      final end = trimmed.substring(trimmed.length - 3);
      return '$start****$end';
    }
    return trimmed;
  }
}
