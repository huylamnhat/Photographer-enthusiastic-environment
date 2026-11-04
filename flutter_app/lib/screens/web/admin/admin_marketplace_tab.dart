import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AdminMarketplaceTab extends StatefulWidget {
  const AdminMarketplaceTab({super.key});

  @override
  State<AdminMarketplaceTab> createState() => _AdminMarketplaceTabState();
}

class _AdminMarketplaceTabState extends State<AdminMarketplaceTab> {
  final List<Map<String, dynamic>> _pendingListings = [
    {
      'id': 'mkt-002',
      'title': 'Bộ máy ảnh Olympus OM-1 + Lens Zuiko 50mm f/1.4',
      'category': 'Máy ảnh SLR cơ khí',
      'seller_name': 'Lê Quang Huy',
      'price': 3600000,
      'condition': '95% Nguyên bản, view sáng rõ, cơ tốc chuẩn',
      'location': 'Bình Thạnh, TP.HCM',
      'image_url': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800',
    },
    {
      'id': 'mkt-003',
      'title': 'Ống kính Canon FD 35mm f/2 Concave huyền thoại',
      'category': 'Ống kính (Lens)',
      'seller_name': 'Hoàng Long',
      'price': 6200000,
      'condition': 'Kính đẹp không mốc rễ, vòng khẩu nảy',
      'location': 'Hoàn Kiếm, Hà Nội',
      'image_url': 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=800',
    }
  ];

  void _moderate(int index, bool approve) {
    final title = _pendingListings[index]['title'];
    setState(() => _pendingListings.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approve ? 'Đã duyệt tin: $title lên sàn!' : 'Đã từ chối tin: $title'),
        backgroundColor: approve ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiền Kiểm Tin Đăng Sàn Thiết Bị (Marketplace)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text('Chính sách kiểm duyệt 100%: Bảo vệ người mua khỏi hàng giả, thiết bị lỗi kẹt màn trập',
              style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 20),

          if (_pendingListings.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: AppColors.success.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text('Tất cả tin đăng máy ảnh và ống kính đã được duyệt sạch!', style: TextStyle(color: AppColors.inkMuted, fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _pendingListings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = _pendingListings[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item['image_url'], width: 120, height: 100, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text('${item['price']}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Người bán: ${item['seller_name']} • Khu vực: ${item['location']}', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                              const SizedBox(height: 6),
                              Text('Tình trạng: ${item['condition']}', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                    onPressed: () => _moderate(index, false),
                                    child: const Text('Từ chối tin'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () => _moderate(index, true),
                                    child: const Text('Phê duyệt lên sàn'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

