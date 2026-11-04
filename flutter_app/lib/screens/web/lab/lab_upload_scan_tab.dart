import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';

class LabUploadScanTab extends StatefulWidget {
  const LabUploadScanTab({super.key});

  @override
  State<LabUploadScanTab> createState() => _LabUploadScanTabState();
}

class _LabUploadScanTabState extends State<LabUploadScanTab> {
  final _orderIdController = TextEditingController(text: 'ORD-2024-88412');
  final _rollCodeController = TextEditingController(text: 'ROLL-VISION3-500T-01');
  final _scannerController = TextEditingController(text: 'Fuji Frontier SP-3000');
  String _scanResolution = 'TIFF 16-bit (4800 dpi)';
  bool _qcColorBalance = true;
  bool _qcDustScratch = true;
  bool _isUploading = false;
  bool _isDone = false;

  final List<String> _frames = [
    MockTestAssets.photoHanoiAfternoon,
    MockTestAssets.photoStreetVendor,
    MockTestAssets.photoSaigonCafe,
    MockTestAssets.photoDalatPine,
    MockTestAssets.photoHoiAnNight,
    MockTestAssets.photoFilmStripExpose,
  ];

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
            content: Text('File scan TIFF đã được nạp tự động vào Digital Film Archive của khách hàng! (Kích hoạt khóa an toàn thu hồi 24h)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
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
                  Text('WEB-LAB-04 // TẢI FILE SCAN & QC', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Nạp Ảnh Scan & Kiểm Định Chất Lượng', style: AppTypography.pageTitle),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: AppColors.secondary),
                    SizedBox(width: 6),
                    Text('Chế độ an toàn: Thu hồi & Ghi đè trong 24 giờ', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Upload Form & QC Checklist (Flex 5)
              Expanded(
                flex: 5,
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
                      const Text('THÔNG TIN ĐƠN & THIẾT BỊ QUÉT', style: AppTypography.labelCaps),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _orderIdController,
                              decoration: const InputDecoration(labelText: 'MÃ ĐƠN HÀNG'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _rollCodeController,
                              decoration: const InputDecoration(labelText: 'MÃ CUỘN PHIM'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _scannerController,
                              decoration: const InputDecoration(labelText: 'MÁY SCAN SỬ DỤNG'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _scanResolution,
                              decoration: const InputDecoration(labelText: 'ĐỘ PHÂN GIẢI & ĐỊNH DẠNG'),
                              items: const [
                                DropdownMenuItem(value: 'JPG Standard (3000x2000)', child: Text('JPG Standard')),
                                DropdownMenuItem(value: 'JPG Hi-Res (4800x3200)', child: Text('JPG Hi-Res')),
                                DropdownMenuItem(value: 'TIFF 16-bit (4800 dpi)', child: Text('TIFF 16-bit Master')),
                              ],
                              onChanged: (v) => setState(() => _scanResolution = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Drag Drop Mock Area
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_upload_outlined, size: 36, color: AppColors.primary),
                              const SizedBox(height: 8),
                              const Text('Kéo thả thư mục tệp scan hoặc nhấn để chọn file ZIP / TIFF', style: AppTypography.cardTitle),
                              const SizedBox(height: 4),
                              Text('Đã nạp 36 frames TIFF (Dung lượng: 1.42 GB) · Đã quét mã checksum MD5', style: AppTypography.caption),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('CHECKLIST KIỂM ĐỊNH CHẤT LƯỢNG (QC GATE):', style: AppTypography.labelCaps),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _qcColorBalance,
                        onChanged: (v) => setState(() => _qcColorBalance = v!),
                        title: const Text('Đã cân chỉnh Base màu âm bản & độ tương phản chuẩn profile hãng'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: AppColors.secondary,
                      ),
                      CheckboxListTile(
                        value: _qcDustScratch,
                        onChanged: (v) => setState(() => _qcDustScratch = v!),
                        title: const Text('Đã chạy Digital ICE khử bụi quang học & soi thủ công không vệt xước'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: AppColors.secondary,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          if (_isDone)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                              onPressed: () {
                                setState(() => _isDone = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã thu hồi gói scan trong cửa sổ 24 giờ!')),
                                );
                              },
                              icon: const Icon(Icons.undo, size: 16),
                              label: const Text('Thu hồi & Ghi đè (24h)'),
                            ),
                          const Spacer(),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                            onPressed: _isUploading ? null : _submitUpload,
                            icon: _isUploading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.check, size: 16),
                            label: Text(_isUploading ? 'Đang nạp Cloud...' : 'Xác nhận QC & Nạp vào Archive'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Frame-by-Frame QC Grid Preview (Flex 5)
              Expanded(
                flex: 5,
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
                          const Text('LƯỚI KIỂM SOÁT TỪNG FRAME (36 FRAMES)', style: AppTypography.labelCaps),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.surfaceSunken, borderRadius: BorderRadius.circular(4)),
                            child: const Text('100% Zoom Check', style: AppTypography.dataMono),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: _frames.length,
                        itemBuilder: (ctx, idx) {
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              MockTestAssets.image(
                                _frames[idx],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              Positioned(
                                left: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    '#${(idx + 1).toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4,
                                bottom: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Trạng thái kiểm tra: 6/6 frames hiển thị đạt chuẩn phơi sáng & lấy nét đúng tâm hạt.', style: AppTypography.caption),
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
