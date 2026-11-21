import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';
import '../../../core/services/web_api_service.dart';

class LabClaimsTab extends StatefulWidget {
  const LabClaimsTab({super.key});

  @override
  State<LabClaimsTab> createState() => _LabClaimsTabState();
}

class _LabClaimsTabState extends State<LabClaimsTab> {
  List<Map<String, dynamic>> _claims = [];

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    final data = await WebApiService().getLabDisputes();
    if (!mounted) return;
    setState(() {
      final mapped = data.map<Map<String, dynamic>>((d) {
        final ev = (d['evidence_urls'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final msgs = (d['messages'] as List?) ?? [];
        String compNote = (d['compensation_note'] ?? '').toString();
        if (compNote.isEmpty && msgs.isNotEmpty) {
          final lastMsg = msgs.last;
          if (lastMsg is Map && lastMsg['text'] != null) {
            compNote = lastMsg['text'].toString();
          }
        }
        final st = (d['status'] ?? 'NEGOTIATING').toString().toUpperCase();
        final isCompleted = st == 'COMPENSATED' || st == 'RESOLVED' || st == 'REFUNDED';
        return {
          'id': (d['dispute_id'] ?? '').toString(),
          'orderId': (d['order_id'] ?? '').toString(),
          'customer': (d['customer_name'] ?? '').toString(),
          'issue': (d['description'] ?? d['issue_type'] ?? '').toString(),
          'amount': '${d['amount_requested'] ?? 0}đ',
          'status': st,
          'isCompleted': isCompleted,
          'compNote': compNote,
          'photo': ev.isNotEmpty ? ev.first : MockTestAssets.photoFilmStripExpose,
          'time': (d['created_at'] ?? '').toString().split('T').first,
        };
      }).toList();

      // Đẩy các khiếu nại đã hoàn thành xuống dưới, giữ khiếu nại cần xử lý lên trên
      mapped.sort((a, b) {
        final aDone = a['isCompleted'] == true ? 1 : 0;
        final bDone = b['isCompleted'] == true ? 1 : 0;
        return aDone.compareTo(bDone);
      });
      _claims = mapped;
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
                  Text('Xử lý Khiếu nại', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadClaims,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Làm mới'),
              ),
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
            child: _claims.isEmpty
                ? const Center(child: Text('Không có khiếu nại nào tại Lab', style: AppTypography.cardTitle))
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _claims.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, idx) {
                      final c = _claims[idx];
                      final st = c['status'].toString().toUpperCase();
                      final isCompensated = st == 'COMPENSATED' || st == 'RESOLVED';
                      final isEscalated = st == 'ESCALATED';
                      final isRefunded = st == 'REFUNDED';
                      final isDone = isCompensated || isRefunded;
                      final compNote = (c['compNote'] ?? '').toString();

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
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isCompensated || isRefunded
                                            ? AppColors.successBg
                                            : (isEscalated ? AppColors.dangerBg : AppColors.surfaceSunken),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isCompensated
                                            ? 'ĐÃ ĐỀN BÙ CUỘN FILM'
                                            : (isRefunded
                                                ? 'ĐÃ HOÀN TIỀN'
                                                : (isEscalated ? 'ĐÃ CHUYỂN ADMIN' : 'ĐANG THƯƠNG LƯỢNG')),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isCompensated || isRefunded
                                              ? AppColors.secondary
                                              : (isEscalated ? AppColors.danger : AppColors.primary),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(c['issue'], style: AppTypography.body),
                                if (compNote.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.card_giftcard, size: 14, color: AppColors.secondary),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Phản hồi đền bù đã gửi khách: $compNote',
                                            style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text('Ngày tạo: ${c['time']} · Số tiền tranh chấp: ${c['amount']}', style: AppTypography.caption),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (!isDone)
                            Column(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                                  onPressed: () async {
                                    await WebApiService().replyLabDispute(
                                      c['id'],
                                      'Lab đã đền bù tặng 01 cuộn phim mới, voucher giảm 50% và hỗ trợ scan lại miễn phí cho khách hàng.',
                                    );
                                    await _loadClaims();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.secondary,
                                        content: Text('Đã gửi thông báo đền bù cuộn film mới cho khách ${c['customer']} (Đơn ${c['orderId']})!'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.card_giftcard, size: 14),
                                  label: const Text('Tặng cuộn film đền bù'),
                                ),
                                if (!isEscalated) ...[
                                  const SizedBox(height: 6),
                                  OutlinedButton(
                                    onPressed: () async {
                                      await WebApiService().replyLabDispute(
                                        c['id'],
                                        'Lab đề nghị chuyển hồ sơ lên Admin Tổng Sàn phân xử.',
                                        escalate: true,
                                      );
                                      await _loadClaims();
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã chuyển tiếp khiếu nại lên Quản trị viên Admin can thiệp!')),
                                      );
                                    },
                                    child: const Text('Chuyển Admin phân xử'),
                                  ),
                                ],
                              ],
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
                                  SizedBox(width: 6),
                                  Text(
                                    'Đã hoàn thành',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
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
