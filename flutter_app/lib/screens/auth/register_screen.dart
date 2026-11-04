import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../navigation_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController(text: '0988776655');
  final _fullNameController = TextEditingController(text: 'Trần Minh Đức');
  final _otpController = TextEditingController();
  bool _otpSent = false;

  void _sendOtp() {
    setState(() {
      _otpSent = true;
      _otpController.text = '8888';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mã OTP mô phỏng: 8888 (Tự động điền nội bộ)'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _verifyAndRegister() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const NavigationShell()),
      (route) => false,
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
          'ĐĂNG KÝ THÀNH VIÊN MỚI',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('TẠO THẺ THÀNH VIÊN ANALOG', style: AppTypography.labelCaps),
                const SizedBox(height: 4),
                Text('Tham gia cộng đồng MiniLab', style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text('Lưu trữ file scan trọn đời và giao lưu cùng nhiếp ảnh gia khắp cả nước.', style: AppTypography.bodySmall),
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
                      Text('HỌ VÀ TÊN', style: AppTypography.labelCaps),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _fullNameController,
                        style: AppTypography.bodySmall,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline, size: 18, color: AppColors.inkMuted),
                          hintText: 'Nguyễn Văn A',
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text('SỐ ĐIỆN THOẠI', style: AppTypography.labelCaps),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTypography.bodySmall,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone_outlined, size: 18, color: AppColors.inkMuted),
                          hintText: '09xxxxxxxx',
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (!_otpSent)
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            onPressed: _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text('Gửi mã OTP xác nhận', style: AppTypography.button),
                          ),
                        ),

                      if (_otpSent) ...[
                        Text('MÃ XÁC NHẬN OTP (MÔ PHỎNG NỘI BỘ)', style: AppTypography.labelCaps),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _otpController,
                          style: AppTypography.dataMono.copyWith(fontSize: 14, letterSpacing: 4),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '••••',
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            onPressed: _verifyAndRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: Text('Xác nhận & Vào ứng dụng', style: AppTypography.button),
                          ),
                        ),
                      ],
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
