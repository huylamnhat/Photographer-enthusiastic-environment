import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../web_login_screen.dart';
import 'admin_overview_tab.dart';
import 'admin_users_tab.dart';
import 'admin_lab_approval_tab.dart';
import 'admin_marketplace_tab.dart';
import 'admin_disputes_tab.dart';

class AdminPortalShell extends StatefulWidget {
  const AdminPortalShell({super.key});

  @override
  State<AdminPortalShell> createState() => _AdminPortalShellState();
}

class _AdminPortalShellState extends State<AdminPortalShell> {
  int _selectedTabIndex = 0;

  final List<Widget> _tabs = [
    const AdminOverviewTab(),
    const AdminUsersTab(),
    const AdminLabApprovalTab(),
    const AdminMarketplaceTab(),
    const AdminDisputesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          // Left Sidebar (Desktop Navigation)
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(right: BorderSide(color: AppColors.outline, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MINILAB ADMIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                          Text('Bảng Điều Khiển Sàn', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // Nav items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    children: [
                      _buildNavItem(0, 'Tổng quan vận hành', Icons.dashboard_outlined),
                      _buildNavItem(1, 'Tài khoản & Phân quyền', Icons.manage_accounts_outlined),
                      _buildNavItem(2, 'Thẩm định mở tiệm Lab', Icons.verified_user_outlined),
                      _buildNavItem(3, 'Tiền kiểm sàn Marketplace', Icons.camera_alt_outlined),
                      _buildNavItem(4, 'Xử lý khiếu nại & Hoàn tiền', Icons.gavel_outlined),
                    ],
                  ),
                ),

                const Divider(),
                // Admin User Profile Footer
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('System Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('admin@minilab.vn', style: TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đăng xuất',
                        icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const WebLoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: _tabs[_selectedTabIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 20, color: isSelected ? AppColors.primary : AppColors.inkMuted),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.ink,
          ),
        ),
        onTap: () => setState(() => _selectedTabIndex = index),
      ),
    );
  }
}

