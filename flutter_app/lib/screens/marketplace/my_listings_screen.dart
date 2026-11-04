import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myListings = [
      {
        'id': 'mkt-001',
        'title': 'Canon QL17 GIII (Black Limited Edition)',
        'price': '4.800.000đ',
        'status': 'ĐANG HIỂN THỊ',
        'image': MockTestAssets.marketplaceCam1,
        'views': '124 lượt xem',
      },
    ];

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
          'QUẢN LÝ TIN ĐĂNG CÁ NHÂN',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: myListings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = myListings[index];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: MockTestAssets.image(item['image'] as String, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String, style: AppTypography.cardTitle.copyWith(fontSize: 13), maxLines: 1),
                      const SizedBox(height: 2),
                      Text(item['price'] as String, style: AppTypography.metric.copyWith(fontSize: 14, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              item['status'] as String,
                              style: AppTypography.dataMono.copyWith(fontSize: 8, color: AppColors.secondary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(item['views'] as String, style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 18, color: AppColors.inkMuted),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa tin')),
                    const PopupMenuItem(value: 'sold', child: Text('Đánh dấu đã bán')),
                    const PopupMenuItem(value: 'delete', child: Text('Gỡ tin đăng')),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
