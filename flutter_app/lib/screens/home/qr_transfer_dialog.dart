import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/external_url_helper.dart';

Future<Map<String, dynamic>?> showQrTransferDialog({
  required BuildContext context,
  required String orderId,
  required String labName,
  required double amount,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _QrTransferDialog(
      orderId: orderId,
      labName: labName,
      amount: amount,
    ),
  );
}

class _QrTransferDialog extends StatefulWidget {
  final String orderId;
  final String labName;
  final double amount;

  const _QrTransferDialog({
    required this.orderId,
    required this.labName,
    required this.amount,
  });

  @override
  State<_QrTransferDialog> createState() => _QrTransferDialogState();
}

class _QrTransferDialogState extends State<_QrTransferDialog> {
  Timer? _pollTimer;
  bool _loading = true;
  bool _checking = false;
  bool _resolved = false;
  String _qrImageUrl = '';
  String _bankName = '';
  String _accountNo = '';
  String _accountName = '';
  String _transferContent = '';

  @override
  void initState() {
    super.initState();
    _transferContent = widget.orderId;
    _fetchQrInfo();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _checkConfirmed(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchQrInfo() async {
    final res = await ApiService().getOrderQrInfo(widget.orderId);
    if (!mounted) return;
    final data = res['data'];
    if (data is Map) {
      if (data['cancelled'] == true) {
        _resolved = true;
        _pollTimer?.cancel();
        Navigator.of(context).pop({'paid': false, 'cancelled': true});
        return;
      }
      if (data['paid'] == true) {
        _resolved = true;
        _pollTimer?.cancel();
        Navigator.of(context).pop({'paid': true});
        return;
      }
      setState(() {
        _qrImageUrl = (data['qr_image_url'] ?? '').toString();
        _bankName = (data['bank_name'] ?? '').toString();
        _accountNo = (data['account_no'] ?? '').toString();
        _accountName = (data['account_name'] ?? '').toString();
        final tc = (data['transfer_content'] ?? '').toString();
        if (tc.isNotEmpty) _transferContent = tc;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkConfirmed({bool silent = false}) async {
    if (_resolved || (_checking && !silent)) return;
    if (!silent) setState(() => _checking = true);

    final res = await ApiService().getOrderQrInfo(widget.orderId);
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
      Navigator.of(context).pop({'paid': true});
      return;
    }

    if (!silent) {
      final messenger = ScaffoldMessenger.of(context);
      setState(() => _checking = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Nhân viên Lab đang kiểm tra tiền vào tài khoản, vui lòng chờ giây lát.'),
        ),
      );
    }
  }

  Widget _buildQrPreview() {
    if (_loading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_qrImageUrl.isEmpty) {
      return Container(
        height: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_2, size: 48, color: AppColors.inkMuted),
            const SizedBox(height: 8),
            Text(
              'Tiệm Lab chưa tải ảnh mã QR lên hệ thống.\nBạn có thể tải ảnh QR trong mục Hồ sơ Tiệm Lab hoặc liên hệ trực tiếp tiệm.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted, fontSize: 11),
            ),
          ],
        ),
      );
    }

    if (_qrImageUrl.startsWith('data:image') && _qrImageUrl.contains(',')) {
      try {
        final bytes = Uint8List.fromList(base64Decode(_qrImageUrl.split(',').last));
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(bytes, height: 240, fit: BoxFit.contain),
        );
      } catch (_) {}
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        _qrImageUrl,
        height: 240,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceSunken,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Không tải được ảnh QR', style: AppTypography.bodySmall),
        ),
      ),
    );
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
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'QR CHUYỂN KHOẢN',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.labName,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Center(child: _buildQrPreview()),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Số tiền cần chuyển:', style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
                        Text(
                          _formatVnd(widget.amount),
                          style: AppTypography.cardTitle.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nội dung CK:', style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_transferContent, style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await copyPaymentUrl(_transferContent);
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Đã sao chép nội dung chuyển khoản')),
                                );
                              },
                              child: const Icon(Icons.copy, size: 15, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_bankName.isNotEmpty || _accountNo.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tài khoản nhận:', style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
                          Flexible(
                            child: Text(
                              [_bankName, _accountNo, _accountName].where((s) => s.isNotEmpty).join(' • '),
                              textAlign: TextAlign.right,
                              style: AppTypography.dataMono.copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sau khi bạn chuyển khoản xong, nhân viên tiệm Lab sẽ kiểm tra tiền vào tài khoản và bấm xác nhận tiếp nhận đơn hàng.',
                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted, height: 1.4),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _checking ? null : () => _checkConfirmed(silent: false),
                icon: const Icon(Icons.verified_outlined, size: 18),
                label: Text(_checking ? 'Đang kiểm tra...' : 'Tôi đã chuyển khoản • Kiểm tra xác nhận'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  _pollTimer?.cancel();
                  Navigator.of(context).pop(null);
                },
                child: Text(
                  'Đóng • Chờ nhân viên Lab xác nhận',
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
