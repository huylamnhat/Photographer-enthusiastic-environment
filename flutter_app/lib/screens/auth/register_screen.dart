import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
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

  @override
  void dispose() {
    _phoneController.dispose();
    _fullNameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    setState(() {
      _otpSent = true;
      _otpController.text = '8888'; // Mock internal OTP
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mã OTP mô phỏng: 8888 (Tự động điền)'),
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
      appBar: AppBar(
        title: const Text('Tạo tài khoản mới'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tham gia MiniLab',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bắt đầu trải nghiệm số hóa film và quản lý kho ảnh cá nhân',
                style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('HỌ VÀ TÊN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline, size: 20, color: AppColors.inkMuted),
                        hintText: 'Nhập họ và tên',
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('SỐ ĐIỆN THOẠI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined, size: 20, color: AppColors.inkMuted),
                        hintText: '09xx xxx xxx',
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!_otpSent)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _sendOtp,
                          child: const Text('Nhận mã xác thực OTP', style: TextStyle(fontSize: 14)),
                        ),
                      )
                    else ...[
                      const Text('MÃ XÁC THỰC OTP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: '8888',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Hệ thống mô phỏng nội bộ: Mã OTP mặc định là 8888',
                        style: TextStyle(fontSize: 12, color: AppColors.secondary, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _verifyAndRegister,
                          child: const Text('Xác nhận & Hoàn tất', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

