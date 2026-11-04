import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import 'lab_detail_screen.dart';
import 'create_order_screen.dart';

class LabSearchScreen extends StatefulWidget {
  const LabSearchScreen({super.key});

  @override
  State<LabSearchScreen> createState() => _LabSearchScreenState();
}

class _LabSearchScreenState extends State<LabSearchScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'Tất cả';
  final Set<String> _selectedCompareLabs = {'llab', 'croplab'};

  final List<Map<String, dynamic>> _labs = [
    {
      'id': 'llab',
      'name': 'LLab Sài Gòn',
      'tag': 'XÁC THỰC',
      'rating': '4.9',
      'reviews': '140',
      'distance': '1.8km (Q.1)',
      'services': ['C-41', 'B&W', 'ECN-2'],
      'machine': 'Noritsu HS-1800',
      'machineDesc': 'Tone ấm tự nhiên',
      'sla': '24 Giờ',
      'price': '70.000đ',
      'image': MockTestAssets.labCover1,
      'drop': 'Có tủ Drop 24/7',
    },
    {
      'id': 'croplab',
      'name': 'Croplab Retro',
      'tag': 'PHỔ BIẾN',
      'rating': '4.8',
      'reviews': '98',
      'distance': '3.2km (Bình Thạnh)',
      'services': ['C-41', 'B&W'],
      'machine': 'Fuji SP-3000',
      'machineDesc': 'Độ trong, xanh pastel',
      'sla': '36 Giờ',
      'price': '65.000đ',
      'image': MockTestAssets.labCover2,
      'drop': 'Nhận trực tiếp',
    },
    {
      'id': 'nadar',
      'name': 'Nadar Darkroom',
      'tag': 'THỦ CÔNG',
      'rating': '5.0',
      'reviews': '45',
      'distance': '4.5km (Q.3)',
      'services': ['B&W Chuyên sâu', 'TIFF 16-bit'],
      'machine': 'Hasselblad Flextight',
      'machineDesc': 'D-76 & XTOL Silver Gelatin',
      'sla': '48 Giờ',
      'price': '90.000đ',
      'image': MockTestAssets.labCover3,
      'drop': 'Hẹn trước',
    },
  ];

  void _toggleCompare(String labId) {
    setState(() {
      if (_selectedCompareLabs.contains(labId)) {
        _selectedCompareLabs.remove(labId);
      } else {
        if (_selectedCompareLabs.length >= 2) {
          _selectedCompareLabs.remove(_selectedCompareLabs.first);
        }
        _selectedCompareLabs.add(labId);
      }
    });
  }

  void _showCompareModal() {
    final selectedList = _labs.where((l) => _selectedCompareLabs.contains(l['id'])).toList();
    if (selectedList.length < 2) return;

    final labA = selectedList[0];
    final labB = selectedList[1];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.balance, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đối Chiếu Kỹ Thuật Lab', style: AppTypography.cardTitle),
                          Text('Dữ liệu thông số & biểu phí chuẩn hoá', style: AppTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Header
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text('CHỈ TIÊU KỸ THUẬT', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        labA['name'],
                        textAlign: TextAlign.center,
                        style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        labB['name'],
                        textAlign: TextAlign.center,
                        style: AppTypography.labelCaps.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              _buildCompareRow('Giá C-41 (135/36)', labA['price'], labB['price'], isHighlight: true),
              _buildCompareRow('Thời gian SLA', labA['sla'], labB['sla']),
              _buildCompareRow('Hệ Máy Scan', labA['machine'], labB['machine']),
              _buildCompareRow('Tone màu', labA['machineDesc'], labB['machineDesc']),
              _buildCompareRow('Gửi Roll', labA['drop'], labB['drop']),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateOrderScreen(initialLabId: labA['id']),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: Text('Chọn ${labA['name']}', style: AppTypography.button.copyWith(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateOrderScreen(initialLabId: labB['id']),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                      ),
                      child: Text('Chọn ${labB['name']}', style: AppTypography.button.copyWith(fontSize: 12, color: AppColors.ink)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompareRow(String label, String valA, String valB, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valA,
              textAlign: TextAlign.center,
              style: isHighlight
                  ? AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)
                  : AppTypography.dataMono.copyWith(fontSize: 11),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valB,
              textAlign: TextAlign.center,
              style: isHighlight
                  ? AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold)
                  : AppTypography.dataMono.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLabs = _labs.where((lab) {
      if (_activeFilter == 'C-41 Màu') {
        return (lab['services'] as List).contains('C-41');
      } else if (_activeFilter == 'B&W Đen trắng') {
        return (lab['services'] as List).any((s) => s.toString().contains('B&W'));
      } else if (_activeFilter == 'ECN-2 Cine') {
        return (lab['services'] as List).contains('ECN-2');
      } else if (_activeFilter == 'Lấy trong 24h') {
        return lab['sla'] == '24 Giờ';
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outline, height: 1),
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FILM LAB',
              style: AppTypography.cardTitle.copyWith(letterSpacing: 1.0, fontSize: 14),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search bar and filter button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: AppTypography.bodySmall,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search, size: 18, color: AppColors.inkMuted),
                            hintText: 'Tìm tên Lab, địa chỉ hoặc máy scan...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tune, size: 16, color: AppColors.inkMuted),
                          const SizedBox(width: 4),
                          Text('Lọc', style: AppTypography.labelCaps),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Filter chips scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', count: '(${_labs.length})'),
                      const SizedBox(width: 6),
                      _buildFilterChip('C-41 Màu'),
                      const SizedBox(width: 6),
                      _buildFilterChip('B&W Đen trắng'),
                      const SizedBox(width: 6),
                      _buildFilterChip('ECN-2 Cine'),
                      const SizedBox(width: 6),
                      _buildFilterChip('Lấy trong 24h'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ledger summary banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(
                            'Khu vực: TP. Hồ Chí Minh',
                            style: AppTypography.labelCaps.copyWith(color: AppColors.ink),
                          ),
                        ],
                      ),
                      Text(
                        '${filteredLabs.length}/${_labs.length} LAB SẴN SÀNG',
                        style: AppTypography.dataMono.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Lab list ledger
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredLabs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final lab = filteredLabs[index];
                    final isCompared = _selectedCompareLabs.contains(lab['id']);

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: MockTestAssets.image(lab['image'], fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            lab['name'],
                                            style: AppTypography.cardTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceSunken,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            lab['tag'],
                                            style: AppTypography.labelCaps.copyWith(fontSize: 8, color: AppColors.secondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 12, color: AppColors.primary),
                                        const SizedBox(width: 2),
                                        Text(lab['rating'], style: AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                                        Text(' (${lab['reviews']}) • ', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted)),
                                        Text(lab['distance'], style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Compare checkbox button
                              InkWell(
                                onTap: () => _toggleCompare(lab['id']),
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompared ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceSunken,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: isCompared ? AppColors.primary : AppColors.outline),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCompared ? Icons.check_box : Icons.check_box_outline_blank,
                                        size: 14,
                                        color: isCompared ? AppColors.primary : AppColors.inkMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'So sánh',
                                        style: AppTypography.labelCaps.copyWith(
                                          fontSize: 9,
                                          color: isCompared ? AppColors.primary : AppColors.ink,
                                          fontWeight: isCompared ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Capability badges
                          Wrap(
                            spacing: 4,
                            children: [
                              ...(lab['services'] as List).map(
                                (s) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSunken,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(s, style: AppTypography.dataMono.copyWith(fontSize: 9)),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSunken,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  lab['machine'],
                                  style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Specs ribbon & actions
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 12, color: AppColors.secondary),
                                    const SizedBox(width: 4),
                                    Text('SLA: ', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                                    Text(
                                      lab['sla'],
                                      style: AppTypography.dataMono.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Từ ', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                                    Text(
                                      lab['price'],
                                      style: AppTypography.dataMono.copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                    Text('/cuộn', style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => LabDetailScreen(labId: lab['id'])),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(60, 30),
                                  side: const BorderSide(color: AppColors.outline),
                                ),
                                child: Text('Chi tiết tiệm', style: AppTypography.button.copyWith(fontSize: 11, color: AppColors.ink)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => CreateOrderScreen(initialLabId: lab['id'])),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(60, 30),
                                  elevation: 0,
                                ),
                                child: Text('Đặt tráng scan', style: AppTypography.button.copyWith(fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Floating Comparison Dock
          if (_selectedCompareLabs.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_selectedCompareLabs.length}',
                          style: AppTypography.dataMono.copyWith(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ĐÃ CHỌN SO SÁNH', style: AppTypography.labelCaps.copyWith(fontSize: 8, color: Colors.white70)),
                          Text(
                            _selectedCompareLabs.map((id) => _labs.firstWhere((l) => l['id'] == id)['name']).join(' vs '),
                            style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showCompareModal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                      ),
                      child: Row(
                        children: [
                          Text('So sánh ngay', style: AppTypography.button.copyWith(fontSize: 11)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_upward, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {String? count}) {
    final isSelected = _activeFilter == label;
    return InkWell(
      onTap: () => setState(() => _activeFilter = label),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelCaps.copyWith(
                fontSize: 10,
                color: isSelected ? Colors.white : AppColors.ink,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 3),
              Text(
                count,
                style: AppTypography.dataMono.copyWith(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : AppColors.inkMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
