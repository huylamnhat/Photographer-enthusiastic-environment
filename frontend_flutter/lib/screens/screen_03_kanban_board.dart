import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class KanbanBoardScreen extends StatefulWidget {
  final Function(String orderId)? onOpenQC;

  const KanbanBoardScreen({super.key, this.onOpenQC});

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  List<OrderModel> orders = [];
  bool isLoading = true;
  String selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);
    final data = await ApiService.getKanbanOrders(process: selectedFilter);
    setState(() {
      orders = data;
      isLoading = false;
    });
  }

  void _advanceOrder(OrderModel order) async {
    final stages = ['RECEIVED', 'WAITING_DEV', 'PROCESSING_DEV', 'PROCESSING_SCAN', 'READY_QC', 'COMPLETED'];
    final currentIndex = stages.indexOf(order.stage);
    if (currentIndex < stages.length - 1) {
      final nextStage = stages[currentIndex + 1];
      final success = await ApiService.updateOrderStage(order.orderId, nextStage);
      if (success) {
        setState(() => order.stage = nextStage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đơn ${order.orderId} đã chuyển sang công đoạn: $nextStage'),
              backgroundColor: LabColors.secondary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _showScanBarcodeDialog() {
    final nameCtrl = TextEditingController(text: 'Nguyễn Hải Đăng');
    final filmCtrl = TextEditingController(text: 'Kodak Portra 160 (135/36)');
    String process = 'C-41';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.barcode_scanner, color: LabColors.primary),
              SizedBox(width: 8),
              Text('Quét Mã Barcode Đơn Mới'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên khách hàng', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: filmCtrl,
                decoration: const InputDecoration(labelText: 'Loại film / Cuộn', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: process,
                decoration: const InputDecoration(labelText: 'Quy trình xử lý', border: OutlineInputBorder()),
                items: ['C-41', 'B&W', 'ECN-2', 'E-6']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setDState(() => process = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: LabColors.primaryContainer, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);
                await ApiService.scanBarcode(nameCtrl.text, filmCtrl.text, process);
                _loadOrders();
              },
              child: const Text('Nhận Cuộn Phim (+)'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final columns = [
      {'stage': 'RECEIVED', 'title': 'Tiếp nhận & Phân loại', 'color': LabColors.outline},
      {'stage': 'WAITING_DEV', 'title': 'Chờ tráng hóa chất', 'color': LabColors.primary},
      {'stage': 'PROCESSING_DEV', 'title': 'Đang trong máy tráng', 'color': LabColors.secondary},
      {'stage': 'PROCESSING_SCAN', 'title': 'Đang quét máy Scanner', 'color': LabColors.primaryContainer},
      {'stage': 'READY_QC', 'title': 'QC & Chuẩn bị trả file', 'color': LabColors.secondary},
    ];

    return Scaffold(
      backgroundColor: LabColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Toolbar & Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bảng Kanban Tiếp nhận & Vận hành',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: LabColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Text(
                            'CA SÁNG: 28 ĐƠN ĐANG CHẠY',
                            style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: LabColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: const Text(
                            'BỂ C-41: 37.8°C (CHUẨN)',
                            style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, fontWeight: FontWeight.bold, color: LabColors.onSecondaryContainer),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.sync, size: 16, color: LabColors.secondary),
                      label: const Text('Đồng bộ Noritsu V30'),
                      onPressed: _loadOrders,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LabColors.primaryContainer,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.barcode_scanner, size: 18),
                      label: const Text('Quét mã đơn mới (+)'),
                      onPressed: _showScanBarcodeDialog,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Telemetry Metric Row
            Row(
              children: [
                _buildMetricCard('TỔNG CUỘN HÔM NAY', '54', '+12 cuộn', LabColors.secondary),
                _buildMetricCard('BỂ C-41 NHIỆT ĐỘ', '37.8°C', 'Chuẩn ±0.1°', LabColors.primary),
                _buildMetricCard('HÓA CHẤT ECN-2', '14/25', 'cuộn đã chạy', LabColors.onSurfaceVariant),
                _buildMetricCard('SCANNER FRONTIER', 'SP-3000', 'ACTIVE', LabColors.secondary),
                _buildMetricCard('SLA NGUY CƠ TRỄ', '2 đơn', '< 3h hạn', LabColors.error),
                _buildMetricCard('QC HOÀN TẤT', '94.8%', 'Pass 1st try', LabColors.secondary),
              ],
            ),
            const SizedBox(height: 24),

            // Kanban Columns
            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: columns.map((col) {
                  final stageOrders = orders.where((o) => o.stage == col['stage']).toList();

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LabColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                col['title'] as String,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: LabColors.onSurface,
                                ),
                              ),
                              CircleAvatar(
                                radius: 10,
                                backgroundColor: LabColors.surfaceContainerHigh,
                                child: Text(
                                  '${stageOrders.length}',
                                  style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          ...stageOrders.map((order) => _buildOrderCard(order)),
                          if (stageOrders.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Không có đơn ở khâu này',
                                  style: TextStyle(fontSize: 11, color: LabColors.outline),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LabColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LabColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 9, color: LabColors.outline)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text(sub, style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 10, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: order.slaHoursLeft < 3 ? LabColors.errorContainer : LabColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${order.slaHoursLeft.toStringAsFixed(1)}h SLA',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Mono',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: order.slaHoursLeft < 3 ? LabColors.onErrorContainer : LabColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              order.customerName,
              style: const TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              '${order.rollCount}x ${order.filmType}',
              style: const TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 11, color: LabColors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '${order.processType} • ${order.scanner}',
              style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.primary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (order.stage == 'READY_QC')
                  InkWell(
                    onTap: () => widget.onOpenQC?.call(order.orderId),
                    child: const Text(
                      'Mở QC Scan →',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: LabColors.primary),
                    ),
                  )
                else
                  const SizedBox(),
                InkWell(
                  onTap: () => _advanceOrder(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: LabColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Tiếp theo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_forward_ios, size: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

