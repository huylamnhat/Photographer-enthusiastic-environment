import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../web_login_screen.dart';
import 'admin_overview_tab.dart';
import 'admin_users_tab.dart';
import 'admin_lab_approval_tab.dart';
import 'admin_marketplace_tab.dart';
import 'admin_moderation_tab.dart';
import 'admin_services_tab.dart';
import 'admin_disputes_tab.dart';
import 'admin_audit_logs_tab.dart';

class AdminPortalShell extends StatefulWidget {
  const AdminPortalShell({super.key});

  @override
  State<AdminPortalShell> createState() => _AdminPortalShellState();
}

class _AdminPortalShellState extends State<AdminPortalShell> {
  int _selectedTabIndex = 0;

  late final List<Widget> _tabs = [
    AdminOverviewTab(onNavigateTab: (idx) => setState(() => _selectedTabIndex = idx)),
    const AdminUsersTab(),
    const AdminLabApprovalTab(),
    const AdminMarketplaceTab(),
    const AdminModerationTab(),
    const AdminServicesTab(),
    const AdminDisputesTab(),
    const AdminAuditLogsTab(),
  ];

  final List<Map<String, String>> _menuItems = [
    {'title': '1. Tổng quan vận hành', 'code': 'ADM-02'},
    {'title': '2. Tài khoản & Phân quyền', 'code': 'ADM-03'},
    {'title': '3. Thẩm định đối tác', 'code': 'ADM-04'},
    {'title': '4. Kiểm duyệt sàn mua bán', 'code': 'ADM-05'},
    {'title': '5. Hậu kiểm cộng đồng', 'code': 'ADM-06'},
    {'title': '6. Danh mục kỹ thuật & Lab', 'code': 'ADM-07'},
    {'title': '7. Khiếu nại & Hoàn tiền', 'code': 'ADM-08'},
    {'title': '8. Nhật ký kiểm toán', 'code': 'ADM-09'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          // Left Sidebar (256px) - Matching Stitch WEB-ADM-02
          Container(
            width: 256,
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(right: BorderSide(color: AppColors.outline, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceRaised,
                    border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'MINILAB ARCHIVE',
                            style: TextStyle(
                              fontFamilyFallback: AppTypography.fontSans,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: -0.5,
                              color: AppColors.ink,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SYS.ADM',
                              style: TextStyle(
                                fontFamilyFallback: AppTypography.fontMono,
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'HỆ THỐNG VẬN HÀNH',
                        style: TextStyle(
                          fontFamilyFallback: AppTypography.fontMono,
                          fontSize: 10,
                          color: AppColors.inkMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Label
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'SỔ QUẢN TRỊ & ĐIỀU HÀNH',
                    style: TextStyle(
                      fontFamilyFallback: AppTypography.fontMono,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // Nav Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _menuItems.length,
                    itemBuilder: (ctx, idx) {
                      final item = _menuItems[idx];
                      final isSelected = _selectedTabIndex == idx;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: InkWell(
                          onTap: () => setState(() => _selectedTabIndex = idx),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceSunken : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['title']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? AppColors.primary : AppColors.ink,
                                  ),
                                ),
                                Text(
                                  item['code']!,
                                  style: TextStyle(
                                    fontFamilyFallback: AppTypography.fontMono,
                                    fontSize: 11,
                                    color: isSelected ? AppColors.primary : AppColors.outline,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Footer Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('v4.8.2-PROD', style: AppTypography.dataMono),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              const Text('ONLINE', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('BẢN PHÁT HÀNH ĐỘC QUYỀN', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area & Sticky Header
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceRaised,
                    border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'HỆ THỐNG / VẬN HÀNH TRUNG TÂM',
                        style: TextStyle(
                          fontFamilyFallback: AppTypography.fontMono,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Row(
                        children: [
                          // Search Box with shortcut
                          Container(
                            width: 280,
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search, size: 18, color: AppColors.outline),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text('Tra cứu mã phiếu, lab, đơn...', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                                ),
                                Text('⌘ K', style: TextStyle(fontSize: 10, color: AppColors.outline, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Notification bell with badge 7
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, size: 20),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: const Text('7', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),

                          // User avatar & title
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: const Text('VT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Vũ Minh Tuấn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('CHỈ HUY HỆ THỐNG', style: TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          // Logout button
                          IconButton(
                            tooltip: 'Đăng xuất',
                            icon: const Icon(Icons.logout, size: 18, color: AppColors.inkMuted),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const WebLoginScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content View
                Expanded(
                  child: _tabs[_selectedTabIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
