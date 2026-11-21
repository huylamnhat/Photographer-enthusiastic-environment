import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';
import '../../../providers/auth_provider.dart';
import '../portal_notification_bell.dart';
import '../web_login_screen.dart';
import 'lab_kanban_tab.dart';
import 'lab_upload_scan_tab.dart';
import 'lab_services_tab.dart';
import 'lab_profile_tab.dart';
import 'lab_claims_tab.dart';
import 'lab_sla_report_tab.dart';

class LabPortalShell extends StatefulWidget {
  const LabPortalShell({super.key});

  @override
  State<LabPortalShell> createState() => _LabPortalShellState();
}

class _LabPortalShellState extends State<LabPortalShell> {
  int _selectedTabIndex = 0;
  String _labName = '';
  String _labBranch = '';
  String _labCode = '';
  List<dynamic> _notifications = [];
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    _loadLabHeader();
    _loadLabNotifications();
    _notifTimer = Timer.periodic(const Duration(seconds: 20), (_) => _loadLabNotifications());
  }

  @override
  void dispose() {
    _notifTimer?.cancel();
    super.dispose();
  }

  Future<List<dynamic>> _loadLabNotifications() async {
    final items = await WebApiService().getLabNotifications();
    if (mounted) {
      setState(() => _notifications = items);
    }
    return items;
  }

  Future<void> _loadLabHeader() async {
    final p = await WebApiService().getLabProfile();
    if (!mounted || p.isEmpty) return;
    setState(() {
      _labName = (p['name'] ?? '').toString();
      final city = (p['city'] ?? '').toString();
      final addr = (p['address'] ?? '').toString();
      _labBranch = addr.isNotEmpty ? addr : (_labName + (city.isNotEmpty ? ' - $city' : ''));
      _labCode = (p['lab_id'] ?? '').toString();
    });
  }

  final List<Widget> _tabs = const [
    LabKanbanTab(),
    LabUploadScanTab(),
    LabServicesTab(),
    LabProfileTab(),
    LabClaimsTab(),
    LabSlaReportTab(),
  ];

  final List<Map<String, String>> _menuItems = [
    {'title': '1. Tiếp nhận & Xử lý', 'icon': 'view_kanban'},
    {'title': '2. Gửi ảnh cho khách', 'icon': 'cloud_upload'},
    {'title': '3. Dịch vụ & Bảng giá', 'icon': 'price_change'},
    {'title': '4. Hồ sơ tiệm', 'icon': 'storefront'},
    {'title': '5. Khiếu nại', 'icon': 'report_problem'},
    {'title': '6. Lịch sử & Hiệu suất', 'icon': 'history_toggle_off'},
  ];

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().currentUser;
    final displayLabName = _labName.isNotEmpty
        ? _labName
        : ((authUser?.fullName ?? 'Film Lab').replaceAll(RegExp(r'\s*\(.*?\)'), '').trim());
    final displayBranch = _labBranch.isNotEmpty
        ? _labBranch
        : (authUser?.address ?? displayLabName);
    final displayLabCode = (_labCode.isNotEmpty ? _labCode : (authUser?.labId ?? 'LAB-OPS')).toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          // Sidebar 260px
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(right: BorderSide(color: AppColors.outline, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceRaised,
                    border: Border(bottom: BorderSide(color: AppColors.outline, width: 1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayLabName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'CỔNG LAB • $displayLabCode',
                              style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.camera_roll_outlined, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('QUẢN LÝ TIỆM', style: AppTypography.labelCaps),
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
                          onTap: () {
                            setState(() => _selectedTabIndex = idx);
                            _loadLabNotifications();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceSunken : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['title']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: isSelected ? AppColors.primary : AppColors.ink,
                              ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('MINILAB', style: AppTypography.dataMono),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('Đang hoạt động', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Header & Tab View
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
                      // Branch Indicator
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  displayBranch,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // User Profile and Logout
                      Row(
                        children: [
                          // Search Box
                          Container(
                            width: 220,
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search, size: 16, color: AppColors.outline),
                                SizedBox(width: 8),
                                Expanded(child: Text('Tìm mã đơn ORD-...', style: TextStyle(color: AppColors.outline, fontSize: 12))),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          PortalNotificationBell(
                            notifications: _notifications,
                            onRefresh: _loadLabNotifications,
                            onNavigateTab: (idx) {
                              setState(() => _selectedTabIndex = idx);
                              _loadLabNotifications();
                            },
                            title: 'Thông báo Tiệm Lab',
                          ),
                          const SizedBox(width: 8),

                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: const Text('LAB', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayLabName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const Text('KỸ THUẬT VIÊN TRỰC CA', style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

                          IconButton(
                            tooltip: 'Đăng xuất',
                            icon: const Icon(Icons.logout, size: 18, color: AppColors.inkMuted),
                            onPressed: () {
                              context.read<AuthProvider>().logout();
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
