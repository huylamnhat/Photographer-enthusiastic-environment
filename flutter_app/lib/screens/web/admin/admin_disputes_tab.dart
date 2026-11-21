import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';
import '../../../core/services/web_api_service.dart';

class AdminDisputesTab extends StatefulWidget {
  const AdminDisputesTab({super.key});

  @override
  State<AdminDisputesTab> createState() => _AdminDisputesTabState();
}

class _AdminDisputesTabState extends State<AdminDisputesTab> {
  List<Map<String, dynamic>> _disputes = [];
  int _selectedDisputeIdx = 0;

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    final data = await WebApiService().getAdminDisputes();
    if (!mounted) return;
    setState(() {
      final mapped = data.map<Map<String, dynamic>>((d) {
        final ev = (d['evidence_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final rawStatus = (d['status'] ?? 'OPEN').toString().toUpperCase();
        final isDone = ['RESOLVED', 'REFUNDED', 'COMPENSATED'].contains(rawStatus);
        final statusLabel = rawStatus == 'REFUNDED'
            ? 'ĐÃ HOÀN TIỀN'
            : (rawStatus == 'COMPENSATED'
                ? 'ĐÃ ĐỀN BÙ'
                : (rawStatus == 'RESOLVED' ? 'ĐÃ GIẢI QUYẾT' : 'ĐANG MỞ'));
        return {
          'id': (d['dispute_id'] ?? '').toString(),
          'orderId': (d['order_id'] ?? '').toString(),
          'customer': (d['customer_name'] ?? '').toString(),
          'lab': (d['lab_name'] ?? '').toString(),
          'issue': (d['issue_type'] ?? '').toString(),
          'amount': d['amount_requested'] ?? 0,
          'status': isDone ? 'RESOLVED' : 'OPEN',
          'statusLabel': statusLabel,
          'isCompleted': isDone,
          'time': (d['created_at'] ?? '').toString().split('T').first,
          'customerEvidence': ev.isNotEmpty ? ev.first : MockTestAssets.photoFilmStripExpose,
          'labEvidence': ev.length > 1 ? ev[1] : MockTestAssets.photoStreetVendor,
          'description': (d['description'] ?? '').toString(),
        };
      }).toList();

      // Đẩy các khiếu nại đã giải quyết/hoàn thành xuống dưới, giữ khiếu nại cần xử lý lên trên
      mapped.sort((a, b) {
        final aDone = a['isCompleted'] == true ? 1 : 0;
        final bDone = b['isCompleted'] == true ? 1 : 0;
        return aDone.compareTo(bDone);
      });
      _disputes = mapped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _disputes.isNotEmpty;
    final safeIdx = hasItems ? _selectedDisputeIdx.clamp(0, _disputes.length - 1) : 0;
    final d = hasItems ? _disputes[safeIdx] : null;

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
                  Text('Khiếu nại & Hoàn tiền', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadDisputes,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Làm mới'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (!hasItems)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Center(child: Text('Không có khiếu nại nào trong CSDL', style: AppTypography.cardTitle)),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        final isSel = idx == safeIdx;
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
                              (item['statusLabel'] ?? (isOpen ? 'ĐANG MỞ' : 'ĐÃ GIẢI QUYẾT')).toString(),
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

                if (d != null)
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${d['id']} // ĐƠN HÀNG: ${d['orderId']}', style: AppTypography.dataMono.copyWith(color: AppColors.primary)),
                                    Text(d['issue'], style: AppTypography.sectionHeading),
                                  ],
                                ),
                              ),
                              Text('${d['amount']} đ', style: AppTypography.metric.copyWith(fontSize: 22, color: AppColors.danger)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          const Text('NỘI DUNG GIẢI TRÌNH & THƯƠNG LƯỢNG:', style: AppTypography.labelCaps),
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

                          if (d['isCompleted'] != true && d['status'] == 'OPEN')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () async {
                                    await WebApiService().resolveDispute(d['id'], 'CLOSE');
                                    await _loadDisputes();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đã từ chối hoàn tiền & đóng khiếu nại.')),
                                    );
                                  },
                                  child: const Text('Bác bỏ khiếu nại'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                                  onPressed: () async {
                                    await WebApiService().resolveDispute(d['id'], 'APPROVE_REFUND');
                                    await _loadDisputes();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã duyệt giao dịch hoàn tiền ${d['amount']}đ cho khách ${d['customer']}!')),
                                    );
                                  },
                                  icon: const Icon(Icons.check_circle_outline, size: 16),
                                  label: const Text('Phê duyệt hoàn tiền (Refund)'),
                                ),
                              ],
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, size: 18, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Hồ sơ khiếu nại này đã hoàn thành (${d['statusLabel'] ?? 'ĐÃ GIẢI QUYẾT'}).',
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
