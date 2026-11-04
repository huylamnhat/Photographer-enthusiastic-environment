import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';

class LabClaimsTab extends StatefulWidget {
  const LabClaimsTab({super.key});

  @override
  State<LabClaimsTab> createState() => _LabClaimsTabState();
}

class _LabClaimsTabState extends State<LabClaimsTab> {
  final List<Map<String, dynamic>> _claims = [
    {
      'id': 'CLM-2026-081',
      'orderId': 'ORD-2024-88412',
      'customer': 'Lê Hoàng Nam',
      'issue': 'Khách phản ánh ảnh quét frame #14 bị vệt bụi nhỏ góc phải',
      'amount': '50.000đ',
      'status': 'WAITING_LAB',
      'photo': MockTestAssets.photoFilmStripExpose,
      'time': '35 phút trước',
    },
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
              Text('WEB-LAB-07 // XỬ LÝ KHIẾU NẠI & THƯƠNG LƯỢNG', style: AppTypography.labelCaps),
              SizedBox(height: 4),
              Text('Trung tâm Thương lượng Đền bù với Khách hàng', style: AppTypography.pageTitle),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _claims.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, idx) {
                final c = _claims[idx];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 80,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.outline)),
                      child: MockTestAssets.image(c['photo'], width: 100, height: 80, borderRadius: BorderRadius.circular(6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${c['id']} · Đơn: ${c['orderId']}', style: AppTypography.dataMono.copyWith(color: AppColors.primary)),
                              const SizedBox(width: 8),
                              Text('Khách: ${c['customer']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(c['issue'], style: AppTypography.body),
                          const SizedBox(height: 4),
                          Text('Thời gian: ${c['time']} · Số tiền tranh chấp: ${c['amount']}', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã gửi đề xuất tặng cuộn phim mới và voucher giảm 50% cho khách!')),
                            );
                          },
                          icon: const Icon(Icons.card_giftcard, size: 14),
                          label: const Text('Tặng cuộn film đền bù'),
                        ),
                        const SizedBox(height: 6),
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã chuyển tiếp khiếu nại lên Quản trị viên can thiệp')),
                            );
                          },
                          child: const Text('Chuyển Admin phân xử'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
