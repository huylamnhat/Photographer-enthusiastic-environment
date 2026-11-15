import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/local_image_picker.dart';
import '../../models/order_model.dart';
import 'review_lab_screen.dart';
import '../archive/archive_gallery_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel? order;
  final String? orderId;

  const OrderDetailScreen({super.key, this.order, this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _liveOrder;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _liveOrder = widget.order;
    _fetchOrder();
  }

  Future<void> _fetchOrder() async {
    final targetId = widget.orderId ?? widget.order?.orderId;
    if (targetId == null || targetId.isEmpty) return;
    setState(() => _loading = true);
    final res = await ApiService().getOrderById(targetId);
    if (!mounted) return;
    setState(() {
      if (res != null) _liveOrder = res;
      _loading = false;
    });
  }

  int _activeStepIndex(OrderModel? o) {
    if (o == null) return 0;
    final col = o.kanbanColumn.toUpperCase();
    final st = o.status.toUpperCase();
    if (col == 'QUEUE' || st == 'RECEIVED' || st == 'PENDING_FILM') return 0; // 1. Tiếp nhận
    if (col == 'DEVELOPING') return 1; // 2. Vào Tank / Tráng
    if (col == 'DRYING' || col == 'QC' || st == 'QC_CHECK') return 2; // 3. Sấy khô
    if (col == 'SCANNING') return 3; // 4. Scan số hóa
    if (col == 'READY' || st == 'READY_FOR_DOWNLOAD' || st == 'COMPLETED') return 4; // 5. QC & Archive
    return 0;
  }

  String _stepBadgeText(int activeIdx) {
    switch (activeIdx) {
      case 0:
        return 'BƯỚC 1/5: 1. TIẾP NHẬN';
      case 1:
        return 'BƯỚC 2/5: 2. VÀO TANK / TRÁNG';
      case 2:
        return 'BƯỚC 3/5: 3. SẤY KHÔ';
      case 3:
        return 'BƯỚC 4/5: 4. SCAN SỐ HÓA';
      default:
        return 'BƯỚC 5/5: 5. QC & ARCHIVE';
    }
  }

  void _showDisputeDialog(String displayId, double totalAmount) {
    final issueCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Gửi Khiếu nại / Hỗ trợ Đơn #$displayId', style: AppTypography.cardTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Khiếu nại sẽ được gửi đồng thời tới Cổng Tiệm Film Lab và Bảng Quản trị Admin để đối soát.',
              style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 12),
            Text('VẤN ĐỀ GẶP PHẢI', style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            TextField(
              controller: issueCtrl,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Ví dụ: Ảnh scan bị xước dải film / lệch màu...',
              ),
            ),
            const SizedBox(height: 12),
            Text('MÔ TẢ CHI TIẾT CHO LAB & ADMIN', style: AppTypography.labelCaps),
            const SizedBox(height: 4),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Nhập mô tả chi tiết vấn đề bạn gặp phải...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final issue = issueCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (issue.isEmpty || desc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.danger,
                    content: Text('Vui lòng nhập vấn đề gặp phải và mô tả chi tiết!'),
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              final ok = await ApiService().createOrderDispute(displayId, {
                'issue_type': issue,
                'description': desc,
                'amount_requested': totalAmount > 0 ? totalAmount : 70000,
              });
              await _fetchOrder();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: ok ? AppColors.secondary : AppColors.danger,
                  content: Text(
                    ok
                        ? 'Đã gửi khiếu nại đơn #$displayId tới Cổng Tiệm Lab và Admin Tổng Sàn!'
                        : 'Không thể gửi khiếu nại, vui lòng thử lại.',
                  ),
                ),
              );
            },
            child: const Text('Gửi Khiếu nại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = _liveOrder;
    final displayId = o?.orderId ?? (widget.orderId ?? 'ORD-2026-8801');
    final labName = o?.labName ?? 'CropLab Hà Nội';
    final filmName = o?.items.isNotEmpty == true
        ? '${o!.items.first.quantity} cuộn ${o.items.first.filmName}'
        : '02 cuộn Kodak ColorPlus 200 (135/36)';
    final processName = o?.items.isNotEmpty == true
        ? o!.items.first.name
        : 'Quy trình: C-41 Tiêu chuẩn • Máy Noritsu HS-1800';
    final totalAmount = o?.totalAmount ?? 140000;
    final price =
        '${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
    final activeIdx = _activeStepIndex(o);

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
            Text('CHI TIẾT ĐƠN #$displayId', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ tiến độ từ Lab',
            icon: _loading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            onPressed: _fetchOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lab & Status Header Card
            Container(
              padding: const EdgeInsets.all(16),
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
                      Row(
                        children: [
                          const Icon(Icons.storefront, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(labName, style: AppTypography.cardTitle),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (activeIdx == 4 ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _stepBadgeText(activeIdx),
                          style: AppTypography.labelCaps.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: activeIdx == 4 ? AppColors.secondary : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(filmName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    processName,
                    style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.outline),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TỔNG THANH TOÁN (VÍ MINILAB)', style: AppTypography.labelCaps),
                      Text(
                        price,
                        style: AppTypography.metric.copyWith(fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Compensation / Dispute Response Card (Hiển thị khi Lab tặng cuộn film đền bù hoặc phản hồi khiếu nại)
            if ((o?.compensationNote != null && o!.compensationNote!.isNotEmpty) ||
                (o?.disputeId != null && o!.disputeId!.isNotEmpty) ||
                (o?.disputeMessages.isNotEmpty == true)) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.card_giftcard, size: 18, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'THÔNG BÁO ĐỀN BÙ & PHẢN HỒI KHIẾU NẠI',
                              style: AppTypography.labelCaps.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            o?.disputeStatus == 'COMPENSATED'
                                ? 'ĐÃ ĐỀN BÙ CUỘN FILM'
                                : (o?.disputeStatus == 'REFUNDED'
                                    ? 'ĐÃ HOÀN TIỀN'
                                    : (o?.disputeStatus ?? 'ĐANG XỬ LÝ')),
                            style: AppTypography.labelCaps.copyWith(
                              fontSize: 9,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (o?.compensationNote != null && o!.compensationNote!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        o.compensationNote!,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                    if (o?.disputeMessages.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: AppColors.outline),
                      const SizedBox(height: 8),
                      ...o!.disputeMessages.map((m) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${m['sender'] ?? 'Hệ thống'}: ${m['text'] ?? ''} (${m['time'] ?? ''})',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Google Drive Link Card & Scan Photos of this specific Order
            if ((o?.driveLink != null && o!.driveLink!.isNotEmpty) ||
                (o?.driveLinkHistory.isNotEmpty == true)) ...[
              Builder(
                builder: (context) {
                  final links = (o!.driveLinkHistory.isNotEmpty)
                      ? o.driveLinkHistory
                      : [if (o.driveLink != null && o.driveLink!.isNotEmpty) o.driveLink!];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...links.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final dLink = entry.value;
                        final isLatest = idx == 0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isLatest ? const Color(0xFFE3F2FD) : AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLatest
                                  ? const Color(0xFF1565C0).withValues(alpha: 0.45)
                                  : AppColors.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.cloud_done_outlined,
                                    size: 18,
                                    color: isLatest ? const Color(0xFF1565C0) : AppColors.inkMuted,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isLatest
                                          ? 'LINK GOOGLE DRIVE MỚI NHẤT CỦA ĐƠN #$displayId'
                                          : 'LINK GOOGLE DRIVE CŨ #${links.length - idx} CỦA ĐƠN #$displayId (GIỮ NGUYÊN)',
                                      style: AppTypography.labelCaps.copyWith(
                                        color: isLatest ? const Color(0xFF1565C0) : AppColors.inkMuted,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              SelectableText(
                                sanitizeGoogleDriveUrl(dLink),
                                style: AppTypography.dataMono.copyWith(
                                  fontSize: 11,
                                  color: isLatest ? const Color(0xFF0D47A1) : AppColors.ink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      openUrlInNewTab(dLink);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1565C0),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                    icon: const Icon(Icons.open_in_new, size: 14),
                                    label: const Text('Mở Google Drive', style: TextStyle(fontSize: 11)),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final clean = await copyTextSafe(dLink);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Đã sao chép link Google Drive: $clean')),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 14),
                                    label: const Text('Sao chép Link', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      if (o.scanPhotos.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ẢNH SCAN CỦA ĐƠN #$displayId (${o.scanPhotos.length} TẤM - 1080x720)',
                          style: AppTypography.sectionHeading.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: o.scanPhotos.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.35,
                          ),
                          itemBuilder: (ctx, idx) {
                            final sp = o.scanPhotos[idx];
                            final imgUrl = (sp['image_url'] ?? '').toString();
                            final title = (sp['title'] ?? 'Ảnh #${idx + 1}').toString();
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.outline),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  MockTestAssets.image(imgUrl, fit: BoxFit.cover),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      color: Colors.black.withValues(alpha: 0.65),
                                      child: Text(
                                        title,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ],

            // Live Timeline SLA Stepper
            Text('TIẾN ĐỘ TRÁNG SCAN & NHẬT KÝ CA TRỰC (LIVE KANBAN)', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  _buildTimelineStep(
                    stepNumber: '1',
                    title: '1. Tiếp nhận',
                    subtitle: 'Tiếp nhận cuộn phim tại Lab, phân loại hộp chống ẩm & gán mã QR quản lý.',
                    time: activeIdx == 0 ? 'Đang ở bước này' : 'Hoàn tất',
                    isDone: activeIdx > 0,
                    isActive: activeIdx == 0,
                  ),
                  _buildTimelineStep(
                    stepNumber: '2',
                    title: '2. Vào Tank / Tráng',
                    subtitle: 'Vào Tank hóa chất Jobo ATL-2 tráng tự động kiểm soát nhiệt độ chuẩn 37.8°C.',
                    time: activeIdx == 1 ? 'Đang thực hiện' : (activeIdx > 1 ? 'Hoàn tất' : 'Chờ xử lý'),
                    isDone: activeIdx > 1,
                    isActive: activeIdx == 1,
                  ),
                  _buildTimelineStep(
                    stepNumber: '3',
                    title: '3. Sấy khô',
                    subtitle: 'Tủ sấy khí sạch kiểm soát độ ẩm 42%, cân bằng phẳng giữ màng phim không bụi.',
                    time: activeIdx == 2 ? 'Đang thực hiện' : (activeIdx > 2 ? 'Hoàn tất' : 'Chờ xử lý'),
                    isDone: activeIdx > 2,
                    isActive: activeIdx == 2,
                  ),
                  _buildTimelineStep(
                    stepNumber: '4',
                    title: '4. Scan số hóa',
                    subtitle: 'Quét quang học độ phân giải cao trên hệ máy Noritsu HS-1800 / Fuji Frontier.',
                    time: activeIdx == 3 ? 'Đang thực hiện' : (activeIdx > 3 ? 'Hoàn tất' : 'Chờ xử lý'),
                    isDone: activeIdx > 3,
                    isActive: activeIdx == 3,
                  ),
                  _buildTimelineStep(
                    stepNumber: '5',
                    title: '5. QC & Archive',
                    subtitle: 'Kiểm định chất lượng 36 khung hình & đồng bộ file lên Kho ảnh Digital Archive.',
                    time: activeIdx == 4 ? 'Đã sẵn sàng tải!' : 'Chờ hoàn tất',
                    isDone: activeIdx == 4,
                    isActive: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions Block
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArchiveGalleryScreen(initialOrderId: displayId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 16),
                  SizedBox(width: 8),
                  Text('Vào Kho Lưu Trữ Digital Archive', style: AppTypography.button),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewLabScreen(
                            labId: o?.labId ?? 'lab-001',
                            orderId: displayId,
                            labName: labName,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_outline, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Đánh giá Lab', style: AppTypography.button.copyWith(fontSize: 11, color: AppColors.ink)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDisputeDialog(displayId, totalAmount),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.report_problem_outlined, size: 14, color: AppColors.danger),
                        const SizedBox(width: 6),
                        Text('Khiếu nại / Hỗ trợ', style: AppTypography.button.copyWith(fontSize: 11, color: AppColors.ink)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String stepNumber,
    required String title,
    required String subtitle,
    required String time,
    bool isDone = false,
    bool isActive = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? AppColors.secondary : (isActive ? AppColors.primary : AppColors.surfaceSunken),
                shape: BoxShape.circle,
                border: Border.all(color: isActive ? AppColors.primary : AppColors.outline),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : Text(
                        stepNumber,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : AppColors.inkMuted,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone ? AppColors.secondary : AppColors.outline,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 13,
                        color: isActive ? AppColors.primary : (isDone ? AppColors.ink : AppColors.inkMuted),
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: AppTypography.dataMono.copyWith(
                      fontSize: 10,
                      color: isActive ? AppColors.primary : AppColors.inkMuted,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
