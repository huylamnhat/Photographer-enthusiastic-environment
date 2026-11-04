import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/web_api_service.dart';

class AdminLabApprovalTab extends StatefulWidget {
  const AdminLabApprovalTab({super.key});

  @override
  State<AdminLabApprovalTab> createState() => _AdminLabApprovalTabState();
}

class _AdminLabApprovalTabState extends State<AdminLabApprovalTab> {
  List<dynamic> _pendingLabs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final list = await WebApiService().getAdminPendingLabs();
    if (mounted) {
      setState(() {
        _pendingLabs = list;
        _isLoading = false;
      });
    }
  }

  void _handleReview(int index, String action) async {
    final app = _pendingLabs[index];
    await WebApiService().reviewLabApplication(app['application_id'], action);

    setState(() {
      _pendingLabs.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'APPROVE'
              ? 'Đã phê duyệt mở tiệm Film Lab: ${app['name']}!'
              : 'Đã từ chối hồ sơ lab: ${app['name']}'),
          backgroundColor: action == 'APPROVE' ? AppColors.success : AppColors.danger,
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
          const Text('Thẩm Định & Duyệt Đối Tác Mở Tiệm Film Lab', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text('Kiểm tra điều kiện kỹ thuật máy scan, quy chuẩn phòng tối và xử lý hóa chất môi trường',
              style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 20),

          if (_pendingLabs.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: AppColors.secondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text('Hiện không có hồ sơ tiệm Film Lab nào chờ thẩm định', style: TextStyle(color: AppColors.inkMuted, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _pendingLabs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final lab = _pendingLabs[index];
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
                            Text(lab['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(4)),
                              child: const Text('CHỜ THẨM ĐỊNH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 16, color: AppColors.inkMuted),
                            const SizedBox(width: 6),
                            Text('Chủ tiệm: ${lab['owner_name']} • Hotline: ${lab['phone']} • Email: ${lab['email']}',
                                style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.inkMuted),
                            const SizedBox(width: 6),
                            Text('${lab['address']} (${lab['city']})', style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.surfaceSunken, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• Giấy phép đăng ký: ${lab['business_license']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('• Thiết bị máy scan đăng ký: ${(lab['scanner_models'] as List).join(', ')}', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Text('• Ghi chú kiểm định: ${lab['inspection_note']}', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                              icon: const Icon(Icons.close, size: 16),
                              label: const Text('Từ chối hồ sơ'),
                              onPressed: () => _handleReview(index, 'REJECT'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text('Phê duyệt mở tiệm Lab'),
                              onPressed: () => _handleReview(index, 'APPROVE'),
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

