import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _submitted = false;

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
          'KHÔI PHỤC MẬT KHẨU',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('QUÊN MẬT KHẨU TRUY CẬP', style: AppTypography.labelCaps),
                const SizedBox(height: 4),
                Text('Thiết lập lại thông tin', style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text(
                  'Nhập email hoặc số điện thoại thành viên để hệ thống tạo đường dẫn đặt lại mật khẩu an toàn.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('EMAIL HOẶC SỐ ĐIỆN THOẠI', style: AppTypography.labelCaps),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _controller,
                        style: AppTypography.bodySmall,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.inkMuted),
                          hintText: 'email@minilab.vn',
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!_submitted)
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _submitted = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text('Gửi liên kết khôi phục', style: AppTypography.button),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, color: AppColors.secondary, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                'Liên kết khôi phục nội bộ đã được gửi thành công. Vui lòng kiểm tra hộp thư.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
