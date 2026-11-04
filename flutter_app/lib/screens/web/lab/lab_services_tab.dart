import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/web_api_service.dart';

class LabServicesTab extends StatefulWidget {
  const LabServicesTab({super.key});

  @override
  State<LabServicesTab> createState() => _LabServicesTabState();
}

class _LabServicesTabState extends State<LabServicesTab> {
  List<dynamic> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() async {
    final list = await WebApiService().getLabServices();
    if (mounted) {
      setState(() {
        _services = list;
        _isLoading = false;
      });
    }
  }

  void _editPrice(int index) {
    final s = _services[index];
    final controller = TextEditingController(text: s['price'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Đổi giá gói: ${s['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Giá mới (VND)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                s['price'] = int.tryParse(controller.text) ?? s['price'];
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã cập nhật giá mới: ${s['price']}đ'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Lưu thay đổi'),
          )
        ],
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
                  Text('Quản Lý Gói Dịch Vụ & Bảng Giá Tráng / Scan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  SizedBox(height: 4),
                  Text('Thiết lập giá niêm yết theo định dạng phim (135, 120), quy trình (C-41, B&W, ECN-2) và độ phân giải scan',
                      style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Thêm gói dịch vụ mới'),
                onPressed: () {},
              )
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _services.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final s = _services[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.camera_roll, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text('Khổ: ${s['film_format']} • Quy trình: ${s['process_type']} • Độ phân giải: ${s['scan_resolution']}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Thời gian: ~${s['estimated_hours']}h', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('${s['price']}đ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 14),
                          label: const Text('Đổi giá'),
                          onPressed: () => _editPrice(index),
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
}

