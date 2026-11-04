import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/web_api_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final users = await WebApiService().getAdminUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _toggleUserStatus(int index) {
    setState(() {
      final current = _users[index]['status'];
      _users[index]['status'] = current == 'ACTIVE' ? 'BLOCKED' : 'ACTIVE';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật trạng thái tài khoản: ${_users[index]['full_name']}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Padding(
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
                  Text('Quản lý Tài Khoản & Phân Quyền (RBAC)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  SizedBox(height: 4),
                  Text('Kiểm soát 5 vai trò hệ thống: Customer, Film Lab Owner, Expert, Shipper, Admin', style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Thêm tài khoản'),
                onPressed: () {},
              )
            ],
          ),
          const SizedBox(height: 20),

          // User Table Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final u = _users[index];
                  final isActive = u['status'] == 'ACTIVE';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surfaceSunken,
                          child: Icon(
                            u['role'] == 'Admin' ? Icons.security : (u['role'] == 'LabOwner' ? Icons.store : Icons.person),
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['full_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(u['email'], style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: _buildRoleBadge(u['role']),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive ? AppColors.success : AppColors.danger,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(isActive ? 'HOẠT ĐỘNG' : 'ĐÃ KHÓA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isActive ? AppColors.success : AppColors.danger,
                                  )),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: isActive ? 'Khóa tài khoản' : 'Mở khóa',
                          icon: Icon(isActive ? Icons.lock_outline : Icons.lock_open, color: isActive ? AppColors.danger : AppColors.success),
                          onPressed: () => _toggleUserStatus(index),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg = AppColors.neutralBg;
    Color fg = AppColors.neutral;
    if (role == 'Admin') {
      bg = Colors.red.withValues(alpha: 0.12);
      fg = Colors.red.shade800;
    } else if (role == 'LabOwner') {
      bg = AppColors.primary.withValues(alpha: 0.12);
      fg = AppColors.primary;
    } else if (role == 'Expert') {
      bg = Colors.purple.withValues(alpha: 0.12);
      fg = Colors.purple;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(role, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

