import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/api_service.dart';
import '../../models/community_model.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final Set<String> _registeredEventIds = {};
  List<EventModel> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await ApiService().getEvents();
    if (!mounted) return;
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workshop & Photowalk')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAmber))
          : _events.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có sự kiện nào từ cơ sở dữ liệu.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final ev = _events[index];
                    final isReg = _registeredEventIds.contains(ev.eventId);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                child: Image.network(
                                  ev.coverImage,
                                  height: 170,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(height: 170, color: AppColors.surfaceElevated),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: ev.type == 'PHOTOWALK' ? AppColors.infoBlue : AppColors.primaryAmber,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ev.type,
                                    style: TextStyle(
                                      color: ev.type == 'PHOTOWALK' ? Colors.white : Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ev.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Text('Host: ${ev.organizerName}', style: const TextStyle(color: AppColors.primaryAmber, fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(ev.date, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(ev.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(ev.description, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4)),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ev.fee,
                                          style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.w800, fontSize: 15),
                                        ),
                                        Text(
                                          'Đã đăng ký: ${ev.registeredCount + (isReg ? 1 : 0)}/${ev.maxSlots} chỗ',
                                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (!isReg) {
                                          await ApiService().registerForEvent(ev.eventId);
                                        }
                                        if (!context.mounted) return;
                                        setState(() {
                                          if (isReg) {
                                            _registeredEventIds.remove(ev.eventId);
                                          } else {
                                            _registeredEventIds.add(ev.eventId);
                                          }
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(isReg ? 'Đã hủy đăng ký sự kiện' : 'Đăng ký tham gia thành công!'),
                                            backgroundColor: AppColors.successGreen,
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isReg ? AppColors.surfaceElevated : AppColors.primaryAmber,
                                        foregroundColor: isReg ? AppColors.textSecondary : Colors.black,
                                      ),
                                      child: Text(isReg ? 'ĐÃ ĐĂNG KÝ' : 'ĐĂNG KÝ NGAY'),
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
