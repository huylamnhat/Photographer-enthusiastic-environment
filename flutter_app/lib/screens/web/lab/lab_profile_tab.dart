import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/mock/mock_test_assets.dart';
import '../../../core/services/web_api_service.dart';
import '../../../core/utils/local_image_picker.dart';

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
  final _qrUrlCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _accountNoCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  String? _pendingQrBase64;
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
      _qrUrlCtrl.text = (p['qr_image_url'] ?? '').toString();
      _bankNameCtrl.text = (p['bank_name'] ?? '').toString();
      _accountNoCtrl.text = (p['account_no'] ?? '').toString();
      _accountNameCtrl.text = (p['account_name'] ?? '').toString();
      _pendingQrBase64 = null;
      _rating = (p['rating'] as num?)?.toDouble() ?? 4.9;
    });
  }

  Future<void> _pickQrImage() async {
    final picked = await pickLocalImagesFromComputer(multiple: false, preserveOriginal: true);
    if (!mounted || picked.isEmpty) return;
    setState(() {
      _pendingQrBase64 = picked.first.dataUrl;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chọn ảnh QR: ${picked.first.name}. Hãy bấm "Lưu thay đổi hồ sơ" để lưu lên hệ thống.')),
    );
  }

  String _resolvePreviewQrUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('/')) {
      final origin = ApiConstants.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
      return '$origin$trimmed';
    }
    return trimmed;
  }

  Widget _buildQrPreviewBox() {
    final base64Src = _pendingQrBase64;
    if (base64Src != null && base64Src.contains(',')) {
      try {
        final bytes = Uint8List.fromList(base64Decode(base64Src.split(',').last));
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, width: 150, height: 150, fit: BoxFit.contain),
        );
      } catch (_) {}
    }

    final resolvedUrl = _resolvePreviewQrUrl(_qrUrlCtrl.text);
    if (resolvedUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          resolvedUrl,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, size: 42, color: AppColors.inkMuted),
        ),
      );
    }

    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        'Chưa có ảnh QR',
        style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
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
                  Text('Thông tin tiệm Lab', style: AppTypography.pageTitle),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await WebApiService().updateLabProfile({
                    'name': _labNameCtrl.text,
                    'phone': _phoneCtrl.text,
                    'email': _emailCtrl.text,
                    'address': _addressCtrl.text,
                    'qr_image_url': _qrUrlCtrl.text.trim(),
                    if (_pendingQrBase64 != null) 'qr_image_base64': _pendingQrBase64,
                    'bank_name': _bankNameCtrl.text.trim(),
                    'account_no': _accountNoCtrl.text.trim(),
                    'account_name': _accountNameCtrl.text.trim(),
                  });
                  await _loadProfile();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật hồ sơ & mã QR thanh toán của tiệm lên cơ sở dữ liệu!')),
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
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.outline),
                      const SizedBox(height: 16),
                      const Text(
                        'MÃ QR NHẬN CHUYỂN KHOẢN TRỰC TIẾP (NV TỰ KIỂM TRA TIỀN VÀO, KHÔNG QUA VÍ LAB):',
                        style: AppTypography.labelCaps,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQrPreviewBox(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _pickQrImage,
                                      icon: const Icon(Icons.upload_file, size: 16),
                                      label: const Text('Tải ảnh QR của bạn lên'),
                                    ),
                                    if (_pendingQrBase64 != null || _qrUrlCtrl.text.isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          setState(() {
                                            _pendingQrBase64 = null;
                                            _qrUrlCtrl.clear();
                                          });
                                        },
                                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.danger),
                                        label: const Text('Xóa ảnh QR', style: TextStyle(color: AppColors.danger)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _qrUrlCtrl,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'HOẶC DÁN LINK ẢNH QR',
                                    hintText: 'https://... hoặc để trống nếu tải ảnh từ máy',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _bankNameCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'NGÂN HÀNG (VD: VCB, MB, TCB)',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _accountNoCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'SỐ TÀI KHOẢN',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _accountNameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'TÊN CHỦ TÀI KHOẢN',
                                  ),
                                ),
                              ],
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
