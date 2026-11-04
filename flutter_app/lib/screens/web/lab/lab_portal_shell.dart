import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../web_login_screen.dart';
import 'lab_kanban_tab.dart';
import 'lab_upload_scan_tab.dart';
import 'lab_services_tab.dart';
import 'lab_profile_tab.dart';
import 'lab_sla_report_tab.dart';

class LabPortalShell extends StatefulWidget {
  const LabPortalShell({super.key});

  @override
  State<LabPortalShell> createState() => _LabPortalShellState();
}

class _LabPortalShellState extends State<LabPortalShell> {
  int _selectedTabIndex = 0;

  final List<Widget> _tabs = [
    const LabKanbanTab(),
    const LabUploadScanTab(),
    const LabServicesTab(),
    const LabProfileTab(),
    const LabSlaReportTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          // Left Sidebar (Lab Portal Navigation)
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(right: BorderSide(color: AppColors.outline, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lab Brand Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.store, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CROPLAB HÀ NỘI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                          Text('Cổng Vận Hành Film Lab', style: TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
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
                      _buildNavItem(0, 'Bảng Kanban Vận Hành', Icons.view_kanban_outlined),
                      _buildNavItem(1, 'Tải file scan & QC', Icons.cloud_upload_outlined),
                      _buildNavItem(2, 'Gói dịch vụ & Bảng giá', Icons.price_change_outlined),
                      _buildNavItem(3, 'Cấu hình hồ sơ tiệm Lab', Icons.storefront_outlined),
                      _buildNavItem(4, 'Báo cáo hiệu suất SLA', Icons.bar_chart_outlined),
                    ],
                  ),
                ),

                const Divider(),
                // Lab Owner Footer
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150'),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trần Văn Đức (CropLab)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1),
                            Text('labowner@croplab.vn', style: TextStyle(fontSize: 10, color: AppColors.inkMuted), maxLines: 1),
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
        color: isSelected ? AppColors.secondary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, size: 20, color: isSelected ? AppColors.secondary : AppColors.inkMuted),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.secondary : AppColors.ink,
          ),
        ),
        onTap: () => setState(() => _selectedTabIndex = index),
      ),
    );
  }
}

