import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';

class LabSlaReportTab extends StatefulWidget {
  const LabSlaReportTab({super.key});

  @override
  State<LabSlaReportTab> createState() => _LabSlaReportTabState();
}

class _LabSlaReportTabState extends State<LabSlaReportTab> {
  List<Map<String, dynamic>> _orderHistory = [];
  Map<String, dynamic> _slaData = {};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSlaReport();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _loadSlaReport());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSlaReport() async {
    final res = await WebApiService().getLabSlaReport();
    final rawOrders = (res['orders'] as List?) ?? [];

    if (!mounted) return;
    setState(() {
      _slaData = res;
      final targetHours = res['sla_target_hours'] ?? 12;
      _orderHistory = rawOrders.map<Map<String, dynamic>>((o) {
        final items = (o['items'] as List?) ?? [];
        final first = items.isNotEmpty ? items.first as Map<String, dynamic> : <String, dynamic>{};
        final rawRating = o['rating'];
        final hasRating = rawRating is num && rawRating > 0;
        final col = (o['kanban_column'] ?? '').toString().toUpperCase();
        final st = (o['status'] ?? '').toString().toUpperCase();
        final slaOk = col == 'READY' || st == 'READY_FOR_DOWNLOAD' || st == 'COMPLETED';
        final orderTargetHours = o['sla_target_hours'] ?? targetHours;
        return {
          'id': (o['order_id'] ?? '').toString(),
          'customer': (o['customer_name'] ?? 'Khách hàng').toString(),
          'service': (first['name'] ?? 'Tráng & Scan C-41').toString(),
          'rolls': items.fold<int>(0, (sum, it) => sum + ((it['quantity'] as num?)?.toInt() ?? 1)),
          'amount': '${o['total_amount'] ?? 0}đ',
          'date': (o['order_date'] ?? '').toString().split('T').first,
          'sla': slaOk ? 'Đạt (Mục tiêu ${orderTargetHours}h)' : 'Đang xử lý (${orderTargetHours}h)',
          'slaOk': slaOk,
          'hasRating': hasRating,
          'rating': hasRating ? '${rawRating.toDouble().toStringAsFixed(1)} ★' : 'Chưa đánh giá',
          'comment': (o['review_comment'] ?? '').toString().trim(),
          'reviewService': (o['review_service'] ?? '').toString().trim(),
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Lịch sử đơn & Hiệu suất', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadSlaReport,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Làm mới'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              _buildSummaryCard('TRẢ ẢNH ĐÚNG HẸN', '${_slaData['on_time_delivery_rate'] ?? '98.7%'}', 'Mục tiêu: ${_slaData['sla_target_hours'] ?? 12}h', AppColors.secondary),
              const SizedBox(width: 16),
              _buildSummaryCard('TỔNG ĐƠN HÀNG', '${_orderHistory.length} đơn', 'Công suất: ${_slaData['daily_capacity'] ?? '80 cuộn / ngày'}', AppColors.primary),
              const SizedBox(width: 16),
              _buildSummaryCard('CHẤT LƯỢNG ĐẠT CHUẨN', '${_slaData['qc_pass_rate'] ?? '99.2%'}', 'Trung bình: ${_slaData['average_turnaround_hours'] ?? 9.4}h', AppColors.ink),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2.1),
                1: FlexColumnWidth(2.1),
                2: FlexColumnWidth(2.8),
                3: FlexColumnWidth(1.0),
                4: FlexColumnWidth(1.6),
                5: FlexColumnWidth(2.0),
                6: FlexColumnWidth(3.4),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  children: [
                    _th('MÃ ĐƠN'),
                    _th('KHÁCH HÀNG'),
                    _th('GÓI DỊCH VỤ'),
                    _th('SỐ CUỘN'),
                    _th('DOANH THU'),
                    _th('THỜI GIAN'),
                    _th('ĐÁNH GIÁ KHÁCH HÀNG'),
                  ],
                ),
                ..._orderHistory.map((h) => TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5))),
                  children: [
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['id'], style: AppTypography.dataMono.copyWith(color: AppColors.primary))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['service'], style: AppTypography.tableCell)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['rolls'].toString(), style: AppTypography.dataMono)),
                    Padding(padding: const EdgeInsets.all(12), child: Text(h['amount'], style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold))),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        h['sla'],
                        style: TextStyle(
                          color: h['slaOk'] == true ? AppColors.secondary : AppColors.inkMuted,
                          fontWeight: h['slaOk'] == true ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: h['hasRating'] == true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h['rating'],
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                if ((h['comment'] ?? '').toString().isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${h['comment']}"',
                                    style: const TextStyle(
                                      color: AppColors.ink,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                                if ((h['reviewService'] ?? '').toString().isNotEmpty &&
                                    h['reviewService'] != 'Tráng & Scan Film') ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    h['reviewService'],
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.secondary,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : const Text(
                              'Chưa đánh giá',
                              style: TextStyle(
                                color: AppColors.inkMuted,
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String val, String sub, Color valColor) {
    return Expanded(
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
            Text(title, style: AppTypography.labelCaps),
            const SizedBox(height: 8),
            Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valColor)),
            const SizedBox(height: 4),
            Text(sub, style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _th(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(title, style: AppTypography.labelCaps),
    );
  }
}
