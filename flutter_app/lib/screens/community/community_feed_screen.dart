import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  String _selectedCategory = 'Tất cả';

  final List<Map<String, dynamic>> _posts = [
    {
      'id': 'post-001',
      'author': 'Lê Quang Huy',
      'avatar': MockTestAssets.avatarExpert,
      'badge': 'CHUYÊN GIA ANALOG',
      'time': '2 giờ trước',
      'title': 'Bí quyết đo sáng chụp phim âm bản màu: Đừng sợ dư sáng!',
      'content': 'Phim âm bản màu (Color Negative như Portra 400, Gold 200) có dải nhạy sáng (Dynamic Range) về phía highlight cực kỳ ấn tượng, lên đến +3 hoặc +4 stops mà vẫn giữ trọn vẹn chi tiết mây trời. Hãy luôn đo sáng vào vùng bóng râm (shadow) để da người luôn đủ sáng và mịn màng.',
      'category': 'Kinh nghiệm chụp',
      'image': MockTestAssets.samplePhoto2,
      'tags': ['#kodakportra400', '#metering', '#streetphotography'],
      'likes': 89,
      'comments': 14,
    },
    {
      'id': 'post-002',
      'author': 'Nguyễn Hoàng Anh',
      'avatar': MockTestAssets.avatarCustomer,
      'badge': 'THÀNH VIÊN',
      'time': '5 giờ trước',
      'title': 'Trải nghiệm tráng film điện ảnh ECN-2 tại LLab Sài Gòn',
      'content': 'Cuộn Kodak Vision3 500T của mình vừa được trả ảnh scan sau 48h. Thợ lab tẩy lớp than Remjet rất sạch, không hề bị đốm đen hay ám mờ. Màu sắc buổi đêm ở phố đi bộ lên ánh đèn neon ấm áp đúng chất điện ảnh.',
      'category': 'Review Film',
      'image': MockTestAssets.samplePhoto3,
      'tags': ['#vision3_500t', '#ecn2', '#saigonnights'],
      'likes': 56,
      'comments': 9,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _posts.where((p) {
      if (_selectedCategory == 'Tất cả') return true;
      return p['category'] == _selectedCategory;
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
              'CỘNG ĐỒNG ANALOG',
              style: AppTypography.cardTitle.copyWith(letterSpacing: 1.0, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_outlined, size: 20),
            tooltip: 'Sự kiện Photowalk',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 20),
            tooltip: 'Hồ sơ & Cài đặt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
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
        icon: const Icon(Icons.edit, size: 18),
        label: Text('Soạn bài viết', style: AppTypography.button),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCatChip('Tất cả'),
                  const SizedBox(width: 6),
                  _buildCatChip('Kinh nghiệm chụp'),
                  const SizedBox(width: 6),
                  _buildCatChip('Review Film'),
                  const SizedBox(width: 6),
                  _buildCatChip('Phòng tối & Scan'),
                  const SizedBox(width: 6),
                  _buildCatChip('Hỏi đáp kỹ thuật'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Posts Feed
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final post = filtered[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(postData: post),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Author Strip
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: MockTestAssets.image(post['avatar'] as String, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(post['author'] as String, style: AppTypography.cardTitle.copyWith(fontSize: 12)),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceSunken,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            post['badge'] as String,
                                            style: AppTypography.labelCaps.copyWith(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(post['time'] as String, style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.more_horiz, size: 18, color: AppColors.inkMuted),
                            ],
                          ),
                        ),

                        // Title & Summary
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(post['title'] as String, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                              const SizedBox(height: 6),
                              Text(
                                post['content'] as String,
                                style: AppTypography.bodySmall.copyWith(height: 1.4),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Image attachment
                        if (post['image'] != null)
                          SizedBox(
                            height: 180,
                            child: MockTestAssets.image(post['image'] as String, fit: BoxFit.cover),
                          ),

                        // Tags & Metrics footer
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                spacing: 4,
                                children: (post['tags'] as List).map((t) {
                                  return Text(t, style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.secondary));
                                }).toList(),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.favorite_border, size: 14, color: AppColors.inkMuted),
                                  const SizedBox(width: 4),
                                  Text('${post['likes']}', style: AppTypography.dataMono.copyWith(fontSize: 11)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.inkMuted),
                                  const SizedBox(width: 4),
                                  Text('${post['comments']}', style: AppTypography.dataMono.copyWith(fontSize: 11)),
                                ],
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
