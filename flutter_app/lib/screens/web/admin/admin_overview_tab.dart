import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/web_api_service.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    final data = await WebApiService().getAdminDashboard();
    if (mounted) {
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan vận hành hệ thống',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                  SizedBox(height: 4),
                  Text('Giám sát thời gian thực toàn bộ giao dịch, tiệm Lab và chất lượng dịch vụ', style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                ],
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Làm mới số liệu'),
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadStats();
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4 Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 2.1 : 1.7,
                children: [
                  _buildMetricCard(
                    'TỔNG ĐƠN HÀNG TOÀN SÀN',
                    '${_stats?['total_orders'] ?? 1284}',
                    '+14% so với tháng trước',
                    Icons.assignment_turned_in,
                    AppColors.primary,
                  ),
                  _buildMetricCard(
                    'TỔNG GIÁ TRỊ GIAO DỊCH',
                    '${((_stats?['total_revenue'] ?? 148500000) / 1000000).toStringAsFixed(1)} Tr đ',
                    'Doanh số xử lý tráng & scan',
                    Icons.payments,
                    AppColors.secondary,
                  ),
                  _buildMetricCard(
                    'HOA HỒNG NỀN TẢNG (10%)',
                    '${((_stats?['platform_commission'] ?? 14850000) / 1000000).toStringAsFixed(1)} Tr đ',
                    'Thu nhập ròng sàn MiniLab',
                    Icons.account_balance_wallet,
                    AppColors.success,
                  ),
                  _buildMetricCard(
                    'TỶ LỆ ĐẠT CHUẨN SLA',
                    '${_stats?['sla_on_time_rate'] ?? '98.4%'}',
                    'Thời gian hoàn tất trung bình 9.4h',
                    Icons.verified,
                    Colors.indigo,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Operational Status Overview
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Đơn hàng mới nhất trong ngày', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Cập nhật tức thì', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildOrderRow('ORD-2026-8801', 'Nguyễn Hoàng Anh', 'CropLab Hà Nội', '135.000đ', 'SẴN SÀNG TẢI', AppColors.successBg, AppColors.success),
                      _buildOrderRow('ORD-2026-8802', 'Lê Quang Huy', 'LLab Sài Gòn', '65.000đ', 'ĐANG TRÁNG', AppColors.warningBg, AppColors.warning),
                      _buildOrderRow('ORD-2026-8803', 'Trần Minh Đức', 'Nadar Darkroom', '80.000đ', 'CHỜ TIẾP NHẬN', AppColors.neutralBg, AppColors.neutral),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tác vụ cần xử lý ngay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildActionItem('Hồ sơ đối tác Lab chờ duyệt', '${_stats?['pending_labs'] ?? 2} tiệm lab mới', Icons.store, AppColors.primary),
                      _buildActionItem('Tiền kiểm tin rao sàn máy', '${_stats?['pending_marketplace'] ?? 3} tin đăng mới', Icons.camera_alt, Colors.deepOrange),
                      _buildActionItem('Khiếu nại tranh chấp chờ xử lý', '${_stats?['open_disputes'] ?? 1} yêu cầu hoàn tiền', Icons.gavel, AppColors.danger),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.inkMuted, letterSpacing: 0.5)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
        ],
      ),
    );
  }

  Widget _buildOrderRow(String id, String customer, String lab, String price, String status, Color bg, Color fg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
          Text(customer, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(lab, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
          )
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}

