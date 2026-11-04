import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../models/archive_photo_model.dart';

class PhotoDetailScreen extends StatefulWidget {
  final ArchivePhotoModel? photo;
  final Map<String, dynamic>? photoData;

  const PhotoDetailScreen({super.key, this.photo, this.photoData});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.photo?.isFavorite ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.photo?.title ?? (widget.photoData?['title'] ?? 'Quán cà phê dốc số 4, Đà Lạt');
    final imageUrl = widget.photo?.imageUrl ?? (widget.photoData?['image'] ?? MockTestAssets.samplePhoto1);
    final camera = widget.photo?.metadata.camera ?? (widget.photoData?['camera'] ?? 'Canon AE-1 Program');
    final lens = widget.photo?.metadata.lens ?? (widget.photoData?['lens'] ?? 'FD 50mm f/1.4');
    final film = widget.photo?.metadata.filmStock ?? (widget.photoData?['film'] ?? 'Kodak Portra 400');
    final scanner = widget.photo?.metadata.process ?? (widget.photoData?['scanner'] ?? 'Noritsu HS-1800');
    final exif = widget.photo != null
        ? '${widget.photo!.metadata.shutterSpeed} • ${widget.photo!.metadata.aperture} • ISO ${widget.photo!.metadata.iso}'
        : (widget.photoData?['exif'] ?? '1/250s • f/2.8 • ISO 400');
    final dimensions = widget.photo?.metadata.dimensions ?? '6048 x 4032 (24.1 MP)';
    final fileSize = widget.photo?.metadata.fileSize ?? (widget.photoData?['fileSize'] ?? '18.4 MB TIFF');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: AppTypography.cardTitle.copyWith(color: Colors.white, fontSize: 13),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
              size: 20,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã tạo liên kết chia sẻ bảo mật (hết hạn sau 7 ngày)')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pinch & Zoom Viewer
          Expanded(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Center(
                child: MockTestAssets.image(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),

          // Tactile EXIF Metadata Sheet (Stitch APP-CUS-15)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('METADATA EXIF & THÔNG SỐ SCAN', style: AppTypography.labelCaps),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(
                          'MASTER FILE',
                          style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.secondary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Metadata table
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaBox('THIẾT BỊ CHỤP', camera, lens),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetaBox('DÒNG PHIM & EXIF', film, exif),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaBox('MÁY QUÉT LAB', scanner, 'Tone ấm Noritsu'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetaBox('ĐỘ PHÂN GIẢI', dimensions, fileSize),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Download Original File Button
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đang tải file $fileSize chất lượng gốc từ máy chủ...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download, size: 16),
                          const SizedBox(width: 8),
                          Text('Tải xuống file gốc $fileSize', style: AppTypography.button),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaBox(String label, String value, String sub) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            sub,
            style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.inkMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
