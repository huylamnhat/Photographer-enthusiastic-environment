import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/community_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<EventModel> _events = [
    EventModel(
      eventId: 'evt-001',
      organizerName: 'Lê Quang Huy & CropLab',
      title: 'Photowalk Mùa Hoa Sưa - Dạo Phố Cùng Máy Cơ',
      date: 'Chủ Nhật, 15/03/2026 • 07:30 - 11:30',
      location: 'Quanh Hồ Gươm & Phố Cổ Hà Nội',
      registeredCount: 24,
      maxSlots: 30,
      fee: 'Miễn phí tham gia (Hỗ trợ 20% phí tráng scan)',
      coverImage: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
      description: 'Buổi giao lưu chụp ảnh đường phố đầu xuân dành cho tất cả mọi người yêu thích máy ảnh cơ. Chúng ta sẽ cùng nhau chia sẻ góc nhìn về bố cục, ánh sáng và trải nghiệm những cuộn film màu sắc phong phú.',
      isRegistered: false,
    ),
    EventModel(
      eventId: 'evt-002',
      organizerName: 'CropLab Academy',
      title: 'Workshop Thực Hành: Tự Tráng Phim B&W Tại Nhà',
      date: 'Thứ Bảy, 21/03/2026 • 14:00 - 17:30',
      location: 'Phòng tối CropLab - Đặng Thai Mai, Tây Hồ',
      registeredCount: 8,
      maxSlots: 10,
      fee: '250.000đ (Bao gồm hóa chất, tank và 1 cuộn film)',
      coverImage: 'https://images.unsplash.com/photo-1471341971476-ae15ff5dd4ea?w=800',
      description: 'Học cách lên cuộn trong túi tối (changing bag), pha chế dung dịch Kodak D-76, kiểm soát chu kỳ lắc agitation và tự tay mang về dải film âm bản sắc nét.',
      isRegistered: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sự kiện & Workshop Photowalk'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final evt = _events[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    evt.coverImage,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.neutralBg, borderRadius: BorderRadius.circular(4)),
                        child: Text(evt.organizerName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                      ),
                      const SizedBox(height: 8),
                      Text(evt.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(evt.date, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(evt.location, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.people_outline, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text('Đã đăng ký: ${evt.registeredCount}/${evt.maxSlots} người',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(evt.description, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted, height: 1.4)),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: evt.isRegistered
                            ? OutlinedButton.icon(
                                icon: const Icon(Icons.check, color: AppColors.success),
                                label: const Text('Bạn đã đăng ký tham gia (Vé nội bộ)', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                onPressed: null,
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    evt.isRegistered = true;
                                    evt.registeredCount++;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đăng ký tham gia Photowalk thành công!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                },
                                child: const Text('Đăng ký tham gia ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
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

