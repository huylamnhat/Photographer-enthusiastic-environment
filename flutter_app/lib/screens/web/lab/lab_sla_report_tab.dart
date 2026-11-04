import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class LabSlaReportTab extends StatefulWidget {
  const LabSlaReportTab({super.key});

  @override
  State<LabSlaReportTab> createState() => _LabSlaReportTabState();
}

class _LabSlaReportTabState extends State<LabSlaReportTab> {
  final List<Map<String, dynamic>> _orderHistory = [
    {
      'id': 'ORD-2026-8801',
      'customer': 'Nguyễn Hoàng Anh',
      'service': 'Tráng & Scan 135 Color C-41',
      'rolls': 2,
      'amount': '100.000đ',
      'date': '01/03/2026',
      'sla': '10h / 12h (Đạt)',
      'rating': '5.0 ★',
    },
    {
      'id': 'ORD-2026-8802',
      'customer': 'Trần Văn Đức',
      'service': 'Tráng ECN-2 Cine 500T',
      'rolls': 1,
      'amount': '80.000đ',
      'date': '02/03/2026',
      'sla': '22h / 24h (Đạt)',
      'rating': '4.8 ★',
    },
    {
      'id': 'ORD-2026-8803',
      'customer': 'Lê Quang Huy',
      'service': 'Tráng B&W D-76 Thủ công',
      'rolls': 3,
      'amount': '210.000đ',
      'date': '03/03/2026',
      'sla': '14h / 16h (Đạt)',
      'rating': '5.0 ★',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEB-LAB-08 // LỊCH SỬ ĐƠN & BÁO CÁO HIỆU SUẤT SLA', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Chỉ Số Vận Hành & Lịch Sử Tráng Scan', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: const Text('Xuất báo cáo thuế & doanh thu'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3 KPI cards for Lab Performance
          Row(
            children: [
              _buildSummaryCard('TỶ LỆ TRẢ FILE ĐÚNG SLA', '98.6%', '+0.4% so với tuần trước', AppColors.secondary),
              const SizedBox(width: 16),
              _buildSummaryCard('TỔNG SẢN LƯỢNG THÁNG NÀY', '614 cuộn', 'C-41: 420 | B&W: 134 | ECN-2: 60', AppColors.primary),
              const SizedBox(width: 16),
              _buildSummaryCard('DOANH THU THỰC NHẬN TIỆM', '34.850.000đ', 'Sau khi trừ 10% phí nền tảng', AppColors.ink),
            ],
          ),
          const SizedBox(height: 24),

          // History Table
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(2.5),
                2: FlexColumnWidth(4),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(2),
                6: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  children: [
                    _th('MÃ ĐƠN'),
                    _th('KHÁCH HÀNG'),
                    _th('GÓI DỊCH VỤ'),
                    _th('SỐ CUỘN'),
                    _th('DOANH THU'),
                    _th('THỜI GIAN SLA'),
                    _th('ĐÁNH GIÁ'),
                  ],
                ),
                ..._orderHistory.map((h) => TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5))),
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['id'], style: AppTypography.dataMono.copyWith(color: AppColors.primary))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['service'], style: AppTypography.tableCell)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['rolls'].toString(), style: AppTypography.dataMono)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['amount'], style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold))),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(h['sla'], style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['rating'], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String val, String sub, Color valColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.labelCaps),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valColor)),
            const SizedBox(height: 4),
            Text(sub, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _th(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(title, style: AppTypography.labelCaps),
    );
  }
}
