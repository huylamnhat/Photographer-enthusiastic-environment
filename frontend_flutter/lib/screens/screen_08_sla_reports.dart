import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';

class SlaReportsScreen extends StatefulWidget {
  const SlaReportsScreen({super.key});

  @override
  State<SlaReportsScreen> createState() => _SlaReportsScreenState();
}

class _SlaReportsScreenState extends State<SlaReportsScreen> {
  Map<String, dynamic>? reportData;
  bool isLoading = true;
  String selectedPeriod = '10-2024';

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => isLoading = true);
    final data = await ApiService.getSlaReports();
    setState(() {
      reportData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final metrics = reportData?['metrics'] ?? {};
    final dailyStats = (reportData?['dailyStats'] as List?) ?? [];

    return Scaffold(
      backgroundColor: LabColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lịch sử Đơn & Hiệu suất Vận hành SLA',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Báo cáo kiểm định chất lượng phòng tối, thời gian xoay vòng hóa chất và đối soát khách hàng.',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 13, color: LabColors.onSurfaceVariant),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: LabColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: LabColors.outlineVariant, width: 0.5),
                      ),
                      child: DropdownButton<String>(
                        value: selectedPeriod,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: '10-2024', child: Text('Tháng 10/2024 (Hiện tại)')),
                          DropdownMenuItem(value: '09-2024', child: Text('Tháng 09/2024')),
                          DropdownMenuItem(value: 'q3-2024', child: Text('Quý 3/2024 (Tổng hợp)')),
                        ],
                        onChanged: (v) => setState(() => selectedPeriod = v!),
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.file_download, size: 16),
                      label: const Text('Xuất báo cáo PDF/CSV'),
                      onPressed: () {},
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: LabColors.primary, foregroundColor: Colors.white),
                      icon: const Icon(Icons.verified, size: 16),
                      label: const Text('Đối soát ca trực'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Performance Metrics
            Row(
              children: [
                _buildMetric('TỔNG ĐƠN HOÀN THÀNH', '${metrics['total_orders'] ?? 1482}', '+14% MoM', LabColors.secondary),
                _buildMetric('TỶ LỆ ĐÚNG HẠN SLA', '${metrics['on_time_rate'] ?? 98.4}%', 'Vượt chỉ tiêu >95%', LabColors.secondary),
                _buildMetric('XOAY VÒNG TRUNG BÌNH', '${metrics['avg_turnaround_hours'] ?? 28.5}h', 'Cam kết < 48h', LabColors.primary),
                _buildMetric('QC ĐẠT LẦN ĐẦU', '${metrics['first_pass_qc'] ?? 94.8}%', 'Pass rate SP-3000', LabColors.secondary),
              ],
            ),
            const SizedBox(height: 24),

            // Daily Turnover Stats Table
            const Text(
              'BIẾN ĐỘNG NĂNG LỰC SẢN XUẤT 7 NGÀY GẦN NHẤT',
              style: TextStyle(fontFamily: 'IBM Plex Sans', fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(child: Text('NGÀY', style: TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, fontSize: 11, color: LabColors.outline))),
                        Expanded(child: Text('SỐ CUỘN XỬ LÝ', style: TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, fontSize: 11, color: LabColors.outline))),
                        Expanded(child: Text('ĐƠN ĐÚNG HẠN', style: TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, fontSize: 11, color: LabColors.outline))),
                        Expanded(child: Text('THỜI GIAN TRẢ FILE TB', style: TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, fontSize: 11, color: LabColors.outline))),
                        Expanded(child: Text('TRẠNG THÁI CA', style: TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, fontSize: 11, color: LabColors.outline))),
                      ],
                    ),
                    const Divider(height: 20),
                    ...dailyStats.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(item['date'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            Expanded(child: Text('${item['orders']} cuộn', style: const TextStyle(fontSize: 13))),
                            Expanded(child: Text('${item['on_time']} đơn (100%)', style: const TextStyle(fontSize: 13, color: LabColors.secondary, fontWeight: FontWeight.bold))),
                            Expanded(child: Text('${item['avg_time']} giờ', style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 13))),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(color: LabColors.secondaryContainer, borderRadius: BorderRadius.circular(9999)),
                                  child: const Text('ĐẠT CHỈ TIÊU', style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, fontWeight: FontWeight.bold, color: LabColors.onSecondaryContainer)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LabColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LabColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

