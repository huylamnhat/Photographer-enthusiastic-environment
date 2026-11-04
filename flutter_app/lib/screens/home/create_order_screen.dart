import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../models/lab_model.dart';
import 'checkout_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final LabModel? lab;
  final String? initialLabId;

  const CreateOrderScreen({super.key, this.lab, this.initialLabId});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _filmNameController = TextEditingController(text: 'Kodak Portra 400');
  final _notesController = TextEditingController();

  String _filmFormat = '135'; // 135, 120, 4x5
  String _process = 'C-41'; // C-41, B&W, ECN-2
  String _scanner = 'Noritsu HS-1800'; // Noritsu HS-1800, Fuji Frontier SP-3000
  String _resolution = 'Standard JPG'; // Standard JPG, High-Res JPG (+20k), Master TIFF (+50k)
  String _pushPull = 'Box Speed'; // Box Speed, Push +1 stop (+15k), Pull -1 stop (+15k)
  String _negativeHandling = 'STORE_15D'; // STORE_15D, SHIP_HOME (+25k), DISPOSE

  int _quantity = 2;

  double _calculateTotal() {
    double base = 70000;
    if (_process == 'B&W') base = 85000;
    if (_process == 'ECN-2') base = 95000;
    if (_filmFormat == '120') base += 15000;
    if (_filmFormat == '4x5') base += 35000;

    double extraPerRoll = 0;
    if (_resolution == 'High-Res JPG') extraPerRoll += 20000;
    if (_resolution == 'Master TIFF') extraPerRoll += 50000;
    if (_pushPull.contains('Push') || _pushPull.contains('Pull')) extraPerRoll += 15000;

    double subtotal = (base + extraPerRoll) * _quantity;
    if (_negativeHandling == 'SHIP_HOME') subtotal += 25000;

    return subtotal;
  }

  @override
  Widget build(BuildContext context) {
    final labName = widget.lab?.name ??
        (widget.initialLabId == 'croplab' ? 'Croplab Retro' : (widget.initialLabId == 'nadar' ? 'Nadar Darkroom' : 'LLab Sài Gòn'));
    final total = _calculateTotal();

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
          'ĐẶT DỊCH VỤ TRÁNG & SCAN',
          style: AppTypography.cardTitle.copyWith(letterSpacing: 0.5, fontSize: 13),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Target Lab Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TIỆM LAB TIẾP NHẬN', style: AppTypography.labelCaps.copyWith(fontSize: 9)),
                        Text(labName, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Text('SLA 24H', style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.secondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 1: Film Name & Quantity
            Text('1. THÔNG TIN CUỘN PHIM', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TÊN HOẶC DÒNG PHIM', style: AppTypography.labelCaps),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _filmNameController,
                    style: AppTypography.bodySmall,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.camera_roll_outlined, size: 18, color: AppColors.inkMuted),
                      hintText: 'Ví dụ: Kodak Portra 400, Fuji Color 200, Ilford HP5...',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SỐ LƯỢNG CUỘN', style: AppTypography.labelCaps),
                          Text('Đóng gói cùng lượt', style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted)),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 30),
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                              onPressed: () => setState(() => _quantity++),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Format & Chemistry
            Text('2. KHỔ PHIM & QUY TRÌNH HÓA CHẤT', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KHỔ PHIM (FORMAT)', style: AppTypography.labelCaps),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildChoiceChip('135 (35mm)', _filmFormat == '135', () => setState(() => _filmFormat = '135'))),
                      const SizedBox(width: 6),
                      Expanded(child: _buildChoiceChip('120 (Medium)', _filmFormat == '120', () => setState(() => _filmFormat = '120'))),
                      const SizedBox(width: 6),
                      Expanded(child: _buildChoiceChip('4x5 (Large)', _filmFormat == '4x5', () => setState(() => _filmFormat = '4x5'))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text('QUY TRÌNH HÓA HỌC (PROCESS)', style: AppTypography.labelCaps),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildChoiceChip('C-41 Màu', _process == 'C-41', () => setState(() => _process = 'C-41'))),
                      const SizedBox(width: 6),
                      Expanded(child: _buildChoiceChip('B&W Thủ công', _process == 'B&W', () => setState(() => _process = 'B&W'))),
                      const SizedBox(width: 6),
                      Expanded(child: _buildChoiceChip('ECN-2 Điện ảnh', _process == 'ECN-2', () => setState(() => _process = 'ECN-2'))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text('HỆ MÁY QUÉT ƯU TIÊN', style: AppTypography.labelCaps),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          'Noritsu HS-1800',
                          _scanner == 'Noritsu HS-1800',
                          () => setState(() => _scanner = 'Noritsu HS-1800'),
                          subtitle: 'Tone ấm tự nhiên',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildChoiceChip(
                          'Fuji Frontier SP-3000',
                          _scanner == 'Fuji Frontier SP-3000',
                          () => setState(() => _scanner = 'Fuji Frontier SP-3000'),
                          subtitle: 'Tone xanh pastel',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 3: Scan Resolution & Push/Pull
            Text('3. ĐỘ PHÂN GIẢI SCAN & TÙY CHỌN ISO', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ĐỘ PHÂN GIẢI FILE SỐ HÓA', style: AppTypography.labelCaps),
                  const SizedBox(height: 6),
                  _buildRadioOption(
                    title: 'Standard JPG (2000x3000px, 300dpi)',
                    subtitle: 'Đủ xem màn hình, đăng mạng xã hội • Đã bao gồm',
                    isSelected: _resolution == 'Standard JPG',
                    onTap: () => setState(() => _resolution = 'Standard JPG'),
                  ),
                  const SizedBox(height: 6),
                  _buildRadioOption(
                    title: 'High-Res JPG (3000x4500px, 300dpi)',
                    subtitle: 'Phù hợp in ấn khổ A4 • +20.000đ/cuộn',
                    isSelected: _resolution == 'High-Res JPG',
                    onTap: () => setState(() => _resolution = 'High-Res JPG'),
                  ),
                  const SizedBox(height: 6),
                  _buildRadioOption(
                    title: 'Master TIFF 16-bit (4000x6000px)',
                    subtitle: 'Không nén, chi tiết vùng tối tối đa • +50.000đ/cuộn',
                    isSelected: _resolution == 'Master TIFF',
                    onTap: () => setState(() => _resolution = 'Master TIFF'),
                  ),
                  const SizedBox(height: 14),

                  Text('ĐẨY / KÉO SÁNG (PUSH/PULL PROCESSING)', style: AppTypography.labelCaps),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip('Box Speed', _pushPull == 'Box Speed', () => setState(() => _pushPull = 'Box Speed')),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildChoiceChip('Push +1 (+15k)', _pushPull == 'Push +1', () => setState(() => _pushPull = 'Push +1')),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildChoiceChip('Pull -1 (+15k)', _pushPull == 'Pull -1', () => setState(() => _pushPull = 'Pull -1')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 4: Negative Handling
            Text('4. XỬ LÝ ÂM BẢN (NEGATIVES)', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  _buildRadioOption(
                    title: 'Lưu tại tủ tiệm Lab (Miễn phí 15 ngày)',
                    subtitle: 'Bạn có thể ghé lấy trực tiếp bất cứ lúc nào trong giờ làm việc.',
                    isSelected: _negativeHandling == 'STORE_15D',
                    onTap: () => setState(() => _negativeHandling = 'STORE_15D'),
                  ),
                  const SizedBox(height: 6),
                  _buildRadioOption(
                    title: 'Chuyển bưu điện về tận nhà (+25.000đ)',
                    subtitle: 'Lab cắt dải 6 frames vào bao bảo quản giấy Acid-free và bọc chống gập.',
                    isSelected: _negativeHandling == 'SHIP_HOME',
                    onTap: () => setState(() => _negativeHandling = 'SHIP_HOME'),
                  ),
                  const SizedBox(height: 6),
                  _buildRadioOption(
                    title: 'Hủy âm bản theo quy chuẩn môi trường',
                    subtitle: 'Chỉ nhận file ảnh qua mạng, ủy quyền cho Lab xử lý tiêu hủy an toàn.',
                    isSelected: _negativeHandling == 'DISPOSE',
                    onTap: () => setState(() => _negativeHandling = 'DISPOSE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes field
            Text('GHI CHÚ KỸ THUẬT CHO LAB', style: AppTypography.labelCaps),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: AppTypography.bodySmall,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Cuộn này chụp trong nhà tối, nhờ lab cân màu tone lạnh...',
                contentPadding: EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TỔNG TẠM TÍNH', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                  Text(
                    '${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                    style: AppTypography.metric.copyWith(fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  final dummyLab = widget.lab ??
                      LabModel(
                        labId: widget.initialLabId ?? 'llab',
                        name: labName,
                        tagline: 'Phòng tối tiêu chuẩn ISO',
                        address: '15/4 Lê Thánh Tôn, Bến Nghé, Quận 1',
                        city: 'TP.HCM',
                        phone: '0901234567',
                        email: 'contact@minilab.vn',
                        rating: 4.9,
                        reviewCount: 140,
                        turnaroundHours: 24,
                        scannerModels: const ['Noritsu HS-1800', 'Fuji Frontier SP-3000'],
                        supportedFormats: const ['135', '120', '4x5'],
                        supportedProcesses: const ['C-41', 'B&W', 'ECN-2'],
                        coverImage: MockTestAssets.labCover1,
                        logoUrl: MockTestAssets.labLogoLlab,
                        isVerified: true,
                        priceRange: '70.000đ - 130.000đ',
                        description: 'Chuyên tráng và scan ảnh analog.',
                        packages: const [],
                      );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        lab: dummyLab,
                        filmName: '${_filmNameController.text} ($_filmFormat, $_process)',
                        quantity: _quantity,
                        packageName: '$_process ($_resolution)',
                        totalPrice: total,
                        pushPull: _pushPull,
                        cutOption: 'Bao bảo quản chuẩn',
                        shippingMethod: _negativeHandling,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Row(
                  children: [
                    Text('Tiếp tục xác nhận đơn', style: AppTypography.button),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String title, bool isSelected, VoidCallback onTap, {String? subtitle}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceSunken : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.labelCaps.copyWith(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.ink,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(fontSize: 9, color: AppColors.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.04) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 12,
                      color: isSelected ? AppColors.primary : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
