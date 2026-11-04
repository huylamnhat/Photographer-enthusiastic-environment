import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LabUploadScanTab extends StatefulWidget {
  const LabUploadScanTab({super.key});

  @override
  State<LabUploadScanTab> createState() => _LabUploadScanTabState();
}

class _LabUploadScanTabState extends State<LabUploadScanTab> {
  final _orderIdController = TextEditingController(text: 'ORD-2026-8802');
  final _rollCodeController = TextEditingController(text: 'ROLL-ILFORD-03');
  final _scannerController = TextEditingController(text: 'Noritsu HS-1800');
  bool _qcColorBalance = true;
  bool _qcDustScratch = true;
  bool _isUploading = false;
  bool _isDone = false;

  void _submitUpload() {
    setState(() => _isUploading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _isDone = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File scan TIFF đã được nạp tự động vào Digital Film Archive của khách hàng!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tải File Scan & Kiểm Định Chất Lượng QC', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('Upload file scan độ phân giải cao (.JPG, .TIFF), kiểm tra chuẩn màu sắc và tự động đồng bộ vào Digital Film Archive của khách hàng',
                style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
            const SizedBox(height: 24),

            Container(
              constraints: const BoxConstraints(maxWidth: 720),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order and Roll Info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MÃ ĐƠN HÀNG XỬ LÝ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _orderIdController,
                              decoration: const InputDecoration(hintText: 'ORD-2026-...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('MÃ CUỘN PHIM (ROLL CODE)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _rollCodeController,
                              decoration: const InputDecoration(hintText: 'ROLL-...'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('THIẾT BỊ MÁY SCAN THỰC HIỆN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _scannerController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.scanner, color: AppColors.inkMuted, size: 20)),
                  ),
                  const SizedBox(height: 20),

                  // Drag & Drop Upload Zone
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                        const SizedBox(height: 10),
                        const Text('Kéo thả file ảnh scan hoặc bấm để duyệt tệp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text('Hỗ trợ .JPG, .TIFF 16-bit dung lượng tối đa 25MB / frame', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                        const SizedBox(height: 8),
                        Text('Đã đính kèm: 36 frames scan từ mẻ Noritsu_03.zip', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quality Control Checklist
                  const Text('TIÊU CHUẨN KIỂM ĐỊNH CHẤT LƯỢNG (QC CHECKLIST)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    dense: true,
                    title: const Text('Độ sạch bề mặt: Đã khử bụi và không có vệt xước trên dải âm bản', style: TextStyle(fontSize: 13)),
                    value: _qcDustScratch,
                    onChanged: (v) => setState(() => _qcDustScratch = v!),
                  ),
                  CheckboxListTile(
                    dense: true,
                    title: const Text('Màu sắc & Contrast: Cân bằng trắng trung tính, chi tiết vùng tối (Shadow) rõ nét', style: TextStyle(fontSize: 13)),
                    value: _qcColorBalance,
                    onChanged: (v) => setState(() => _qcColorBalance = v!),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : _submitUpload,
                      icon: _isUploading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(_isDone ? 'Đã nạp file vào Archive thành công!' : 'Xác nhận đạt chuẩn QC & Nạp vào Archive',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

