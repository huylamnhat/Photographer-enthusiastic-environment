import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';

class AdminServicesTab extends StatefulWidget {
  const AdminServicesTab({super.key});

  @override
  State<AdminServicesTab> createState() => _AdminServicesTabState();
}

class _AdminServicesTabState extends State<AdminServicesTab> {
  List<Map<String, dynamic>> _standards = [];
  List<Map<String, dynamic>> _labServices = [];

  @override
  void initState() {
    super.initState();
    _loadAdminServices();
  }

  Future<void> _loadAdminServices() async {
    final res = await WebApiService().getAdminServices();
    final rawStandards = (res['standards'] as List?) ?? [];
    final rawPackages = (res['packages'] as List?) ?? [];

    if (!mounted) return;
    setState(() {
      _standards = rawStandards.map<Map<String, dynamic>>((s) {
        final code = (s['code'] ?? 'C-41').toString();
        return {
          'code': 'PROC-$code',
          'name': (s['name'] ?? '').toString(),
          'temp': code == 'B&W' ? '20.0°C - 24.0°C' : (code == 'ECN-2' ? '41.1°C (Prebath)' : '37.8°C ± 0.1°'),
          'formats': (s['formats'] ?? '135, 120').toString(),
          'status': (s['status'] ?? 'ACTIVE').toString(),
        };
      }).toList();

      _labServices = rawPackages.map<Map<String, dynamic>>((p) {
        return {
          'package_id': (p['package_id'] ?? '').toString(),
          'lab': (p['lab_name'] ?? 'CropLab Hà Nội').toString(),
          'service': (p['name'] ?? '').toString(),
          'price': '${p['price'] ?? 0}đ',
          'sla': '${p['estimated_hours'] ?? 12}h',
          'enabled': (p['status'] ?? 'ACTIVE') == 'ACTIVE',
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
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dịch vụ & Quy chuẩn kỹ thuật', style: AppTypography.pageTitle),
            ],
          ),
          const SizedBox(height: 24),

          const Text('1. QUY TRÌNH TRÁNG CHUẨN', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(2.5),
                3: FlexColumnWidth(2.5),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  children: [
                    _th('MÃ QUY TRÌNH'),
                    _th('TÊN QUY TRÌNH'),
                    _th('NHIỆT ĐỘ CHUẨN'),
                    _th('KHỔ PHIM'),
                  ],
                ),
                ..._standards.map((s) => TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5))),
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(s['code'], style: AppTypography.dataMono.copyWith(color: AppColors.primary))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s['temp'], style: AppTypography.dataMono)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(s['formats'], style: AppTypography.tableCell)),
                  ],
                )),
              ],
            ),
          ),
          const SizedBox(height: 28),

          const Text('2. DỊCH VỤ CỦA CÁC TIỆM LAB', style: AppTypography.labelCaps),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(1.8),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  children: [
                    _th('TIỆM LAB'),
                    _th('GÓI DỊCH VỤ'),
                    _th('GIÁ NIÊM YẾT'),
                    _th('TRẢ ẢNH'),
                    _th('TRẠNG THÁI'),
                  ],
                ),
                ..._labServices.map((ls) => TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5))),
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(ls['lab'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(ls['service'], style: AppTypography.tableCell)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(ls['price'], style: AppTypography.dataMono.copyWith(color: AppColors.primary))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(ls['sla'], style: AppTypography.dataMono)),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Switch(
                            value: ls['enabled'],
                            activeThumbColor: AppColors.secondary,
                            onChanged: (v) async {
                              await WebApiService().updateLabService(
                                ls['package_id'],
                                {'status': v ? 'ACTIVE' : 'INACTIVE'},
                              );
                              if (!context.mounted) return;
                              setState(() => ls['enabled'] = v);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(v ? 'Đã mở lại dịch vụ' : 'Đã ẩn an toàn dịch vụ vi phạm!')),
                              );
                            },
                          ),
                          Text(ls['enabled'] ? 'Hiển thị' : 'Đã ẩn', style: AppTypography.caption),
                        ],
                      ),
                    ),
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
