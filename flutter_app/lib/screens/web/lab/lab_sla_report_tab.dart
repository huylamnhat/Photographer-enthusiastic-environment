import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/web_api_service.dart';

class LabSlaReportTab extends StatefulWidget {
  const LabSlaReportTab({super.key});

  @override
  State<LabSlaReportTab> createState() => _LabSlaReportTabState();
}

class _LabSlaReportTabState extends State<LabSlaReportTab> {
  Map<String, dynamic>? _slaData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await WebApiService().getLabSlaReport();
    if (mounted) {
      setState(() {
        _slaData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Báo Cáo Hiệu Suất SLA & Năng Suất Tráng Phim', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
          const SizedBox(height: 4),
          const Text('Thống kê tỷ lệ giao file scan đúng hẹn cam kết, công suất máy tráng và tỷ lệ kiểm định QC',
              style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
          const SizedBox(height: 24),

          // SLA Metrics Grid
          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            children: [
              _buildCard('TỶ LỆ ĐÚNG HẸN CAM KẾT (SLA)', '${_slaData?['on_time_delivery_rate'] ?? '98.7%'}', 'Cam kết trả file trong 12h', AppColors.success),
              _buildCard('THỜI GIAN HOÀN TẤT TRUNG BÌNH', '${_slaData?['average_turnaround_hours'] ?? '9.4'} Giờ', 'Nhanh hơn 2.6h so với cam kết', AppColors.primary),
              _buildCard('TỶ LỆ KIỂM ĐỊNH QC ĐẠT CHUẨN', '${_slaData?['qc_pass_rate'] ?? '99.2%'}', 'Không phát sinh khiếu nại trầy xước', Colors.indigo),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chi tiết vận hành trong tháng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 14),
                _buildRow('Tổng số cuộn phim đã xử lý hoàn tất:', '${_slaData?['total_completed_orders'] ?? 1284} cuộn'),
                _buildRow('Số đơn phát sinh trễ hẹn SLA:', '${_slaData?['delayed_orders'] ?? 17} đơn (chiếm 1.3%)'),
                _buildRow('Công suất tiếp nhận tối đa hàng ngày:', '${_slaData?['daily_capacity'] ?? '80 cuộn / ngày'}'),
                _buildRow('Đánh giá chất lượng trung bình từ khách hàng:', '4.9 / 5.0 ⭐ (328 đánh giá)'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.inkMuted, letterSpacing: 0.5)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.ink)),
        ],
      ),
    );
  }
}

