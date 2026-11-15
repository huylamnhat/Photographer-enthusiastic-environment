import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/local_image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../models/lab_model.dart';
import '../../models/community_model.dart';
import 'lab_search_screen.dart';
import 'lab_detail_screen.dart';
import 'create_order_screen.dart';
import '../orders/order_detail_screen.dart';
import '../orders/order_list_screen.dart';
import '../community/events_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OrderModel? _latestOrder;
  List<OrderModel> _allOrders = [];
  List<LabModel> _labs = [];
  List<EventModel> _events = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _loadingOrder = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadLatestOrder();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadLatestOrder(silent: true),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadLatestOrder(silent: true);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatVnd(num amount) {
    final str = amount.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buf.write('.');
      }
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  Future<void> _loadLatestOrder({bool silent = false}) async {
    if (!silent) {
      setState(() => _loadingOrder = true);
    }
    final results = await Future.wait([
      ApiService().getOrders(),
      ApiService().getLabs(),
      ApiService().getEvents(),
      ApiService().getNotifications(),
    ]);
    if (!mounted) return;
    final orders = results[0] as List<OrderModel>;
    final labs = results[1] as List<LabModel>;
    final events = results[2] as List<EventModel>;
    final notifications = results[3] as List<Map<String, dynamic>>;
    setState(() {
      _allOrders = orders;
      if (orders.isNotEmpty) {
        _latestOrder = orders.first;
      }
      if (labs.isNotEmpty) {
        _labs = labs;
      }
      if (events.isNotEmpty) {
        _events = events;
      }
      _notifications = notifications;
      _loadingOrder = false;
    });
  }

  void _showNotificationsModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Thông báo Đền bù & Tiến độ (${_notifications.length})',
                style: AppTypography.cardTitle.copyWith(fontSize: 14),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: _notifications.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Hiện chưa có thông báo mới nào.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _notifications.map((n) {
                      final title = (n['title'] ?? 'Thông báo hệ thống').toString();
                      final msg = (n['message'] ?? '').toString();
                      final ordId = (n['order_id'] ?? '').toString();
                      final driveLink = (n['drive_link'] ?? '').toString();
                      final isComp = n['type'] == 'COMPENSATION' || n['type'] == 'REFUND';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isComp
                              ? AppColors.secondary.withValues(alpha: 0.08)
                              : AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isComp ? AppColors.secondary : AppColors.outline,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 12,
                                color: isComp ? AppColors.secondary : AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(msg, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                            if (driveLink.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              SelectableText(
                                sanitizeGoogleDriveUrl(driveLink),
                                style: AppTypography.dataMono.copyWith(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 4,
                              children: [
                                if (driveLink.isNotEmpty) ...[
                                  TextButton.icon(
                                    onPressed: () {
                                      openUrlInNewTab(driveLink);
                                    },
                                    icon: const Icon(Icons.add_to_drive, size: 13),
                                    label: const Text('Mở Google Drive', style: TextStyle(fontSize: 11)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final clean = await copyTextSafe(driveLink);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Đã sao chép link Google Drive: $clean')),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 13),
                                    label: const Text('Copy Link Drive', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                                if (ordId.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      final targetOrd = _allOrders
                                          .where((o) => o.orderId == ordId)
                                          .firstOrNull;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OrderDetailScreen(
                                            order: targetOrd,
                                            orderId: ordId,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.open_in_new, size: 13),
                                    label: Text('Xem đơn #$ordId', style: const TextStyle(fontSize: 11)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  int _stepIdx(OrderModel? o) {
    if (o == null) return 1;
    final col = o.kanbanColumn.toUpperCase();
    final st = o.status.toUpperCase();
    if (col == 'QUEUE' || st == 'RECEIVED' || st == 'PENDING_FILM') return 0; // 1. Tiếp nhận
    if (col == 'DEVELOPING') return 1; // 2. Vào Tank / Tráng
    if (col == 'DRYING' || col == 'QC' || st == 'QC_CHECK') return 2; // 3. Sấy khô
    if (col == 'SCANNING') return 3; // 4. Scan số hóa
    if (col == 'READY' || st == 'READY_FOR_DOWNLOAD' || st == 'COMPLETED') return 4; // 5. QC & Archive
    return 1;
  }

  String _stepDetailLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Bước 1/5: 1. Tiếp nhận cuộn phim tại Lab';
      case 1:
        return 'Bước 2/5: 2. Vào Tank / Tráng hóa chất (37.8°C)';
      case 2:
        return 'Bước 3/5: 3. Sấy khô & Cân bằng phẳng';
      case 3:
        return 'Bước 4/5: 4. Scan số hóa Noritsu / Frontier';
      default:
        return 'Bước 5/5: 5. QC & Archive (Sẵn sàng tải)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;
    final userFullName = (currentUser?.fullName != null && currentUser!.fullName.isNotEmpty)
        ? currentUser.fullName
        : 'Khách hàng MiniLab';
    final userBadgeCode = (currentUser?.userId != null && currentUser!.userId.isNotEmpty)
        ? currentUser.userId.toUpperCase()
        : 'VN-882';
    final String userAvatar = (currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty)
        ? currentUser.avatarUrl!
        : MockTestAssets.avatarCustomer;
    final String userCity = (currentUser?.address != null && currentUser!.address!.isNotEmpty)
        ? currentUser.address!
        : 'TP. Hồ Chí Minh';

    final activeStep = _stepIdx(_latestOrder);
    final displayOrderId = _latestOrder?.orderId ?? 'ORD-2026-8801';
    final displayLabName = _latestOrder?.labName ?? 'CropLab Hà Nội';
    final displayFilm = (_latestOrder != null && _latestOrder!.items.isNotEmpty)
        ? '${_latestOrder!.items.first.quantity.toString().padLeft(2, '0')} cuộn ${_latestOrder!.items.first.filmName}'
        : '02 cuộn Kodak Portra 400 (135/36)';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outline, height: 1),
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'KHÁM PHÁ',
              style: AppTypography.cardTitle.copyWith(
                letterSpacing: 1.0,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ tiến độ & thông báo từ Lab',
            icon: _loadingOrder
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            onPressed: _loadLatestOrder,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Xem thông báo Đền bù & Tiến độ',
                icon: Icon(
                  _notifications.isNotEmpty ? Icons.notifications_active : Icons.notifications_none,
                  size: 20,
                  color: _notifications.isNotEmpty ? AppColors.primary : AppColors.ink,
                ),
                onPressed: _showNotificationsModal,
              ),
              if (_notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_notifications.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 32,
                height: 32,
                child: MockTestAssets.image(userAvatar, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome & Location Context (Stitch APP-CUS-04)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THẺ THÀNH VIÊN #$userBadgeCode',
                        style: AppTypography.labelCaps.copyWith(
                          letterSpacing: 1.2,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Xin chào, $userFullName',
                        style: AppTypography.pageTitle.copyWith(fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        userCity,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Compensation / Dispute Notification Banner (Hiển thị ngay khi Lab bấm tặng cuộn film đền bù)
            if (_notifications.isNotEmpty) ...[
              InkWell(
                onTap: _showNotificationsModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, color: AppColors.secondary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (_notifications.first['title'] ?? 'Thông báo mới từ Lab').toString(),
                              style: AppTypography.cardTitle.copyWith(fontSize: 12, color: AppColors.secondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (_notifications.first['message'] ?? '').toString(),
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, size: 18, color: AppColors.secondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Search Bar with ⌘K
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LabSearchScreen()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: AppColors.inkMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tìm tiệm tráng, dòng film, sự kiện...',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text(
                        '⌘ K',
                        style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.inkMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Realtime Order Status Card (Stitch APP-CUS-04)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ĐƠN HÀNG ĐANG XỬ LÝ',
                            style: AppTypography.labelCaps.copyWith(
                              letterSpacing: 1.0,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(
                          '#$displayOrderId',
                          style: AppTypography.dataMono.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayLabName,
                            style: AppTypography.cardTitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayFilm,
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('TIẾN ĐỘ KANBAN LAB', style: AppTypography.labelCaps.copyWith(fontSize: 9)),
                          const SizedBox(height: 2),
                          Text(
                            activeStep == 4 ? 'Hoàn tất 5/5' : 'Bước ${activeStep + 1}/5',
                            style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 5-step synchronized Kanban timeline
                  Column(
                    children: [
                      Row(
                        children: List.generate(5, (idx) {
                          final isDone = idx < activeStep || activeStep == 4;
                          final isCurrent = idx == activeStep && activeStep < 4;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: idx < 4 ? 4 : 0),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppColors.secondary
                                      : (isCurrent ? AppColors.primary : AppColors.outline),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i < 5; i++)
                            Text(
                              const ['1.Tiếp nhận', '2.Vào Tank', '3.Sấy khô', '4.Scan số', '5.QC/Archive'][i],
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 8.5,
                                fontWeight: i == activeStep ? FontWeight.bold : FontWeight.normal,
                                color: i < activeStep || activeStep == 4
                                    ? AppColors.secondary
                                    : (i == activeStep ? AppColors.primary : AppColors.inkMuted),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.outline),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              activeStep == 4 ? Icons.check_circle : Icons.sync,
                              size: 14,
                              color: activeStep == 4 ? AppColors.secondary : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _stepDetailLabel(activeStep),
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.dataMono.copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(
                                order: _latestOrder,
                                orderId: displayOrderId,
                              ),
                            ),
                          );
                          _loadLatestOrder();
                        },
                        child: Row(
                          children: [
                            Text(
                              'Xem chi tiết',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Disputed Orders Section (Đơn hàng đã khiếu nại)
            _buildDisputedOrdersSection(),
            const SizedBox(height: 24),

            // Quick Technical Services Directory (2x2 grid)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DỊCH VỤ CHUẨN HÓA',
                  style: AppTypography.sectionHeading.copyWith(fontSize: 14),
                ),
                Text(
                  'Quy trình Lab',
                  style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
              children: [
                _buildServiceCard(
                  context,
                  title: 'Tráng C-41',
                  subtitle: 'Màu tiêu chuẩn',
                  icon: Icons.palette_outlined,
                  color: AppColors.primary,
                ),
                _buildServiceCard(
                  context,
                  title: 'Tráng B&W',
                  subtitle: 'Thủ công tay',
                  icon: Icons.contrast,
                  color: AppColors.ink,
                ),
                _buildServiceCard(
                  context,
                  title: 'Tráng ECN-2',
                  subtitle: 'Tẩy than điện ảnh',
                  icon: Icons.movie_filter_outlined,
                  color: AppColors.primary,
                ),
                _buildServiceCard(
                  context,
                  title: 'Quét TIFF',
                  subtitle: 'Frontier / Noritsu',
                  icon: Icons.scanner_outlined,
                  color: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Featured Film Labs Ledger List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'FILM LAB GẦN BẠN',
                      style: AppTypography.sectionHeading.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Text('Sài Gòn', style: AppTypography.labelCaps.copyWith(fontSize: 9)),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LabSearchScreen()),
                    );
                  },
                  child: Text(
                    'Tất cả (${_labs.isNotEmpty ? _labs.length : 5})',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_labs.isNotEmpty)
              ..._labs.take(3).map(
                (lab) {
                  final priceLabel = lab.packages.isNotEmpty
                      ? _formatVnd(lab.packages.map((p) => p.price).reduce((a, b) => a < b ? a : b))
                      : lab.priceRange.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildLabCard(
                      context,
                      lab: lab,
                      labId: lab.labId,
                      name: lab.name,
                      distance: '${lab.city} • ${lab.address}',
                      rating: lab.rating.toStringAsFixed(1),
                      reviewCount: '${lab.reviewCount}',
                      sla: 'SLA: ${lab.turnaroundHours}h',
                      machine: lab.scannerModels.isNotEmpty ? lab.scannerModels.first : 'Noritsu HS-1800',
                      price: priceLabel,
                      verified: lab.isVerified,
                    ),
                  );
                },
              )
            else ...[
              _buildLabCard(
                context,
                labId: 'lab-001',
                name: 'CropLab Hà Nội',
                distance: 'Tây Hồ, Hà Nội • Số 10 ngõ 12 Đặng Thai Mai',
                rating: '4.9',
                reviewCount: '328',
                sla: 'SLA: 12h',
                machine: 'Noritsu HS-1800',
                price: '50.000đ',
                verified: true,
              ),
              const SizedBox(height: 8),
              _buildLabCard(
                context,
                labId: 'lab-002',
                name: 'LLab Film Sài Gòn',
                distance: 'Bình Thạnh, TP.HCM • 40/2 Phan Văn Trị',
                rating: '4.8',
                reviewCount: '512',
                sla: 'SLA: 8h',
                machine: 'Fuji Frontier SP-3000',
                price: '60.000đ',
                verified: true,
              ),
              const SizedBox(height: 8),
              _buildLabCard(
                context,
                labId: 'lab-003',
                name: 'Nadar Darkroom & Lab',
                distance: 'Hoàn Kiếm, Hà Nội • 15 Tràng Tiền',
                rating: '5.0',
                reviewCount: '145',
                sla: 'SLA: 24h',
                machine: 'Hasselblad Flextight X5',
                price: '70.000đ',
                tag: 'B&W SPEC',
                verified: true,
              ),
            ],
            const SizedBox(height: 24),

            // Community Event Warm Paper Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_activity_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'CỘNG ĐỒNG ANALOG',
                            style: AppTypography.labelCaps.copyWith(
                              letterSpacing: 1.0,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Sắp diễn ra',
                        style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _events.isNotEmpty
                                  ? _events.first.title
                                  : 'Photowalk Mùa Hoa Sưa - Dạo Phố Cùng Máy Cơ',
                              style: AppTypography.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _events.isNotEmpty
                                  ? _events.first.description
                                  : 'Buổi giao lưu chụp ảnh đường phố đầu xuân, hướng dẫn đo sáng bằng mắt (Sunny 16) và bố cục đời thường.',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'THÁNG 3',
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 9,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '15',
                              style: AppTypography.metric.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _events.isNotEmpty
                            ? '${_events.first.registeredCount}/${_events.first.maxSlots} người tham gia'
                            : '3/30 người tham gia',
                        style: AppTypography.dataMono.copyWith(fontSize: 11, color: AppColors.inkMuted),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EventsScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: Text('Đăng ký', style: AppTypography.button.copyWith(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Micro Footer
            Center(
              child: Text(
                'FILM PROCESSING INDEX • CẬP NHẬT LÚC 14:30',
                style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LabSearchScreen()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.outline),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabCard(
    BuildContext context, {
    LabModel? lab,
    String? labId,
    required String name,
    required String distance,
    required String rating,
    required String reviewCount,
    required String sla,
    required String machine,
    required String price,
    String? tag,
    bool verified = false,
  }) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabDetailScreen(
              lab: lab,
              labId: lab?.labId ?? labId ?? name.toLowerCase().replaceAll(' ', '-'),
            ),
          ),
        );
        _loadLatestOrder(silent: true);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: AppTypography.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (verified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: AppColors.secondary),
                      ],
                      if (tag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(
                            tag,
                            style: AppTypography.dataMono.copyWith(fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        ' ($reviewCount)',
                        style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(distance, style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(sla, style: AppTypography.dataMono.copyWith(fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(machine, style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('Từ ', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                    Text(
                      price,
                      style: AppTypography.dataMono.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (lab != null && lab.packages.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'GÓI DỊCH VỤ (${lab.packages.length})',
                style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: lab.packages.map((pkg) {
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateOrderScreen(
                            lab: lab,
                            initialLabId: lab.labId,
                            initialPackageId: pkg.packageId,
                          ),
                        ),
                      );
                      _loadLatestOrder(silent: true);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withAlpha(70)),
                      ),
                      child: Text(
                        '${pkg.name} (${_formatVnd(pkg.price)})',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _disputeStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'NEGOTIATING':
      case 'IN_NEGOTIATION':
        return 'ĐANG THƯƠNG LƯỢNG';
      case 'COMPENSATED':
        return 'ĐÃ ĐỀN BÙ CUỘN FILM';
      case 'REFUNDED':
        return 'ĐÃ HOÀN TIỀN';
      case 'ESCALATED':
        return 'CHỜ ADMIN PHÂN XỬ';
      case 'RESOLVED':
        return 'ĐÃ GIẢI QUYẾT';
      default:
        return 'ĐANG KHIẾU NẠI';
    }
  }

  Color _disputeStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPENSATED':
      case 'REFUNDED':
      case 'RESOLVED':
        return AppColors.secondary;
      case 'ESCALATED':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Widget _buildDisputedOrdersSection() {
    final disputedOrders = _allOrders.where((o) => o.hasDispute).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.gavel_outlined, size: 16, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'ĐƠN HÀNG ĐÃ KHIẾU NẠI (${disputedOrders.length})',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sectionHeading.copyWith(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderListScreen(initialTab: 4),
                  ),
                );
                _loadLatestOrder(silent: true);
              },
              child: Row(
                children: [
                  Text(
                    'Xem mục Đã khiếu nại',
                    style: AppTypography.labelCaps.copyWith(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_ios, size: 9, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (disputedOrders.isEmpty)
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrderListScreen(initialTab: 4),
                ),
              );
              _loadLatestOrder(silent: true);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.inkMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hiện chưa có đơn hàng nào đang khiếu nại.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: AppColors.inkMuted),
                ],
              ),
            ),
          )
        else
          ...disputedOrders.map((order) {
            final status = order.disputeStatus ?? '';
            final badgeColor = _disputeStatusColor(status);
            final badgeText = _disputeStatusLabel(status);
            String latestNote = order.compensationNote ?? '';
            if (latestNote.isEmpty && order.disputeMessages.isNotEmpty) {
              final lastMsg = order.disputeMessages.last;
              final sender = (lastMsg['sender'] ?? 'Hệ thống').toString();
              final text = (lastMsg['text'] ?? '').toString();
              if (text.isNotEmpty) {
                latestNote = '$sender: $text';
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(
                        order: order,
                        orderId: order.orderId,
                      ),
                    ),
                  );
                  _loadLatestOrder(silent: true);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${order.orderId}',
                            style: AppTypography.dataMono.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.labName,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.cardTitle.copyWith(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText,
                              style: AppTypography.labelCaps.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((order.disputeIssue ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${(order.disputeId ?? '').isNotEmpty ? '[${order.disputeId}] ' : ''}${order.disputeIssue}',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                      if (latestNote.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            latestNote,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
