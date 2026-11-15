import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';

class LabKanbanTab extends StatefulWidget {
  const LabKanbanTab({super.key});

  @override
  State<LabKanbanTab> createState() => _LabKanbanTabState();
}

class _LabKanbanTabState extends State<LabKanbanTab> {
  final Map<String, List<Map<String, dynamic>>> _kanbanData = {
    '1. Tiếp nhận': [],
    '2. Vào Tank / Tráng': [],
    '3. Sấy khô': [],
    '4. Scan số hóa': [],
    '5. QC & Archive': [],
  };

  @override
  void initState() {
    super.initState();
    _loadKanban();
  }

  Map<String, dynamic> _mapOrderToCard(Map<String, dynamic> o, String nextStep) {
    final items = (o['items'] as List?) ?? [];
    final firstItem = items.isNotEmpty ? items.first as Map<String, dynamic> : <String, dynamic>{};
    return {
      'rawId': (o['order_id'] ?? '').toString(),
      'id': '#${o['order_id'] ?? ''}',
      'customer': (o['customer_name'] ?? 'Khách hàng').toString(),
      'film': (firstItem['film_name'] ?? 'Kodak Portra 400').toString(),
      'tags': [
        (firstItem['name'] ?? 'C-41').toString(),
        if (firstItem['options'] != null && firstItem['options']['push_pull'] != null)
          firstItem['options']['push_pull'].toString(),
      ],
      'slaRemaining': (o['status'] == 'COMPLETED' || o['status'] == 'READY_FOR_DOWNLOAD') ? 'Hoàn thành' : 'Đúng hạn SLA',
      'isUrgent': o['kanban_column'] == 'DEVELOPING',
      'statusNote': 'Trạng thái: ${o['status']}',
      'nextStep': nextStep,
    };
  }

  Future<void> _loadKanban() async {
    final data = await WebApiService().getLabKanban();
    if (!mounted) return;
    final qList = (data['QUEUE'] as List?) ?? [];
    final devList = (data['DEVELOPING'] as List?) ?? [];
    final dryList = (data['DRYING'] as List?) ?? (data['QC'] as List?) ?? [];
    final scanList = (data['SCANNING'] as List?) ?? [];
    final readyList = (data['READY'] as List?) ?? [];

    setState(() {
      _kanbanData['1. Tiếp nhận'] = qList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Chuyển Tank →')).toList();
      _kanbanData['2. Vào Tank / Tráng'] = devList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Sang Tủ Sấy →')).toList();
      _kanbanData['3. Sấy khô'] = dryList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Chuyển Scan →')).toList();
      _kanbanData['4. Scan số hóa'] = scanList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Chuyển QC & Archive →')).toList();
      _kanbanData['5. QC & Archive'] = readyList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Lưu bao negative')).toList();
    });
  }

  String _mapColToBackendStep(String colName) {
    if (colName.startsWith('1.')) return 'QUEUE';
    if (colName.startsWith('2.')) return 'DEVELOPING';
    if (colName.startsWith('3.')) return 'DRYING';
    if (colName.startsWith('4.')) return 'SCANNING';
    return 'READY';
  }

  Future<void> _moveCard(String fromCol, String toCol, Map<String, dynamic> card) async {
    final backendStep = _mapColToBackendStep(toCol);
    final rawId = (card['rawId'] ?? card['id'].toString().replaceAll('#', '')).toString();
    await WebApiService().updateKanbanStep(rawId, backendStep);
    await _loadKanban();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã chuyển đơn ${card['id']} sang $toCol (Đồng bộ trực tiếp với Mobile Khách hàng)'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalActive = _kanbanData.values.fold<int>(0, (sum, list) => sum + list.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MINILAB OPS // TRẠM XỬ LÝ TRUNG TÂM (SQL SERVER)', style: AppTypography.labelCaps),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('Bảng Kanban Tiếp nhận & Vận hành', style: AppTypography.pageTitle),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('CA TRỰC SÁNG: $totalActive ĐƠN TRONG CSDL', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadKanban,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Đồng bộ từ CSDL'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (ctx, constraints) {
              return Row(
                children: [
                  _buildMetricTile('TỔNG ĐƠN TRONG BẢNG', '$totalActive', 'đơn hàng', AppColors.secondary),
                  const SizedBox(width: 12),
                  _buildMetricTile('BỂ C-41 NHIỆT ĐỘ', '37.8°C', 'Chuẩn ±0.1°', AppColors.primary),
                  const SizedBox(width: 12),
                  _buildMetricTile('SCANNER NORITSU', 'ACTIVE', 'HS-1800 #1', AppColors.secondary),
                  const SizedBox(width: 12),
                  _buildMetricTile('QC HOÀN TẤT', '99.2%', 'Pass 1st try', AppColors.secondary),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 680,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn('1. Tiếp nhận', '2. Vào Tank / Tráng', AppColors.primary),
                const SizedBox(width: 14),
                _buildKanbanColumn('2. Vào Tank / Tráng', '3. Sấy khô', AppColors.secondary),
                const SizedBox(width: 14),
                _buildKanbanColumn('3. Sấy khô', '4. Scan số hóa', AppColors.inkMuted),
                const SizedBox(width: 14),
                _buildKanbanColumn('4. Scan số hóa', '5. QC & Archive', AppColors.primary),
                const SizedBox(width: 14),
                _buildKanbanColumn('5. QC & Archive', null, AppColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String val, String sub, Color valColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valColor)),
                const SizedBox(width: 6),
                Text(sub, style: AppTypography.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(String colName, String? nextCol, Color dotColor) {
    final cards = _kanbanData[colName] ?? [];
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outline),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(colName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cards.length.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.separated(
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final c = cards[idx];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: c['isUrgent'] == true ? AppColors.primary : AppColors.outline,
                        width: c['isUrgent'] == true ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c['id'], style: AppTypography.dataMono.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: c['isUrgent'] == true ? AppColors.warningBg : AppColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                c['slaRemaining'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: c['isUrgent'] == true ? AppColors.warning : AppColors.inkMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(c['customer'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(c['film'], style: AppTypography.caption),
                        const SizedBox(height: 6),

                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: (c['tags'] as List).map<Widget>((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(tag.toString(), style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c['statusNote'], style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                            if (nextCol != null)
                              InkWell(
                                onTap: () => _moveCard(colName, nextCol, c),
                                child: Text(c['nextStep'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              )
                            else
                              const Text('Lưu bao ✓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
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
      ),
    );
  }
}
