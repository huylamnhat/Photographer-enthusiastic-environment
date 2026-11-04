import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AdminServicesTab extends StatefulWidget {
  const AdminServicesTab({super.key});

  @override
  State<AdminServicesTab> createState() => _AdminServicesTabState();
}

class _AdminServicesTabState extends State<AdminServicesTab> {
  final List<Map<String, dynamic>> _standards = [
    {'code': 'PROC-C41', 'name': 'Màu âm bản tiêu chuẩn (C-41)', 'temp': '37.8°C ± 0.1°', 'formats': '135, 120, 220', 'status': 'ACTIVE'},
    {'code': 'PROC-BW', 'name': 'Đen trắng thủ công (B&W D-76 / Xtol)', 'temp': '20.0°C - 24.0°C', 'formats': '135, 120, 4x5 Large', 'status': 'ACTIVE'},
    {'code': 'PROC-ECN2', 'name': 'Phim điện ảnh có lớp than (ECN-2)', 'temp': '41.1°C (Prebath)', 'formats': '135, 120', 'status': 'ACTIVE'},
    {'code': 'PROC-E6', 'name': 'Đảo màu dương bản Slide (E-6)', 'temp': '38.0°C ± 0.2°', 'formats': '135, 120', 'status': 'ACTIVE'},
  ];

  final List<Map<String, dynamic>> _labServices = [
    {'lab': 'CropLab Hà Nội', 'service': 'Tráng & Scan C-41 Noritsu HS-1800', 'price': '50.000đ', 'sla': '12h', 'enabled': true},
    {'lab': 'CropLab Hà Nội', 'service': 'Tráng ECN-2 Tẩy than thủ công', 'price': '80.000đ', 'sla': '24h', 'enabled': true},
    {'lab': 'LLab Sài Gòn', 'service': 'Tráng & Scan Frontier SP-3000', 'price': '65.000đ', 'sla': '8h', 'enabled': true},
    {'lab': 'Nadir Darkroom', 'service': 'Tráng B&W đẩy sáng Push +2', 'price': '90.000đ', 'sla': '48h', 'enabled': true},
    {'lab': 'RetroTone Hanoi', 'service': 'Gói Scan thô TIFF 16-bit 4800dpi', 'price': '120.000đ', 'sla': '36h', 'enabled': false},
  ];

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
              Text('WEB-ADM-07 // QUY CHUẨN KỸ THUẬT & DỊCH VỤ LAB', style: AppTypography.labelCaps),
              SizedBox(height: 4),
              Text('Quản lý Danh mục Kỹ thuật Toàn Sàn', style: AppTypography.pageTitle),
            ],
          ),
          const SizedBox(height: 24),

          // Section 1: Standard Processes
          const Text('1. QUY CHUẨN HOÁ CHẤT & NHIỆT ĐỘ HỆ THỐNG', style: AppTypography.labelCaps),
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
                    _th('MÃ QUY CHUẨN'),
                    _th('TÊN QUY TRÌNH HÓA CHẤT'),
                    _th('NHIỆT ĐỘ BỂ CHUẨN'),
                    _th('KHỔ PHIM HỖ TRỢ'),
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

          // Section 2: Lab Services with Emergency Killswitch
          const Text('2. BẢNG DỊCH VỤ ĐỐI TÁC LAB (CÔNG TẮC AN TOÀN TOÀN SÀN)', style: AppTypography.labelCaps),
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
                    _th('CAM KẾT SLA'),
                    _th('TRẠNG THÁI / ẨN'),
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
                            activeColor: AppColors.secondary,
                            onChanged: (v) {
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

