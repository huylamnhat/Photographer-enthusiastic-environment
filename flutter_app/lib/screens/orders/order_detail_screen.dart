import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/order_model.dart';
import '../../core/services/api_service.dart';
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
  OrderModel? _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _fetchLiveDetail();
  }

  void _fetchLiveDetail() async {
    final targetId = _order?.orderId ?? widget.orderId;
    if (targetId == null || targetId.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final fetched = await ApiService().getOrderById(targetId);
      if (fetched != null && mounted) {
        setState(() {
          _order = fetched;
        });
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayId = _order?.orderId ?? (widget.orderId ?? 'ORD-9281');
    final labName = _order?.labName ?? 'LLab Sài Gòn';
    final filmName = _order?.items.isNotEmpty == true
        ? _order!.items.first.filmName
        : '02 cuộn Kodak ColorPlus 200 (135/36)';
    final price = _order != null ? '${_order!.totalAmount.toInt()}đ' : '140.000đ';
    final status = _order?.status ?? 'PROCESSING';

    String currentStepBadge = 'BƯỚC 3/5: SẤY KHÔ';
    if (_order != null && _order!.timeline.isNotEmpty) {
      final activeStep = _order!.timeline.lastWhere(
        (s) => s.status == 'IN_PROGRESS' || s.status == 'COMPLETED',
        orElse: () => _order!.timeline.first,
      );
      currentStepBadge = 'BƯỚC ${activeStep.step}/${_order!.timeline.length}: ${activeStep.name.toUpperCase()}';
    }

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
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.sync, size: 20, color: AppColors.primary),
            tooltip: 'Đồng bộ tiến độ từ Film Lab',
            onPressed: _isLoading ? null : _fetchLiveDetail,
          ),
          const SizedBox(width: 8),
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
                          color: status == 'COMPLETED' || status == 'READY_FOR_DOWNLOAD'
                              ? AppColors.secondary.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          currentStepBadge,
                          style: AppTypography.labelCaps.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: status == 'COMPLETED' || status == 'READY_FOR_DOWNLOAD'
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(filmName, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Quy trình: C-41 Tiêu chuẩn • Máy Noritsu HS-1800',
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
            const SizedBox(height: 20),

            // Live Timeline SLA Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TIẾN ĐỘ TRÁNG SCAN & NHẬT KÝ CA TRỰC', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
                if (_order != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LIVE KẾT NỐI LAB', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: _buildTimelineWidgetList(),
              ),
            ),
            const SizedBox(height: 20),

            // Actions Block
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArchiveGalleryScreen()),
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
                          builder: (_) => ReviewLabScreen(orderId: displayId, labName: labName),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã kết nối kênh đối soát với Lab và Admin.')),
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
                        const Icon(Icons.support_agent, size: 14, color: AppColors.inkMuted),
                        const SizedBox(width: 6),
                        Text('Hỗ trợ đơn', style: AppTypography.button.copyWith(fontSize: 11, color: AppColors.ink)),
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

  List<Widget> _buildTimelineWidgetList() {
    if (_order != null && _order!.timeline.isNotEmpty) {
      final list = <Widget>[];
      final steps = _order!.timeline;
      for (int i = 0; i < steps.length; i++) {
        final st = steps[i];
        final isDone = st.status == 'COMPLETED';
        final isActive = st.status == 'IN_PROGRESS';
        final isLast = i == steps.length - 1;

        list.add(_buildTimelineStep(
          stepNumber: st.step.toString(),
          title: st.name,
          subtitle: st.note.isNotEmpty ? st.note : (isDone ? 'Đã hoàn thành' : (isActive ? 'Đang xử lý tại Lab' : 'Chờ xử lý')),
          time: st.time.isNotEmpty ? st.time : (isActive ? 'Hiện tại' : 'Chờ'),
          isDone: isDone,
          isActive: isActive,
          isLast: isLast,
        ));
      }
      return list;
    }

    // Default static mock timeline
    return [
      _buildTimelineStep(
        stepNumber: '1',
        title: 'Tiếp nhận & Vào mã QR',
        subtitle: 'Đã phân loại hộp chống ẩm, gán mã vạch quản lý cuộn phim.',
        time: '09:15',
        isDone: true,
      ),
      _buildTimelineStep(
        stepNumber: '2',
        title: 'Vào Tank hóa chất Jobo ATL-2',
        subtitle: 'Tráng C-41 tự động nhiệt độ 37.8°C (pH 10.05). Hóa chất Kodak Flexicolor.',
        time: '10:45',
        isDone: true,
      ),
      _buildTimelineStep(
        stepNumber: '3',
        title: 'Sấy khô & Cân bằng phẳng',
        subtitle: 'Tủ sấy khí sạch kiểm soát độ ẩm 42%. Giữ màng phim không bụi.',
        time: 'Hiện tại',
        isActive: true,
      ),
      _buildTimelineStep(
        stepNumber: '4',
        title: 'Quét quang học Noritsu HS-1800',
        subtitle: 'Scan độ phân giải cao 2000x3000px, cân màu tone ấm chuẩn analog.',
        time: 'Dự kiến 16:30',
      ),
      _buildTimelineStep(
        stepNumber: '5',
        title: 'Kiểm định QC & Tải file vào Archive',
        subtitle: 'Kỹ thuật viên duyệt 36 khung hình và xuất link tải lên máy chủ cá nhân.',
        time: 'Dự kiến 18:00',
        isLast: true,
      ),
    ];
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
