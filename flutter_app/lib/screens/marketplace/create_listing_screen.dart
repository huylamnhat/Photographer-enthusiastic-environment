import 'package:flutter/material.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/local_image_picker.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _conditionController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Rangefinder';
  bool _shutterCheck = true;
  bool _meterCheck = true;
  bool _lensCheck = true;
  bool _sealsCheck = true;
  bool _submitting = false;
  bool _submitted = false;
  final List<PickedLocalImage> _pickedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _conditionController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickEquipmentImages() async {
    final picked = await pickLocalImagesFromComputer(multiple: true);
    if (!mounted || picked.isEmpty) return;
    setState(() {
      for (final img in picked) {
        if (_pickedImages.length >= 6) break;
        _pickedImages.add(img);
      }
    });
  }

  Future<void> _submitListing() async {
    final title = _titleController.text.trim();
    final priceDigits = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final price = double.tryParse(priceDigits) ?? 0;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('Vui lòng nhập tiêu đề thiết bị cần bán.'),
        ),
      );
      return;
    }
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('Vui lòng nhập giá bán hợp lệ (lớn hơn 0đ).'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final res = await ApiService().createMarketplaceListing({
      'title': title,
      'category': _category,
      'condition': _conditionController.text.trim().isNotEmpty
          ? _conditionController.text.trim()
          : 'Đã kiểm tra 4 bước cơ học',
      'price': price,
      if (_locationController.text.trim().isNotEmpty)
        'location': _locationController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'phone_contact': _phoneController.text.trim(),
      if (_descController.text.trim().isNotEmpty)
        'description': _descController.text.trim(),
      if (_pickedImages.isNotEmpty)
        'image_urls': _pickedImages.map((e) => e.dataUrl).toList(),
      'mechanical_checklist': {
        'Màn trập (Shutter)': _shutterCheck ? 'Đạt chuẩn tốc độ' : 'Cần lưu ý',
        'Đo sáng (Light Meter)': _meterCheck ? 'Hoạt động ổn định' : 'Không dùng / hỏng',
        'Thấu kính (Optics)': _lensCheck ? 'Trong sạch, không mốc rễ' : 'Có vết nhẹ',
        'Buồng phim & Mút sáng': _sealsCheck ? 'Kín sáng' : 'Cần thay mút',
      },
    });
    if (!mounted) return;
    setState(() => _submitting = false);

    if (res == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('Không thể gửi tin đăng. Vui lòng thử lại.'),
        ),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceRaised,
          elevation: 0,
          title: Text('ĐĂNG TIN THÀNH CÔNG', style: AppTypography.cardTitle.copyWith(fontSize: 13)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.secondary, size: 54),
                const SizedBox(height: 16),
                Text(
                  'Tin đăng đã chuyển sang hàng chờ tiền kiểm!',
                  textAlign: TextAlign.center,
                  style: AppTypography.pageTitle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin sẽ kiểm duyệt tin đăng của bạn trước khi hiển thị công khai trên Chợ Thiết bị.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Về Chợ Thiết Bị', style: AppTypography.button),
                ),
              ],
            ),
          ),
        ),
      );
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
        title: Text(
          'ĐĂNG TIN BÁN THIẾT BỊ ANALOG',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickEquipmentImages,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text(
                      'Chọn ảnh thật thiết bị (${_pickedImages.length}/6 ảnh)',
                      style: AppTypography.labelCaps.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kèm ảnh thân máy, buồng tối và thấu kính để Admin tiền kiểm nhanh',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
            ),
            if (_pickedImages.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_pickedImages.length, (i) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: MockTestAssets.image(
                          _pickedImages[i].dataUrl,
                          width: 78,
                          height: 78,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _pickedImages.removeAt(i)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
            const SizedBox(height: 16),

            Text('TIÊU ĐỀ TIN ĐĂNG', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Canon QL17 GIII Black Edition...',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GIÁ MONG MUỐN (VNĐ)', style: AppTypography.labelCaps),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _priceController,
                        style: AppTypography.dataMono,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '4800000',
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DÒNG THIẾT BỊ', style: AppTypography.labelCaps),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _category,
                            isExpanded: true,
                            style: AppTypography.bodySmall,
                            items: ['Rangefinder', 'SLR Cơ khí', 'Point & Shoot', 'Ống kính (Lens)'].map((c) {
                              return DropdownMenuItem(value: c, child: Text(c));
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _category = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ĐỊA ĐIỂM GIAO DỊCH', style: AppTypography.labelCaps),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _locationController,
                        style: AppTypography.bodySmall,
                        decoration: const InputDecoration(
                          hintText: 'VD: Hoàn Kiếm, Hà Nội',
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SĐT / ZALO LIÊN HỆ', style: AppTypography.labelCaps),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _phoneController,
                        style: AppTypography.dataMono,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '09xxxxxxxx',
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Text('TÌNH TRẠNG TỔNG QUAN', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            TextField(
              controller: _conditionController,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                hintText: 'VD: 96% Ngoại hình đẹp, kính trong',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 16),

            Text('CAM KẾT TÌNH TRẠNG CƠ HỌC BẮT BUỘC', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  _buildCheckRow('Màn trập nhảy đúng tốc độ (Shutter accuracy)', _shutterCheck, (v) => setState(() => _shutterCheck = v!)),
                  const Divider(height: 12, color: AppColors.outline),
                  _buildCheckRow('Hệ thống đo sáng (Light meter) còn hoạt động', _meterCheck, (v) => setState(() => _meterCheck = v!)),
                  const Divider(height: 12, color: AppColors.outline),
                  _buildCheckRow('Thấu kính không trầy xước, không mù rễ tre', _lensCheck, (v) => setState(() => _lensCheck = v!)),
                  const Divider(height: 12, color: AppColors.outline),
                  _buildCheckRow('Buồng phim kín sáng, mút chắn sáng không rữa', _sealsCheck, (v) => setState(() => _sealsCheck = v!)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text('MÔ TẢ CHI TIẾT LỊCH SỬ SỬ DỤNG', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 3,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                hintText: 'Nêu rõ phụ kiện đi kèm (dây đeo, cap lens, pin đo sáng, bao da)...',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _submitting ? 'Đang gửi tin...' : 'Gửi Tin Đăng Tiền Kiểm',
                  style: AppTypography.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        ),
      ],
    );
  }
}
