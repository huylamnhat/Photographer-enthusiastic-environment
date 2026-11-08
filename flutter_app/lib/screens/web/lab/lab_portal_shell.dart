import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
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
  final String _currentBranch = 'CropLab Sài Gòn - Chi nhánh Q.3';

  final List<Widget> _tabs = const [
    LabKanbanTab(),
    LabUploadScanTab(),
    LabServicesTab(),
    LabProfileTab(),
    LabClaimsTab(),
    LabSlaReportTab(),
  ];

  final List<Map<String, String>> _menuItems = [
    {'title': '1. Tiếp nhận & Phân loại', 'code': 'WEB-LAB-03', 'icon': 'view_kanban'},
    {'title': '2. Tải file scan & QC', 'code': 'WEB-LAB-04', 'icon': 'cloud_upload'},
    {'title': '3. Dịch vụ & Bảng giá', 'code': 'WEB-LAB-05', 'icon': 'price_change'},
    {'title': '4. Hồ sơ tiệm công khai', 'code': 'WEB-LAB-06', 'icon': 'storefront'},
    {'title': '5. Xử lý khiếu nại', 'code': 'WEB-LAB-07', 'icon': 'report_problem'},
    {'title': '6. Lịch sử đơn & SLA', 'code': 'WEB-LAB-08', 'icon': 'history_toggle_off'},
  ];

  @override
  Widget build(BuildContext context) {
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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CROPLAB SÀI GÒN',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'CỔNG VẬN HÀNH FILM LAB',
                            style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
                  child: Text('QUY TRÌNH PHÒNG TỐI (DARKROOM)', style: AppTypography.labelCaps),
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
                                    fontSize: 10,
                                    color: isSelected ? AppColors.primary : AppColors.outline,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('LAB-OPS // v4.8.2', style: AppTypography.dataMono),
                      Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('ONLINE', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(_currentBranch, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
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
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CropLab Sài Gòn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text('KỸ THUẬT VIÊN TRỰC CA', style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),

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
