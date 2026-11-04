import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/web_api_service.dart';

class LabKanbanTab extends StatefulWidget {
  const LabKanbanTab({super.key});

  @override
  State<LabKanbanTab> createState() => _LabKanbanTabState();
}

class _LabKanbanTabState extends State<LabKanbanTab> {
  Map<String, dynamic> _kanban = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKanban();
  }

  void _loadKanban() async {
    final data = await WebApiService().getLabKanban();
    if (mounted) {
      setState(() {
        _kanban = data;
        _isLoading = false;
      });
    }
  }

  void _moveStep(String orderId, String targetColumn) async {
    await WebApiService().updateKanbanStep(orderId, targetColumn);
    _loadKanban();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đơn $orderId đã chuyển sang công đoạn: $targetColumn'), backgroundColor: AppColors.secondary),
      );
    }
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
                  Text('Bảng Kanban Vận Hành & Tiến Độ Xử Lý Film (SLA)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  SizedBox(height: 4),
                  Text('Theo dõi và chuyển giao từng công đoạn: Tiếp nhận ➔ Tráng hóa chất ➔ Scan máy ➔ Kiểm định QC ➔ Hoàn tất',
                      style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Đồng bộ tiến độ'),
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadKanban();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5 Kanban Columns Layout
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKanbanColumn('1. CHỜ TIẾP NHẬN', Icons.inbox, AppColors.neutral, _kanban['QUEUE'] ?? [], 'QUEUE'),
                const SizedBox(width: 14),
                _buildKanbanColumn('2. ĐANG TRÁNG', Icons.science, AppColors.primary, _kanban['DEVELOPING'] ?? [], 'DEVELOPING'),
                const SizedBox(width: 14),
                _buildKanbanColumn('3. ĐANG SCAN', Icons.scanner, Colors.blueGrey, _kanban['SCANNING'] ?? [], 'SCANNING'),
                const SizedBox(width: 14),
                _buildKanbanColumn('4. KIỂM ĐỊNH QC', Icons.find_in_page, Colors.indigo, _kanban['QC'] ?? [], 'QC'),
                const SizedBox(width: 14),
                _buildKanbanColumn('5. SẴN SÀNG TẢI', Icons.check_circle, AppColors.success, _kanban['READY'] ?? [], 'READY'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String title, IconData icon, Color headerColor, List<dynamic> items, String colKey) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: headerColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: headerColor, letterSpacing: 0.5),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: headerColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('${items.length}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: headerColor)),
                )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text('Trống', style: TextStyle(color: AppColors.inkMuted.withValues(alpha: 0.5), fontSize: 12)),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final order = items[idx];
                        return _buildKanbanCard(order, colKey);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanCard(dynamic order, String currentCol) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['order_id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
              Text('${order['total_amount']}đ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(order['customer_name'] ?? 'Khách hàng', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 2),
          Text('Phim: ${order['items']?[0]?['film_name'] ?? 'Kodak 135'}', style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
          const SizedBox(height: 8),

          // Next action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (currentCol == 'QUEUE')
                _buildActionBtn('Vào tráng ➔', () => _moveStep(order['order_id'], 'DEVELOPING')),
              if (currentCol == 'DEVELOPING')
                _buildActionBtn('Sang scan ➔', () => _moveStep(order['order_id'], 'SCANNING')),
              if (currentCol == 'SCANNING')
                _buildActionBtn('Chuyển QC ➔', () => _moveStep(order['order_id'], 'QC')),
              if (currentCol == 'QC')
                _buildActionBtn('Hoàn tất ➔', () => _moveStep(order['order_id'], 'READY')),
              if (currentCol == 'READY')
                const Icon(Icons.done_all, size: 16, color: AppColors.success),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

