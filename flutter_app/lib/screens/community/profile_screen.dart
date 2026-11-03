import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản & Cài đặt'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(
                      user?.avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Nguyễn Hoàng Anh',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'hoanganh@gmail.com',
                    style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Vai trò: ${user?.role ?? 'Customer'}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings list
            _buildSettingTile(
              Icons.location_on_outlined,
              'Địa chỉ nhận & giao film',
              user?.address ?? '123 Phố Huế, Hai Bà Trưng, Hà Nội',
              () {},
            ),
            _buildSettingTile(
              Icons.lock_outline,
              'Bảo mật & Đổi mật khẩu',
              'Quản lý mật khẩu và mã OTP xác thực',
              () {},
            ),
            _buildSettingTile(
              Icons.cloud_sync_outlined,
              'Đồng bộ Digital Film Archive',
              'Tự động lưu trữ ảnh scan gốc chuẩn TIFF/JPG',
              () {},
            ),
            _buildSettingTile(
              Icons.info_outline,
              'Về nền tảng MiniLab',
              'Phiên bản 1.0.0 (Nhóm 8 Capstone)',
              () {},
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Đăng xuất tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  auth.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
        trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.inkMuted),
        onTap: onTap,
      ),
    );
  }
}

