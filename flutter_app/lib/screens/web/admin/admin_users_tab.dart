import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';
import '../../../core/services/web_api_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _selectedRole = 'Tất cả';
  String _selectedStatus = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final data = await WebApiService().getAdminUsers();
    if (!mounted) return;
    setState(() {
      _users = data.map<Map<String, dynamic>>((u) {
        final rawStatus = (u['status'] ?? 'ACTIVE').toString();
        return {
          'id': (u['user_id'] ?? '').toString(),
          'name': (u['full_name'] ?? '').toString(),
          'email': (u['email'] ?? '').toString(),
          'phone': (u['phone'] ?? '').toString(),
          'role': (u['role'] ?? 'Customer').toString(),
          'avatar': (u['avatar_url'] ?? MockTestAssets.avatarCustomer).toString(),
          'status': rawStatus == 'LOCKED' ? 'BANNED' : rawStatus,
          'joined': (u['created_at'] ?? '').toString().split('T').first,
        };
      }).toList();
    });
  }

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
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                await WebApiService().updateAdminUser(user['id'], status: 'LOCKED');
                if (!mounted || !ctx.mounted) return;
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
                  Text('WEB-ADM-03 // PHÂN HỆ RBAC (SQL SERVER)', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Tài khoản & Phân quyền', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Tải lại từ CSDL'),
              ),
            ],
          ),
          const SizedBox(height: 20),

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
                                onPressed: () async {
                                  final ok = await WebApiService().updateAdminUser(u['id'], status: 'ACTIVE');
                                  if (!mounted) return;
                                  if (ok) {
                                    setState(() => u['status'] = 'ACTIVE');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã mở khóa tài khoản ${u['name']}. Tên người dùng đã được khôi phục trên cộng đồng!')),
                                    );
                                  }
                                },
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
