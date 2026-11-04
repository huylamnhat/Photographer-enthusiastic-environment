import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import 'lab_search_screen.dart';
import 'lab_detail_screen.dart';
import '../orders/order_detail_screen.dart';
import '../community/events_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              'KHÁM PHÁ',
              style: AppTypography.cardTitle.copyWith(
                letterSpacing: 1.0,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 20, color: AppColors.ink),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 32,
                height: 32,
                child: MockTestAssets.image(MockTestAssets.avatarCustomer, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome & Location Context (Stitch APP-CUS-04)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THẺ THÀNH VIÊN #VN-882',
                      style: AppTypography.labelCaps.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Xin chào, Hoàng Anh',
                      style: AppTypography.pageTitle.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'TP. Hồ Chí Minh',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar with ⌘K
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LabSearchScreen()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: AppColors.inkMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tìm tiệm tráng, dòng film, sự kiện...',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text(
                        '⌘ K',
                        style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.inkMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Realtime Order Status Card (Stitch APP-CUS-04)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ĐƠN HÀNG ĐANG XỬ LÝ',
                            style: AppTypography.labelCaps.copyWith(
                              letterSpacing: 1.0,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(
                          '#ORD-9281',
                          style: AppTypography.dataMono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LLab Sài Gòn',
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '02 cuộn Kodak ColorPlus 200 (135/36)',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('DỰ KIẾN TRẢ ẢNH', style: AppTypography.labelCaps.copyWith(fontSize: 9)),
                          const SizedBox(height: 2),
                          Text(
                            '18:00 hôm nay',
                            style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3-step timeline
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.outline,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tiếp nhận',
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 10,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Tráng & Scan',
                              textAlign: TextAlign.center,
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Kho Archive',
                              textAlign: TextAlign.right,
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 10,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.outline),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text(
                            'Bể tráng: C-41 Jobo ATL-2 (37.8°C)',
                            style: AppTypography.dataMono.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderDetailScreen(orderId: 'ORD-9281'),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Xem chi tiết',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Technical Services Directory (2x2 grid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DỊCH VỤ CHUẨN HÓA',
                  style: AppTypography.sectionHeading.copyWith(fontSize: 14),
                ),
                Text(
                  'Quy trình Lab',
                  style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
              children: [
                _buildServiceCard(
                  context,
                  title: 'Tráng C-41',
                  subtitle: 'Màu tiêu chuẩn',
                  icon: Icons.palette_outlined,
                  color: AppColors.primary,
                ),
                _buildServiceCard(
                  context,
                  title: 'Tráng B&W',
                  subtitle: 'Thủ công tay',
                  icon: Icons.contrast,
                  color: AppColors.ink,
                ),
                _buildServiceCard(
                  context,
                  title: 'Tráng ECN-2',
                  subtitle: 'Tẩy than điện ảnh',
                  icon: Icons.movie_filter_outlined,
                  color: AppColors.primary,
                ),
                _buildServiceCard(
                  context,
                  title: 'Quét TIFF',
                  subtitle: 'Frontier / Noritsu',
                  icon: Icons.scanner_outlined,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Featured Film Labs Ledger List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'FILM LAB GẦN BẠN',
                      style: AppTypography.sectionHeading.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text('Sài Gòn', style: AppTypography.labelCaps.copyWith(fontSize: 9)),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LabSearchScreen()),
                    );
                  },
                  child: Text(
                    'Tất cả (18)',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildLabCard(
              context,
              name: 'LLab Sài Gòn',
              distance: 'Quận 1 • Cách bạn 1.2 km',
              rating: '4.9',
              reviewCount: '128',
              sla: 'SLA: 24h',
              machine: 'Noritsu HS-1800',
              price: '70.000đ',
              verified: true,
            ),
            const SizedBox(height: 8),
            _buildLabCard(
              context,
              name: 'Croplab Retro',
              distance: 'Bình Thạnh • Cách bạn 3.5 km',
              rating: '4.8',
              reviewCount: '96',
              sla: 'SLA: 48h',
              machine: 'Fuji Frontier SP-3000',
              price: '65.000đ',
              verified: true,
            ),
            const SizedBox(height: 8),
            _buildLabCard(
              context,
              name: 'Nadar Darkroom',
              distance: 'Quận 3 • Cách bạn 2.1 km',
              rating: '5.0',
              reviewCount: '42',
              sla: 'SLA: 72h chuyên sâu',
              machine: 'Hóa chất Kodak D-76',
              price: '90.000đ',
              tag: 'B&W SPEC',
              verified: true,
            ),
            const SizedBox(height: 24),

            // Community Event Warm Paper Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_activity_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'CỘNG ĐỒNG ANALOG',
                            style: AppTypography.labelCaps.copyWith(
                              letterSpacing: 1.0,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Sắp diễn ra',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Photowalk Chợ Lớn Analog',
                              style: AppTypography.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Khám phá văn hóa kiến trúc phố người Hoa qua cuộn phim 35mm đường phố.',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'T.BẢY',
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 9,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '26',
                              style: AppTypography.metric.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '14 người tham gia',
                        style: AppTypography.dataMono.copyWith(fontSize: 11, color: AppColors.inkMuted),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EventsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: Text('Đăng ký', style: AppTypography.button.copyWith(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Micro Footer
            Center(
              child: Text(
                'FILM PROCESSING INDEX • CẬP NHẬT LÚC 14:30',
                style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LabSearchScreen()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outline),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
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
  }

  Widget _buildLabCard(
    BuildContext context, {
    required String name,
    required String distance,
    required String rating,
    required String reviewCount,
    required String sla,
    required String machine,
    required String price,
    String? tag,
    bool verified = false,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabDetailScreen(labId: name.toLowerCase().replaceAll(' ', '-')),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: AppTypography.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: AppColors.secondary),
                      ],
                      if (tag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.dataMono.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' ($reviewCount)',
                        style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(distance, style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(sla, style: AppTypography.dataMono.copyWith(fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(machine, style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Từ ', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                    Text(
                      price,
                      style: AppTypography.dataMono.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
