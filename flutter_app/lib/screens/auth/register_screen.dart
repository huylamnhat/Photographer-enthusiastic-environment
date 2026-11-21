import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../navigation_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng điền đầy đủ họ tên, email, số điện thoại và mật khẩu');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService().registerCustomer({
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });

    if (!mounted) return;
    if (res['success'] == true && res['token'] != null && res['user'] is Map<String, dynamic>) {
      context.read<AuthProvider>().setAuthenticatedUser(
            res['token'].toString(),
            Map<String, dynamic>.from(res['user'] as Map),
          );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const NavigationShell()),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res['message']?.toString() ?? 'Không thể đăng ký tài khoản';
      });
    }
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
          'ĐĂNG KÝ KHÁCH HÀNG MỚI',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: Center(
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
                  Text(
                    'Đặt tráng phim theo dõi thời gian thực, nhận link Google Drive theo từng đơn và giao lưu cộng đồng.',
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

                        Text('EMAIL', style: AppTypography.labelCaps),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTypography.bodySmall,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.inkMuted),
                            hintText: 'tenban@gmail.com',
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
                        const SizedBox(height: 14),

                        Text('MẬT KHẨU (TỐI THIỂU 6 KÝ TỰ)', style: AppTypography.labelCaps),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppTypography.bodySmall,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkMuted),
                            hintText: '••••••••',
                            contentPadding: const EdgeInsets.all(10),
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

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, size: 16, color: AppColors.errorRed),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(fontSize: 12, color: AppColors.errorRed),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),

                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text('Đăng ký & Tạo tài khoản', style: AppTypography.button),
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
      ),
    );
  }
}
