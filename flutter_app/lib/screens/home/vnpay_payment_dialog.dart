import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/external_url_helper.dart';

Future<Map<String, dynamic>?> showVnpayPaymentFlowDialog({
  required BuildContext context,
  required String orderId,
  required String labName,
  required double amount,
  required String paymentUrl,
  String? txnRef,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _VnpayPaymentWaitDialog(
      orderId: orderId,
      labName: labName,
      amount: amount,
      paymentUrl: paymentUrl,
      txnRef: txnRef,
    ),
  );
}

class _VnpayPaymentWaitDialog extends StatefulWidget {
  final String orderId;
  final String labName;
  final double amount;
  final String paymentUrl;
  final String? txnRef;

  const _VnpayPaymentWaitDialog({
    required this.orderId,
    required this.labName,
    required this.amount,
    required this.paymentUrl,
    this.txnRef,
  });

  @override
  State<_VnpayPaymentWaitDialog> createState() => _VnpayPaymentWaitDialogState();
}

class _VnpayPaymentWaitDialogState extends State<_VnpayPaymentWaitDialog> {
  static const Color _vnpayColor = Color(0xFF005BAA);
  Timer? _pollTimer;
  bool _checking = false;
  bool _resolved = false;
  String _statusMessage =
      'Đã mở trang thanh toán VNPAY. Hệ thống sẽ tự động cập nhật sau khi bạn hoàn tất.';

  @override
  void initState() {
    super.initState();
    _launchVnpay();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchVnpay() async {
    await openExternalPaymentUrl(widget.paymentUrl);
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_resolved || (_checking && !silent)) return;
    if (!silent) {
      setState(() => _checking = true);
    }

    final res = await ApiService().checkVnpayPaymentStatus(widget.orderId);
    if (!mounted || _resolved) return;

    final data = res['data'];
    if (data is Map && data['cancelled'] == true) {
      _resolved = true;
      _pollTimer?.cancel();
      Navigator.of(context).pop({'paid': false, 'cancelled': true});
      return;
    }
    if (data is Map && data['paid'] == true) {
      _resolved = true;
      _pollTimer?.cancel();
      Navigator.of(context).pop({
        'paid': true,
        'trans_id': data['trans_id']?.toString() ?? '',
      });
      return;
    }

    if (!silent) {
      final msg = data is Map ? (data['vnpay_message']?.toString() ?? '') : '';
      setState(() {
        _checking = false;
        _statusMessage = msg.isNotEmpty
            ? msg
            : 'Chưa ghi nhận thanh toán thành công. Hãy hoàn tất trên trang VNPAY rồi thử lại.';
      });
    }
  }

  String _formatVnd(double value) {
    return '${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _vnpayColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'VNPAY',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'THANH TOÁN VNPAY',
                      style: AppTypography.cardTitle.copyWith(fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Đơn hàng:', style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
                        Text('#${widget.orderId}', style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Số tiền:', style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
                        Text(
                          _formatVnd(widget.amount),
                          style: AppTypography.cardTitle.copyWith(color: _vnpayColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if ((widget.txnRef ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Mã tham chiếu VNPAY: ${widget.txnRef}',
                        style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.inkMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _vnpayColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _vnpayColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THẺ DEMO THANH TOÁN (NCB):',
                      style: AppTypography.labelCaps.copyWith(fontSize: 9, color: _vnpayColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Số thẻ: 9704198526191432198  •  Chủ thẻ: NGUYEN VAN A\nPhát hành: 07/15  •  Mật khẩu OTP: 123456',
                      style: AppTypography.dataMono.copyWith(fontSize: 10, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _vnpayColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted, height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _checking ? null : () => _checkStatus(silent: false),
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(_checking ? 'Đang kiểm tra VNPAY...' : 'Tôi đã thanh toán • Kiểm tra ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _vnpayColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _launchVnpay,
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Mở lại VNPAY', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await copyPaymentUrl(widget.paymentUrl);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Đã sao chép link thanh toán VNPAY')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 15),
                      label: const Text('Copy link', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.outline),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  _pollTimer?.cancel();
                  Navigator.of(context).pop(null);
                },
                child: Text(
                  'Đóng • Thanh toán sau trong Chi tiết đơn',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
