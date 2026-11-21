import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/external_url_helper.dart';
import '../../core/utils/local_image_picker.dart';
import '../../models/order_model.dart';
import 'review_lab_screen.dart';
import '../archive/archive_gallery_screen.dart';
import '../home/payment_receipt_screen.dart';
import '../home/qr_transfer_dialog.dart';
import '../home/vnpay_payment_dialog.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel? order;
  final String? orderId;

  const OrderDetailScreen({super.key, this.order, this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _liveOrder;
  bool _loading = false;
  bool _ahamoveBusy = false;

  @override
  void initState() {
    super.initState();
    _liveOrder = widget.order;
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    final targetId = widget.orderId ?? widget.order?.orderId;
    if (targetId == null || targetId.isEmpty) return;
    setState(() => _loading = true);
    final res = await ApiService().getOrderById(targetId);
    if (!mounted) return;
    setState(() {
      if (res != null) _liveOrder = res;
      _loading = false;
    });
  }

  int _activeStepIndex(OrderModel? o) {
    if (o == null) return 0;
    final col = o.kanbanColumn.toUpperCase();
    final st = o.status.toUpperCase();
    if (col == 'QUEUE' || st == 'RECEIVED' || st == 'PENDING_FILM') return 0; // 1. Tiếp nhận
    if (col == 'DEVELOPING') return 1; // 2. Vào Tank / Tráng
    if (col == 'DRYING' || col == 'QC' || st == 'QC_CHECK') return 2; // 3. Sấy khô
    if (col == 'SCANNING') return 3; // 4. Scan số hóa
    if (col == 'READY' || st == 'READY_FOR_DOWNLOAD' || st == 'COMPLETED') return 4; // 5. QC & Archive
    return 0;
  }

  String _stepBadgeText(int activeIdx) {
    switch (activeIdx) {
      case 0:
        return '1/5 • TIẾP NHẬN';
      case 1:
        return '2/5 • ĐANG TRÁNG';
      case 2:
        return '3/5 • ĐANG SẤY';
      case 3:
        return '4/5 • ĐANG QUÉT ẢNH';
      default:
        return '5/5 • HOÀN TẤT';
    }
  }

  void _showDisputeDialog(String displayId, double totalAmount) {
    final issueCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Gửi Khiếu nại / Hỗ trợ Đơn #$displayId', style: AppTypography.cardTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khiếu nại sẽ được gửi đồng thời tới Cổng Tiệm Film Lab và Bảng Quản trị Admin để đối soát.',
              style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),
            Text('VẤN ĐỀ GẶP PHẢI', style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            TextField(
              controller: issueCtrl,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Ví dụ: Ảnh scan bị xước dải film / lệch màu...',
              ),
            ),
            const SizedBox(height: 12),
            Text('MÔ TẢ CHI TIẾT CHO LAB & ADMIN', style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Nhập mô tả chi tiết vấn đề bạn gặp phải...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final issue = issueCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (issue.isEmpty || desc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.danger,
                    content: Text('Vui lòng nhập vấn đề gặp phải và mô tả chi tiết!'),
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              final ok = await ApiService().createOrderDispute(displayId, {
                'issue_type': issue,
                'description': desc,
                'amount_requested': totalAmount > 0 ? totalAmount : 70000,
              });
              await _fetchOrder();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: ok ? AppColors.secondary : AppColors.danger,
                  content: Text(
                    ok
                        ? 'Đã gửi khiếu nại đơn #$displayId tới Cổng Tiệm Lab và Admin Tổng Sàn!'
                        : 'Không thể gửi khiếu nại, vui lòng thử lại.',
                  ),
                ),
              );
            },
            child: const Text('Gửi Khiếu nại'),
          ),
        ],
      ),
    );
  }

  String _formatPaymentLabel(String? method) {
    switch ((method ?? '').toUpperCase()) {
      case 'VNPAY':
        return 'VNPAY';
      case 'INTERNAL_QR':
        return 'QR CHUYỂN KHOẢN';
      case 'CASH_ON_DROP':
        return 'TIỀN MẶT TẠI LAB';
      default:
        return (method == null || method.isEmpty) ? 'VNPAY' : method;
    }
  }

  Future<void> _payPendingVnpay(OrderModel order) async {
    final res = await ApiService().createVnpayPayment(
      orderId: order.orderId,
      amount: order.totalAmount,
      orderInfo: 'Thanh toan don ${order.orderId}',
    );
    if (!mounted) return;
    if (res['already_paid'] == true || (res['data'] is Map && res['data']['paid'] == true)) {
      await _fetchOrder();
      return;
    }
    final data = res['data'] as Map?;
    final paymentUrl = data?['paymentUrl']?.toString() ?? '';
    if (res['success'] != true || paymentUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Không thể khởi tạo thanh toán VNPAY')),
      );
      return;
    }
    final result = await showVnpayPaymentFlowDialog(
      context: context,
      orderId: order.orderId,
      labName: order.labName,
      amount: order.totalAmount,
      paymentUrl: paymentUrl,
      txnRef: data?['txn_ref']?.toString(),
    );
    if (!mounted) return;
    await _fetchOrder();
    if (!mounted) return;
    if (result != null && result['paid'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentReceiptScreen(
            orderId: order.orderId,
            labName: order.labName,
            amount: order.totalAmount,
            paymentMethod: 'VNPAY',
            transactionId: result['trans_id']?.toString(),
          ),
        ),
      );
    }
  }

  Future<void> _openPendingQrTransfer(OrderModel order) async {
    final result = await showQrTransferDialog(
      context: context,
      orderId: order.orderId,
      labName: order.labName,
      amount: order.totalAmount,
    );
    if (!mounted) return;
    await _fetchOrder();
    if (!mounted) return;
    if (result != null && result['paid'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentReceiptScreen(
            orderId: order.orderId,
            labName: order.labName,
            amount: order.totalAmount,
            paymentMethod: 'QR Chuyển khoản trực tiếp',
          ),
        ),
      );
    }
  }

  Future<void> _bookAhamove(OrderModel order) async {
    setState(() => _ahamoveBusy = true);
    final res = await ApiService().bookAhamovePickup(
      order.orderId,
      pickupAddress: order.pickupAddress,
      pickupPhone: order.pickupPhone,
    );
    if (!mounted) return;
    setState(() => _ahamoveBusy = false);
    await _fetchOrder();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: res['success'] == true ? AppColors.secondary : AppColors.danger,
        content: Text(res['message']?.toString() ?? 'Đã gửi yêu cầu gọi tài xế'),
      ),
    );
  }

  Future<void> _refreshAhamove(OrderModel order) async {
    setState(() => _ahamoveBusy = true);
    await ApiService().getAhamoveShipmentStatus(order.orderId);
    await _fetchOrder();
    if (mounted) setState(() => _ahamoveBusy = false);
  }

  Future<void> _cancelAhamove(OrderModel order) async {
    setState(() => _ahamoveBusy = true);
    final res = await ApiService().cancelAhamovePickup(order.orderId);
    if (!mounted) return;
    setState(() => _ahamoveBusy = false);
    await _fetchOrder();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: res['success'] == true ? AppColors.secondary : AppColors.danger,
        content: Text(res['message']?.toString() ?? 'Đã hủy vận đơn AhaMove'),
      ),
    );
  }

  Widget _buildAhamoveCard(OrderModel o) {
    final ship = o.shipment;
    final stateKey = o.normalizedShipmentState;
    final statusStr = (ship?['status'] ?? '').toString().toUpperCase();
    final extId = (ship?['external_order_id'] ?? '').toString();
    final sharedLink = (ship?['shared_link'] ?? '').toString();
    final driverName = (ship?['driver_name'] ?? '').toString();
    final driverPhone = (ship?['driver_phone'] ?? '').toString();
    final canBook = (ship == null || statusStr == 'CANCELLED') &&
        o.paymentStatus.toUpperCase() == 'PAID' &&
        o.status.toUpperCase() != 'CANCELLED';

    Color accentColor = const Color(0xFFEA580C);
    IconData statusIcon = Icons.delivery_dining;
    if (stateKey == 'DELIVERED') {
      accentColor = AppColors.secondary;
      statusIcon = Icons.check_circle_outline;
    } else if (stateKey == 'ASSIGNED' || stateKey == 'PICKED_UP' || stateKey == 'IN_TRANSIT') {
      accentColor = AppColors.primary;
      statusIcon = Icons.directions_bike_outlined;
    } else if (stateKey == 'CANCELLED' || stateKey == 'FAILED') {
      accentColor = AppColors.danger;
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GIAO NHẬN AHAMOVE • LẤY FILM TẬN NƠI',
                  style: AppTypography.labelCaps.copyWith(color: accentColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accentColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o.shipmentHeadlineVi,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: accentColor),
                ),
                const SizedBox(height: 3),
                Text(
                  o.shipmentHintVi,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.ink),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (o.pickupAddress.isNotEmpty)
            Text('Địa chỉ lấy hàng: ${o.pickupAddress}', style: AppTypography.bodySmall),
          if (ship != null) ...[
            const SizedBox(height: 4),
            Text(
              'Mã vận đơn AhaMove: ${extId.isNotEmpty ? '#$extId' : 'N/A'}',
              style: AppTypography.dataMono.copyWith(fontSize: 11, color: AppColors.inkMuted),
            ),
            if (driverName.isNotEmpty || driverPhone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Thông tin tài xế: ${[driverName, driverPhone].where((s) => s.isNotEmpty).join(' • ')}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
              ),
            ],
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (canBook)
                ElevatedButton.icon(
                  onPressed: _ahamoveBusy ? null : () => _bookAhamove(o),
                  icon: const Icon(Icons.local_shipping_outlined, size: 15),
                  label: Text(_ahamoveBusy ? 'Đang gọi tài xế...' : 'Gọi tài xế lấy film'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA580C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              if (ship != null && extId.isNotEmpty) ...[
                OutlinedButton.icon(
                  onPressed: _ahamoveBusy ? null : () => _refreshAhamove(o),
                  icon: const Icon(Icons.refresh, size: 15),
                  label: const Text('Cập nhật trạng thái'),
                ),
                if (sharedLink.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => openExternalPaymentUrl(sharedLink),
                    icon: const Icon(Icons.map_outlined, size: 15),
                    label: const Text('Xem hành trình'),
                  ),
                if (statusStr != 'CANCELLED' && statusStr != 'DELIVERED')
                  OutlinedButton.icon(
                    onPressed: _ahamoveBusy ? null : () => _cancelAhamove(o),
                    icon: const Icon(Icons.cancel_outlined, size: 15, color: AppColors.danger),
                    label: const Text('Hủy Shipper', style: TextStyle(color: AppColors.danger)),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = _liveOrder;
    final displayId = o?.orderId ?? (widget.orderId ?? 'ORD-2026-8801');
    final labName = o?.labName ?? 'CropLab Hà Nội';
    final filmName = o?.items.isNotEmpty == true
        ? '${o!.items.first.quantity} cuộn ${o.items.first.filmName}'
        : '02 cuộn Kodak ColorPlus 200 (135/36)';
    final processName = o?.items.isNotEmpty == true
        ? o!.items.first.name
        : 'Quy trình: C-41 Tiêu chuẩn • Máy Noritsu HS-1800';
    final totalAmount = o?.totalAmount ?? 140000;
    final price =
        '${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    final activeIdx = _activeStepIndex(o);

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
            Text('CHI TIẾT ĐƠN #$displayId', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ tiến độ từ Lab',
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            onPressed: _fetchOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lab & Status Header Card
            Container(
              padding: const EdgeInsets.all(16),
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
                          const Icon(Icons.storefront, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(labName, style: AppTypography.cardTitle),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (activeIdx == 4 ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (o?.status.toUpperCase() == 'CANCELLED' || o?.paymentStatus.toUpperCase() == 'CANCELLED')
                              ? 'ĐÃ HỦY ĐƠN'
                              : (o?.paymentStatus.toUpperCase() == 'PENDING'
                                  ? (o?.paymentMethod.toUpperCase() == 'INTERNAL_QR'
                                      ? 'CHỜ NV LAB XÁC NHẬN QR'
                                      : 'CHỜ THANH TOÁN VNPAY')
                                  : _stepBadgeText(activeIdx)),
                          style: AppTypography.labelCaps.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: activeIdx == 4 ? AppColors.secondary : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(filmName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    processName,
                    style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.outline),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TỔNG THANH TOÁN (${_formatPaymentLabel(o?.paymentMethod)})',
                        style: AppTypography.labelCaps,
                      ),
                      Text(
                        price,
                        style: AppTypography.metric.copyWith(fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                  if (o != null &&
                      o.status.toUpperCase() == 'CANCELLED') ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.cancel_outlined, size: 16, color: AppColors.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (o.cancelReason != null && o.cancelReason!.isNotEmpty)
                                  ? 'Đơn hàng đã bị hủy: ${o.cancelReason}'
                                  : 'Đơn hàng đã bị hủy do quá hạn thanh toán VNPAY.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.danger, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (o != null &&
                      o.paymentStatus.toUpperCase() == 'PENDING' &&
                      o.status.toUpperCase() != 'CANCELLED') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: o.paymentMethod.toUpperCase() == 'INTERNAL_QR'
                          ? ElevatedButton.icon(
                              onPressed: () => _openPendingQrTransfer(o),
                              icon: const Icon(Icons.qr_code_2, size: 16),
                              label: const Text('Xem mã QR chuyển khoản & Chờ Lab xác nhận'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () => _payPendingVnpay(o),
                              icon: const Icon(Icons.account_balance_outlined, size: 16),
                              label: const Text('Thanh toán ngay qua VNPAY'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF005BAA),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (o != null && o.isPickupOrder)
              _buildAhamoveCard(o),

            // Compensation / Dispute Response Card (Hiển thị khi Lab tặng cuộn film đền bù hoặc phản hồi khiếu nại)
            if ((o?.compensationNote != null && o!.compensationNote!.isNotEmpty) ||
                (o?.disputeId != null && o!.disputeId!.isNotEmpty) ||
                (o?.disputeMessages.isNotEmpty == true)) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.card_giftcard, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'THÔNG BÁO ĐỀN BÙ & PHẢN HỒI KHIẾU NẠI',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            o?.disputeStatus == 'COMPENSATED'
                                ? 'ĐÃ ĐỀN BÙ CUỘN FILM'
                                : (o?.disputeStatus == 'REFUNDED'
                                    ? 'ĐÃ HOÀN TIỀN'
                                    : (o?.disputeStatus ?? 'ĐANG XỬ LÝ')),
                            style: AppTypography.labelCaps.copyWith(
                              fontSize: 9,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (o?.compensationNote != null && o!.compensationNote!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        o.compensationNote!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                    if (o?.disputeMessages.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: AppColors.outline),
                      const SizedBox(height: 8),
                      ...o!.disputeMessages.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${m['sender'] ?? 'Hệ thống'}: ${m['text'] ?? ''} (${m['time'] ?? ''})',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Google Drive Link Card & Scan Photos of this specific Order
            if ((o?.driveLink != null && o!.driveLink!.isNotEmpty) ||
                (o?.driveLinkHistory.isNotEmpty == true)) ...[
              Builder(
                builder: (context) {
                  final links = (o!.driveLinkHistory.isNotEmpty)
                      ? o.driveLinkHistory
                      : [if (o.driveLink != null && o.driveLink!.isNotEmpty) o.driveLink!];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...links.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final dLink = entry.value;
                        final isLatest = idx == 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isLatest ? const Color(0xFFE3F2FD) : AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLatest
                                  ? const Color(0xFF1565C0).withValues(alpha: 0.45)
                                  : AppColors.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.cloud_done_outlined,
                                    size: 18,
                                    color: isLatest ? const Color(0xFF1565C0) : AppColors.inkMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isLatest
                                          ? 'LINK GOOGLE DRIVE MỚI NHẤT CỦA ĐƠN #$displayId'
                                          : 'LINK GOOGLE DRIVE CŨ #${links.length - idx} CỦA ĐƠN #$displayId (GIỮ NGUYÊN)',
                                      style: AppTypography.labelCaps.copyWith(
                                        color: isLatest ? const Color(0xFF1565C0) : AppColors.inkMuted,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SelectableText(
                                sanitizeGoogleDriveUrl(dLink),
                                style: AppTypography.dataMono.copyWith(
                                  fontSize: 11,
                                  color: isLatest ? const Color(0xFF0D47A1) : AppColors.ink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      openUrlInNewTab(dLink);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                    icon: const Icon(Icons.open_in_new, size: 14),
                                    label: const Text('Mở Google Drive', style: TextStyle(fontSize: 11)),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final clean = await copyTextSafe(dLink);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Đã sao chép link Google Drive: $clean')),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 14),
                                    label: const Text('Sao chép Link', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      if (o.scanPhotos.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ẢNH SCAN CỦA ĐƠN #$displayId (${o.scanPhotos.length} TẤM - 1080x720)',
                          style: AppTypography.sectionHeading.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: o.scanPhotos.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.35,
                          ),
                          itemBuilder: (ctx, idx) {
                            final sp = o.scanPhotos[idx];
                            final imgUrl = (sp['image_url'] ?? '').toString();
                            final title = (sp['title'] ?? 'Ảnh #${idx + 1}').toString();
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.outline),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  MockTestAssets.image(imgUrl, fit: BoxFit.cover),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      color: Colors.black.withValues(alpha: 0.65),
                                      child: Text(
                                        title,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ],

            // Live Timeline Stepper
            Text('TIẾN ĐỘ ĐƠN HÀNG', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  _buildTimelineStep(
                    stepNumber: '1',
                    title: '1. Tiếp nhận',
                    subtitle: (activeIdx == 0 && o != null && o.isPickupOrder && o.normalizedShipmentState != 'DELIVERED')
                        ? '${o.shipmentHeadlineVi} — ${o.shipmentHintVi}'
                        : 'Tiệm đã nhận cuộn phim và xếp hàng xử lý.',
                    time: activeIdx == 0
                        ? ((o != null && o.isPickupOrder && o.normalizedShipmentState != 'DELIVERED')
                            ? o.shipmentHeadlineVi
                            : 'Đang ở bước này')
                        : 'Hoàn tất',
                    isDone: activeIdx > 0,
                    isActive: activeIdx == 0,
                  ),
                  _buildTimelineStep(
                    stepNumber: '2',
                    title: '2. Tráng phim',
                    subtitle: 'Đang tiến hành tráng cuộn phim của bạn.',
                    time: activeIdx == 1 ? 'Đang thực hiện' : (activeIdx > 1 ? 'Hoàn tất' : 'Chờ xử lý'),
                    isDone: activeIdx > 1,
                    isActive: activeIdx == 1,
                  ),
                  _buildTimelineStep(
                    stepNumber: '3',
                    title: '3. Sấy khô',
                    subtitle: 'Làm khô tự nhiên trong phòng sạch.',
                    time: activeIdx == 2 ? 'Đang thực hiện' : (activeIdx > 2 ? 'Hoàn tất' : 'Chờ xử lý'),
                    isDone: activeIdx > 2,
                    isActive: activeIdx == 2,
                  ),
                  _buildTimelineStep(
                    stepNumber: '4',
                    title: '4. Quét ảnh',
                    subtitle: 'Số hóa từng khung hình sang ảnh chất lượng cao.',
                    time: activeIdx == 3 ? 'Đang thực hiện' : (activeIdx > 3 ? 'Hoàn tất' : 'Chờ xử lý'),
                    isDone: activeIdx > 3,
                    isActive: activeIdx == 3,
                  ),
                  _buildTimelineStep(
                    stepNumber: '5',
                    title: '5. Hoàn tất & Trả ảnh',
                    subtitle: 'Ảnh đã được gửi lên Kho ảnh của bạn.',
                    time: activeIdx == 4 ? 'Đã sẵn sàng tải!' : 'Chờ hoàn tất',
                    isDone: activeIdx == 4,
                    isActive: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions Block
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchiveGalleryScreen(initialOrderId: displayId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Mở Kho ảnh của tôi', style: AppTypography.button),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewLabScreen(
                            labId: o?.labId ?? 'lab-001',
                            orderId: displayId,
                            labName: labName,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_outline, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Đánh giá Lab', style: AppTypography.button.copyWith(fontSize: 11, color: AppColors.ink)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDisputeDialog(displayId, totalAmount),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.report_problem_outlined, size: 14, color: AppColors.danger),
                        const SizedBox(width: 6),
                        Text('Khiếu nại / Hỗ trợ', style: AppTypography.button.copyWith(fontSize: 11, color: AppColors.ink)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required String time,
    bool isDone = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? AppColors.secondary : (isActive ? AppColors.primary : AppColors.surfaceSunken),
                shape: BoxShape.circle,
                border: Border.all(color: isActive ? AppColors.primary : AppColors.outline),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : Text(
                        stepNumber,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : AppColors.inkMuted,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? AppColors.secondary : AppColors.outline,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13,
                        color: isActive ? AppColors.primary : (isDone ? AppColors.ink : AppColors.inkMuted),
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: AppTypography.dataMono.copyWith(
                      fontSize: 10,
                      color: isActive ? AppColors.primary : AppColors.inkMuted,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
