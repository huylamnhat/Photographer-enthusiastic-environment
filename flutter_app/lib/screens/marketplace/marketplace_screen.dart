import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import 'listing_detail_screen.dart';
import 'create_listing_screen.dart';
import 'my_listings_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'Tất cả';

  final List<Map<String, dynamic>> _mockListings = [
    {
      'id': 'mkt-001',
      'title': 'Canon QL17 GIII (Black Limited Edition)',
      'category': 'Rangefinder',
      'condition': '98% Đo sáng & màn trập chuẩn xác',
      'price': '4.800.000đ',
      'location': 'Hoàn Kiếm, Hà Nội',
      'seller': 'Nguyễn Hoàng Anh',
      'sellerAvatar': MockTestAssets.avatarCustomer,
      'image': MockTestAssets.marketplaceCam1,
      'lens': 'Canon 40mm f/1.7',
      'shutter': 'Cơ khí 1/4s - 1/500s + B',
      'meter': 'Pin PX625 đo sáng kim chỉ tốt',
      'verified': true,
      'desc': 'Máy phiên bản đen nguyên bản hiếm gặp. Viewfinder sáng rõ, thấu kính không mốc xước rễ tre. Đã dán lại mút xốp chống lọt sáng buồng film.',
    },
    {
      'id': 'mkt-002',
      'title': 'Leica M6 Classic 0.72x (Silver Chrome)',
      'category': 'Rangefinder',
      'condition': '95% Hoạt động hoàn hảo',
      'price': '58.000.000đ',
      'location': 'Quận 1, TP.HCM',
      'seller': 'Lê Quang Huy',
      'sellerAvatar': MockTestAssets.avatarExpert,
      'image': MockTestAssets.marketplaceCam2,
      'lens': 'Chỉ body (Khớp nối Leica M)',
      'shutter': 'Màn trập vải cơ khí tĩnh lặng',
      'meter': 'Đèn LED đo sáng chính xác tuyệt đối',
      'verified': true,
      'desc': 'Body Leica M6 Classic hình thức đẹp, mạ chrome đều màu, không mụn rộp zinc oxide. Cơ cấu lên cò mượt mà, rèm trập không rách thủng.',
    },
    {
      'id': 'mkt-003',
      'title': 'Contax T2 Titanium Black (Carl Zeiss T*)',
      'category': 'Point & Shoot',
      'condition': '97% Đầy đủ bao da zin',
      'price': '28.500.000đ',
      'location': 'Quận 3, TP.HCM',
      'seller': 'Trần Văn Tuấn',
      'sellerAvatar': MockTestAssets.avatarAdmin,
      'image': MockTestAssets.marketplaceCam1,
      'lens': 'Carl Zeiss Sonnar 38mm f/2.8 T*',
      'shutter': 'Điện tử 1s - 1/500s',
      'meter': 'Đo sáng quang học tự động',
      'verified': true,
      'desc': 'Huyền thoại P&S vỏ kim loại titan cao cấp. Không lỗi thấu kính răng cưa, flash hồi nhanh, kính tráng phủ T* đậm đà tương phản.',
    },
    {
      'id': 'mkt-004',
      'title': 'Olympus OM-1n Black + Zuiko 50mm f/1.8',
      'category': 'SLR Cơ khí',
      'condition': '93% Kèm lens Zuiko',
      'price': '3.600.000đ',
      'location': 'Thanh Xuân, Hà Nội',
      'seller': 'Phạm Thu Trang',
      'sellerAvatar': MockTestAssets.avatarCustomer,
      'image': MockTestAssets.marketplaceCam2,
      'lens': 'Olympus F.Zuiko Auto-S 50mm f/1.8',
      'shutter': 'Full cơ cơ cấu giảm rung',
      'meter': 'Kim đo sáng hoạt động',
      'verified': false,
      'desc': 'Bộ máy nhỏ gọn bậc nhất dòng máy ảnh cơ 35mm. Viewfinder rộng sáng bao quát, màn trập nhả êm ái ở mọi tốc độ.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _mockListings.where((item) {
      if (_selectedCategory == 'Tất cả') return true;
      return item['category'] == _selectedCategory;
    }).toList();

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
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'SÀN MÁY & THIẾT BỊ',
              style: AppTypography.cardTitle.copyWith(letterSpacing: 1.0, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined, size: 20),
            tooltip: 'Tin của tôi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_photo_alternate, size: 18),
        label: Text('Đăng tin rao bán', style: AppTypography.button),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateListingScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCatChip('Tất cả'),
                  const SizedBox(width: 6),
                  _buildCatChip('Rangefinder'),
                  const SizedBox(width: 6),
                  _buildCatChip('SLR Cơ khí'),
                  const SizedBox(width: 6),
                  _buildCatChip('Point & Shoot'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Slogan / Verification banner (Stitch APP-CUS-16)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tất cả tin đăng máy ảnh đều được tiền kiểm cơ học trước khi hiển thị.',
                      style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Listings 2x2 Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listingData: item),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              MockTestAssets.image(item['image'], fit: BoxFit.cover),
                              if (item['verified'] == true)
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check, size: 10, color: Colors.white),
                                        const SizedBox(width: 2),
                                        Text(
                                          'TIỀN KIỂM',
                                          style: AppTypography.dataMono.copyWith(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['price'],
                                style: AppTypography.metric.copyWith(fontSize: 14, color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['title'],
                                style: AppTypography.cardTitle.copyWith(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['condition'],
                                style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted),
                                maxLines: 1,
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

  Widget _buildCatChip(String label) {
    final isSelected = _selectedCategory == label;
    return InkWell(
      onTap: () => setState(() => _selectedCategory = label),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelCaps.copyWith(
              fontSize: 10,
              color: isSelected ? Colors.white : AppColors.ink,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
