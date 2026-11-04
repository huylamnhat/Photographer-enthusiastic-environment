import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<Map<String, dynamic>> _events = [
    {
      'id': 'evt-001',
      'title': 'Photowalk Chợ Lớn Analog: Sắc Màu Phố Người Hoa',
      'organizer': 'Lê Quang Huy & LLab Sài Gòn',
      'date': 'Thứ Bảy, 26/03/2026 • 07:30 - 11:30',
      'location': 'Khu phố cổ Chợ Lớn, Quận 5, TP.HCM',
      'registered': 14,
      'max': 25,
      'fee': 'Miễn phí (Tặng voucher giảm 20% tráng C-41)',
      'image': MockTestAssets.samplePhoto3,
      'isRegistered': false,
      'desc': 'Khám phá văn hóa kiến trúc phố người Hoa qua cuộn phim 35mm đường phố. Cùng nhau chia sẻ góc nhìn về tương phản ánh sáng xiên ban mai, cân chỉnh thước ngắm Rangefinder và giao lưu cuộn phim đầu tay.',
    },
    {
      'id': 'evt-002',
      'title': 'Workshop Phòng Tối: Tự Tráng & Phóng Rọi Ảnh B&W',
      'organizer': 'Nadar Darkroom Masterclass',
      'date': 'Chủ Nhật, 29/03/2026 • 13:30 - 17:30',
      'location': 'Phòng tối Nadar - 12/4 Trương Quyền, Quận 3',
      'registered': 8,
      'max': 10,
      'fee': '250.000đ (Bao gồm hóa chất D-76, tank và giấy ảnh rọi)',
      'image': MockTestAssets.labCover3,
      'isRegistered': true,
      'desc': 'Thực hành lên cuộn trong túi tối changing bag, pha chế thuốc tráng Kodak D-76 đúng nhiệt độ 20°C, kiểm soát chu kỳ lắc agitation và tự tay mang về bản rọi bạc truyền thống (Silver Gelatin Print).',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'SỰ KIỆN PHOTOWALK & WORKSHOP',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final evt = _events[index];
          final isRegistered = evt['isRegistered'] as bool;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      MockTestAssets.image(evt['image'] as String, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'SỰ KIỆN CỘNG ĐỒNG',
                            style: AppTypography.labelCaps.copyWith(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${evt['registered']}/${evt['max']} ĐÃ ĐĂNG KÝ',
                            style: AppTypography.dataMono.copyWith(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(evt['title'] as String, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Tổ chức bởi: ${evt['organizer']}', style: AppTypography.labelCaps.copyWith(color: AppColors.inkMuted)),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(evt['date'] as String, style: AppTypography.dataMono.copyWith(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.inkMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(evt['location'] as String, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number_outlined, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(evt['fee'] as String, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.outline),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isRegistered ? 'Bạn đã giữ chỗ sự kiện' : 'Còn ${evt['max'] - evt['registered']} chỗ trống',
                            style: AppTypography.labelCaps.copyWith(
                              fontSize: 10,
                              color: isRegistered ? AppColors.secondary : AppColors.inkMuted,
                              fontWeight: isRegistered ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                evt['isRegistered'] = !isRegistered;
                                if (!isRegistered) {
                                  evt['registered'] = (evt['registered'] as int) + 1;
                                } else {
                                  evt['registered'] = (evt['registered'] as int) - 1;
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRegistered ? AppColors.surfaceSunken : AppColors.primary,
                              foregroundColor: isRegistered ? AppColors.ink : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: isRegistered ? const BorderSide(color: AppColors.outline) : BorderSide.none,
                              ),
                            ),
                            child: Text(
                              isRegistered ? 'Hủy đăng ký' : 'Đăng ký tham gia',
                              style: AppTypography.button.copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
