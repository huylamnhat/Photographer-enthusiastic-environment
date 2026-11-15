import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final fullName = (currentUser?.fullName != null && currentUser!.fullName.isNotEmpty)
        ? currentUser.fullName
        : 'Khách hàng MiniLab';
    final email = (currentUser?.email != null && currentUser!.email.isNotEmpty)
        ? currentUser.email
        : 'khachhang@minilab.vn';
    final phone = (currentUser?.phone != null && currentUser!.phone.isNotEmpty)
        ? ' • ${currentUser.phone}'
        : '';
    final userIdCode = (currentUser?.userId != null && currentUser!.userId.isNotEmpty)
        ? '#${currentUser.userId.toUpperCase()}'
        : '#VN-882';
    final String avatarUrl = (currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty)
        ? currentUser.avatarUrl!
        : MockTestAssets.avatarCustomer;
    final roleBadge = currentUser?.role == 'Expert'
        ? 'CHUYÊN GIA NHIẾP ẢNH (EXPERT)'
        : 'CỘNG ĐỒNG NHIẾP ẢNH GIA';

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
          'HỒ SƠ CÁ NHÂN & CÀI ĐẶT',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Membership Dossier Card (Stitch APP-CUS-26)
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
                      border: Border(bottom: BorderSide(color: AppColors.outline)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('THẺ THÀNH VIÊN ANALOG', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                        Text(userIdCode, style: AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: MockTestAssets.image(avatarUrl, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullName, style: AppTypography.cardTitle.copyWith(fontSize: 16)),
                              const SizedBox(height: 2),
                              Text('$email$phone', style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  roleBadge,
                                  style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.outline),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem('14', 'Cuộn đã tráng'),
                        ),
                        Container(width: 1, height: 28, color: AppColors.outline),
                        Expanded(
                          child: _buildMetricItem('420', 'Frames Archive'),
                        ),
                        Container(width: 1, height: 28, color: AppColors.outline),
                        Expanded(
                          child: _buildMetricItem('450k', 'Ví MiniLab Pay'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lab Preferences
            Text('TIỆM LAB YÊU THÍCH', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  _buildPrefRow('LLab Sài Gòn (Q.1)', 'Noritsu HS-1800 • Tone ấm', true),
                  const Divider(height: 14, color: AppColors.outline),
                  _buildPrefRow('Croplab Retro (Bình Thạnh)', 'Fuji Frontier SP-3000 • Xanh pastel', true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings & Security
            Text('CÀI ĐẶT BẢO MẬT & THÔNG BÁO', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  _buildSettingRow(Icons.security, 'Xác thực hai yếu tố (2FA / Passkey)', 'Đã bật qua thiết bị xác thực'),
                  const Divider(height: 14, color: AppColors.outline),
                  _buildSettingRow(Icons.notifications_outlined, 'Thông báo tiến độ ca trực Lab', 'Nhận thông báo khi ảnh đã scan xong'),
                  const Divider(height: 14, color: AppColors.outline),
                  _buildSettingRow(Icons.lock_outline, 'Quyền riêng tư kho ảnh số', 'Chỉ người có link bảo mật mới xem được'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Đăng xuất tài khoản', style: AppTypography.button.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTypography.metric.copyWith(fontSize: 16, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
      ],
    );
  }

  Widget _buildPrefRow(String name, String sub, bool isFav) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTypography.cardTitle.copyWith(fontSize: 12)),
            const SizedBox(height: 2),
            Text(sub, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted)),
          ],
        ),
        const Icon(Icons.favorite, size: 16, color: AppColors.primary),
      ],
    );
  }

  Widget _buildSettingRow(IconData icon, String title, String sub) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.inkMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.cardTitle.copyWith(fontSize: 12)),
              const SizedBox(height: 2),
              Text(sub, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, size: 16, color: AppColors.inkMuted),
      ],
    );
  }
}
