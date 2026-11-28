import 'package:flutter/material.dart';

/// Thẻ giao diện bổ trợ hiển thị trạng thái bể hóa chất tráng phim (C-41 / ECN-2 / B&W)
/// dành cho định hướng mở rộng quản lý buồng tối trên cổng Web Lab.
class LabChemicalTankCard extends StatelessWidget {
  final String tankName;
  final String processType;
  final double targetTempCelsius;
  final int processedRolls;
  final int maxCapacityRolls;

  const LabChemicalTankCard({
    super.key,
    required this.tankName,
    required this.processType,
    this.targetTempCelsius = 37.8,
    required this.processedRolls,
    this.maxCapacityRolls = 40,
  });

  @override
  Widget build(BuildContext context) {
    final safeMax = maxCapacityRolls <= 0 ? 1 : maxCapacityRolls;
    final ratio = (processedRolls / safeMax).clamp(0.0, 1.0);
    final isWarning = ratio >= 0.75;
    final isCritical = ratio >= 0.95;

    final Color accentColor = isCritical
        ? const Color(0xFFDC2626)
        : isWarning
            ? const Color(0xFFD97706)
            : const Color(0xFF059669);

    final String statusText = isCritical
        ? 'Cần thay thuốc tráng'
        : isWarning
            ? 'Cần châm bù hóa chất'
            : 'Sẵn sàng chạy mẻ mới';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tankName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$processType • ${targetTempCelsius.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã tráng: $processedRolls / $safeMax cuộn',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Khung tóm tắt số liệu ca làm việc để xem trước khi xuất biểu mẫu đối soát trên Web Lab.
class LabShiftSummaryBanner extends StatelessWidget {
  final String shiftTitle;
  final int completedOrders;
  final int totalRollsScanned;

  const LabShiftSummaryBanner({
    super.key,
    required this.shiftTitle,
    required this.completedOrders,
    required this.totalRollsScanned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_outlined, size: 18, color: Color(0xFF0F172A)),
              const SizedBox(width: 8),
              Text(
                shiftTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Text(
            'Đơn hoàn tất: $completedOrders',
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
          Text(
            'Tổng cuộn đã scan: $totalRollsScanned',
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
          ),
        ],
      ),
    );
  }
}
