import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/archive_provider.dart';
import 'photo_detail_screen.dart';
import 'album_detail_screen.dart';

class ArchiveGalleryScreen extends StatelessWidget {
  const ArchiveGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final archive = context.watch<ArchiveProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho ảnh số (Archive)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: 'Albums',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlbumDetailScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Tải hàng loạt',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tạo tệp nén ZIP tải xuống ảnh gốc TIFF/JPG...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Album chips filter
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: AppColors.surfaceRaised,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildAlbumChip(context, 'Tất cả', archive.selectedAlbum == 'Tất cả', () {
                  archive.selectAlbum('Tất cả');
                }),
                _buildAlbumChip(context, 'Mùa thu Hà Nội 2026', archive.selectedAlbum == 'Mùa thu Hà Nội 2026', () {
                  archive.selectAlbum('Mùa thu Hà Nội 2026');
                }),
                _buildAlbumChip(context, 'Chuyến đi Ninh Bình', archive.selectedAlbum == 'Chuyến đi Ninh Bình', () {
                  archive.selectAlbum('Chuyến đi Ninh Bình');
                }),
              ],
            ),
          ),
          const Divider(height: 1),

          // Photo Grid
          Expanded(
            child: archive.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => archive.fetchPhotos(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: archive.photos.length,
                      itemBuilder: (context, index) {
                        final photo = archive.photos[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PhotoDetailScreen(photo: photo)),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.outline),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        photo.thumbnailUrl,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () => archive.toggleFavorite(photo.photoId),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              photo.isFavorite ? Icons.favorite : Icons.favorite_border,
                                              size: 16,
                                              color: photo.isFavorite ? Colors.redAccent : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        photo.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${photo.metadata.filmStock} • ${photo.metadata.camera}',
                                        style: const TextStyle(fontSize: 10, color: AppColors.inkMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumChip(BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

