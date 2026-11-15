import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';
import '../../../core/services/web_api_service.dart';

class LabProfileTab extends StatefulWidget {
  const LabProfileTab({super.key});

  @override
  State<LabProfileTab> createState() => _LabProfileTabState();
}

class _LabProfileTabState extends State<LabProfileTab> {
  final _labNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _negativeDaysCtrl = TextEditingController(text: '30');
  final _scanDaysCtrl = TextEditingController(text: '60');
  final _hoursCtrl = TextEditingController(text: '08:30 - 20:00 (Hàng ngày)');
  double _rating = 4.9;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await WebApiService().getLabProfile();
    if (!mounted || p.isEmpty) return;
    setState(() {
      _labNameCtrl.text = (p['name'] ?? '').toString();
      _phoneCtrl.text = (p['phone'] ?? '').toString();
      _emailCtrl.text = (p['email'] ?? '').toString();
      _addressCtrl.text = (p['address'] ?? '').toString();
      _rating = (p['rating'] as num?)?.toDouble() ?? 4.9;
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
                  Text('WEB-LAB-06 // HỒ SƠ TIỆM LAB CÔNG KHAI (SQL SERVER)', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Cấu hình Thông Tin Tiệm & Chính Sách Lưu Bản Âm', style: AppTypography.pageTitle),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await WebApiService().updateLabProfile({
                    'name': _labNameCtrl.text,
                    'phone': _phoneCtrl.text,
                    'email': _emailCtrl.text,
                    'address': _addressCtrl.text,
                  });
                  if (!context.mounted) return;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật hồ sơ công khai của tiệm lên cơ sở dữ liệu!')),
                  );
                },
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Lưu thay đổi hồ sơ'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      const Text('THÔNG TIN LIÊN HỆ & ĐỊA ĐIỂM', style: AppTypography.labelCaps),
                      const SizedBox(height: 12),
                      TextField(controller: _labNameCtrl, decoration: const InputDecoration(labelText: 'TÊN THƯƠNG HIỆU LAB')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'HOTLINE TIỆM'))),
                          const SizedBox(width: 12),
                          Expanded(child: TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'EMAIL LIÊN HỆ'))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'ĐỊA CHỈ TRỤ SỞ CHÍNH')),
                      const SizedBox(height: 12),
                      TextField(controller: _hoursCtrl, decoration: const InputDecoration(labelText: 'GIỜ MỞ CỬA TIẾP NHẬN PHIM')),
                      const SizedBox(height: 20),

                      const Text('CHÍNH SÁCH LƯU TRỮ BẢO VỆ PHIM (RÀNG BUỘC PHÁP LÝ):', style: AppTypography.labelCaps),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _negativeDaysCtrl,
                              decoration: const InputDecoration(
                                labelText: 'LƯU GIỮ ÂM BẢN (NGÀY)',
                                helperText: 'Thời hạn khách đến nhận lại cuộn phim cắt bao',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _scanDaysCtrl,
                              decoration: const InputDecoration(
                                labelText: 'LƯU FILE CLOUD (NGÀY)',
                                helperText: 'Thời hạn file scan gốc lưu trữ trên Cloud',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

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
                      const Text('XEM TRƯỚC THẺ TIỆM TRÊN APP KHÁCH HÀNG', style: AppTypography.labelCaps),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MockTestAssets.image(
                              MockTestAssets.labCoverCroplab,
                              height: 110,
                              width: double.infinity,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(_labNameCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified, size: 14, color: AppColors.secondary),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(_addressCtrl.text, style: AppTypography.caption),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Giữ âm bản: ${_negativeDaysCtrl.text} ngày', style: AppTypography.caption),
                                      Text('Đánh giá: $_rating ★', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                                    ],
                                  ),
                                ],
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
