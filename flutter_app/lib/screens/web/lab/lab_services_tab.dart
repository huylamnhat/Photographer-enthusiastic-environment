import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class LabServicesTab extends StatefulWidget {
  const LabServicesTab({super.key});

  @override
  State<LabServicesTab> createState() => _LabServicesTabState();
}

class _LabServicesTabState extends State<LabServicesTab> {
  final List<Map<String, dynamic>> _packages = [
    {
      'name': 'Tráng & Scan 135 Color C-41 (Tiêu chuẩn M)',
      'process': 'C-41 Noritsu HS-1800',
      'price': 50000,
      'sla': '12 giờ',
      'status': 'ACTIVE',
    },
    {
      'name': 'Tráng & Scan 135 ECN-2 Cine (Tẩy than)',
      'process': 'ECN-2 Thủ công',
      'price': 80000,
      'sla': '24 giờ',
      'status': 'ACTIVE',
    },
    {
      'name': 'Tráng & Scan 120 Medium Format (C-41 / B&W)',
      'process': 'Jobo ATL-1500 / Frontier SP-3000',
      'price': 90000,
      'sla': '16 giờ',
      'status': 'ACTIVE',
    },
    {
      'name': 'Gói Scan Cao Cấp TIFF 16-bit Uncompressed',
      'process': 'Noritsu HS-1800 (6048x4032px)',
      'price': 120000,
      'sla': '24 giờ',
      'status': 'PAUSED',
    },
  ];

  final List<Map<String, dynamic>> _priceAuditTrail = [
    {
      'service': 'Tráng & Scan 135 Color C-41',
      'oldPrice': '45.000đ',
      'newPrice': '50.000đ',
      'date': '2026-02-15 10:00',
      'reason': 'Điều chỉnh giá hóa chất Kodak C-41 Developer nhập khẩu tăng 12%',
      'changedBy': 'Trần Văn Đức (Owner)',
    },
    {
      'service': 'Tráng & Scan 135 ECN-2 Cine',
      'oldPrice': '75.000đ',
      'newPrice': '80.000đ',
      'date': '2026-01-20 14:30',
      'reason': 'Tăng chi phí phụ gia tẩy than Remjet và nước rửa lọc ion',
      'changedBy': 'Trần Văn Đức (Owner)',
    },
  ];

  void _showAddServiceModal() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final slaCtrl = TextEditingController(text: '12 giờ');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Thêm Gói Dịch Vụ Mới', style: AppTypography.cardTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên gói dịch vụ')),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá niêm yết (VNĐ)')),
            const SizedBox(height: 12),
            TextField(controller: slaCtrl, decoration: const InputDecoration(labelText: 'SLA cam kết trả file')),
          ],
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                setState(() {
                  _packages.add({
                    'name': nameCtrl.text,
                    'process': 'C-41 Tiêu chuẩn',
                    'price': int.tryParse(priceCtrl.text) ?? 50000,
                    'sla': slaCtrl.text,
                    'status': 'ACTIVE',
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Lưu gói dịch vụ'),
          ),
        ],
      ),
    );
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
                  Text('WEB-LAB-05 // DỊCH VỤ & BẢNG GIÁ', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Cấu hình Gói Dịch Vụ & Lịch Sử Đổi Giá', style: AppTypography.pageTitle),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddServiceModal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tạo gói dịch vụ mới (+)'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Active Service Packages Table (Flex 6)
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('DANH MỤC GÓI ĐANG PHỤC VỤ (${_packages.length})', style: AppTypography.labelCaps),
                            const Text('SLA CAM KẾT', style: AppTypography.labelCaps),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _packages.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, idx) {
                          final pkg = _packages[idx];
                          final isActive = pkg['status'] == 'ACTIVE';
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pkg['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text('${pkg['process']} · Cam kết: ${pkg['sla']}', style: AppTypography.caption),
                                    ],
                                  ),
                                ),
                                Text('${pkg['price']} đ', style: AppTypography.dataMono.copyWith(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                Switch(
                                  value: isActive,
                                  activeColor: AppColors.secondary,
                                  onChanged: (v) {
                                    setState(() => pkg['status'] = v ? 'ACTIVE' : 'PAUSED');
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Audit Trail Panel (Flex 4)
              Expanded(
                flex: 4,
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
                      const Row(
                        children: [
                          Icon(Icons.history_edu_outlined, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('LỊCH SỬ ĐỔI GIÁ (AUDIT TRAIL)', style: AppTypography.cardTitle),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Mọi biến động giá được ghi vết minh bạch để bảo vệ quyền lợi người dùng', style: AppTypography.caption),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      ..._priceAuditTrail.map((audit) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(audit['service'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(audit['date'], style: AppTypography.caption),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(audit['oldPrice'], style: const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.inkMuted, fontSize: 11)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(audit['newPrice'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Lý do: ${audit['reason']}', style: AppTypography.caption),
                              const SizedBox(height: 4),
                              Text('Bởi: ${audit['changedBy']}', style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
