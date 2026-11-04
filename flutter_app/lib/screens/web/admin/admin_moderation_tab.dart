import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AdminModerationTab extends StatefulWidget {
  const AdminModerationTab({super.key});

  @override
  State<AdminModerationTab> createState() => _AdminModerationTabState();
}

class _AdminModerationTabState extends State<AdminModerationTab> {
  final List<Map<String, dynamic>> _reports = [
    {
      'id': 'REP-COM-104',
      'author': 'Trần Văn Tùng',
      'authorRole': 'Customer',
      'postTitle': 'Cách pha thuốc tráng lậu D-76 bằng xà phòng giặt',
      'reportedBy': 'Lê Quang Huy (Verified Expert)',
      'reason': 'Nội dung kỹ thuật sai lệch nghiêm trọng, phá hủy cuộn phim của người khác',
      'time': '30 phút trước',
      'status': 'PENDING',
    },
    {
      'id': 'REP-COM-105',
      'author': 'Hoàng Văn Bách',
      'authorRole': 'Customer',
      'postTitle': 'Nhận thanh lý film outdate giá rẻ không nguồn gốc',
      'reportedBy': 'Đỗ Hữu Nghĩa',
      'reason': 'Spam quảng cáo bán hàng lậu tràn lan các nhóm thảo luận',
      'time': '2 giờ trước',
      'status': 'PENDING',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WEB-ADM-06 // HẬU KIỂM CỘNG ĐỒNG', style: AppTypography.labelCaps),
              SizedBox(height: 4),
              Text('Kiểm duyệt Nội dung Vi phạm & Báo cáo', style: AppTypography.pageTitle),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reports.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (ctx, idx) {
                final rep = _reports[idx];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.report_problem, color: AppColors.danger, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(rep['id'], style: AppTypography.dataMono.copyWith(color: AppColors.danger)),
                                    const SizedBox(width: 8),
                                    Text('Tác giả: ${rep['author']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                Text(rep['time'], style: AppTypography.caption),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(rep['postTitle'], style: AppTypography.cardTitle),
                            const SizedBox(height: 4),
                            Text('Bị báo cáo bởi: ${rep['reportedBy']}', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
                            Text('Lý do vi phạm: ${rep['reason']}', style: AppTypography.caption),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                            onPressed: () {
                              setState(() => _reports.removeAt(idx));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã gỡ bài viết vi phạm của ${rep['author']}')),
                              );
                            },
                            child: const Text('Gỡ bài vi phạm'),
                          ),
                          const SizedBox(height: 6),
                          OutlinedButton(
                            onPressed: () {
                              setState(() => _reports.removeAt(idx));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã bỏ qua báo cáo')),
                              );
                            },
                            child: const Text('Bỏ qua'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

