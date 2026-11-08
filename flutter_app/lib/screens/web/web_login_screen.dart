import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/services/api_service.dart';
import 'admin/admin_portal_shell.dart';
import 'lab/lab_portal_shell.dart';

class WebLoginScreen extends StatefulWidget {
  const WebLoginScreen({super.key});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  // Mode: 0 for Admin Portal (WEB-ADM-01), 1 for Film Lab Portal (WEB-LAB-02)
  int _loginMode = 0; // 0 = Admin, 1 = Lab

  final _emailController = TextEditingController(text: 'admin.tuan@minilab.vn');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _isLoading = false;

  void _switchMode(int mode) {
    setState(() {
      _loginMode = mode;
      if (mode == 0) {
        _emailController.text = 'admin.tuan@minilab.vn';
        _passwordController.text = 'password123';
      } else {
        _emailController.text = 'saigon.lab@minilab.vn';
        _passwordController.text = 'password123';
      }
    });
  }

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final lowerEmail = email.toLowerCase();
    final uname = lowerEmail.split('@')[0];

    try {
      await ApiService().login(email, password);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (_loginMode == 0 || uname.contains('admin')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPortalShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LabPortalShell()),
        );
      }
    } catch (_) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      if (_loginMode == 0 || uname.contains('admin')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPortalShell()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LabPortalShell()),
        );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Identification Tag (Stitch WEB-ADM-01 / WEB-LAB-02)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.terminal, size: 14, color: AppColors.inkMuted),
                    const SizedBox(width: 6),
                    Text(
                      _loginMode == 0
                          ? 'SYS_TERMINAL // CENTRAL_ADMIN'
                          : 'LAB_OPS_PORTAL // DARKROOM_CORE',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.inkMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SECURE_NODE_OK',
                      style: AppTypography.labelCaps.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

              // Primary Authentication Dossier Card
              Container(
                constraints: const BoxConstraints(maxWidth: 480),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dossier Header Strip
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                        border: Border(bottom: BorderSide(color: AppColors.outline)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _loginMode == 0 ? AppColors.primary : AppColors.secondary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      _loginMode == 0 ? Icons.admin_panel_settings : Icons.storefront,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'MINILAB ARCHIVE',
                                        style: AppTypography.cardTitle.copyWith(letterSpacing: 0.5),
                                      ),
                                      Text(
                                        _loginMode == 0
                                            ? 'CENTRAL ADMIN PLATFORM'
                                            : 'LABORATORY OPS ENGINE',
                                        style: AppTypography.labelCaps.copyWith(
                                          fontSize: 9,
                                          color: AppColors.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceRaised,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: Text(
                                  _loginMode == 0 ? 'SYS.ADM' : 'LAB.OPS',
                                  style: AppTypography.dataMono.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _loginMode == 0 ? AppColors.primary : AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _loginMode == 0
                                ? 'Đăng nhập Quản trị Hệ thống'
                                : 'Đăng nhập Cổng Vận hành Film Lab',
                            style: AppTypography.pageTitle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _loginMode == 0
                                ? 'Hệ thống kiểm soát và điều phối toàn sàn MiniLab.'
                                : 'Quản lý tiếp nhận tráng scan, vận hành phòng tối và tải file.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    // Role Tabs Switcher (Top of Card) - Exclusively Admin & Film Lab for Web
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(bottom: BorderSide(color: AppColors.outline)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModeTab(0, 'Admin Console (Quản trị)', Icons.security),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildModeTab(1, 'Cổng Tiệm Film Lab', Icons.storefront),
                          ),
                        ],
                      ),
                    ),

                    // Credential Ledger Form
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role Description Banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _loginMode == 0
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : AppColors.secondary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _loginMode == 0
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.secondary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _loginMode == 0 ? Icons.shield_outlined : Icons.science_outlined,
                                  size: 18,
                                  color: _loginMode == 0 ? AppColors.primary : AppColors.secondary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _loginMode == 0 ? 'KHÔNG GIAN: ADMIN TỔNG SÀN' : 'KHÔNG GIAN: PHÒNG TỐI FILM LAB',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _loginMode == 0 ? AppColors.primary : AppColors.secondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _loginMode == 0
                                            ? 'Quản lý thẩm định đối tác lab, kiểm duyệt bài chợ và khiếu nại.'
                                            : 'Vận hành bảng Kanban tiếp nhận, sấy khô, scan và kiểm định QC.',
                                        style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Email Field
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _loginMode == 0 ? 'TÀI KHOẢN ADMIN' : 'TÀI KHOẢN KỸ THUẬT VIÊN / LAB',
                                style: AppTypography.labelCaps,
                              ),
                              Text(
                                _loginMode == 0 ? 'ID: ADM-HN-884' : 'ID: LAB-SG-01',
                                style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.inkMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailController,
                            style: AppTypography.bodyMedium,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.badge_outlined, size: 18, color: AppColors.inkMuted),
                              hintText: 'email@minilab.vn',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('MẬT KHẨU BẢO MẬT', style: AppTypography.labelCaps),
                              Text(
                                'Passkey / HSM',
                                style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.inkMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: AppTypography.bodyMedium,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.inkMuted),
                              hintText: '••••••••',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                          const SizedBox(height: 22),

                          // Login Submit Button
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _loginMode == 0 ? AppColors.primary : AppColors.secondary,
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
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _loginMode == 0 ? Icons.login : Icons.storefront,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _loginMode == 0 ? 'Vào Bảng Quản Trị Admin' : 'Vào Cổng Vận Hành Film Lab',
                                          style: AppTypography.button.copyWith(fontSize: 13),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick Test Preset Buttons
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
                                const Text('CHỌN NHANH TÀI KHOẢN MẪU:', style: AppTypography.labelCaps),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    _buildQuickChip('👑 Admin Sàn', 0, 'admin.tuan@minilab.vn'),
                                    _buildQuickChip('🏢 Tiệm Lab Sài Gòn', 1, 'saigon.lab@minilab.vn'),
                                    _buildQuickChip('🏢 Tiệm CropLab Hà Nội', 1, 'croplab@minilab.vn'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Compliance Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(11)),
                        border: Border(top: BorderSide(color: AppColors.outline)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: AppColors.inkMuted),
                              SizedBox(width: 6),
                              Text(
                                'MINILAB PROTOCOL v4.8',
                                style: TextStyle(fontSize: 10, color: AppColors.inkMuted, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            'STANDALONE MODULES',
                            style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                '© 2026 MINILAB PLATFORM • HỆ THỐNG VẬN HÀNH & KHO LƯU TRỮ PHIM',
                style: TextStyle(fontSize: 10, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(int mode, String label, IconData icon) {
    final isSelected = _loginMode == mode;
    return InkWell(
      onTap: () => _switchMode(mode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected ? Border.all(color: AppColors.outline) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? (_loginMode == 0 ? AppColors.primary : AppColors.secondary) : AppColors.inkMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.ink : AppColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, int mode, String email) {
    final isCurrent = _loginMode == mode && _emailController.text == email;

    return InkWell(
      onTap: () {
        _switchMode(mode);
        _emailController.text = email;
        _passwordController.text = 'password123';
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isCurrent ? AppColors.primary : AppColors.outline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppColors.primary : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
