import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
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
  String? _errorMessage;

  void _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ tài khoản và mật khẩu');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ok = await authProvider.login(identifier, password);

    if (!mounted) return;

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavigationShell()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = authProvider.errorMessage ?? authProvider.error ?? 'Sai tài khoản hoặc mật khẩu';
      });
    }
  }

  Widget _buildQuickChip(String name, String email) {
    final isSelected = _identifierController.text.trim() == email;
    return InkWell(
      onTap: () {
        setState(() {
          _identifierController.text = email;
          _passwordController.text = 'password123';
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.ink,
          ),
        ),
      ),
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
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 12),
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
                              const SizedBox(height: 16),
                              Text('TÀI KHOẢN MẪU TEST NHANH:', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildQuickChip('Nguyễn Hoàng Anh', 'khachhang@minilab.vn'),
                                  _buildQuickChip('Phạm Thu Trang', 'thutrang.pham@gmail.com'),
                                  _buildQuickChip('Lê Quang Huy (Expert)', 'chuyengia@film.vn'),
                                  _buildQuickChip('Trần Đình Trọng (Bị ban)', 'trong.tran@minilab.vn'),
                                ],
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
