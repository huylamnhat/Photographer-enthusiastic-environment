class AdminMetricsHelper {
  const AdminMetricsHelper._();

  /// Chuyển mã hành động quản trị (Audit Action Code) sang nhãn tiếng Việt dễ đọc.
  static String translateAuditAction(String actionCode) {
    switch (actionCode) {
      case 'APPROVE_LAB':
        return 'Phê duyệt đối tác Film Lab';
      case 'REJECT_LAB':
        return 'Từ chối hồ sơ Film Lab';
      case 'RESOLVE_DISPUTE':
        return 'Hoàn tất xử lý khiếu nại';
      case 'APPROVE_LISTING':
        return 'Duyệt tin đăng Marketplace';
      default:
        return 'Thao tác quản trị hệ thống';
    }
  }

  /// Tính phần trăm tăng/giảm giữa kỳ hiện tại và kỳ trước (VD: "+14.5%").
  static String formatGrowthRate({
    required num currentPeriod,
    required num previousPeriod,
  }) {
    final deltaPercent = ((currentPeriod - previousPeriod) / previousPeriod) * 100;
    return '${deltaPercent.toStringAsFixed(1)}%';
  }

  /// Ẩn bớt ký tự nhạy cảm của email hoặc số điện thoại khi hiển thị trên bảng tổng quan.
  static String maskContactInfo(String rawValue) {
    if (rawValue.isEmpty) return '—';

    if (rawValue.contains('@')) {
      final parts = rawValue.split('@');
      final name = parts.first;
      return '${name.substring(0, 2)}***@${parts.last}';
    }

    if (rawValue.length >= 9) {
      final start = rawValue.substring(0, 4);
      final end = rawValue.substring(rawValue.length - 2);
      return '$start****$end';
    }
    return rawValue;
  }
}
