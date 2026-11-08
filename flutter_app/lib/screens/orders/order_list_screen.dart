import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  int _activeTab = 0; // 0 = Tất cả, 1 = Đang xử lý, 2 = Sẵn sàng tải, 3 = Hoàn tất

  final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 'ORD-9281',
      'lab': 'LLab Sài Gòn',
      'film': '02 cuộn Kodak ColorPlus 200 (135/36)',
      'process': 'C-41 Standard JPG',
      'step': 'Bước 3/5: Sấy khô & Cân bằng phẳng',
      'status': 'PROCESSING',
      'statusLabel': 'ĐANG XỬ LÝ',
      'slaText': 'Dự kiến 18:00 hôm nay',
      'price': '140.000đ',
      'time': 'Hôm nay 09:15',
    },
    {
      'id': 'ORD-8742',
      'lab': 'Croplab Retro',
      'film': '01 cuộn Fuji Superia Premium 400 (135/36)',
      'process': 'C-41 Fuji SP-3000',
      'step': 'Bước 5/5: Đã xuất bản vào kho Archive',
      'status': 'READY',
      'statusLabel': 'SẴN SÀNG TẢI',
      'slaText': 'Đã hoàn thành đúng hạn',
      'price': '65.000đ',
      'time': 'Hôm qua 16:30',
    },
    {
      'id': 'ORD-8119',
      'lab': 'Nadar Darkroom',
      'film': '01 cuộn Ilford HP5 Plus 400 (120 Medium)',
      'process': 'B&W D-76 Thủ công Master TIFF',
      'step': 'Đã nhận lại âm bản tại tiệm',
      'status': 'COMPLETED',
      'statusLabel': 'HOÀN TẤT',
      'slaText': 'Lưu kho 60 ngày',
      'price': '135.000đ',
      'time': '3 ngày trước',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _mockOrders.where((o) {
      if (_activeTab == 1) return o['status'] == 'PROCESSING';
      if (_activeTab == 2) return o['status'] == 'READY';
      if (_activeTab == 3) return o['status'] == 'COMPLETED';
      return true;
    }).toList();

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
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ĐƠN HÀNG CỦA TÔI',
              style: AppTypography.cardTitle.copyWith(letterSpacing: 1.0, fontSize: 14),
            ),
          ],
        ),
        
      ),
      body: Column(
        children: [
          // Filter Tabs (Stitch APP-CUS-10)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceRaised,
            child: Row(
              children: [
                _buildTab(0, 'Tất cả (${_mockOrders.length})'),
                const SizedBox(width: 6),
                _buildTab(1, 'Đang tráng scan'),
                const SizedBox(width: 6),
                _buildTab(2, 'Sẵn sàng tải'),
                const SizedBox(width: 6),
                _buildTab(3, 'Hoàn tất'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),

          // Orders List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('Không có đơn hàng nào trong mục này', style: AppTypography.bodySmall),
                  )
                : RefreshIndicator(
                    onRefresh: () async => await Future.delayed(const Duration(milliseconds: 300)),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isReady = item['status'] == 'READY';
                      final isProcessing = item['status'] == 'PROCESSING';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(orderId: item['id']),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '#${item['id']}',
                                        style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(item['lab'], style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isReady
                                          ? AppColors.secondary.withValues(alpha: 0.1)
                                          : (isProcessing ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceSunken),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item['statusLabel'],
                                      style: AppTypography.labelCaps.copyWith(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isReady ? AppColors.secondary : (isProcessing ? AppColors.primary : AppColors.inkMuted),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(item['film'], style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(item['process'], style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted)),
                              const SizedBox(height: 10),
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
                                        Icon(
                                          isReady ? Icons.check_circle : (isProcessing ? Icons.timelapse : Icons.archive),
                                          size: 14,
                                          color: isReady ? AppColors.secondary : (isProcessing ? AppColors.primary : AppColors.inkMuted),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(item['step'], style: AppTypography.dataMono.copyWith(fontSize: 11)),
                                      ],
                                    ),
                                    Text(
                                      item['price'],
                                      style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.ink),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item['slaText'], style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                                  Row(
                                    children: [
                                      Text(
                                        'Chi tiết timeline',
                                        style: AppTypography.labelCaps.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 9, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
        ),
        child: Text(
          label,
          style: AppTypography.labelCaps.copyWith(
            fontSize: 10,
            color: isSelected ? Colors.white : AppColors.ink,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
