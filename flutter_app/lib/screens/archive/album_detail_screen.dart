import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';

class AlbumDetailScreen extends StatefulWidget {
  const AlbumDetailScreen({super.key});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  List<Map<String, dynamic>> _albums = [
    {
      'title': 'Mùa thu Hà Nội 2026 (ORD-2026-8801)',
      'count': 2,
      'cover': MockTestAssets.samplePhoto1,
      'roll': 'Kodak Portra 400 • CropLab Hà Nội',
      'date': '01/03/2026',
    },
    {
      'title': 'Phố cổ & Cà phê sáng (ORD-2026-8819)',
      'count': 1,
      'cover': MockTestAssets.samplePhoto2,
      'roll': 'Kodak Portra 400 • CropLab Hà Nội',
      'date': '01/03/2026',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final photos = await ApiService().getArchivePhotos();
    if (!mounted || photos.isEmpty) return;
    final grouped = <String, Map<String, dynamic>>{};
    for (final p in photos) {
      final name = p.albumName.isNotEmpty ? p.albumName : 'Album ${p.orderId}';
      if (!grouped.containsKey(name)) {
        grouped[name] = {
          'title': name,
          'count': 0,
          'cover': p.imageUrl.isNotEmpty ? p.imageUrl : MockTestAssets.samplePhoto1,
          'roll': '${p.metadata.filmStock} • ${p.metadata.lab}',
          'date': p.createdAt.split('T').first,
        };
      }
      grouped[name]!['count'] = (grouped[name]!['count'] as int) + 1;
    }
    setState(() {
      _albums = grouped.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final albums = _albums;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outline, height: 1),
        ),
        title: Text(
          'QUẢN LÝ ALBUM & BỘ SƯU TẬP',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tạo Album bộ sưu tập mới')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: albums.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final alb = albums[index];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MockTestAssets.image(alb['cover'] as String, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${alb['count']} frames',
                            style: AppTypography.dataMono.copyWith(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(alb['title'] as String, style: AppTypography.cardTitle),
                          const SizedBox(height: 2),
                          Text(alb['roll'] as String, style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted)),
                        ],
                      ),
                      Text(
                        alb['date'] as String,
                        style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
