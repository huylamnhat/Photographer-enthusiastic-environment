import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Rangefinder';
  bool _shutterCheck = true;
  bool _meterCheck = true;
  bool _lensCheck = true;
  bool _sealsCheck = true;
  bool _submitted = false;

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
                Text('Tin đăng đã chuyển sang hàng chờ tiền kiểm!', textAlign: TextAlign.center, style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  'Hệ thống Admin sẽ đối soát checklist kỹ thuật trong vòng 2 giờ làm việc trước khi niêm yết lên sàn.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Về Sàn Máy', style: AppTypography.button),
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
            // Image upload placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text('Tải lên ảnh thật thiết bị (Tối đa 6 ảnh)', style: AppTypography.labelCaps.copyWith(fontSize: 10)),
                  Text('Kèm ảnh buồng tối và thấu kính để tiền kiểm nhanh', style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form inputs
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
                          hintText: '4.800.000',
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
            const SizedBox(height: 16),

            // Checklist verification section (Stitch APP-CUS-18 / WEB-ADM-05)
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
                onPressed: () => setState(() => _submitted = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Gửi Tin Đăng Tiền Kiểm', style: AppTypography.button),
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
