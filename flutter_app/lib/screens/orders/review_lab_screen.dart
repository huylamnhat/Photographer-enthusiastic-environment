import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ReviewLabScreen extends StatefulWidget {
  final String? labId;
  final String? orderId;
  final String labName;

  const ReviewLabScreen({
    super.key,
    this.labId,
    this.orderId,
    required this.labName,
  });

  @override
  State<ReviewLabScreen> createState() => _ReviewLabScreenState();
}

class _ReviewLabScreenState extends State<ReviewLabScreen> {
  int _rating = 5;
  final _commentController = TextEditingController(
    text: 'Màu scan máy Noritsu rất đẹp và trong trẻo, thời gian xử lý nhanh đúng cam kết SLA 24h.',
  );
  bool _submitted = false;

  final List<String> _tags = [
    'Màu sắc chuẩn analog',
    'Đúng hẹn SLA',
    'Scan sạch không bụi',
    'Bao bọc cẩn thận',
    'Tư vấn nhiệt tình',
  ];
  final Set<String> _selectedTags = {'Màu sắc chuẩn analog', 'Đúng hẹn SLA'};

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceRaised,
          elevation: 0,
          title: Text('ĐÁNH GIÁ THÀNH CÔNG', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.secondary, size: 54),
                const SizedBox(height: 16),
                Text('Cảm ơn bạn đã gửi đánh giá!', style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 6),
                Text(
                  'Đánh giá của bạn đã được ghi nhận vào bảng hiệu suất Lab và chia sẻ với cộng đồng.',
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
                  child: Text('Trở lại đơn hàng', style: AppTypography.button),
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
          'ĐÁNH GIÁ FILM LAB',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  Text(widget.labName, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Đơn hàng: #${widget.orderId ?? 'ORD-9281'}', style: AppTypography.dataMono.copyWith(fontSize: 11, color: AppColors.inkMuted)),
                  const SizedBox(height: 14),

                  // Rating Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        iconSize: 32,
                        icon: Icon(
                          star <= _rating ? Icons.star : Icons.star_border,
                          color: AppColors.primary,
                        ),
                        onPressed: () => setState(() => _rating = star),
                      );
                    }),
                  ),
                  Text(
                    '$_rating / 5 SAO (${_rating == 5 ? 'XUẤT SẮC' : (_rating >= 4 ? 'TỐT' : 'CẦN CẢI THIỆN')})',
                    style: AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tags selection
            Text('ĐIỂM NỔI BẬT CỦA LAB', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceSunken : AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
                    ),
                    child: Text(
                      tag,
                      style: AppTypography.labelCaps.copyWith(
                        fontSize: 10,
                        color: isSelected ? AppColors.primary : AppColors.ink,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Comment text area
            Text('CHI TIẾT TRẢI NGHIỆM', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ chất lượng màu scan, hạt grain, độ sắc nét hoặc sự phục vụ của tiệm...',
                contentPadding: EdgeInsets.all(12),
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
                child: Text('Gửi Đánh Giá Ngay', style: AppTypography.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
