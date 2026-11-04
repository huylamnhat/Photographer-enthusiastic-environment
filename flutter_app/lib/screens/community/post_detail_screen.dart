import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../models/community_model.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPostModel? post;
  final Map<String, dynamic>? postData;

  const PostDetailScreen({super.key, this.post, this.postData});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  int _likesCount = 89;
  bool _isLiked = false;

  final List<Map<String, String>> _mockComments = [
    {
      'author': 'Phạm Thu Trang',
      'avatar': MockTestAssets.avatarCustomer,
      'time': '1 giờ trước',
      'content': 'Bài viết chia sẻ rất chi tiết! Em vừa chụp một cuộn Portra 400 đo sáng theo shadow, mây trời Hà Nội lên màu ngả vàng ươm rất thích.',
    },
    {
      'author': 'Saigon Darkroom Tech',
      'avatar': MockTestAssets.avatarLabOwner,
      'time': '30 phút trước',
      'content': 'Xác nhận từ kỹ thuật viên lab: Film âm bản C-41 đo sáng dư 1 đến 2 stops lúc nào cũng cho hạt grain mịn màng và màu da dễ scan hơn là chụp thiếu sáng.',
    },
  ];

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _mockComments.add({
        'author': 'Nguyễn Hoàng Anh',
        'avatar': MockTestAssets.avatarCustomer,
        'time': 'Vừa xong',
        'content': text,
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.post?.title ?? (widget.postData?['title'] ?? 'Bí quyết đo sáng chụp phim âm bản màu: Đừng sợ dư sáng!');
    final author = widget.post?.authorName ?? (widget.postData?['author'] ?? 'Lê Quang Huy');
    final avatar = widget.post?.authorAvatar ?? (widget.postData?['avatar'] ?? MockTestAssets.avatarExpert);
    final badge = widget.post?.authorBadge ?? (widget.postData?['badge'] ?? 'CHUYÊN GIA ANALOG');
    final content = widget.post?.content ??
        (widget.postData?['content'] ??
            'Phim âm bản màu (Color Negative như Portra 400, Gold 200) có dải nhạy sáng (Dynamic Range) về phía highlight cực kỳ ấn tượng, lên đến +3 hoặc +4 stops mà vẫn giữ trọn vẹn chi tiết mây trời. Hãy luôn đo sáng vào vùng bóng râm (shadow) để da người luôn đủ sáng và mịn màng.\n\nNgược lại, nếu bạn đo sáng thiếu (underexposure), các hạt muối bạc trong vùng tối không kịp kích hoạt phản ứng hóa học, khi tráng scan sẽ sinh ra hiện tượng hạt grain vỡ hạt và màu ngả sang xanh lá (muddy green). Do đó, kinh nghiệm vàng cho người mới chơi film: Nếu phân vân giữa 2 khẩu độ, hãy chọn khẩu mở lớn hơn!');
    final image = widget.post?.imageUrl ?? (widget.postData?['image'] ?? MockTestAssets.samplePhoto2);

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
          'CHI TIẾT BÀI VIẾT & THẢO LUẬN',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Author Header
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: MockTestAssets.image(avatar, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(author, style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSunken,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    badge,
                                    style: AppTypography.labelCaps.copyWith(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Text('Hôm nay • Chuyên mục Kỹ thuật chụp', style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title & Body
                  Text(title, style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(content, style: AppTypography.bodySmall.copyWith(fontSize: 13, height: 1.5)),
                  const SizedBox(height: 14),

                  // Image attachment
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 220,
                      child: MockTestAssets.image(image, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Likes & Share bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isLiked = !_isLiked;
                              _likesCount += _isLiked ? 1 : -1;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: _isLiked ? Colors.redAccent : AppColors.inkMuted,
                              ),
                              const SizedBox(width: 6),
                              Text('$_likesCount Lượt thích', style: AppTypography.dataMono.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        Text('${_mockComments.length} Bình luận', style: AppTypography.dataMono.copyWith(fontSize: 11, color: AppColors.inkMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Comments section
                  Text('BÌNH LUẬN & THẢO LUẬN', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mockComments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cmt = _mockComments[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: MockTestAssets.image(cmt['avatar']!, fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(cmt['author']!, style: AppTypography.cardTitle.copyWith(fontSize: 11)),
                                const Spacer(),
                                Text(cmt['time']!, style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(cmt['content']!, style: AppTypography.bodySmall.copyWith(fontSize: 11, height: 1.3)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Comment Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: AppTypography.bodySmall,
                        decoration: const InputDecoration(
                          hintText: 'Viết phản hồi hoặc chia sẻ góc nhìn...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text('Gửi', style: AppTypography.button.copyWith(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
