import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'Kinh nghiệm chụp';
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceRaised,
          elevation: 0,
          title: Text('ĐĂNG BÀI THÀNH CÔNG', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.secondary, size: 54),
                const SizedBox(height: 16),
                Text('Bài viết đã được chia sẻ lên diễn đàn!', textAlign: TextAlign.center, style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Cảm ơn bạn đã đóng góp kiến thức nhiếp ảnh bổ ích cho cộng đồng analog MiniLab.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Về Diễn Đàn', style: AppTypography.button),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          'SOẠN BÀI VIẾT DIỄN ĐÀN',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('CHUYÊN MỤC THẢO LUẬN', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  style: AppTypography.bodySmall,
                  items: ['Kinh nghiệm chụp', 'Review Film', 'Phòng tối & Scan', 'Hỏi đáp kỹ thuật'].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _category = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('TIÊU ĐỀ BÀI VIẾT', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: AppTypography.cardTitle.copyWith(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Kinh nghiệm kéo ISO (Push) cuộn Tri-X 400 lên 1600...',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 16),

            Text('NỘI DUNG CHIA SẺ', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            TextField(
              controller: _contentController,
              maxLines: 8,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                hintText: 'Mô tả thông số khẩu độ, tốc độ, hóa chất thuốc tráng hoặc cảm nhận hạt grain cuộn phim...',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 16),

            // Image attachment mockup
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text('Đính kèm ảnh minh họa từ cuộn phim', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () => setState(() => _submitted = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Xuất Bản Lên Diễn Đàn', style: AppTypography.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
