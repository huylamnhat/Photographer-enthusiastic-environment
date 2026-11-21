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
    '2. Tráng phim': [],
    '3. Sấy khô': [],
    '4. Quét ảnh': [],
    '5. Hoàn tất': [],
  };
  List<Map<String, dynamic>> _pendingPaymentOrders = [];

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
      'slaRemaining': (o['status'] == 'COMPLETED' || o['status'] == 'READY_FOR_DOWNLOAD') ? 'Hoàn thành' : 'Đúng hẹn',
      'isUrgent': o['kanban_column'] == 'DEVELOPING',
      'statusNote': 'Trạng thái: ${o['status']}',
      'nextStep': nextStep,
      'shipping_method': (o['shipping_method'] ?? '').toString(),
      'pickup_address': (o['pickup_address'] ?? '').toString(),
      'shipment': o['shipment'],
    };
  }

  Future<void> _loadKanban() async {
    final data = await WebApiService().getLabKanban();
    if (!mounted) return;
    final pendingPayList = (data['PENDING_PAYMENT'] as List?) ?? [];
    final qList = (data['QUEUE'] as List?) ?? [];
    final devList = (data['DEVELOPING'] as List?) ?? [];
    final dryList = (data['DRYING'] as List?) ?? (data['QC'] as List?) ?? [];
    final scanList = (data['SCANNING'] as List?) ?? [];
    final readyList = (data['READY'] as List?) ?? [];

    setState(() {
      _pendingPaymentOrders = pendingPayList
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _kanbanData['1. Tiếp nhận'] = qList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Chuyển tráng →')).toList();
      _kanbanData['2. Tráng phim'] = devList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Sang sấy khô →')).toList();
      _kanbanData['3. Sấy khô'] = dryList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Chuyển quét ảnh →')).toList();
      _kanbanData['4. Quét ảnh'] = scanList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Hoàn tất →')).toList();
      _kanbanData['5. Hoàn tất'] = readyList.map((o) => _mapOrderToCard(o as Map<String, dynamic>, 'Đã xong')).toList();
    });
  }

  Future<void> _confirmCancelPendingOrder(Map<String, dynamic> order) async {
    final orderId = (order['order_id'] ?? '').toString();
    final customerName = (order['customer_name'] ?? 'Khách hàng').toString();
    final reasonCtrl = TextEditingController(text: 'Khách hàng thanh toán VNPAY quá hạn');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: Text('Hủy đơn chờ thanh toán #$orderId?', style: AppTypography.cardTitle),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khách hàng $customerName chưa hoàn tất thanh toán qua VNPAY. Sau khi hủy, khách không thể thanh toán tiếp cho đơn này.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 12),
              Text('LÝ DO HỦY ĐƠN', style: AppTypography.labelCaps),
              const SizedBox(height: 6),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                style: AppTypography.bodySmall,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                  hintText: 'Nhập lý do hủy đơn...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Giữ lại'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: const Text('Xác nhận hủy đơn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );

    final reasonText = reasonCtrl.text.trim();
    reasonCtrl.dispose();

    if (confirmed != true || !mounted) return;

    final res = await WebApiService().cancelLabPendingOrder(
      orderId,
      reason: reasonText.isNotEmpty ? reasonText : 'Khách hàng thanh toán VNPAY quá hạn',
    );
    if (!mounted) return;

    if (res['success'] == true) {
      await _loadKanban();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text('Đã hủy đơn #$orderId thành công'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(res['message']?.toString() ?? 'Không thể hủy đơn hàng'),
        ),
      );
    }
  }

  Future<void> _confirmManualQrPaid(Map<String, dynamic> order) async {
    final orderId = (order['order_id'] ?? '').toString();
    final customerName = (order['customer_name'] ?? 'Khách hàng').toString();
    final amountStr = _formatVnd(order['total_amount']);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        title: Text('Xác nhận đã nhận tiền đơn #$orderId?', style: AppTypography.cardTitle),
        content: Text(
          'Bạn đã kiểm tra biến động số dư và thấy $customerName chuyển khoản $amountStr qua QR (nội dung #$orderId)?\n\nSau khi xác nhận, đơn sẽ chuyển thẳng vào cột 1. Tiếp nhận để xử lý (không cộng ví Lab).',
          style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Chưa thấy tiền'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Đã nhận tiền • Tiếp nhận đơn'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final res = await WebApiService().confirmLabPendingOrderPayment(orderId);
    if (!mounted) return;

    if (res['success'] == true) {
      await _loadKanban();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text('Đã xác nhận tiền vào cho đơn #$orderId và chuyển sang 1. Tiếp nhận'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(res['message']?.toString() ?? 'Không thể xác nhận thanh toán'),
        ),
      );
    }
  }

  String _formatWaitElapsed(String? isoDate) {
    final dt = DateTime.tryParse(isoDate ?? '')?.toLocal();
    if (dt == null) return 'Vừa tạo';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa tạo (<1 phút)';
    if (diff.inMinutes < 60) return 'Đã chờ ${diff.inMinutes} phút';
    if (diff.inHours < 24) {
      final mins = diff.inMinutes % 60;
      return 'Đã chờ ${diff.inHours}h ${mins}p';
    }
    return 'Đã chờ ${diff.inDays} ngày';
  }

  bool _isOverduePayment(String? isoDate) {
    final dt = DateTime.tryParse(isoDate ?? '')?.toLocal();
    if (dt == null) return false;
    return DateTime.now().difference(dt).inMinutes >= 15;
  }

  String _formatVnd(dynamic amount) {
    final numVal = (amount is num) ? amount.toDouble() : double.tryParse(amount?.toString() ?? '0') ?? 0;
    return '${numVal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
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
    final res = await WebApiService().updateKanbanStepWithResult(rawId, backendStep);
    if (!mounted) return;
    if (res['success'] == true) {
      await _loadKanban();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chuyển đơn ${card['id']} sang $toCol (Đồng bộ trực tiếp với Mobile Khách hàng)'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(res['message']?.toString() ?? 'Không thể chuyển bước xử lý'),
        ),
      );
    }
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
                  Row(
                    children: [
                      const Text('Quản lý & Xử lý đơn hàng', style: AppTypography.pageTitle),
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
                            Text('$totalActive ĐƠN ĐANG XỬ LÝ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
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
                label: const Text('Làm mới'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (ctx, constraints) {
              final doneCount = _kanbanData['5. Hoàn tất']?.length ?? 0;
              final processingCount = (totalActive - doneCount).clamp(0, totalActive);
              return Row(
                children: [
                  _buildMetricTile('TỔNG ĐƠN XỬ LÝ', '$totalActive', 'đã thanh toán', AppColors.secondary),
                  const SizedBox(width: 12),
                  _buildMetricTile(
                    'CHỜ THANH TOÁN',
                    '${_pendingPaymentOrders.length}',
                    'chờ khách trả tiền',
                    _pendingPaymentOrders.isNotEmpty ? AppColors.warning : AppColors.inkMuted,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricTile('ĐANG LÀM', '$processingCount', 'đang xử lý', AppColors.primary),
                  const SizedBox(width: 12),
                  _buildMetricTile('ĐÃ HOÀN TẤT', '$doneCount', 'sẵn sàng trả ảnh', AppColors.secondary),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          _buildPendingPaymentSection(),
          const SizedBox(height: 20),

          SizedBox(
            height: 680,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn('1. Tiếp nhận', '2. Tráng phim', AppColors.primary),
                const SizedBox(width: 14),
                _buildKanbanColumn('2. Tráng phim', '3. Sấy khô', AppColors.secondary),
                const SizedBox(width: 14),
                _buildKanbanColumn('3. Sấy khô', '4. Quét ảnh', AppColors.inkMuted),
                const SizedBox(width: 14),
                _buildKanbanColumn('4. Quét ảnh', '5. Hoàn tất', AppColors.primary),
                const SizedBox(width: 14),
                _buildKanbanColumn('5. Hoàn tất', null, AppColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _pendingPaymentOrders.isNotEmpty ? AppColors.warningBg.withValues(alpha: 0.45) : AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _pendingPaymentOrders.isNotEmpty ? AppColors.warning.withValues(alpha: 0.5) : AppColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                size: 18,
                color: _pendingPaymentOrders.isNotEmpty ? AppColors.warning : AppColors.inkMuted,
              ),
              const SizedBox(width: 8),
              Text(
                'ĐƠN CHỜ THANH TOÁN & CHỜ NV KIỂM TRA TIỀN (${_pendingPaymentOrders.length})',
                style: AppTypography.cardTitle.copyWith(
                  fontSize: 13,
                  color: _pendingPaymentOrders.isNotEmpty ? AppColors.warning : AppColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'Đơn QR: NV kiểm tra tiền vào rồi bấm Đã nhận tiền • Quá hạn có thể hủy đơn',
                style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
          if (_pendingPaymentOrders.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Hiện không có đơn nào đang chờ thanh toán.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _pendingPaymentOrders.map((o) {
                final items = (o['items'] as List?) ?? [];
                final firstItem = items.isNotEmpty ? items.first as Map : <String, dynamic>{};
                final filmName = (firstItem['film_name'] ?? 'Dịch vụ tráng scan').toString();
                final orderId = (o['order_id'] ?? '').toString();
                final customerName = (o['customer_name'] ?? 'Khách hàng').toString();
                final customerPhone = (o['customer_phone'] ?? '').toString();
                final orderDate = o['order_date']?.toString();
                final overdue = _isOverduePayment(orderDate);
                final elapsedText = _formatWaitElapsed(orderDate);
                final payMethod = (o['payment_method'] ?? 'VNPAY').toString().toUpperCase();
                final isQrMethod = payMethod == 'INTERNAL_QR';

                return Container(
                  width: 340,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: overdue ? AppColors.danger : AppColors.outline,
                      width: overdue ? 1.5 : 1,
                    ),
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
                                '#$orderId',
                                style: AppTypography.dataMono.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isQrMethod ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFF005BAA).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isQrMethod ? 'QR CK' : 'VNPAY',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isQrMethod ? AppColors.primary : const Color(0xFF005BAA),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: overdue ? AppColors.dangerBg : AppColors.warningBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              overdue ? 'QUÁ HẠN ($elapsedText)' : elapsedText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: overdue ? AppColors.danger : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        customerPhone.isNotEmpty ? '$customerName • $customerPhone' : customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(filmName, style: AppTypography.caption),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatVnd(o['total_amount']),
                            style: AppTypography.cardTitle.copyWith(color: AppColors.primary, fontSize: 13),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isQrMethod) ...[
                                ElevatedButton.icon(
                                  onPressed: () => _confirmManualQrPaid(o),
                                  icon: const Icon(Icons.check_circle_outline, size: 13),
                                  label: const Text(
                                    'Đã nhận tiền',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              OutlinedButton.icon(
                                onPressed: () => _confirmCancelPendingOrder(o),
                                icon: const Icon(Icons.cancel_outlined, size: 13, color: AppColors.danger),
                                label: const Text(
                                  'Hủy đơn',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  side: const BorderSide(color: AppColors.danger),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
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

                        Builder(
                          builder: (_) {
                            final ship = c['shipment'] is Map ? c['shipment'] as Map : null;
                            final shipMethod = (c['shipping_method'] ?? '').toString().toUpperCase();
                            final requiresDelivery = shipMethod == 'AHAMOVE_PICKUP' || ship != null;
                            final shipStatus = (ship?['status'] ?? '').toString().toUpperCase();
                            final ahaStatus = (ship?['ahamove_status'] ?? '').toString().toUpperCase();
                            final isDelivered = shipStatus == 'DELIVERED' || ahaStatus == 'COMPLETED';
                            final canAdvance = !colName.startsWith('1.') || !requiresDelivery || isDelivered;
                            final extId = (ship?['external_order_id'] ?? '').toString();
                            final rawOrderId = (c['rawId'] ?? '').toString();
                            final booked = extId.isNotEmpty && shipStatus != 'CANCELLED';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(c['statusNote'], style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                                    if (nextCol != null) ...[
                                      if (canAdvance)
                                        InkWell(
                                          onTap: () => _moveCard(colName, nextCol, c),
                                          child: Text(c['nextStep'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.warningBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Chờ giao tới Lab',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning),
                                          ),
                                        ),
                                    ] else
                                      const Text('Đã xong ✓', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                  ],
                                ),
                                if (requiresDelivery) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: (isDelivered ? AppColors.secondary : const Color(0xFFEA580C)).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: (isDelivered ? AppColors.secondary : const Color(0xFFEA580C)).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            isDelivered
                                                ? (extId.isNotEmpty ? 'AhaMove #$extId (Đã giao tới Lab ✓)' : 'Đã giao tới Lab ✓')
                                                : (booked ? 'AhaMove #$extId ($shipStatus)' : 'AhaMove: Chưa gọi xe'),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isDelivered ? AppColors.secondary : const Color(0xFFEA580C),
                                            ),
                                          ),
                                        ),
                                        if (!isDelivered) ...[
                                          if (booked) ...[
                                            const SizedBox(width: 6),
                                            InkWell(
                                              onTap: () async {
                                                final messenger = ScaffoldMessenger.of(context);
                                                final res = await WebApiService().syncLabAhamoveStatus(rawOrderId);
                                                if (!mounted) return;
                                                await _loadKanban();
                                                final syncedStatus = (res['data']?['status'] ?? res['data']?['ahamove_status'] ?? '').toString();
                                                messenger.showSnackBar(
                                                  SnackBar(content: Text(syncedStatus.isNotEmpty ? 'Trạng thái AhaMove: $syncedStatus' : 'Đã đồng bộ AhaMove')),
                                                );
                                              },
                                              child: const Text(
                                                'Đồng bộ',
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                                              ),
                                            ),
                                          ],
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () async {
                                              final messenger = ScaffoldMessenger.of(context);
                                              final res = booked
                                                  ? await WebApiService().cancelLabAhamovePickup(rawOrderId)
                                                  : await WebApiService().bookLabAhamovePickup(rawOrderId);
                                              if (!mounted) return;
                                              await _loadKanban();
                                              messenger.showSnackBar(
                                                SnackBar(content: Text(res['message']?.toString() ?? 'Đã cập nhật AhaMove')),
                                              );
                                            },
                                            child: Text(
                                              booked ? 'Hủy xe' : 'Gọi AhaMove',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: booked ? AppColors.danger : const Color(0xFFEA580C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
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
