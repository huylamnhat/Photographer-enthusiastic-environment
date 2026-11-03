import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/community_provider.dart';
import '../../models/community_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _category = 'Kinh nghiệm chụp';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soạn bài viết mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CHUYÊN MỤC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'Kinh nghiệm chụp', child: Text('Kinh nghiệm chụp & Đo sáng')),
                DropdownMenuItem(value: 'Review Cuộn Film', child: Text('Review Cuộn Film & Hạt Grain')),
                DropdownMenuItem(value: 'Kỹ thuật tráng phim', child: Text('Kỹ thuật tráng phim & Hóa chất')),
                DropdownMenuItem(value: 'Hỏi đáp kỹ thuật', child: Text('Hỏi đáp lỗi máy cơ & Thắc mắc')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            const Text('TIÊU ĐỀ BÀI VIẾT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Nhập tiêu đề thảo luận...'),
            ),
            const SizedBox(height: 16),

            const Text('NỘI DUNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(hintText: 'Chia sẻ góc nhìn, kinh nghiệm, thông số chụp...'),
            ),
            const SizedBox(height: 16),

            // Image picker mock box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Đính kèm ảnh minh họa từ cuộn film', style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final newPost = CommunityPostModel(
                    postId: 'post-${DateTime.now().millisecondsSinceEpoch}',
                    authorId: 'usr-001',
                    authorName: 'Nguyễn Hoàng Anh',
                    authorAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                    authorBadge: 'Thành viên đam mê',
                    title: _titleController.text.isNotEmpty ? _titleController.text : 'Kinh nghiệm chụp film mới',
                    content: _contentController.text,
                    category: _category,
                    imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
                    likesCount: 1,
                    commentsCount: 0,
                    createdAt: DateTime.now().toIso8601String(),
                  );
                  context.read<CommunityProvider>().addPost(newPost);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đăng bài viết lên cộng đồng!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Đăng bài thảo luận', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
