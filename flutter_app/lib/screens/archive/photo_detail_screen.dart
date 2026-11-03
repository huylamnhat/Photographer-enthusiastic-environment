import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/archive_photo_model.dart';

class PhotoDetailScreen extends StatelessWidget {
  final ArchivePhotoModel photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    final meta = photo.metadata;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(photo.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(photo.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tải file scan gốc độ phân giải cao...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Viewer
          Expanded(
            child: InteractiveViewer(
              child: Center(
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Metadata Sheet
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'THÔNG SỐ ẢNH & METADATA EXIF',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.5),
                    ),
                    Text(meta.fileSize, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),

                // Grid 2 columns of metadata
                Row(
                  children: [
                    Expanded(child: _buildMetaItem('Máy ảnh (Body)', meta.camera, Icons.camera_alt_outlined)),
                    Expanded(child: _buildMetaItem('Ống kính (Lens)', meta.lens, Icons.camera)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildMetaItem('Cuộn Film & ISO', '${meta.filmStock} (ISO ${meta.iso})', Icons.camera_roll_outlined)),
                    Expanded(child: _buildMetaItem('Khẩu độ & Tốc độ', '${meta.aperture} • ${meta.shutterSpeed}', Icons.shutter_speed)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildMetaItem('Quy trình & Tiệm Lab', '${meta.process} - ${meta.lab}', Icons.science_outlined)),
                    Expanded(child: _buildMetaItem('Độ phân giải', meta.dimensions, Icons.aspect_ratio)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.inkMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
              Text(
                value,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

