import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/lab_model.dart';
import 'payment_receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final LabModel lab;
  final String filmName;
  final int quantity;
  final String packageName;
  final double totalPrice;
  final String pushPull;
  final String cutOption;
  final String shippingMethod;

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
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // 100% internal mock payment methods (no external gateway APIs)
  String _selectedPayment = 'MINILAB_WALLET'; // MINILAB_WALLET, INTERNAL_QR, CASH_ON_DROP
  bool _agreedToTerms = true;
  bool _isProcessing = false;

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final assignedOrderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentReceiptScreen(
          orderId: assignedOrderId,
          labName: widget.lab.name,
          amount: widget.totalPrice,
          paymentMethod: _selectedPayment == 'MINILAB_WALLET'
              ? 'Ví MiniLab Pay (Nội bộ)'
              : (_selectedPayment == 'INTERNAL_QR' ? 'QR Chuyển khoản nội bộ' : 'Tiền mặt tại quầy Lab'),
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
                        Text('SỔ TỔNG KẾT ĐƠN HÀNG', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                        Text('DOC_TYPE: ORDER_LEDGER', style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.inkMuted)),
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
                        _buildLedgerItem('Xử lý âm bản:', widget.shippingMethod == 'SHIP_HOME' ? 'Gửi bưu điện về nhà' : 'Lưu tại tủ tiệm 15 ngày'),
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

            // Internal Payment Methods (Strictly No External APIs)
            Text('PHƯƠNG THỨC THANH TOÁN NỘI BỘ', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'MINILAB_WALLET',
              title: 'Ví Số Dư MiniLab Pay (Nội bộ sàn)',
              subtitle: 'Số dư khả dụng: 450.000đ • Trừ trực tiếp tài khoản',
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'INTERNAL_QR',
              title: 'Mã QR Thanh Toán Nội Bộ Lab',
              subtitle: 'Quét mã giao dịch nội bộ ghi nhận tự động vào ca trực của Lab',
              icon: Icons.qr_code_2,
            ),
            const SizedBox(height: 8),
            _buildPaymentOption(
              key: 'CASH_ON_DROP',
              title: 'Thanh toán tiền mặt tại quầy Lab',
              subtitle: 'Thanh toán trực tiếp khi mang cuộn phim đến tiệm',
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
                      'Tôi xác nhận đồng ý với Quy chế xử lý hóa chất, thời gian hoàn trả ảnh scan theo SLA và chính sách bảo quản âm bản của phòng tối.',
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
