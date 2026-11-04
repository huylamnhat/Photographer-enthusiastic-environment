import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _selectedRole = 'Tất cả';
  String _selectedStatus = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _users = [
    {
      'id': 'ADM-HN-884',
      'name': 'Vũ Minh Tuấn',
      'email': 'admin.tuan@minilab.vn',
      'phone': '0901234567',
      'role': 'Admin',
      'avatar': MockTestAssets.avatarAdmin,
      'status': 'ACTIVE',
      'joined': '01/01/2026',
      'lastActive': 'Hôm nay 07:06',
    },
    {
      'id': 'USR-SG-001',
      'name': 'Nguyễn Hoàng Anh',
      'email': 'khachhang@minilab.vn',
      'phone': '0912345678',
      'role': 'Customer',
      'avatar': MockTestAssets.avatarCustomer,
      'status': 'ACTIVE',
      'joined': '10/01/2026',
      'lastActive': 'Hôm nay 06:45',
    },
    {
      'id': 'LAB-SG-014',
      'name': 'Trần Văn Đức (CropLab Owner)',
      'email': 'labowner@croplab.vn',
      'phone': '0904567890',
      'role': 'LabOwner',
      'avatar': MockTestAssets.avatarLabOwner,
      'status': 'ACTIVE',
      'joined': '05/01/2026',
      'lastActive': 'Hôm qua 22:30',
    },
    {
      'id': 'EXP-HN-003',
      'name': 'Lê Quang Huy',
      'email': 'chuyengia@film.vn',
      'phone': '0988776655',
      'role': 'Expert',
      'avatar': MockTestAssets.avatarExpert,
      'status': 'ACTIVE',
      'joined': '02/01/2026',
      'lastActive': '02/03/2026',
    },
    {
      'id': 'USR-DN-099',
      'name': 'Hoàng Văn Bách (Vi phạm)',
      'email': 'bach.spam@gmail.com',
      'phone': '0933445566',
      'role': 'Customer',
      'avatar': MockTestAssets.avatarUser2,
      'status': 'BANNED',
      'joined': '15/02/2026',
      'lastActive': 'Bị khóa 28/02',
    },
  ];

  void _showLockModal(Map<String, dynamic> user) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.lock_person, color: AppColors.danger, size: 24),
            const SizedBox(width: 10),
            Text('Khóa tài khoản: ${user['name']}', style: AppTypography.cardTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã ID: ${user['id']} · Email: ${user['email']}', style: AppTypography.caption),
            const SizedBox(height: 16),
            const Text('LÝ DO KHÓA TÀI KHOẢN (BẮT BUỘC GIẢI TRÌNH AUDIT):', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập chi tiết biên bản vi phạm hoặc giải trình audit...',
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                setState(() => user['status'] = 'BANNED');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã khóa tài khoản ${user['name']} và ghi log kiểm toán!')),
                );
              }
            },
            child: const Text('Xác nhận khóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      if (_selectedRole != 'Tất cả' && u['role'] != _selectedRole) return false;
      if (_selectedStatus != 'Tất cả' && u['status'] != _selectedStatus) return false;
      final q = _searchController.text.toLowerCase().trim();
      if (q.isNotEmpty) {
        final match = u['name'].toString().toLowerCase().contains(q) ||
            u['email'].toString().toLowerCase().contains(q) ||
            u['phone'].toString().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEB-ADM-03 // PHÂN HỆ RBAC', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Tài khoản & Phân quyền', style: AppTypography.pageTitle),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Thêm tài khoản (+)'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filter bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, size: 18),
                      hintText: 'Tìm theo Tên, Email, SĐT...',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: ['Tất cả', 'Admin', 'LabOwner', 'Customer', 'Expert']
                      .map((r) => DropdownMenuItem(value: r, child: Text('Vai trò: $r', style: AppTypography.body)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: ['Tất cả', 'ACTIVE', 'BANNED']
                      .map((s) => DropdownMenuItem(value: s, child: Text('Trạng thái: $s', style: AppTypography.body)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStatus = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Ledger Table
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(3.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1.8),
                4: FlexColumnWidth(2),
                5: FlexColumnWidth(1.8),
              },
              children: [
                TableRow(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  children: [
                    _th('NGƯỜI DÙNG'),
                    _th('EMAIL / SĐT'),
                    _th('VAI TRÒ'),
                    _th('NGÀY TẠO'),
                    _th('TRẠNG THÁI'),
                    _th('THAO TÁC', TextAlign.center),
                  ],
                ),
                ...filtered.map((u) {
                  final isActive = u['status'] == 'ACTIVE';
                  return TableRow(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.surfaceSunken,
                              child: MockTestAssets.image(
                                u['avatar'],
                                width: 32,
                                height: 32,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text(u['id'], style: AppTypography.dataMono),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u['email'], style: AppTypography.tableCell),
                            Text(u['phone'], style: AppTypography.caption),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Text(u['role'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Text(u['joined'], style: AppTypography.dataMono),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.successBg : AppColors.dangerBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              u['status'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isActive ? AppColors.secondary : AppColors.danger,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isActive)
                              IconButton(
                                tooltip: 'Khóa tài khoản',
                                icon: const Icon(Icons.lock_outline, color: AppColors.danger, size: 18),
                                onPressed: () => _showLockModal(u),
                              )
                            else
                              IconButton(
                                tooltip: 'Mở khóa',
                                icon: const Icon(Icons.lock_open, color: AppColors.secondary, size: 18),
                                onPressed: () => setState(() => u['status'] = 'ACTIVE'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _th(String title, [TextAlign align = TextAlign.left]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(title, textAlign: align, style: AppTypography.labelCaps),
    );
  }
}
