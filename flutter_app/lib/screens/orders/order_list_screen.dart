import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.inkMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Sẵn sàng'),
            Tab(text: 'Hoàn tất'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(orderProvider.orders),
          _buildOrderList(orderProvider.orders.where((o) => o.status == 'PROCESSING').toList()),
          _buildOrderList(orderProvider.orders.where((o) => o.status == 'READY_FOR_DOWNLOAD').toList()),
          _buildOrderList(orderProvider.orders.where((o) => o.status == 'COMPLETED').toList()),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.inkMuted),
            SizedBox(height: 12),
            Text('Chưa có đơn hàng trong mục này', style: TextStyle(color: AppColors.inkMuted, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<OrderProvider>().fetchOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(order.labName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      '${order.items.length} gói dịch vụ • ${order.items.map((i) => i.filmName).join(', ')}',
                      style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${order.totalAmount.toInt()}đ', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.ink)),
                        const Row(
                          children: [
                            Text('Xem tiến độ SLA', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                            Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.neutralBg;
    Color fg = AppColors.neutral;
    String label = status;

    switch (status) {
      case 'READY_FOR_DOWNLOAD':
        bg = AppColors.successBg;
        fg = AppColors.success;
        label = 'SẴN SÀNG TẢI';
        break;
      case 'PROCESSING':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        label = 'ĐANG XỬ LÝ';
        break;
      case 'COMPLETED':
        bg = Colors.blue.withOpacity(0.12);
        fg = Colors.blue.shade800;
        label = 'ĐÃ HOÀN TẤT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}

