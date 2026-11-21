import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';

class AdminModerationTab extends StatefulWidget {
  const AdminModerationTab({super.key});

  @override
  State<AdminModerationTab> createState() => _AdminModerationTabState();
}

class _AdminModerationTabState extends State<AdminModerationTab> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = false;
  String _selectedFilter = 'ALL'; // 'ALL', 'AUDIT', 'REPORT'

  @override
  void initState() {
    super.initState();
    _loadReportedPosts();
  }

  Future<void> _loadReportedPosts() async {
    setState(() => _loading = true);
    final posts = await WebApiService().getAdminReportedPosts();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _reports = posts.map<Map<String, dynamic>>((p) {
        final int reportCount = int.tryParse((p['report_count'] ?? 0).toString()) ?? 0;
        final bool isReported = (p['status'] == 'REPORTED') || (reportCount > 0);
        return {
          'id': (p['post_id'] ?? '').toString(),
          'author': (p['author_name'] ?? 'Thành viên cộng đồng').toString(),
          'authorRole': (p['author_badge'] ?? 'Thành viên').toString(),
          'postTitle': (p['title'] ?? '').toString(),
          'content': (p['content'] ?? '').toString(),
          'category': (p['category'] ?? 'Kỹ thuật chụp').toString(),
          'imageUrl': (p['image_url'] ?? '').toString(),
          'reportedBy': isReported
              ? '$reportCount thành viên báo cáo'
              : 'Người dùng mới đăng tải',
          'reason': isReported
              ? (p['report_reason'] ?? 'Vi phạm tiêu chuẩn cộng đồng').toString()
              : 'Bài viết mới xuất bản (Chờ hậu kiểm rà soát nội dung & bản quyền)',
          'time': (p['created_at'] ?? '').toString().split('T').first,
          'status': (p['status'] ?? 'ACTIVE').toString(),
          'isReported': isReported,
          'reportCount': reportCount,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auditCount = _reports.where((r) => r['isReported'] == false).length;
    final reportedCount = _reports.where((r) => r['isReported'] == true).length;

    final filteredList = _reports.where((r) {
      if (_selectedFilter == 'AUDIT') return r['isReported'] == false;
      if (_selectedFilter == 'REPORT') return r['isReported'] == true;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kiểm duyệt bài viết & Báo cáo', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loading ? null : _loadReportedPosts,
                icon: _loading
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, size: 16),
                label: const Text('Làm mới'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overview KPI Badges
          Row(
            children: [
              _buildMetricCard(
                title: 'TỔNG NỘI DUNG THEO DÕI',
                count: '${_reports.length}',
                color: AppColors.ink,
                bg: AppColors.surfaceRaised,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                title: 'BÀI VIẾT MỚI XUẤT BẢN',
                count: '$auditCount',
                color: AppColors.primary,
                bg: AppColors.warningBg,
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                title: 'BÁO CÁO VI PHẠM',
                count: '$reportedCount',
                color: AppColors.danger,
                bg: AppColors.dangerBg,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filter FilterChips
          Row(
            children: [
              FilterChip(
                label: Text('Tất cả (${_reports.length})'),
                selected: _selectedFilter == 'ALL',
                onSelected: (_) => setState(() => _selectedFilter = 'ALL'),
                selectedColor: AppColors.primary.withOpacity(0.15),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Bài viết mới ($auditCount)'),
                selected: _selectedFilter == 'AUDIT',
                onSelected: (_) => setState(() => _selectedFilter = 'AUDIT'),
                selectedColor: AppColors.primary.withOpacity(0.15),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Báo cáo vi phạm ($reportedCount)'),
                selected: _selectedFilter == 'REPORT',
                onSelected: (_) => setState(() => _selectedFilter = 'REPORT'),
                selectedColor: AppColors.dangerBg,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : filteredList.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.verified_user_outlined, size: 48, color: AppColors.secondary),
                              SizedBox(height: 12),
                              Text('Không có bài viết nào đang chờ hậu kiểm', style: AppTypography.cardTitle),
                              SizedBox(height: 4),
                              Text('Tất cả bài viết cộng đồng đã được phê duyệt đạt chuẩn hoặc đã xử lý xong.', style: AppTypography.caption),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final rep = filteredList[idx];
                          final bool isReported = rep['isReported'] == true;

                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isReported ? AppColors.dangerBg : AppColors.warningBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isReported ? Icons.report_problem : Icons.rate_review_outlined,
                                    color: isReported ? AppColors.danger : AppColors.primary,
                                    size: 22,
                                  ),
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
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isReported ? AppColors.dangerBg : AppColors.warningBg,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  isReported ? 'BÁO CÁO VI PHẠM' : 'BÀI VIẾT MỚI',
                                                  style: AppTypography.labelCaps.copyWith(
                                                    color: isReported ? AppColors.danger : AppColors.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(rep['id'], style: AppTypography.dataMono.copyWith(fontSize: 11)),
                                              const SizedBox(width: 8),
                                              Text('Tác giả: ${rep['author']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceSunken,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(rep['authorRole'], style: AppTypography.caption.copyWith(fontSize: 10)),
                                              ),
                                            ],
                                          ),
                                          Text(rep['time'], style: AppTypography.caption),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(rep['postTitle'], style: AppTypography.cardTitle),
                                      if ((rep['content'] as String).isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          rep['content'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isReported ? AppColors.dangerBg.withOpacity(0.5) : AppColors.surfaceSunken,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isReported
                                              ? 'Lý do báo cáo: ${rep['reason']} (${rep['reportedBy']})'
                                              : 'Chuyên mục: ${rep['category']} • Trạng thái: Đang hiển thị (Chờ Admin thẩm tra)',
                                          style: AppTypography.caption.copyWith(
                                            color: isReported ? AppColors.danger : AppColors.inkMuted,
                                            fontWeight: isReported ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                      onPressed: () async {
                                        final ok = await WebApiService().moderateCommunityPost(rep['id'], 'HIDE');
                                        if (!context.mounted) return;
                                        if (ok) {
                                          setState(() => _reports.removeWhere((r) => r['id'] == rep['id']));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Đã gỡ bài viết "${rep['postTitle']}" khỏi diễn đàn')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.block, size: 16),
                                      label: const Text('Gỡ bài vi phạm'),
                                    ),
                                    const SizedBox(height: 6),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final ok = await WebApiService().moderateCommunityPost(rep['id'], 'DISMISS');
                                        if (!context.mounted) return;
                                        if (ok) {
                                          setState(() => _reports.removeWhere((r) => r['id'] == rep['id']));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Đã bỏ qua xét duyệt, giữ bài viết "${rep['postTitle']}"')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.done_all, size: 16),
                                      label: const Text('Bỏ qua (Giữ bài)'),
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

  Widget _buildMetricCard({required String title, required String count, required Color color, required Color bg}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.labelCaps.copyWith(fontSize: 10, color: color)),
            const SizedBox(height: 4),
            Text(count, style: AppTypography.pageTitle.copyWith(fontSize: 20, color: color)),
          ],
        ),
      ),
    );
  }
}
