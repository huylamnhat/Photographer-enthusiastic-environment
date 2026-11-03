import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ReviewLabScreen extends StatefulWidget {
  final String labId;
  final String labName;

  const ReviewLabScreen({super.key, required this.labId, required this.labName});

  @override
  State<ReviewLabScreen> createState() => _ReviewLabScreenState();
}

class _ReviewLabScreenState extends State<ReviewLabScreen> {
  int _rating = 5;
  final _commentController = TextEditingController(text: 'Màu scan máy Noritsu rất đẹp và trong trẻo, thời gian xử lý nhanh đúng cam kết.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá Film Lab'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.labName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 6),
            const Text('Đóng góp của bạn giúp cộng đồng chọn được tiệm lab phù hợp nhất',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
            const SizedBox(height: 20),

            // Star rating selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  iconSize: 36,
                  icon: Icon(
                    starValue <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = starValue),
                );
              }),
            ),
            Text(
              _rating == 5 ? 'Tuyệt vời (5/5)' : '$_rating sao',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: const Text('NHẬN XÉT CỦA BẠN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ cảm nhận về độ nét, màu sắc hạt film hoặc quy cách đóng gói...',
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cảm ơn bạn đã gửi đánh giá cho tiệm Film Lab!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Gửi đánh giá', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

