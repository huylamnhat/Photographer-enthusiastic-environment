import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../navigation_shell.dart';
import '../orders/order_detail_screen.dart';

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Verification Tag
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          'GIAO DỊCH XÁC THỰC NỘI BỘ // OK',
                          style: AppTypography.labelCaps.copyWith(
                            color: AppColors.secondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tactile Paper Ledger Receipt (Stitch APP-CUS-09)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Receipt Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                            border: Border(bottom: BorderSide(color: AppColors.outline)),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.done_all, color: AppColors.secondary, size: 24),
                              ),
                              const SizedBox(height: 12),
                              Text('THANH TOÁN THÀNH CÔNG', style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                              const SizedBox(height: 4),
                              Text(
                                'Đơn hàng đã được ghi nhận vào hàng đợi xử lý của Lab',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                              ),
                            ],
                          ),
                        ),

                        // Ledger Details
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildRow('MÃ ĐƠN HÀNG', orderId, isHighlight: true),
                              const SizedBox(height: 10),
                              _buildRow('TIỆM LAB TIẾP NHẬN', labName),
                              const SizedBox(height: 10),
                              _buildRow('PHƯƠNG THỨC', paymentMethod),
                              const SizedBox(height: 10),
                              _buildRow('THỜI GIAN', 'Hôm nay, ${TimeOfDay.now().format(context)}'),
                              const SizedBox(height: 10),
                              _buildRow('TRẠNG THÁI CA TRỰC', 'Đã tiếp nhận (Bước 1/5)'),
                              const SizedBox(height: 14),
                              const Divider(height: 1, color: AppColors.outline),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('SỐ TIỀN THANH TOÁN', style: AppTypography.labelCaps),
                                  Text(
                                    '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                                    style: AppTypography.metric.copyWith(fontSize: 20, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Footer bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(9)),
                            border: Border(top: BorderSide(color: AppColors.outline)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('HÓA ĐƠN ĐIỆN TỬ', style: AppTypography.labelCaps.copyWith(fontSize: 9)),
                              Text('MINILAB-ARCHIVE-V4.8', style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailScreen(orderId: orderId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timeline, size: 16),
                          const SizedBox(width: 8),
                          Text('Theo dõi tiến độ đơn hàng', style: AppTypography.button),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const NavigationShell()),
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Về màn hình chính', style: AppTypography.button.copyWith(color: AppColors.ink)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: isHighlight
                ? AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)
                : AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
