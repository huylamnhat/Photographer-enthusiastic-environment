import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/api_service.dart';
import '../../models/lab_model.dart';
import '../orders/order_detail_screen.dart';
import 'payment_receipt_screen.dart';
import 'qr_transfer_dialog.dart';
import 'vnpay_payment_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  final LabModel lab;
  final String filmName;
  final int quantity;
  final String packageName;
  final double totalPrice;
  final String pushPull;
  final String cutOption;
  final String shippingMethod;
  final String pickupAddress;
  final String pickupPhone;
  final double shippingFee;

  const CheckoutScreen({
    super.key,
    required this.lab,
    required this.filmName,
    required this.quantity,
    required this.packageName,
    required this.totalPrice,
    required this.pushPull,
    required this.cutOption,
    required this.shippingMethod,
    this.pickupAddress = '',
    this.pickupPhone = '',
    this.shippingFee = 0,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'VNPAY'; // VNPAY, INTERNAL_QR, CASH_ON_DROP
  bool _agreedToTerms = true;
  bool _isProcessing = false;
  String? _createdPendingOrderId;
  String? _createdPendingLabName;
  String? _createdPendingMethod;

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);

    String? assignedOrderId = _createdPendingOrderId;
    String assignedLabName = _createdPendingLabName ?? widget.lab.name;
    final needsNewOrder = assignedOrderId == null || _createdPendingMethod != _selectedPayment;

    if (needsNewOrder) {
      final isAha = widget.shippingMethod == 'AHAMOVE_PICKUP' || widget.shippingMethod.contains('AhaMove');
      final isDropAtLab = widget.shippingMethod.contains('quầy') || widget.shippingMethod == 'DROP_AT_LAB';
      final resolvedShipMethod = isAha
          ? 'AHAMOVE_PICKUP'
          : (isDropAtLab ? 'DROP_AT_LAB' : 'SELF_DROP_OFF');
      final createdOrder = await ApiService().createOrder({
        'lab_id': widget.lab.labId,
        'shipping_method': resolvedShipMethod,
        'pickup_address': widget.pickupAddress.isNotEmpty ? widget.pickupAddress : widget.lab.address,
        if (widget.pickupPhone.isNotEmpty) 'pickup_phone': widget.pickupPhone,
        'shipping_fee': widget.shippingFee,
        'payment_method': _selectedPayment,
        'total_amount': widget.totalPrice,
        'items': [
          {
            'name': widget.packageName,
            'film_name': widget.filmName,
            'quantity': widget.quantity,
            'price': widget.totalPrice / (widget.quantity > 0 ? widget.quantity : 1),
            'options': {
              'push_pull': widget.pushPull,
              'cut_negatives': widget.cutOption,
            },
          }
        ],
      });

      if (!mounted) return;
      if (createdOrder == null) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tạo được đơn hàng, vui lòng thử lại.')),
        );
        return;
      }

      assignedOrderId = createdOrder.orderId;
      assignedLabName = createdOrder.labName;
      if (_selectedPayment == 'VNPAY' || _selectedPayment == 'INTERNAL_QR') {
        _createdPendingOrderId = assignedOrderId;
        _createdPendingLabName = assignedLabName;
        _createdPendingMethod = _selectedPayment;
      }
    }

    if (_selectedPayment == 'INTERNAL_QR') {
      setState(() => _isProcessing = false);
      final result = await showQrTransferDialog(
        context: context,
        orderId: assignedOrderId,
        labName: assignedLabName,
        amount: widget.totalPrice,
      );
      if (!mounted) return;
      if (result != null && result['paid'] == true) {
        _goToReceipt(
          orderId: assignedOrderId,
          labName: assignedLabName,
          paymentMethod: 'QR Chuyển khoản trực tiếp',
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: assignedOrderId),
          ),
        );
      }
      return;
    }

    if (_selectedPayment == 'VNPAY') {
      final vnpRes = await ApiService().createVnpayPayment(
        orderId: assignedOrderId,
        amount: widget.totalPrice,
        orderInfo: 'Thanh toan don $assignedOrderId',
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (vnpRes['already_paid'] == true ||
          (vnpRes['data'] is Map && vnpRes['data']['paid'] == true)) {
        final transId = (vnpRes['data']?['trans_id'] ?? '').toString();
        _goToReceipt(
          orderId: assignedOrderId,
          labName: assignedLabName,
          paymentMethod: 'VNPAY',
          transactionId: transId,
        );
        return;
      }

      final vnpData = vnpRes['data'] as Map?;
      final paymentUrl = vnpData?['paymentUrl']?.toString() ?? '';
      final txnRef = vnpData?['txn_ref']?.toString() ?? '';

      if (vnpRes['success'] != true || paymentUrl.isEmpty) {
        final errMsg = vnpRes['message']?.toString() ?? 'Không khởi tạo được cổng VNPAY';
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceRaised,
            title: const Text('Không thể mở cổng VNPAY'),
            content: Text(
              '$errMsg\n\nĐơn hàng #$assignedOrderId đã được lưu ở trạng thái Chờ thanh toán.',
              style: AppTypography.bodySmall,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: assignedOrderId),
                    ),
                  );
                },
                child: const Text('Xem chi tiết đơn'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
        return;
      }

      final result = await showVnpayPaymentFlowDialog(
        context: context,
        orderId: assignedOrderId,
        labName: assignedLabName,
        amount: widget.totalPrice,
        paymentUrl: paymentUrl,
        txnRef: txnRef,
      );

      if (!mounted) return;
      if (result != null && result['paid'] == true) {
        _goToReceipt(
          orderId: assignedOrderId,
          labName: assignedLabName,
          paymentMethod: 'VNPAY',
          transactionId: result['trans_id']?.toString(),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: assignedOrderId),
          ),
        );
      }
      return;
    }

    setState(() => _isProcessing = false);
    _goToReceipt(
      orderId: assignedOrderId,
      labName: assignedLabName,
      paymentMethod: _selectedPayment == 'INTERNAL_QR'
          ? 'QR Chuyển khoản trực tiếp'
          : 'Tiền mặt tại quầy Lab',
    );
  }

  void _goToReceipt({
    required String orderId,
    required String labName,
    required String paymentMethod,
    String? transactionId,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentReceiptScreen(
          orderId: orderId,
          labName: labName,
          amount: widget.totalPrice,
          paymentMethod: paymentMethod,
          transactionId: transactionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'XÁC NHẬN ĐƠN HÀNG & THANH TOÁN',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Summary Ledger Card (Stitch APP-CUS-08)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                      border: Border(bottom: BorderSide(color: AppColors.outline)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TÓM TẮT ĐƠN HÀNG', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLedgerItem('Tiệm Lab xử lý:', widget.lab.name),
                        const SizedBox(height: 8),
                        _buildLedgerItem('Quy cách phim:', widget.filmName),
                        const SizedBox(height: 8),
                        _buildLedgerItem('Gói dịch vụ:', widget.packageName),
                        const SizedBox(height: 8),
                        _buildLedgerItem('Số lượng cuộn:', '${widget.quantity} cuộn'),
                        const SizedBox(height: 8),
                        _buildLedgerItem(
                          'Giao nhận film:',
                          widget.shippingMethod == 'AHAMOVE_PICKUP'
                              ? 'AhaMove lấy tận nơi'
                              : (widget.shippingMethod == 'SHIP_HOME' ? 'Gửi bưu điện về nhà' : widget.shippingMethod),
                        ),
                        if (widget.shippingMethod == 'AHAMOVE_PICKUP' && widget.pickupAddress.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _buildLedgerItem('Địa chỉ lấy film:', widget.pickupAddress),
                        ],
                        if (widget.shippingFee > 0) ...[
                          const SizedBox(height: 8),
                          _buildLedgerItem(
                            'Phí ship AhaMove:',
                            '${widget.shippingFee.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                          ),
                        ],
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.outline),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('TỔNG CỘNG THANH TOÁN', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                            Text(
                              '${widget.totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                              style: AppTypography.metric.copyWith(fontSize: 18, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Payment Methods (VNPAY Sandbox v2.1.0 + Direct Lab Options)
            Text('PHƯƠNG THỨC THANH TOÁN', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'VNPAY',
              title: 'Thanh toán VNPAY',
              subtitle: 'Quét QR hoặc thẻ ATM / Visa',
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'INTERNAL_QR',
              title: 'Chuyển khoản QR cho tiệm',
              subtitle: 'Quét mã ngân hàng của tiệm Lab',
              icon: Icons.qr_code_2,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'CASH_ON_DROP',
              title: 'Tiền mặt tại tiệm',
              subtitle: 'Thanh toán khi gửi phim tại quầy',
              icon: Icons.storefront_outlined,
            ),
            const SizedBox(height: 16),

            // Policy Agreement Checkbox
            InkWell(
              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _agreedToTerms ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                    color: _agreedToTerms ? AppColors.primary : AppColors.inkMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tôi đồng ý với điều khoản xử lý và bảo quản cuộn phim của tiệm.',
                      style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: (_agreedToTerms && !_isProcessing) ? _handlePayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 16),
                        const SizedBox(width: 8),
                        Text('Xác nhận & Hoàn tất đơn hàng', style: AppTypography.button),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 12, color: AppColors.inkMuted)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required String key,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPayment == key;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 20, color: isSelected ? AppColors.primary : AppColors.inkMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 12,
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
