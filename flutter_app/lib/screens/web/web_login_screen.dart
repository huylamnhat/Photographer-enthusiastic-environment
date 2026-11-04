import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import 'admin/admin_portal_shell.dart';
import 'lab/lab_portal_shell.dart';
import '../navigation_shell.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  final _emailController = TextEditingController(text: 'admin@minilab.vn');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'Admin';

  void _selectDemoAccount(String role, String email) {
    setState(() {
      _selectedRole = role;
      _emailController.text = email;
      _passwordController.text = 'password123';
    });
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final res = await ApiService().login(email, password);
      setState(() => _isLoading = false);

      final userRole = res['user']?['role'] ?? _selectedRole;

      if (!mounted) return;

      if (userRole == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPortalShell()),
        );
      } else if (userRole == 'LabOwner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LabPortalShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavigationShell()),
        );
      }
    } catch (_) {
      setState(() => _isLoading = false);
      // Fallback based on selected role
      if (_selectedRole == 'Admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPortalShell()));
      } else if (_selectedRole == 'LabOwner') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LabPortalShell()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NavigationShell()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header
                Center(
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.camera_roll, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'MINILAB PLATFORM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Cổng Quản Trị & Vận Hành',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    'Hệ thống điều hướng tự động theo phân quyền tài khoản',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Demo Account Selector
                const Text(
                  'CHỌN VAI TRÒ ĐĂNG NHẬP NHANH',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildRoleChip('Admin', 'Quản trị viên', Icons.admin_panel_settings, 'admin@minilab.vn'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRoleChip('LabOwner', 'Film Lab', Icons.store, 'labowner@croplab.vn'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildRoleChip('Customer', 'Khách hàng', Icons.person, 'khachhang@minilab.vn'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),

                // Email Field
                const Text('TÀI KHOẢN (EMAIL / USERNAME)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.inkMuted, size: 20),
                    hintText: 'admin@minilab.vn',
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                const Text('MẬT KHẨU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                const SizedBox(height: 6),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.inkMuted, size: 20),
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: AppColors.inkMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _selectedRole == 'Admin'
                                    ? 'Đăng nhập Quản Trị Viên (Admin)'
                                    : (_selectedRole == 'LabOwner' ? 'Đăng nhập Cổng Tiệm Lab' : 'Đăng nhập Khách Hàng'),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.secondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hệ thống dùng chung 1 backend duy nhất: Tự động phân quyền và điều hướng đúng trang khi đăng nhập.',
                          style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role, String label, IconData icon, String email) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => _selectDemoAccount(role, email),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.primary : AppColors.inkMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.ink,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

