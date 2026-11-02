import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ServicesPricingScreen extends StatefulWidget {
  const ServicesPricingScreen({super.key});

  @override
  State<ServicesPricingScreen> createState() => _ServicesPricingScreenState();
}

class _ServicesPricingScreenState extends State<ServicesPricingScreen> {
  List<ServiceModel> services = [];
  List<PriceHistoryModel> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final sList = await ApiService.getServices();
    final hList = await ApiService.getPriceHistory();
    setState(() {
      services = sList;
      history = hList;
      isLoading = false;
    });
  }

  void _toggleService(ServiceModel service) async {
    final success = await ApiService.toggleServiceStatus(service.serviceId);
    if (success) {
      setState(() {
        service.status = service.status == 'ACTIVE' ? 'PAUSED' : 'ACTIVE';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${service.name} hiện đang ở trạng thái: ${service.status}'),
            backgroundColor: service.status == 'ACTIVE' ? LabColors.secondary : LabColors.outline,
          ),
        );
      }
    }
  }

  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '85000');
    final slaCtrl = TextEditingController(text: '48');
    final descCtrl = TextEditingController(text: 'Tráng máy tự động, scan chuẩn màu');
    String process = 'C-41';
    String format = '135 (35mm)';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_circle, color: LabColors.primary),
              SizedBox(width: 8),
              Text('Thêm Gói Dịch Vụ Mới'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên gói dịch vụ *', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: process,
                        decoration: const InputDecoration(labelText: 'Quy trình', border: OutlineInputBorder()),
                        items: ['C-41', 'B&W', 'ECN-2', 'E-6'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setDState(() => process = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: format,
                        decoration: const InputDecoration(labelText: 'Khổ phim', border: OutlineInputBorder()),
                        items: ['135 (35mm)', '120 (Medium)', '4x5 Sheet'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setDState(() => format = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá niêm yết (VNĐ) *', border: OutlineInputBorder())),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(controller: slaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SLA Cam kết (Giờ)', border: OutlineInputBorder())),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả dịch vụ', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LabColors.primaryContainer, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                await ApiService.createService({
                  'name': nameCtrl.text,
                  'process_type': process,
                  'film_format': format,
                  'base_price': double.tryParse(priceCtrl.text) ?? 80000,
                  'sla_hours': int.tryParse(slaCtrl.text) ?? 48,
                  'description': descCtrl.text,
                });
                _loadData();
              },
              child: const Text('Tạo gói dịch vụ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeCount = services.where((s) => s.status == 'ACTIVE').length;

    return Scaffold(
      backgroundColor: LabColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dịch vụ, Bảng giá & Lịch sử đổi giá',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Hệ thống quản lý định giá, cam kết SLA và kiểm toán biến động chi phí hóa chất',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 13, color: LabColors.onSurfaceVariant),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Xuất biểu phí CSV'),
                      onPressed: () {},
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: LabColors.primaryContainer, foregroundColor: Colors.white),
                      icon: const Icon(Icons.add_circle, size: 18),
                      label: const Text('Thêm gói dịch vụ mới (+)'),
                      onPressed: _showAddServiceDialog,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Metrics
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TỔNG SỐ GÓI QUY CHUẨN', style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${services.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('$activeCount Đang phục vụ', style: const TextStyle(color: LabColors.secondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SLA TRUNG BÌNH CAM KẾT', style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline)),
                          const SizedBox(height: 4),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('28.5h', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              Text('TỐI ƯU', style: TextStyle(color: LabColors.secondary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Responsive Dual-Column Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1050;
                
                final servicesCard = Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: LabColors.surfaceContainerLow,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.table_chart, size: 18, color: LabColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'DANH MỤC GÓI DỊCH VỤ NIÊM YẾT',
                                  style: TextStyle(fontFamily: 'IBM Plex Sans', fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              'TIÊU CHUẨN ISO 9001 / NORITSU HS-1800',
                              style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final s = services[index];
                          final isActive = s.status == 'ACTIVE';

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                // Left details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            s.serviceId,
                                            style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, fontWeight: FontWeight.bold, color: LabColors.primary),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: LabColors.surfaceContainer,
                                              borderRadius: BorderRadius.circular(9999),
                                            ),
                                            child: Text(
                                              s.filmFormat,
                                              style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.onSurfaceVariant),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text('${s.processType} • Máy scan: ${s.scanner}', style: const TextStyle(fontSize: 12, color: LabColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                // Right aligned parameters
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 110,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${s.basePrice.toStringAsFixed(0)} đ', style: const TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, fontSize: 14, color: LabColors.primary)),
                                          Text('+ Push: ${s.pushPullFee.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 10, color: LabColors.outline)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: LabColors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      child: Text('${s.slaHours}h SLA', style: const TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                    const SizedBox(width: 16),
                                    SizedBox(
                                      width: 85,
                                      child: InkWell(
                                        onTap: () => _toggleService(s),
                                        borderRadius: BorderRadius.circular(9999),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: isActive ? LabColors.secondaryContainer : LabColors.surfaceContainer,
                                            borderRadius: BorderRadius.circular(9999),
                                          ),
                                          child: Center(
                                            child: Text(
                                              isActive ? 'ACTIVE' : 'PAUSED',
                                              style: TextStyle(
                                                fontFamily: 'IBM Plex Mono',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isActive ? LabColors.onSecondaryContainer : LabColors.outline,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );

                final auditTrailCard = Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: LabColors.surfaceContainerLow,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, size: 18, color: LabColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'NHẬT KÝ BIẾN ĐỘNG GIÁ',
                                  style: TextStyle(fontFamily: 'IBM Plex Sans', fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            Text(
                              'BẤT BIẾN',
                              style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final h = history[index];
                          return Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(h.effectiveDate, style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, fontWeight: FontWeight.bold, color: LabColors.primary)),
                                    Text(h.historyId, style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(h.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('${h.oldPrice.toStringAsFixed(0)} đ', style: const TextStyle(fontFamily: 'IBM Plex Mono', decoration: TextDecoration.lineThrough, color: LabColors.outline, fontSize: 11)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward, size: 12, color: LabColors.primary),
                                    const SizedBox(width: 6),
                                    Text('${h.newPrice.toStringAsFixed(0)} đ', style: const TextStyle(fontFamily: 'IBM Plex Mono', fontWeight: FontWeight.bold, color: LabColors.primary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: LabColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('"${h.reason}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                                ),
                                const SizedBox(height: 4),
                                Text('Thực hiện: ${h.changedBy}', style: const TextStyle(fontSize: 10, color: LabColors.outline)),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );

                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      servicesCard,
                      const SizedBox(height: 24),
                      auditTrailCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 66,
                      child: servicesCard,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 34,
                      child: auditTrailCard,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

