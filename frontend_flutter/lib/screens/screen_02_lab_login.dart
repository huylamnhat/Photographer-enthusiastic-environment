import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';

class LabLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onNavigateToRegister;

  const LabLoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.onNavigateToRegister,
  });

  @override
  State<LabLoginScreen> createState() => _LabLoginScreenState();
}

class _LabLoginScreenState extends State<LabLoginScreen> {
  final emailCtrl = TextEditingController(text: 'lab@saigonfilm.vn');
  final pwdCtrl = TextEditingController(text: 'LabArchive@2024');
  String selectedBranch = 'sgn-01';
  bool obscurePassword = true;
  bool isLoading = false;
  String? errorMessage;

  void _handleLogin() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final res = await ApiService.login(emailCtrl.text, pwdCtrl.text, selectedBranch);

    setState(() => isLoading = false);

    if (res['success'] == true) {
      widget.onLoginSuccess();
    } else {
      setState(() => errorMessage = res['message'] ?? 'Đăng nhập không thành công');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LabColors.surfaceContainerLow,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            decoration: BoxDecoration(
              color: LabColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Color Accent Strip
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [LabColors.primaryContainer, LabColors.primary, LabColors.secondary],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
                  child: Column(
                    children: [
                      // Logo Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: LabColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.camera_roll, color: LabColors.primary, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'MINILAB ARCHIVE',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: LabColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: LabColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: const Text(
                              'PHÂN HỆ TIỆM LAB',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: LabColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Đăng nhập Film Lab',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: LabColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Hệ thống quản lý tiếp nhận & xử lý cuộn phim analog chuẩn hóa',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 13,
                          color: LabColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.bottom(16),
                          decoration: BoxDecoration(
                            color: LabColors.errorContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: LabColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(color: LabColors.onErrorContainer, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Form Fields
                      TextField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'EMAIL / MÃ TÀI KHOẢN TIỆM',
                          prefixIcon: Icon(Icons.mail_outline, size: 18),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: pwdCtrl,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'MẬT KHẨU BẢO MẬT',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedBranch,
                        decoration: const InputDecoration(
                          labelText: 'CHI NHÁNH TIỆM',
                          prefixIcon: Icon(Icons.storefront_outlined, size: 18),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'sgn-01',
                            child: Text('Chi nhánh 01 - Quận 3, TP.HCM (Lab Trung Tâm)', style: TextStyle(fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'sgn-02',
                            child: Text('Chi nhánh 02 - Thảo Điền, TP.Thủ Đức (Lab Scan Tốc Độ)', style: TextStyle(fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'han-01',
                            child: Text('Chi nhánh 03 - Hoàn Kiếm, Hà Nội (Trạm Nhận)', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                        onChanged: (v) => setState(() => selectedBranch = v!),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LabColors.primaryContainer,
                            foregroundColor: LabColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: isLoading ? null : _handleLogin,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.login),
                          label: Text(
                            isLoading ? 'Đang kích hoạt trạm làm việc...' : 'Đăng nhập',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Register Prompt Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: LabColors.surfaceContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản tiệm? ',
                        style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 13, color: LabColors.onSurfaceVariant),
                      ),
                      InkWell(
                        onTap: widget.onNavigateToRegister,
                        child: const Text(
                          'Đăng ký mở tiệm Lab →',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: LabColors.primary,
                          ),
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

