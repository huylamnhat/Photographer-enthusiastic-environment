import 'package:flutter/material.dart';

/// Thẻ hiển thị chỉ số vận hành toàn nền tảng (KPI) kèm tỷ lệ tăng trưởng
/// dành cho định hướng mở rộng bảng điều khiển trên cổng Web Admin.
class AdminPlatformKpiCard extends StatelessWidget {
  final String title;
  final String metricValue;
  final String growthText;
  final bool isPositiveTrend;
  final IconData icon;

  const AdminPlatformKpiCard({
    super.key,
    required this.title,
    required this.metricValue,
    required this.growthText,
    this.isPositiveTrend = true,
    this.icon = Icons.analytics_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final Color trendBg = isPositiveTrend
        ? const Color(0xFFECFDF5)
        : const Color(0xFFFEF2F2);
    final Color trendFg = isPositiveTrend
        ? const Color(0xFF047857)
        : const Color(0xFFB91C1C);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Icon(icon, size: 20, color: const Color(0xFF475569)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            metricValue,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trendBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$growthText so với kỳ trước',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: trendFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nhãn hiển thị mức độ ưu tiên giải quyết khiếu nại dành cho quản trị viên.
class AdminDisputeSeverityBadge extends StatelessWidget {
  final String severityCode;

  const AdminDisputeSeverityBadge({
    super.key,
    required this.severityCode,
  });

  @override
  Widget build(BuildContext context) {
    final upper = severityCode.trim().toUpperCase();

    late final String label;
    late final Color bgColor;
