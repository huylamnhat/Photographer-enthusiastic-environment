import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';

class AdminAuditLogsTab extends StatefulWidget {
  const AdminAuditLogsTab({super.key});

  @override
  State<AdminAuditLogsTab> createState() => _AdminAuditLogsTabState();
}

class _AdminAuditLogsTabState extends State<AdminAuditLogsTab> {
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final data = await WebApiService().getAdminAuditLogs();
    if (!mounted) return;
    setState(() {
      _logs = data.map<Map<String, dynamic>>((l) {
        return {
          'actor': (l['actor'] ?? 'System').toString(),
          'time': (l['timestamp'] ?? '').toString(),
          'action': (l['action'] ?? '').toString(),
          'target': (l['entity'] ?? '').toString(),
          'reason': '${l['oldVal'] ?? ''} → ${l['newVal'] ?? ''}',
          'ip': (l['ip'] ?? '127.0.0.1').toString(),
        };
      }).toList();
    });
  }

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
                  Text('WEB-ADM-09 // NHẬT KÝ KIỂM TOÁN HỆ THỐNG (SQL SERVER)', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Audit Trail Ghi vết Hành vi Chỉ huy', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadLogs,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Tải lại từ CSDL'),
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
                    _th('DỮ LIỆU CŨ / MỚI (JSON)'),
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
