import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/web_api_service.dart';

class AdminDisputesTab extends StatefulWidget {
  const AdminDisputesTab({super.key});

  @override
  State<AdminDisputesTab> createState() => _AdminDisputesTabState();
}

class _AdminDisputesTabState extends State<AdminDisputesTab> {
  List<dynamic> _disputes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  void _loadDisputes() async {
    final list = await WebApiService().getAdminDisputes();
    if (mounted) {
      setState(() {
        _disputes = list;
        _isLoading = false;
      });
    }
  }

  void _handleRefund(int index) async {
    final d = _disputes[index];
    await WebApiService().resolveDispute(d['dispute_id'], 'APPROVE_REFUND');

    setState(() {
      d['status'] = 'REFUNDED';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã phê duyệt hoàn tiền ${d['amount_requested']}đ cho khách ${d['customer_name']} (Xử lý nội bộ)!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Xử Lý Khiếu Nại, Tranh Chấp & Duyệt Hoàn Tiền', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text('Trọng tài phân xử giữa Khách hàng và Film Lab khi có sự cố xước phim hoặc màu sắc scan không đạt',
              style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount: _disputes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final d = _disputes[index];
                final isRefunded = d['status'] == 'REFUNDED';

                return Container(
                  padding: const EdgeInsets.all(20),
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
                          Text('Mã khiếu nại: ${d['dispute_id']} (Đơn: ${d['order_id']})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRefunded ? AppColors.successBg : AppColors.warningBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isRefunded ? 'ĐÃ HOÀN TIỀN' : 'ĐANG THƯƠNG LƯỢNG',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isRefunded ? AppColors.success : AppColors.warning),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Khách hàng: ${d['customer_name']} ➔ Đối tác: ${d['lab_name']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Vấn đề: ${d['issue_type']}', style: const TextStyle(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Nội dung: ${d['description']}', style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Số tiền yêu cầu hoàn: ${d['amount_requested']}đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          if (!isRefunded)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              icon: const Icon(Icons.currency_exchange, size: 16),
                              label: const Text('Phê duyệt hoàn tiền (Nội bộ)'),
                              onPressed: () => _handleRefund(index),
                            )
                          else
                            const Row(
                              children: [
                                Icon(Icons.check_circle, size: 16, color: AppColors.success),
                                SizedBox(width: 6),
                                Text('Đã hoàn tiền thành công', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

