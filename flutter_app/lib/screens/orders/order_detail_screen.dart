import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order_model.dart';
import 'review_lab_screen.dart';
import '../archive/archive_gallery_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order.orderId),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab & Status Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(order.labName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: order.status == 'READY_FOR_DOWNLOAD' ? AppColors.successBg : AppColors.warningBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          order.status == 'READY_FOR_DOWNLOAD' ? 'SẴN SÀNG TẢI' : 'ĐANG XỬ LÝ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: order.status == 'READY_FOR_DOWNLOAD' ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Địa chỉ nhận film: ${order.pickupAddress}', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng thanh toán:', style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                      Text('${order.totalAmount.toInt()}đ (${order.paymentMethod})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Archive Fast Action Banner (if ready)
            if (order.status == 'READY_FOR_DOWNLOAD')
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_done, color: AppColors.secondary, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('File scan đã đồng bộ!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondary)),
                          Text('Ảnh gốc TIFF/JPG đã nạp vào kho lưu trữ Digital Archive.', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ArchiveGalleryScreen()),
                        );
                      },
                      child: const Text('Xem ảnh', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // Live Timeline SLA
            const Text(
              'QUY TRÌNH XỬ LÝ (LIVE TIMELINE SLA)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.inkMuted, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.timeline.length,
                itemBuilder: (context, index) {
                  final step = order.timeline[index];
                  final isLast = index == order.timeline.length - 1;
                  final isCompleted = step.status == 'COMPLETED';
                  final isInProgress = step.status == 'IN_PROGRESS';

                  Color dotColor = AppColors.outline;
                  if (isCompleted) dotColor = AppColors.success;
                  if (isInProgress) dotColor = AppColors.primary;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isCompleted ? AppColors.success : (isInProgress ? AppColors.primary : Colors.transparent),
                              border: Border.all(color: dotColor, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: isCompleted
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : (isInProgress ? const Center(child: SizedBox(width: 8, height: 8, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5))) : null),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 36,
                              color: isCompleted ? AppColors.success : AppColors.outline,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  step.name,
                                  style: TextStyle(
                                    fontWeight: isInProgress ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 13,
                                    color: (isCompleted || isInProgress) ? AppColors.ink : AppColors.inkMuted,
                                  ),
                                ),
                                if (step.time.isNotEmpty)
                                  Text(step.time, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                              ],
                            ),
                            if (step.note.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 8),
                                child: Text(step.note, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                              )
                            else
                              const SizedBox(height: 18),
                          ],
                        ),
                      )
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Rating CTA
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.star_outline, color: AppColors.primary),
                label: const Text('Đánh giá & Chấm điểm Lab', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewLabScreen(labId: order.labId, labName: order.labName),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

