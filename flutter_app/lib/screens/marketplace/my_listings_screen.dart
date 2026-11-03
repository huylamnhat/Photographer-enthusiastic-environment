import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/marketplace_provider.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketplace = context.watch<MarketplaceProvider>();
    final myList = marketplace.listings.where((l) => l.sellerId == 'usr-001').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý tin đăng cá nhân'),
      ),
      body: myList.isEmpty
          ? const Center(
              child: Text('Bạn chưa có tin đăng bán thiết bị nào.', style: TextStyle(color: AppColors.inkMuted)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = myList[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrls.isNotEmpty ? item.imageUrls.first : 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
                              const SizedBox(height: 2),
                              Text('${item.price.toInt()}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.successBg, borderRadius: BorderRadius.circular(4)),
                                child: const Text('ĐANG HIỂN THỊ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.success)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: AppColors.inkMuted),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

