import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
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
  bool _loading = false;

  List<Map<String, dynamic>> _listings = [];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _loading = true);
    final items = await ApiService().getMarketplaceListings();
    if (!mounted) return;
    final mapped = items.map((l) {
      final formattedPrice =
          '${l.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
      return {
        'id': l.listingId,
        'title': l.title,
        'category': l.category,
        'condition': l.condition,
        'price': formattedPrice,
        'location': l.location,
        'seller': l.sellerName,
        'sellerAvatar': l.sellerAvatar.isNotEmpty ? l.sellerAvatar : MockTestAssets.avatarCustomer,
        'image': l.imageUrls.isNotEmpty ? l.imageUrls.first : MockTestAssets.marketplaceCam1,
        'lens': 'Ống kính tiêu chuẩn theo máy',
        'shutter': 'Cơ khí đã kiểm tra tốc độ',
        'meter': 'Đo sáng hoạt động tốt',
        'verified': l.status == 'ACTIVE',
        'desc': l.description,
      };
    }).toList();

    setState(() {
      _listings = mapped;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _listings.where((item) {
      if (_selectedCategory == 'Tất cả') return true;
      return item['category'].toString().toLowerCase().contains(_selectedCategory.toLowerCase());
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
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            tooltip: 'Làm mới sàn máy',
            onPressed: _loadListings,
          ),
          TextButton.icon(
            icon: const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
            label: Text('Tin của tôi', style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.primary)),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsScreen()),
              );
              _loadListings();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_photo_alternate, size: 18),
        label: Text('Đăng tin rao bán', style: AppTypography.button),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateListingScreen()),
          );
          _loadListings();
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
                  const SizedBox(width: 6),
                  _buildCatChip('Ống kính (Lens)'),
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

            if (_loading && filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 36, color: AppColors.inkMuted),
                    const SizedBox(height: 8),
                    Text('Chưa có thiết bị nào trong mục "$_selectedCategory"', style: AppTypography.bodySmall),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateListingScreen()),
                        );
                        _loadListings();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add_photo_alternate, size: 16),
                      label: const Text('Đăng bán thiết bị ngay'),
                    ),
                  ],
                ),
              )
            else
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
