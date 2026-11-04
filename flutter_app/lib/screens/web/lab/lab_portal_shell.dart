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
  final String? labId;
  final String? labName;

  const LabPortalShell({super.key, this.labId, this.labName});

  @override
  State<LabPortalShell> createState() => _LabPortalShellState();
}

class _LabPortalShellState extends State<LabPortalShell> {
  int _selectedTabIndex = 0;
  late String _currentLabId;
  late String _currentLabName;
  late String _currentBranch;

  final List<Map<String, String>> _availableLabs = [
    {
      'id': 'lab-001',
      'name': 'CropLab Hà Nội',
      'branch': 'Số 10 Đặng Thai Mai, Tây Hồ, Hà Nội',
      'badge': '⭐ Nhận đơn từ Mobile App',
    },
    {
      'id': 'lab-002',
      'name': 'LLab Film Sài Gòn',
      'branch': '40/2 Phan Văn Trị, Bình Thạnh, TP.HCM',
      'badge': 'Chi nhánh Miền Nam',
    },
    {
      'id': 'lab-003',
      'name': 'Nadar Darkroom Atelier',
      'branch': '15 Tràng Tiền, Hoàn Kiếm, Hà Nội',
      'badge': 'Phòng tối Fine-Art',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentLabId = widget.labId ?? 'lab-001';
    _currentLabName = widget.labName ?? 'CropLab Hà Nội';
    final matched = _availableLabs.firstWhere(
      (l) => l['id'] == _currentLabId,
      orElse: () => _availableLabs[0],
    );
    _currentBranch = matched['branch']!;
  }

  List<Widget> get _tabs => [
    LabKanbanTab(key: ValueKey(_currentLabId), labId: _currentLabId, labName: _currentLabName),
    const LabUploadScanTab(),
    const LabServicesTab(),
    const LabProfileTab(),
    const LabClaimsTab(),
    const LabSlaReportTab(),
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
                // Header with current Lab Name
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
                              _currentLabName.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBg,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(_currentLabId.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                ),
                                const SizedBox(width: 6),
                                const Text('CỔNG VẬN HÀNH', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
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
                      Text('$_currentLabId // v4.8.2', style: AppTypography.dataMono),
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
                      // Interactive Lab Switcher Dropdown
                      PopupMenuButton<Map<String, String>>(
                        tooltip: 'Bấm vào đây để chuyển tiệm Lab',
                        onSelected: (lab) {
                          setState(() {
                            _currentLabId = lab['id']!;
                            _currentLabName = lab['name']!;
                            _currentBranch = lab['branch']!;
                          });
                        },
                        itemBuilder: (ctx) => _availableLabs.map((lab) {
                          final isCurrent = lab['id'] == _currentLabId;
                          return PopupMenuItem(
                            value: lab,
                            child: Row(
                              children: [
                                Icon(
                                  isCurrent ? Icons.check_circle : Icons.storefront_outlined,
                                  size: 18,
                                  color: isCurrent ? AppColors.secondary : AppColors.inkMuted,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      lab['name']!,
                                      style: TextStyle(
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                        color: isCurrent ? AppColors.primary : AppColors.ink,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      '${lab['id']} • ${lab['badge']}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.inkMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.storefront, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Text(_currentLabName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.successBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(_currentLabId.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                                      ),
                                    ],
                                  ),
                                  Text(_currentBranch, style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                                ],
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
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
                                  Text(_currentLabName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
