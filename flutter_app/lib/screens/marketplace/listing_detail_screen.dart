import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../models/listing_model.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel? listing;
  final Map<String, dynamic>? listingData;

  const ListingDetailScreen({super.key, this.listing, this.listingData});

  @override
  Widget build(BuildContext context) {
    final title = listing?.title ?? (listingData?['title'] ?? 'Canon QL17 GIII (Black Limited Edition)');
    final price = listing != null
        ? '${listing!.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ'
        : (listingData?['price'] ?? '4.800.000đ');
    final condition = listing?.condition ?? (listingData?['condition'] ?? '98% Đo sáng & màn trập chuẩn xác');
    final category = listing?.category ?? (listingData?['category'] ?? 'Rangefinder');
    final location = listing?.location ?? (listingData?['location'] ?? 'Hoàn Kiếm, Hà Nội');
    final sellerName = listing?.sellerName ?? (listingData?['seller'] ?? 'Nguyễn Hoàng Anh');
    final sellerAvatar = listing?.sellerAvatar ?? (listingData?['sellerAvatar'] ?? MockTestAssets.avatarCustomer);
    final image = listing?.imageUrls.isNotEmpty == true ? listing!.imageUrls.first : (listingData?['image'] ?? MockTestAssets.marketplaceCam1);
    final desc = listing?.description ??
        (listingData?['desc'] ??
            'Máy phiên bản đen nguyên bản hiếm gặp. Viewfinder sáng rõ, thấu kính không mốc xước rễ tre. Đã dán lại mút xốp chống lọt sáng buồng film.');

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.surfaceRaised,
            foregroundColor: AppColors.ink,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  MockTestAssets.image(image, fit: BoxFit.cover),
                  Positioned(
                    top: 40,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ĐÃ TIỀN KIỂM KỸ THUẬT',
                        style: AppTypography.dataMono.copyWith(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Price and title
                  Text(price, style: AppTypography.metric.copyWith(fontSize: 24, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(title, style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(category, style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(condition, style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.secondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mechanical Inspection Checklist (Stitch APP-CUS-17)
                  Text('BIÊN BẢN TIỀN KIỂM CƠ HỌC (MINILAB AUDIT)', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      children: [
                        _buildAuditItem('Màn trập cơ khí (Shutter speeds)', 'Đúng tốc độ từ 1/4s đến 1/500s', true),
                        const SizedBox(height: 6),
                        _buildAuditItem('Hệ thống đo sáng (Light meter)', 'Kim đo sáng phản xạ nhạy theo khẩu độ', true),
                        const SizedBox(height: 6),
                        _buildAuditItem('Thấu kính & Lớp phủ (Coating)', 'Kính trong, không xước dăm, không rễ tre', true),
                        const SizedBox(height: 6),
                        _buildAuditItem('Mút xốp buồng tối (Light seals)', 'Đã thay mới mút nhung chống lọt sáng', true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('MÔ TẢ CHI TIẾT TỪ NGƯỜI BÁN', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Text(desc, style: AppTypography.bodySmall.copyWith(height: 1.4)),
                  ),
                  const SizedBox(height: 16),

                  // Seller profile card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: MockTestAssets.image(sellerAvatar, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sellerName, style: AppTypography.cardTitle),
                              const SizedBox(height: 2),
                              Text(location, style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('ĐÃ XÁC MINH', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.secondary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang mở hộp thoại nhắn tin nội bộ với người bán...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outline),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.ink),
                      const SizedBox(width: 6),
                      Text('Nhắn tin', style: AppTypography.button.copyWith(color: AppColors.ink)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã tạo giao dịch giữ cọc an toàn qua sàn MiniLab.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('Mua ngay', style: AppTypography.button),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditItem(String label, String value, bool passed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(passed ? Icons.check_circle : Icons.error, size: 14, color: passed ? AppColors.secondary : AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.cardTitle.copyWith(fontSize: 11)),
              Text(value, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted)),
            ],
          ),
        ),
      ],
    );
  }
}
