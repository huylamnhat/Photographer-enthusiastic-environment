import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
import '../../models/listing_model.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  bool _loading = true;
  List<ListingModel> _myListings = [];

  @override
  void initState() {
    super.initState();
    _loadMyListings();
  }

  Future<void> _loadMyListings() async {
    setState(() => _loading = true);
    final res = await ApiService().getMyMarketplaceListings();
    if (!mounted) return;
    setState(() {
      _myListings = res;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            onPressed: _loadMyListings,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _myListings.isEmpty
              ? Center(child: Text('Bạn chưa có tin đăng nào', style: AppTypography.bodySmall))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _myListings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _myListings[index];
                    final isPending = item.status == 'PENDING_REVIEW';
                    final isRejected = item.status == 'REJECTED';
                    final statusLabel = isPending
                        ? 'CHỜ ADMIN DUYỆT'
                        : (isRejected ? 'BỊ TỪ CHỐI' : 'ĐANG HIỂN THỊ');
                    final statusColor = isPending
                        ? AppColors.primary
                        : (isRejected ? AppColors.danger : AppColors.secondary);
                    final formattedPrice =
                        '${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

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
                              child: MockTestAssets.image(
                                item.imageUrls.isNotEmpty ? item.imageUrls.first : MockTestAssets.marketplaceCam1,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: AppTypography.cardTitle.copyWith(fontSize: 13), maxLines: 1),
                                const SizedBox(height: 2),
                                Text(formattedPrice, style: AppTypography.metric.copyWith(fontSize: 14, color: AppColors.primary)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: AppTypography.dataMono.copyWith(fontSize: 8, color: statusColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(item.category, style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                                  ],
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
