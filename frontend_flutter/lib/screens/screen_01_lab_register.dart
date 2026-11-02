import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';

class LabRegisterScreen extends StatefulWidget {
  final VoidCallback onNavigateToLogin;

  const LabRegisterScreen({super.key, required this.onNavigateToLogin});

  @override
  State<LabRegisterScreen> createState() => _LabRegisterScreenState();
}

class _LabRegisterScreenState extends State<LabRegisterScreen> {
  int currentStep = 1;

  // Form controllers
  final brandNameCtrl = TextEditingController(text: 'Analog Archive Lab');
  final licenseCtrl = TextEditingController(text: '0319842109');
  final addressCtrl = TextEditingController(text: '145/3 Bis Đường Nguyễn Đình Chiểu, Phường Võ Thị Sáu, Quận 3');
  final phoneCtrl = TextEditingController(text: '0918 245 890');
  final emailCtrl = TextEditingController(text: 'labmaster@analogarchive.vn');
  final repNameCtrl = TextEditingController(text: 'NGUYỄN VĂN AN KHANG');
  final cccdCtrl = TextEditingController(text: '079092004581');

  String selectedRegion = 'HCM';
  bool hasDropbox = true;
  String selectedProcessor = 'Noritsu V30 / V50';
  final Map<String, bool> scanners = {
    'Noritsu HS-1800': true,
    'Fuji Frontier SP-3000': true,
    'Pakon F134 / F235 Plus': false,
    'Epson V850 Pro': false,
  };
  final Map<String, bool> chemistries = {
    'C-41 Màu âm bản': true,
    'B&W Trắng đen': true,
    'ECN-2 Điện ảnh': true,
    'E-6 Dương bản (Slide)': false,
  };

  bool isSubmitting = false;

  void _submitKYC() async {
    setState(() => isSubmitting = true);

    final payload = {
      'brand_name': brandNameCtrl.text,
      'license_no': licenseCtrl.text,
      'region': selectedRegion,
      'address': addressCtrl.text,
      'hotline': phoneCtrl.text,
      'email': emailCtrl.text,
      'has_dropbox': hasDropbox,
      'representative_name': repNameCtrl.text,
      'cccd_number': cccdCtrl.text,
      'scanners': scanners.entries.where((e) => e.value).map((e) => e.key).toList(),
      'processor': selectedProcessor,
      'chemistries': chemistries.entries.where((e) => e.value).map((e) => e.key).toList(),
    };

    final res = await ApiService.registerLab(payload);
    setState(() => isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: LabColors.secondary),
              SizedBox(width: 8),
              Text('Đăng ký thành công!'),
            ],
          ),
          content: Text(res['message'] ?? 'Hồ sơ đã được gửi để kiểm duyệt.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onNavigateToLogin();
              },
              child: const Text('Đến trang Đăng nhập'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LabColors.surfaceContainerLow,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Registry
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: LabColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.biotech, color: LabColors.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: LabColors.surfaceContainer,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: const Text(
                                      'KYC-REG-2025/VN',
                                      style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.onSurfaceVariant),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: LabColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                    child: const Text(
                                      'HỒ SƠ THẨM ĐỊNH',
                                      style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.onSecondaryContainer, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Thẩm định Hồ sơ Cơ sở Tráng Quét Phim Analog',
                                style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: widget.onNavigateToLogin,
                          icon: const Icon(Icons.login, size: 18),
                          label: const Text('Đã có tiệm? Đăng nhập'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stepping indicator
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStepIndicator(1, 'Thông tin Tiệm & Trụ sở'),
                        _buildStepIndicator(2, 'Pháp lý & CCCD Chủ Lab'),
                        _buildStepIndicator(3, 'Hệ máy Scan & Hoá chất'),
                        _buildStepIndicator(4, 'Hiện trường & Hoàn tất'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Step content
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildCurrentStepPanel(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = currentStep == step;
    final isDone = currentStep > step;

    return InkWell(
      onTap: () => setState(() => currentStep = step),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isActive
                ? LabColors.primary
                : (isDone ? LabColors.secondary : LabColors.surfaceContainer),
            child: Text(
              '0$step',
              style: TextStyle(
                fontFamily: 'IBM Plex Mono',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: (isActive || isDone) ? Colors.white : LabColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BƯỚC $step',
                style: TextStyle(
                  fontFamily: 'IBM Plex Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isActive ? LabColors.primary : LabColors.onSurfaceVariant,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans',
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: LabColors.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepPanel() {
    switch (currentStep) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MỤC A-01: Thông tin cơ sở & Chi nhánh', style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: brandNameCtrl, decoration: const InputDecoration(labelText: 'Tên thương hiệu Lab *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: licenseCtrl, decoration: const InputDecoration(labelText: 'Số đăng ký kinh doanh / HKD *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Địa chỉ trụ sở tiếp nhận phim *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Hotline phòng tối *', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email điều phối file *', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Thùng nhận phim Dropbox thông minh 24/7 trước cửa tiệm'),
              value: hasDropbox,
              onChanged: (v) => setState(() => hasDropbox = v),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LabColors.primary, foregroundColor: Colors.white),
                onPressed: () => setState(() => currentStep = 2),
                child: const Text('Tiếp tục: Bước 2 →'),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MỤC B-02: Pháp nhân đại diện & CCCD gắn chip', style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: repNameCtrl, decoration: const InputDecoration(labelText: 'Họ và tên người đại diện pháp luật *', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: cccdCtrl, decoration: const InputDecoration(labelText: 'Số CCCD 12 số gắn chip *', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: LabColors.secondaryContainer.withOpacity(0.4), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: LabColors.secondary),
                  SizedBox(width: 12),
                  Text('Đã nạp file cccd_mat_truoc_scan.jpg & mat_sau_chip.jpg'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: () => setState(() => currentStep = 1), child: const Text('← Quay lại')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: LabColors.primary, foregroundColor: Colors.white),
                  onPressed: () => setState(() => currentStep = 3),
                  child: const Text('Tiếp tục: Bước 3 →'),
                ),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MỤC C-03: Hệ máy Scan & Quy trình Hoá chất', style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('1. HỆ THỐNG MÁY SCAN TẠI TIỆM:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: scanners.keys.map((s) {
                return FilterChip(
                  label: Text(s),
                  selected: scanners[s]!,
                  onSelected: (val) => setState(() => scanners[s] = val),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('2. HỆ THỐNG MÁY TRÁNG:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: selectedProcessor,
              items: ['Noritsu V30 / V50', 'Jobo CPP3 / CPE-2 Plus', 'Tank thủ công Paterson']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedProcessor = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('3. QUY TRÌNH HOÁ CHẤT HỖ TRỢ:', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: chemistries.keys.map((c) {
                return FilterChip(
                  label: Text(c),
                  selected: chemistries[c]!,
                  onSelected: (val) => setState(() => chemistries[c] = val),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: () => setState(() => currentStep = 2), child: const Text('← Quay lại')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: LabColors.primary, foregroundColor: Colors.white),
                  onPressed: () => setState(() => currentStep = 4),
                  child: const Text('Tiếp tục: Bước 4 →'),
                ),
              ],
            ),
          ],
        );
      case 4:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MỤC D-04: Bằng chứng cơ sở thực tế & Xác thực', style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: LabColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: LabColors.secondary),
                      SizedBox(width: 8),
                      Text('Bộ 3 ảnh cơ sở thực tế đã sẵn sàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• Mặt tiền tiệm & biển hiệu (Rõ số nhà 145/3 Bis)'),
                  Text('• Phòng tối máy tráng Noritsu V30 (Bể điều nhiệt C-41 37.8°C)'),
                  Text('• Bàn quét film Noritsu HS-1800 & Fuji Frontier SP-3000'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(onPressed: () => setState(() => currentStep = 3), child: const Text('← Quay lại')),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: LabColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  onPressed: isSubmitting ? null : _submitKYC,
                  icon: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                  label: const Text('Gửi Thẩm định Hồ sơ Lab'),
                ),
              ],
            ),
          ],
        );
    }
  }
}

