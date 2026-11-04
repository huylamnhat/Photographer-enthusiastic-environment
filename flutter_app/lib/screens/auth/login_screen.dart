import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController(text: 'khachhang@minilab.vn');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NavigationShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header (Stitch APP-CUS-01)
                  Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.camera_roll, color: Colors.white, size: 26),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'MINILAB ARCHIVE',
                      style: AppTypography.cardTitle.copyWith(letterSpacing: 1.5, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Hệ sinh thái tráng film & Lưu trữ số vĩnh viễn',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dossier Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                            border: Border(bottom: BorderSide(color: AppColors.outline)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Đăng nhập tài khoản', style: AppTypography.pageTitle.copyWith(fontSize: 16)),
                              const SizedBox(height: 2),
                              Text('Truy cập kho ảnh cá nhân và theo dõi đơn tráng', style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text('TÀI KHOẢN (EMAIL / SĐT)', style: AppTypography.labelCaps),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _identifierController,
                                style: AppTypography.bodySmall,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.badge_outlined, size: 18, color: AppColors.inkMuted),
                                  hintText: 'khachhang@minilab.vn',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 14),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('MẬT KHẨU', style: AppTypography.labelCaps),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                      );
                                    },
                                    child: Text('Quên mật khẩu?', style: AppTypography.labelCaps.copyWith(color: AppColors.primary)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: AppTypography.bodySmall,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkMuted),
                                  hintText: '••••••••',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      size: 18,
                                      color: AppColors.inkMuted,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : Text('Đăng nhập', style: AppTypography.button),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Chưa có tài khoản? ', style: AppTypography.bodySmall),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          'Đăng ký thành viên mới',
                          style: AppTypography.cardTitle.copyWith(fontSize: 12, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
