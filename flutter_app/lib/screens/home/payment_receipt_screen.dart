import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../navigation_shell.dart';

class PaymentReceiptScreen extends StatelessWidget {
  final String orderId;
  final String labName;
  final double amount;
  final String paymentMethod;

  const PaymentReceiptScreen({
    super.key,
    required this.orderId,
    required this.labName,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Biên lai điện tử'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Success Icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.success, size: 36),
              ),
              const SizedBox(height: 14),
              const Text(
                'Thanh toán thành công!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              const Text(
                'Giao dịch được ghi nhận trong hệ thống MiniLab',
                style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Receipt Paper Card (Warm Paper styling)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow('Mã đơn hàng', orderId, isBold: true),
                    const Divider(height: 24),
                    _buildRow('Film Lab xử lý', labName),
                    const SizedBox(height: 12),
                    _buildRow('Số tiền thanh toán', '${amount.toInt()}đ', valueColor: AppColors.primary, isBold: true),
                    const SizedBox(height: 12),
                    _buildRow('Phương thức', paymentMethod),
                    const SizedBox(height: 12),
                    _buildRow('Thời gian', 'Vừa xong'),
                    const SizedBox(height: 12),
                    _buildRow('Trạng thái', 'ĐÃ XÁC NHẬN', valueColor: AppColors.success, isBold: true),
                    const Divider(height: 24),
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 16, color: AppColors.secondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ảnh scan sau khi tráng sẽ tự động đồng bộ vào Digital Film Archive của bạn.',
                            style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const NavigationShell()),
                      (route) => false,
                    );
                  },
                  child: const Text('Xem đơn hàng & Tiến độ'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const NavigationShell()),
                    (route) => false,
                  );
                },
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }
}

