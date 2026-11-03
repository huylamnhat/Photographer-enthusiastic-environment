import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/lab_model.dart';
import '../../providers/order_provider.dart';
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
  String _paymentMethod = 'MOMO'; // MOMO, VNPAY, BANK_TRANSFER, CASH
  final _addressController = TextEditingController(text: '123 Phố Huế, Hai Bà Trưng, Hà Nội');
  bool _isProcessing = false;

  void _confirmAndPay() async {
    setState(() => _isProcessing = true);

    final orderData = {
      'lab_id': widget.lab.labId,
      'shipping_method': widget.shippingMethod,
      'pickup_address': _addressController.text,
      'payment_method': _paymentMethod,
      'items': [
        {
          'package_id': 'pkg-001',
          'film_name': widget.filmName,
          'quantity': widget.quantity,
          'price': widget.totalPrice / widget.quantity,
          'options': {
            'push_pull': widget.pushPull,
            'cut_negatives': widget.cutOption,
          }
        }
      ]
    };

    final order = await context.read<OrderProvider>().addOrder(orderData);
    setState(() => _isProcessing = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentReceiptScreen(
            orderId: order?.orderId ?? 'ORD-2026-8888',
            labName: widget.lab.name,
            amount: widget.totalPrice,
            paymentMethod: _paymentMethod,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận & Thanh toán'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TÓM TẮT ĐƠN HÀNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.packageName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${widget.totalPrice.toInt()}đ', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('• Phim: ${widget.filmName} (x${widget.quantity} cuộn)', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                  Text('• Xử lý: ${widget.pushPull}', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                  Text('• Âm bản: ${widget.cutOption}', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tiệm xử lý:', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                      Text(widget.lab.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pickup Address
            const Text('ĐỊA CHỈ NHẬN / TRẢ PHIM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.inkMuted),
              ),
            ),
            const SizedBox(height: 20),

            // Payment Methods
            const Text('PHƯƠNG THỨC THANH TOÁN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 8),
            _buildPaymentOption('MOMO', 'Ví điện tử MoMo', Icons.account_balance_wallet, 'Mô phỏng thanh toán nội bộ'),
            _buildPaymentOption('VNPAY', 'VNPAY QR', Icons.qr_code, 'Mô phỏng thanh toán nội bộ'),
            _buildPaymentOption('BANK_TRANSFER', 'Chuyển khoản VietQR', Icons.account_balance, 'Tự động xác nhận giao dịch'),
            _buildPaymentOption('CASH', 'Thanh toán tiền mặt khi gửi phim', Icons.money, 'Thanh toán tại quầy Lab'),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _confirmAndPay,
            child: _isProcessing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Thanh toán ${widget.totalPrice.toInt()}đ', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String id, String title, IconData icon, String subtitle) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.inkMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

