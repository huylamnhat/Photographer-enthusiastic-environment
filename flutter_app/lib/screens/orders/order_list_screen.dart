import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/api_service.dart';
import '../../models/order_model.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  final int initialTab;
  const OrderListScreen({super.key, this.initialTab = 0});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late int _activeTab; // 0 = Tất cả, 1 = Đang xử lý, 2 = Sẵn sàng tải, 3 = Hoàn tất, 4 = Đã khiếu nại
  bool _loading = true;
  List<OrderModel> _orders = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab;
    _loadOrders();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadOrders(silent: true),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadOrders(silent: true);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }
    final res = await ApiService().getOrders();
    if (!mounted) return;
    setState(() {
      _orders = res;
      _loading = false;
    });
  }

  String _disputeStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'NEGOTIATING':
      case 'IN_NEGOTIATION':
        return 'ĐANG THƯƠNG LƯỢNG';
      case 'COMPENSATED':
        return 'ĐÃ ĐỀN BÙ CUỘN FILM';
      case 'REFUNDED':
        return 'ĐÃ HOÀN TIỀN';
      case 'ESCALATED':
        return 'CHỜ ADMIN PHÂN XỬ';
      case 'RESOLVED':
        return 'ĐÃ GIẢI QUYẾT';
      default:
        return 'ĐANG KHIẾU NẠI';
    }
  }

  Color _disputeStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPENSATED':
      case 'REFUNDED':
      case 'RESOLVED':
        return AppColors.secondary;
      case 'ESCALATED':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Map<String, dynamic> _mapOrderToCard(OrderModel o) {
    final col = o.kanbanColumn.toUpperCase();
    final st = o.status.toUpperCase();
    String uiStatus = 'PROCESSING';
    String statusLabel = 'ĐANG XỬ LÝ';
    String stepText = 'Bước 2/5: Đang tráng hóa chất';
    String slaText = 'Theo dõi trực tiếp từ Lab Kanban';

    if (col == 'QUEUE' || st == 'RECEIVED' || st == 'PENDING_FILM') {
      uiStatus = 'PROCESSING';
      statusLabel = '1. TIẾP NHẬN';
      stepText = 'Bước 1/5: Tiếp nhận cuộn phim tại Lab';
    } else if (col == 'DEVELOPING') {
      uiStatus = 'PROCESSING';
      statusLabel = '2. VÀO TANK / TRÁNG';
      stepText = 'Bước 2/5: Vào Tank / Tráng hóa chất';
    } else if (col == 'DRYING' || col == 'QC' || st == 'QC_CHECK') {
      uiStatus = 'PROCESSING';
      statusLabel = '3. SẤY KHÔ';
      stepText = 'Bước 3/5: Sấy khô & Cân bằng phẳng';
    } else if (col == 'SCANNING') {
      uiStatus = 'PROCESSING';
      statusLabel = '4. SCAN SỐ HÓA';
      stepText = 'Bước 4/5: Scan số hóa máy Noritsu / Frontier';
    } else if (col == 'READY' || st == 'READY_FOR_DOWNLOAD') {
      uiStatus = 'READY';
      statusLabel = '5. QC & ARCHIVE';
      stepText = 'Bước 5/5: QC & Archive (Sẵn sàng tải)';
      slaText = 'File ảnh đã sẵn sàng trong Kho ảnh';
    } else if (st == 'COMPLETED') {
      uiStatus = 'COMPLETED';
      statusLabel = 'HOÀN TẤT';
      stepText = 'Bước 5/5: QC & Archive (Đã hoàn tất)';
      slaText = 'Lưu kho 60 ngày';
    }

    final firstItem = o.items.isNotEmpty ? o.items.first : null;
    final filmText = firstItem != null
        ? '${firstItem.quantity.toString().padLeft(2, '0')} cuộn ${firstItem.filmName}'
        : '01 cuộn Kodak Portra 400 (135/36)';
    final processText = firstItem != null ? firstItem.name : 'Tráng & Scan C-41 Tiêu chuẩn';
    final formattedPrice =
        '${o.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

    return {
      'order': o,
      'id': o.orderId,
      'lab': o.labName,
      'film': filmText,
      'process': processText,
      'step': stepText,
      'status': uiStatus,
      'statusLabel': statusLabel,
      'slaText': slaText,
      'price': formattedPrice,
      'isDisputed': o.hasDispute,
      'disputeId': o.disputeId ?? '',
      'disputeStatus': o.disputeStatus ?? '',
      'disputeIssue': o.disputeIssue ?? '',
      'disputeDescription': o.disputeDescription ?? '',
      'disputeMessages': o.disputeMessages,
      'compensationNote': o.compensationNote ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final mappedOrders = _orders.map(_mapOrderToCard).toList();
    final disputedCount = mappedOrders.where((o) => o['isDisputed'] == true).length;
    final filtered = mappedOrders.where((o) {
      if (_activeTab == 1) return o['status'] == 'PROCESSING';
      if (_activeTab == 2) return o['status'] == 'READY';
      if (_activeTab == 3) return o['status'] == 'COMPLETED';
      if (_activeTab == 4) return o['isDisputed'] == true;
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
        actions: [
          IconButton(
            tooltip: 'Làm mới tiến độ từ Lab',
            icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Stitch APP-CUS-10)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceRaised,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab(0, 'Tất cả (${mappedOrders.length})'),
                  const SizedBox(width: 6),
                  _buildTab(1, 'Đang tráng scan'),
                  const SizedBox(width: 6),
                  _buildTab(2, 'Sẵn sàng tải'),
                  const SizedBox(width: 6),
                  _buildTab(3, 'Hoàn tất'),
                  const SizedBox(width: 6),
                  _buildTab(4, 'Đã khiếu nại ($disputedCount)'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.outline),

          // Orders List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _activeTab == 4
                              ? 'Chưa có đơn hàng nào đang khiếu nại'
                              : 'Không có đơn hàng nào trong mục này',
                          style: AppTypography.bodySmall,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final isReady = item['status'] == 'READY';
                            final isProcessing = item['status'] == 'PROCESSING';
                            final isDisputed = item['isDisputed'] == true;
                            final disputeStatus = (item['disputeStatus'] ?? '').toString();
                            final disputeColor = _disputeStatusColor(disputeStatus);

                            return InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailScreen(
                                      order: item['order'] as OrderModel?,
                                      orderId: item['id'],
                                    ),
                                  ),
                                );
                                _loadOrders();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceRaised,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDisputed
                                        ? disputeColor.withValues(alpha: 0.45)
                                        : AppColors.outline,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                '#${item['id']}',
                                                style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item['lab'],
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isReady ? Icons.check_circle : (isProcessing ? Icons.timelapse : Icons.archive),
                                                  size: 14,
                                                  color: isReady ? AppColors.secondary : (isProcessing ? AppColors.primary : AppColors.inkMuted),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    item['step'],
                                                    overflow: TextOverflow.ellipsis,
                                                    style: AppTypography.dataMono.copyWith(fontSize: 11),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item['price'],
                                            style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.ink),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isDisputed) ...[
                                      const SizedBox(height: 8),
                                      _buildDisputeInfoBox(item),
                                    ],
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

  Widget _buildDisputeInfoBox(Map<String, dynamic> item) {
    final disputeId = (item['disputeId'] ?? '').toString();
    final disputeStatus = (item['disputeStatus'] ?? '').toString();
    final disputeIssue = (item['disputeIssue'] ?? '').toString();
    final disputeDescription = (item['disputeDescription'] ?? '').toString();
    final compensationNote = (item['compensationNote'] ?? '').toString();
    final messages = (item['disputeMessages'] as List<dynamic>?) ?? [];
    final statusColor = _disputeStatusColor(disputeStatus);
    final statusText = _disputeStatusLabel(disputeStatus);

    String latestResponse = '';
    if (compensationNote.isNotEmpty) {
      latestResponse = 'Đền bù / Kết quả: $compensationNote';
    } else if (messages.isNotEmpty) {
      final lastMsg = messages.last as Map<String, dynamic>;
      final sender = (lastMsg['sender'] ?? 'Hệ thống').toString();
      final text = (lastMsg['text'] ?? '').toString();
      if (text.isNotEmpty) {
        latestResponse = '$sender: $text';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_outlined, size: 14, color: statusColor),
              const SizedBox(width: 6),
              if (disputeId.isNotEmpty) ...[
                Text(
                  '#$disputeId',
                  style: AppTypography.dataMono.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelCaps.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (disputeIssue.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              disputeIssue,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
          ],
          if (disputeDescription.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              disputeDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.inkMuted,
              ),
            ),
          ],
          if (latestResponse.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
              ),
              child: Text(
                latestResponse,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
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
