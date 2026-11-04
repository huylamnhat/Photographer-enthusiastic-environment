import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/api_service.dart';

class LabKanbanTab extends StatefulWidget {
  final String? labId;
  final String? labName;
  const LabKanbanTab({super.key, this.labId, this.labName});

  @override
  State<LabKanbanTab> createState() => _LabKanbanTabState();
}

class _LabKanbanTabState extends State<LabKanbanTab> {
  // 5 Columns matching Stitch WEB-LAB-03
  final Map<String, List<Map<String, dynamic>>> _kanbanData = {
    '1. Tiếp nhận': [
      {
        'id': '#ORD-2024-88412',
        'customer': 'Lê Hoàng Nam',
        'film': 'Kodak Vision3 500T (135)',
        'tags': ['ECN-2', 'Push +1', 'TIFF 16-bit'],
        'slaRemaining': 'còn 3h45',
        'isUrgent': true,
        'statusNote': 'Đang soi kiểm tra',
        'nextStep': 'Chuyển Tank →',
      },
      {
        'id': '#ORD-2024-88415',
        'customer': 'Nguyễn Thu Thảo',
        'film': 'Fujicolor C200 (135)',
        'tags': ['C-41', 'JPG Standard'],
        'slaRemaining': 'còn 18h',
        'isUrgent': false,
        'statusNote': 'Chờ tách tem',
        'nextStep': 'Chuyển Tank →',
      },
      {
        'id': '#ORD-2024-88418',
        'customer': 'Đoàn Vĩnh Khiêm',
        'film': 'Ilford HP5 Plus (120)',
        'tags': ['B&W D-76', 'Roll 120 Mid'],
        'slaRemaining': 'còn 14h',
        'isUrgent': false,
        'statusNote': 'Đã dán nhãn ID',
        'nextStep': 'Chuyển Tank →',
      },
      {
        'id': '#ORD-2024-88421',
        'customer': 'Phạm Hương Trà',
        'film': 'Kodak Tri-X 400 (135)',
        'tags': ['B&W', 'Lưu negative'],
        'slaRemaining': 'còn 22h',
        'isUrgent': false,
        'statusNote': 'Tiếp nhận lễ tân',
        'nextStep': 'Chuyển Tank →',
      },
    ],
    '2. Vào Tank / Tráng': [
      {
        'id': '#ORD-2024-88399',
        'customer': 'Trần Minh Quân',
        'film': 'Kodak Portra 400 (135)',
        'tags': ['Bể C-41 Jobo', 'Lô #04'],
        'slaRemaining': 'còn 1h10',
        'isUrgent': true,
        'progress': 0.75,
        'progressNote': 'Đang hãm Bleach-Fix (06:20 / 08:00)',
        'statusNote': 'Trong bể Jobo',
        'nextStep': 'Sang Tủ Sấy →',
      },
      {
        'id': '#ORD-2024-88402',
        'customer': 'Võ Nhật Quang',
        'film': 'Cinestill 800T (120)',
        'tags': ['C-41 Cross', 'Tank Paterson #2'],
        'slaRemaining': 'còn 6h',
        'isUrgent': false,
        'statusNote': 'Tank quay 3.15 min',
        'nextStep': 'Sang Tủ Sấy →',
      },
      {
        'id': '#ORD-2024-88407',
        'customer': 'Bùi Cẩm Ly',
        'film': 'Kentmere Pan 400 (135)',
        'tags': ['B&W Rodinal 1:50'],
        'slaRemaining': 'còn 8h',
        'isUrgent': false,
        'statusNote': 'Chờ xả nước cuối',
        'nextStep': 'Sang Tủ Sấy →',
      },
    ],
    '3. Sấy khô': [
      {
        'id': '#ORD-2024-88388',
        'customer': 'Hoàng Gia Bảo',
        'film': 'Fujifilm Superia X-TRA 400',
        'tags': ['Tủ sấy #02 (32°C)'],
        'slaRemaining': 'còn 5h',
        'isUrgent': false,
        'statusNote': 'Đã sấy 40/45 phút',
        'nextStep': 'Chuyển Scan →',
      },
      {
        'id': '#ORD-2024-88390',
        'customer': 'Lý Lan Phương',
        'film': 'Fomapan 200 (135)',
        'tags': ['Tủ sấy phòng B&W'],
        'slaRemaining': 'còn 7h',
        'isUrgent': false,
        'statusNote': 'Đã nhỏ Photo-Flo',
        'nextStep': 'Chuyển Scan →',
      },
    ],
    '4. Scan số hóa': [
      {
        'id': '#ORD-2024-88371',
        'customer': 'Chu Khánh Linh',
        'film': 'Kodak Ektar 100 (120)',
        'tags': ['Frontier SP-3000', 'TIFF 4800dpi'],
        'slaRemaining': 'còn 2h15',
        'isUrgent': true,
        'statusNote': 'Frame 8/12 · Băng film sạch',
        'nextStep': 'Chuyển QC →',
      },
      {
        'id': '#ORD-2024-88376',
        'customer': 'Vương Trí Tài',
        'film': 'Ilford Delta 3200 (135)',
        'tags': ['Noritsu HS-1800', 'Hạt thô grain'],
        'slaRemaining': 'còn 5h',
        'isUrgent': false,
        'statusNote': 'Chờ nạp strip',
        'nextStep': 'Chuyển QC →',
      },
    ],
    '5. QC & Archive': [
      {
        'id': '#ORD-2024-88355',
        'customer': 'Mai Thanh Sơn',
        'film': 'Fujicolor 100 Japan (135)',
        'tags': ['36 frames sync', 'Cloud Zip OK'],
        'slaRemaining': 'Hoàn thành',
        'isUrgent': false,
        'statusNote': 'QC ĐẠT · Đã gửi link SMS/Mail',
        'nextStep': 'Lưu bao negative',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchLiveKanban();
  }

  void _fetchLiveKanban() async {
    try {
      final res = await ApiService().getLabKanban(labId: widget.labId);
      if (res.isNotEmpty && mounted) {
        final queue = res['QUEUE'] as List? ?? [];
        setState(() {
          for (var o in queue) {
            final orderId = (o['order_id'] ?? '').toString();
            if (orderId.isNotEmpty && !_kanbanData['1. Tiếp nhận']!.any((x) => x['id'] == orderId || x['id'] == '#$orderId')) {
              _kanbanData['1. Tiếp nhận']!.insert(0, {
                'id': '#$orderId',
                'customer': o['pickup_address'] ?? 'Khách đặt qua App',
                'film': o['items']?[0]?['film_name'] ?? 'Phim 135 Color (C-41)',
                'tags': ['Đơn Live từ Điện thoại', o['items']?[0]?['name'] ?? 'C-41 Standard'],
                'slaRemaining': 'còn 23h59',
                'isUrgent': true,
                'statusNote': 'Khách vừa đặt từ điện thoại',
                'nextStep': 'Chuyển Tank →',
              });
            }
          }
        });
      }
    } catch (_) {}
  }

  void _moveCard(String fromCol, String toCol, Map<String, dynamic> card) {
    setState(() {
      _kanbanData[fromCol]?.remove(card);
      _kanbanData[toCol]?.insert(0, card);
    });

    String backendCol = 'DEVELOPING';
    if (toCol.contains('Tráng') || toCol.contains('Tank')) {
      backendCol = 'DEVELOPING';
    } else if (toCol.contains('Sấy') || toCol.contains('Scan')) {
      backendCol = 'SCANNING';
    } else if (toCol.contains('QC') || toCol.contains('Kiểm định')) {
      backendCol = 'QC';
    } else if (toCol.contains('Hoàn tất') || toCol.contains('Sẵn sàng')) {
      backendCol = 'READY';
    }

    final cleanId = (card['id'] ?? '').toString().replaceAll('#', '');
    ApiService().updateKanbanStep(cleanId, backendCol);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã cập nhật đơn $cleanId sang $toCol lên hệ thống')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MINILAB OPS // TIỆM: ' + (widget.labName ?? 'CropLab Hà Nội').toUpperCase() + ' [' + (widget.labId ?? 'LAB-001').toUpperCase() + '] - TỰ ĐỘNG NHẬN ĐƠN TỪ MOBILE APP', style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
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
                            const Text('CA TRỰC SÁNG: 28 ĐƠN ĐANG XỬ LÝ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('BỂ C-41: 37.8°C (CHUẨN)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.sync, size: 16, color: AppColors.secondary),
                    label: const Text('Đồng bộ Đơn Live (Từ App)'),
                    onPressed: _fetchLiveKanban,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code_scanner, size: 16),
                    label: const Text('Quét mã đơn mới (+)'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 6 Mini Metric Cards
          LayoutBuilder(
            builder: (ctx, constraints) {
              return Row(
                children: [
                  _buildMetricTile('TỔNG CUỘN HÔM NAY', '54', '+12 cuộn', AppColors.secondary),
                  const SizedBox(width: 12),
                  _buildMetricTile('BỂ C-41 NHIỆT ĐỘ', '37.8°C', 'Chuẩn ±0.1°', AppColors.primary),
                  const SizedBox(width: 12),
                  _buildMetricTile('HÓA CHẤT ECN-2', '14/25', 'cuộn đã chạy', AppColors.inkMuted),
                  const SizedBox(width: 12),
                  _buildMetricTile('SCANNER FRONTIER', 'ACTIVE', 'SP-3000 #1', AppColors.secondary),
                  const SizedBox(width: 12),
                  _buildMetricTile('SLA NGUY CƠ TRỄ', '2 đơn', '< 3h hạn', AppColors.danger),
                  const SizedBox(width: 12),
                  _buildMetricTile('QC HOÀN TẤT', '94.8%', 'Pass 1st try', AppColors.secondary),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 5 Kanban Columns
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
            // Column Header
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

            // Cards Scroll
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

                        // Tags
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
                              child: Text(tag, style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                            );
                          }).toList(),
                        ),

                        if (c['progress'] != null) ...[
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: c['progress'],
                            color: AppColors.secondary,
                            backgroundColor: AppColors.surfaceSunken,
                          ),
                          const SizedBox(height: 4),
                          Text(c['progressNote'] ?? '', style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
                        ],

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
