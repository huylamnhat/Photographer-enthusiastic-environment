import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final orders = await ApiService().getOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final fullName = (currentUser?.fullName != null && currentUser!.fullName.isNotEmpty)
        ? currentUser.fullName
        : 'Khách hàng MiniLab';
    final email = (currentUser?.email != null && currentUser!.email.isNotEmpty)
        ? currentUser.email
        : '';
    final phone = (currentUser?.phone != null && currentUser!.phone.isNotEmpty)
        ? (email.isNotEmpty ? ' • ${currentUser.phone}' : currentUser.phone)
        : '';
    final userIdCode = (currentUser?.userId != null && currentUser!.userId.isNotEmpty)
        ? '#${currentUser.userId.toUpperCase()}'
        : '#MEMBER';
    final String avatarUrl = (currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty)
        ? currentUser.avatarUrl!
        : MockTestAssets.avatarCustomer;
    final roleBadge = currentUser?.role == 'Expert'
        ? 'CHUYÊN GIA NHIẾP ẢNH (EXPERT)'
        : 'CỘNG ĐỒNG NHIẾP ẢNH GIA';

    final totalOrders = _orders.length;
    final totalRolls = _orders.fold<int>(
      0,
      (sum, o) => sum + o.items.fold<int>(0, (s, i) => s + i.quantity),
    );
    final driveCount = _orders
        .where((o) => (o.driveLink ?? '').trim().isNotEmpty || o.driveLinkHistory.isNotEmpty)
        .length;
    final orderedLabs = <String>{};
    for (final o in _orders) {
      if (o.labName.trim().isNotEmpty) orderedLabs.add(o.labName.trim());
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
            onPressed: _loadUserStats,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Membership Dossier Card
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
                    child: _loading
                        ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                        : Row(
                            children: [
                              Expanded(child: _buildMetricItem('$totalOrders', 'Đơn đã đặt')),
                              Container(width: 1, height: 28, color: AppColors.outline),
                              Expanded(child: _buildMetricItem('$totalRolls', 'Cuộn đã gửi')),
                              Container(width: 1, height: 28, color: AppColors.outline),
                              Expanded(child: _buildMetricItem('$driveCount', 'Link Drive')),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ordered Film Labs of THIS user only
            Text('TIỆM LAB ĐÃ ĐẶT', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: orderedLabs.isEmpty
                  ? Text(
                      'Bạn chưa đặt đơn ở tiệm Film Lab nào.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                    )
                  : Column(
                      children: orderedLabs.toList().asMap().entries.map((entry) {
                        final idx = entry.key;
                        final labName = entry.value;
                        return Column(
                          children: [
                            if (idx > 0) const Divider(height: 14, color: AppColors.outline),
                            _buildPrefRow(labName, 'Đã từng sử dụng dịch vụ tráng & scan'),
                          ],
                        );
                      }).toList(),
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
                  _buildSettingRow(Icons.security, 'Bảo mật tài khoản', 'Đang đăng nhập phiên cá nhân'),
                  const Divider(height: 14, color: AppColors.outline),
                  _buildSettingRow(Icons.notifications_outlined, 'Thông báo tiến độ ca trực Lab', 'Nhận thông báo khi ảnh đã scan xong'),
                  const Divider(height: 14, color: AppColors.outline),
                  _buildSettingRow(Icons.lock_outline, 'Quyền riêng tư kho link Drive', 'Chỉ hiển thị link từ đơn hàng của bạn'),
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

  Widget _buildPrefRow(String name, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTypography.cardTitle.copyWith(fontSize: 12)),
              const SizedBox(height: 2),
              Text(sub, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted)),
            ],
          ),
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
