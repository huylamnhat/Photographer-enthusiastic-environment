import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AdminAuditLogsTab extends StatelessWidget {
  const AdminAuditLogsTab({super.key});

  final List<Map<String, dynamic>> _logs = const [
    {
      'actor': 'Vũ Minh Tuấn (SYS_ADMIN)',
      'time': '2026-10-27 07:02:14',
      'action': 'LOCK_USER_ACCOUNT',
      'target': 'USR-DN-099 (Hoàng Văn Bách)',
      'reason': 'Phát hiện spam bài viết quảng cáo hóa chất không nhãn mác',
      'ip': '113.161.44.18',
    },
    {
      'actor': 'Hệ thống tự động (CRON_TASK)',
      'time': '2026-10-27 06:00:00',
      'action': 'CALCULATE_SLA_COMPLIANCE',
      'target': '185 Film Labs',
      'reason': 'Chốt chỉ số SLA ca đêm, cảnh báo Nadir Atelier đạt 87.2%',
      'ip': '127.0.0.1 (INTERNAL)',
    },
    {
      'actor': 'Vũ Minh Tuấn (SYS_ADMIN)',
      'time': '2026-10-26 18:30:22',
      'action': 'APPROVE_MARKETPLACE_LISTING',
      'target': 'MKT-POST-890 (Canon F-1 Lake Placid)',
      'reason': 'Đã kiểm tra số seri máy và tem cơ khí hợp lệ',
      'ip': '113.161.44.18',
    },
    {
      'actor': 'Vũ Minh Tuấn (SYS_ADMIN)',
      'time': '2026-10-26 14:15:00',
      'action': 'REFUND_TRANSACTION_APPROVED',
      'target': 'ORD-2026-8799 / Khách: Nguyễn Lan',
      'reason': 'Đền bù lỗi xước phim cuộn Cinestill 800T (50.000đ)',
      'ip': '113.161.44.18',
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
                  Text('WEB-ADM-09 // NHẬT KÝ KIỂM TOÁN HỆ THỐNG', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Audit Trail Ghi vết Hành vi Chỉ huy', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đang kết xuất nhật ký kiểm toán sang tệp CSV...')),
                  );
                },
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: const Text('Xuất CSV (Chỉ đọc)'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2.5),
                3: FlexColumnWidth(2.5),
                4: FlexColumnWidth(4),
                5: FlexColumnWidth(1.8),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  children: [
                    _th('AI THỰC HIỆN'),
                    _th('THỜI GIAN'),
                    _th('THAO TÁC AUDIT'),
                    _th('ĐỐI TƯỢNG TÁC ĐỘNG'),
                    _th('LÝ DO GIẢI TRÌNH BẮT BUỘC'),
                    _th('ĐỊA CHỈ IP'),
                  ],
                ),
                ..._logs.map((log) => TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5))),
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(log['actor'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(log['time'], style: AppTypography.dataMono)),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(log['action'], style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.primary)),
                      ),
                    ),
                    Padding(padding: const EdgeInsets.all(12), child: Text(log['target'], style: AppTypography.tableCell)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(log['reason'], style: AppTypography.caption)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(log['ip'], style: AppTypography.dataMono)),
                  ],
                )),
              ],
            ),
          ),
        ],
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

