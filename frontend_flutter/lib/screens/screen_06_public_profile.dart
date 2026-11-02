import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  LabProfileModel? profile;
  bool isLoading = true;
  bool isSaving = false;

  final nameCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final hoursCtrl = TextEditingController();
  final hotlineCtrl = TextEditingController();
  final pledgeCtrl = TextEditingController();
  final dropboxCtrl = TextEditingController();
  bool hasDropbox = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => isLoading = true);
    final p = await ApiService.getLabProfile();
    if (p != null) {
      profile = p;
      nameCtrl.text = p.brandName;
      bioCtrl.text = p.bio;
      addressCtrl.text = p.address;
      hoursCtrl.text = p.operatingHours;
      hotlineCtrl.text = p.hotline;
      pledgeCtrl.text = p.turnaroundPledge;
      dropboxCtrl.text = p.dropboxInfo;
      hasDropbox = p.hasDropbox;
    }
    setState(() => isLoading = false);
  }

  void _saveProfile() async {
    if (profile == null) return;
    setState(() => isSaving = true);

    profile!.brandName = nameCtrl.text;
    profile!.bio = bioCtrl.text;
    profile!.address = addressCtrl.text;
    profile!.operatingHours = hoursCtrl.text;
    profile!.hotline = hotlineCtrl.text;
    profile!.turnaroundPledge = pledgeCtrl.text;
    profile!.dropboxInfo = dropboxCtrl.text;
    profile!.hasDropbox = hasDropbox;

    final success = await ApiService.updateLabProfile(profile!);
    setState(() => isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Hồ sơ tiệm đã được lưu và đồng bộ thời gian thực!' : 'Lưu hồ sơ thất bại'),
          backgroundColor: success ? LabColors.secondary : LabColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: LabColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top action bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hồ sơ Tiệm Lab Công khai',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cấu hình thông tin xuất hiện trên ứng dụng khách hàng và hồ sơ thương hiệu',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 13, color: LabColors.onSurfaceVariant),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LabColors.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: isSaving ? null : _saveProfile,
                  icon: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.verified),
                  label: const Text('Lưu thay đổi hồ sơ'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Sync Alert
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: LabColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LabColors.outlineVariant, width: 0.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_done, color: LabColors.secondary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đồng bộ tự động kích hoạt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Mọi thay đổi giờ mở cửa hoặc vị trí hộp drop-box sẽ phản ánh ngay trên app khách sau 60 giây.', style: TextStyle(fontSize: 12, color: LabColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('HỒ SƠ ĐANG CÔNG KHAI', style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, fontWeight: FontWeight.bold, color: LabColors.secondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Two Column Form & Preview
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form settings (Left Column)
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. THÔNG TIN NHÃN TIỆM & GIỚI THIỆU', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(labelText: 'Tên thương hiệu Lab công khai', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: bioCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(labelText: 'Mô tả / Lời ngỏ giới thiệu tiệm', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          const Text('2. ĐỊA CHỈ & GIỜ LÀM VIỆC', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: addressCtrl,
                            decoration: const InputDecoration(labelText: 'Địa chỉ trụ sở tiếp nhận phim', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: hoursCtrl,
                                  decoration: const InputDecoration(labelText: 'Giờ mở cửa hàng ngày', border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: hotlineCtrl,
                                  decoration: const InputDecoration(labelText: 'Hotline / Zalo tư vấn', border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('3. HỘP NHẬN PHIM DROPBOX 24/7 & CAM KẾT SLA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Thùng Drop-box gửi phim tự động 24/7 ngoài giờ'),
                            value: hasDropbox,
                            onChanged: (v) => setState(() => hasDropbox = v),
                          ),
                          TextField(
                            controller: dropboxCtrl,
                            decoration: const InputDecoration(labelText: 'Vị trí & Hướng dẫn sử dụng hộp Dropbox', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: pledgeCtrl,
                            decoration: const InputDecoration(labelText: 'Cam kết thời gian trả file (SLA Pledge)', border: OutlineInputBorder()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Preview Card (Right Column)
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.smartphone, size: 18, color: LabColors.primary),
                              SizedBox(width: 8),
                              Text('XEM TRƯỚC TRÊN APP KHÁCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const Divider(height: 24),
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: LabColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=600'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nameCtrl.text,
                            style: const TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const Text(' 4.95 (384 đánh giá) • ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(hasDropbox ? 'Hộp Drop-box 24/7' : 'Giờ hành chính', style: const TextStyle(color: LabColors.secondary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bioCtrl.text,
                            style: const TextStyle(fontSize: 12, color: LabColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: LabColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 14, color: LabColors.primary),
                                    const SizedBox(width: 6),
                                    Text(hoursCtrl.text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.place, size: 14, color: LabColors.primary),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(addressCtrl.text, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

