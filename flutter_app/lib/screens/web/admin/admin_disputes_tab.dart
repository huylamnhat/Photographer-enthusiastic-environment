import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';

class AdminDisputesTab extends StatefulWidget {
  const AdminDisputesTab({super.key});

  @override
  State<AdminDisputesTab> createState() => _AdminDisputesTabState();
}

class _AdminDisputesTabState extends State<AdminDisputesTab> {
  final List<Map<String, dynamic>> _disputes = [
    {
      'id': 'DSP-2026-001',
      'orderId': 'ORD-2026-8801',
      'customer': 'Lê Hoàng Nam',
      'lab': 'Nadir Atelier',
      'issue': 'Lỗi tráng trầy xước cuộn Kodak Portra 400 120',
      'amount': 50000,
      'status': 'OPEN',
      'time': '14 phút trước',
      'customerEvidence': MockTestAssets.photoFilmStripExpose,
      'labEvidence': MockTestAssets.photoStreetVendor,
      'description': 'Khách hàng phản ánh cuộn Portra 400 có 2 vệt xước dọc kéo dài do con lăn máy tráng. Đề xuất hoàn 50.000đ tiền tráng hoặc tặng voucher đền bù.',
    },
    {
      'id': 'DSP-2026-002',
      'orderId': 'ORD-2026-8802',
      'customer': 'Đỗ Thùy Trang',
      'lab': 'Chợ Lớn Film Lab',
      'issue': 'Quá hạn trả tệp quét 48 giờ không thông báo lý do',
      'amount': 65000,
      'status': 'RESOLVED',
      'time': '2 giờ trước',
      'customerEvidence': MockTestAssets.photoHanoiAfternoon,
      'labEvidence': MockTestAssets.photoHanoiAfternoon,
      'description': 'Lab chậm trả ảnh do máy scan Frontier hỏng đèn halogen. Đã đồng ý hoàn 100% tiền quét 65.000đ cho khách.',
    },
  ];

  int _selectedDisputeIdx = 0;

  @override
  Widget build(BuildContext context) {
    final d = _disputes[_selectedDisputeIdx];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WEB-ADM-08 // KHIẾU NẠI & HOÀN TIỀN', style: AppTypography.labelCaps),
              SizedBox(height: 4),
              Text('Xử lý Tranh chấp & Phê duyệt Hoàn tiền', style: AppTypography.pageTitle),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Disputes List
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _disputes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, idx) {
                      final item = _disputes[idx];
                      final isSel = idx == _selectedDisputeIdx;
                      final isOpen = item['status'] == 'OPEN';
                      return ListTile(
                        selected: isSel,
                        selectedTileColor: AppColors.surfaceSunken,
                        title: Text(item['issue'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${item['id']} · ${item['customer']} vs ${item['lab']}\n${item['time']}', style: AppTypography.caption),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: isOpen ? AppColors.dangerBg : AppColors.successBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isOpen ? 'ĐANG MỞ' : 'ĐÃ GIẢI QUYẾT',
                            style: TextStyle(
                              color: isOpen ? AppColors.danger : AppColors.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () => setState(() => _selectedDisputeIdx = idx),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Evidence & Refund Action Panel
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${d['id']} // ĐƠN HÀNG: ${d['orderId']}', style: AppTypography.dataMono.copyWith(color: AppColors.primary)),
                              Text(d['issue'], style: AppTypography.sectionHeading),
                            ],
                          ),
                          Text('${d['amount']} đ', style: AppTypography.metric.copyWith(fontSize: 22, color: AppColors.danger)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      Text('NỘI DUNG GIẢI TRÌNH & THƯƠNG LƯỢNG:', style: AppTypography.labelCaps),
                      const SizedBox(height: 4),
                      Text(d['description'], style: AppTypography.body),

                      const SizedBox(height: 20),
                      const Text('ĐỐI CHIẾU BẰNG CHỨNG HÌNH ẢNH 2 BÊN:', style: AppTypography.labelCaps),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ẢNH LỖI PHÍA KHÁCH HÀNG:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger)),
                                const SizedBox(height: 6),
                                Container(
                                  height: 130,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.outline)),
                                  child: MockTestAssets.image(d['customerEvidence'], height: 130, borderRadius: BorderRadius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ẢNH TIẾP NHẬN PHÍA TIỆM LAB:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                const SizedBox(height: 6),
                                Container(
                                  height: 130,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.outline)),
                                  child: MockTestAssets.image(d['labEvidence'], height: 130, borderRadius: BorderRadius.circular(6)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Refund Decision Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() => d['status'] = 'RESOLVED');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã từ chối hoàn tiền & đóng khiếu nại.')),
                              );
                            },
                            child: const Text('Bác bỏ khiếu nại'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                            onPressed: () {
                              setState(() => d['status'] = 'RESOLVED');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã duyệt giao dịch hoàn tiền ${d['amount']}đ cho khách ${d['customer']}!')),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline, size: 16),
                            label: const Text('Phê duyệt hoàn tiền (Refund)'),
                          ),
                        ],
                      ),
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
