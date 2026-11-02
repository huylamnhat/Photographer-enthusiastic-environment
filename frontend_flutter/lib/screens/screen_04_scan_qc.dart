import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ScanQCScreen extends StatefulWidget {
  final String orderId;

  const ScanQCScreen({super.key, this.orderId = 'ORD-2024-88412'});

  @override
  State<ScanQCScreen> createState() => _ScanQCScreenState();
}

class _ScanQCScreenState extends State<ScanQCScreen> {
  QCBatchModel? batch;
  bool isLoading = true;
  bool isReleasing = false;

  @override
  void initState() {
    super.initState();
    _loadBatch();
  }

  Future<void> _loadBatch() async {
    setState(() => isLoading = true);
    final data = await ApiService.getQCBatch(widget.orderId);
    setState(() {
      batch = data;
      isLoading = false;
    });
  }

  void _toggleFrame(QCFrameModel frame) async {
    if (batch == null) return;
    final nextStatus = frame.qcStatus == 'PASSED' ? 'FLAGGED' : 'PASSED';
    final defect = nextStatus == 'FLAGGED' ? 'Vết bụi quang học / xước' : null;

    final success = await ApiService.toggleFrameQC(batch!.orderId, frame.frameId, nextStatus, defect);
    if (success) {
      setState(() {
        frame.qcStatus = nextStatus;
        frame.defectType = defect;
        batch!.passedFrames = batch!.frames.where((f) => f.qcStatus == 'PASSED').length;
        batch!.flaggedFrames = batch!.frames.where((f) => f.qcStatus == 'FLAGGED').length;
      });
    }
  }

  void _handleRelease() async {
    if (batch == null) return;
    setState(() => isReleasing = true);
    final success = await ApiService.approveAndRelease(batch!.orderId);
    setState(() => isReleasing = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: LabColors.secondary),
              SizedBox(width: 8),
              Text('Phê duyệt Archive thành công!'),
            ],
          ),
          content: Text(
            'Đơn hàng ${batch!.orderId} đã được ký số kiểm định QC hoàn tất.\n'
            '${batch!.passedFrames} tệp ảnh đã tự động nạp vào Digital Film Archive của khách hàng.',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LabColors.secondary, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Xong'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final b = batch!;

    return Scaffold(
      backgroundColor: LabColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Operational Meta Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tải File Scan & Kiểm định QC',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${b.orderId} / Khách: Lê Hoàng Nam • 02 cuộn Kodak Portra 400 (135/36) • C-41 FRESH (37.8°C)',
                      style: const TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 13, color: LabColors.onSurfaceVariant),
                    ),
                  ],
                ),
                // Stats Pills
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: LabColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LabColors.outlineVariant, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      _buildPill('ĐÃ TẢI LÊN', '${b.totalFiles}/${b.totalFiles} TIỆP', LabColors.onSurface),
                      const SizedBox(width: 12),
                      _buildPill('ĐÃ ĐẠT QC', '${b.passedFrames}/${b.totalFiles} FRAME', LabColors.secondary),
                      const SizedBox(width: 12),
                      _buildPill('GẮN CỜ LỖI', '${b.flaggedFrames.toString().padLeft(2, '0')} CẦN XỬ LÝ', LabColors.error),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 1: Resumable Upload Bay
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cloud_sync, color: LabColors.primary, size: 18),
                            SizedBox(width: 8),
                            Text(
                              '1. CÔNG CỤ RESUMABLE UPLOAD TỰ ĐỘNG',
                              style: TextStyle(fontFamily: 'IBM Plex Sans', fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          'CHUNK SIZE: 64MB • PARALLEL: 4 THREADS',
                          style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.archive_outlined, size: 36, color: LabColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Đang tải lên: ${b.totalFiles}/${b.totalFiles} tệp TIFF 16-bit (3.4 GB)',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  const Text('100% Hoàn tất', style: TextStyle(fontFamily: 'IBM Plex Mono', color: LabColors.secondary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: 1.0,
                                backgroundColor: LabColors.surfaceContainerHigh,
                                color: LabColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tốc độ: ${b.speed} • MD5 Checksum: ${b.md5Checksum}',
                                style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, color: LabColors.outline),
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
            const SizedBox(height: 20),

            // Section 2: QC Frames Grid (72 frames)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 18, color: LabColors.primary),
                    SizedBox(width: 8),
                    Text(
                      '2. DANH SÁCH KIỂM ĐỊNH TỪNG KHUNG HÌNH (QC FRAMES)',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LabColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: isReleasing ? null : _handleRelease,
                  icon: const Icon(Icons.verified, size: 18),
                  label: Text(isReleasing ? 'Đang chuyển giao...' : 'Phê duyệt & Trả file vào Archive'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Frame Grid View
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: b.frames.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final frame = b.frames[index];
                final isPassed = frame.qcStatus == 'PASSED';

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _toggleFrame(frame),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                frame.thumbUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: LabColors.surfaceContainerHigh,
                                  child: const Icon(Icons.image, color: LabColors.outline),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    '#${frame.frameNumber.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isPassed ? LabColors.secondary : LabColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isPassed ? Icons.check : Icons.warning_amber,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                frame.filename,
                                style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 9, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                isPassed ? 'ĐẠT CHUẨN' : (frame.defectType ?? 'GẮN CỜ'),
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isPassed ? LabColors.secondary : LabColors.error,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String title, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 9, color: LabColors.outline)),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

