import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AlbumDetailScreen extends StatelessWidget {
  const AlbumDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final albums = [
      {
        'title': 'Mùa thu Hà Nội 2026',
        'count': 36,
        'cover': 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
        'roll': 'Kodak Portra 400',
      },
      {
        'title': 'Chuyến đi Ninh Bình',
        'count': 24,
        'cover': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
        'roll': 'Fujifilm Pro 400H',
      },
      {
        'title': 'Đường phố đêm Sài Gòn',
        'count': 18,
        'cover': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800',
        'roll': 'Kodak Vision3 500T',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Album & Bộ sưu tập'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng tạo Album mới')),
              );
            },
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: albums.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final alb = albums[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    alb['cover'] as String,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(alb['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text('${alb['count']} ảnh scan • ${alb['roll']}', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã sao chép liên kết chia sẻ bộ sưu tập!')),
                          );
                        },
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

