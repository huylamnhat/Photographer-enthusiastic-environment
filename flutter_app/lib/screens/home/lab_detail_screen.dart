import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../models/lab_model.dart';
import 'create_order_screen.dart';

class LabDetailScreen extends StatelessWidget {
  final LabModel? lab;
  final String? labId;

  const LabDetailScreen({super.key, this.lab, this.labId});

  @override
  Widget build(BuildContext context) {
    final labName = lab?.name ?? (labId == 'croplab' ? 'Croplab Retro' : (labId == 'nadar' ? 'Nadar Darkroom' : 'LLab Sài Gòn'));
    final labCover = lab?.coverImage ?? (labId == 'croplab' ? MockTestAssets.labCover2 : (labId == 'nadar' ? MockTestAssets.labCover3 : MockTestAssets.labCover1));
    final rating = lab?.rating.toString() ?? (labId == 'croplab' ? '4.8' : (labId == 'nadar' ? '5.0' : '4.9'));
    final reviewCount = lab?.reviewCount.toString() ?? (labId == 'croplab' ? '98' : (labId == 'nadar' ? '45' : '140'));
    final sla = lab != null ? '${lab!.turnaroundHours}h' : (labId == 'croplab' ? '36h' : (labId == 'nadar' ? '48h' : '24h'));
    final address = lab?.address ?? (labId == 'croplab' ? '287/3 Phan Văn Trị, P.11, Bình Thạnh' : (labId == 'nadar' ? '12/4 Trương Quyền, P.6, Quận 3' : '15/4 Lê Thánh Tôn, P. Bến Nghé, Quận 1'));

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surfaceRaised,
            foregroundColor: AppColors.ink,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  MockTestAssets.image(labCover, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title, verified badge & rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(labName, style: AppTypography.pageTitle),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 16, color: AppColors.secondary),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phòng tối tiêu chuẩn ISO • Chuyên môn analog',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(rating, style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold)),
                            Text(' ($reviewCount)', style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location and SLA summary card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(address, style: AppTypography.bodySmall),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: AppColors.outline),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 16, color: AppColors.secondary),
                                const SizedBox(width: 8),
                                Text('Thời gian SLA trả ảnh: ', style: AppTypography.labelCaps),
                                Text(
                                  sla,
                                  style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                ),
                              ],
                            ),
                            Text('Mở cửa: 09:00 - 20:00', style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Equipment & Chemistry Specs (Stitch APP-CUS-06)
                  Text('THÔNG SỐ BUỒNG TỐI & MÁY QUÉT', style: AppTypography.sectionHeading.copyWith(fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      children: [
                        _buildSpecLine('Hệ thống máy quét:', 'Noritsu HS-1800 & Fuji Frontier SP-3000'),
                        const SizedBox(height: 6),
                        _buildSpecLine('Thiết bị tráng nhiệt:', 'Jobo ATL-2 tự động kiểm soát 37.8°C'),
                        const SizedBox(height: 6),
                        _buildSpecLine('Dòng hóa chất tiêu chuẩn:', 'Kodak Flexicolor C-41, D-76, ECN-2'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Service packages list
                  Text('BẢNG GIÁ DỊCH VỤ TRÁNG & SCAN', style: AppTypography.sectionHeading.copyWith(fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildPackageItem(
                    name: 'Tráng & Scan Màu C-41 (135/36)',
                    detail: 'Độ phân giải tiêu chuẩn 2000x3000px JPG • SLA 24h',
                    price: '70.000đ',
                  ),
                  const SizedBox(height: 8),
                  _buildPackageItem(
                    name: 'Tráng & Scan Thủ Công B&W (135/120)',
                    detail: 'Hóa chất Kodak D-76 / XTOL • Lắc tay buồng tối • SLA 48h',
                    price: '85.000đ',
                  ),
                  const SizedBox(height: 8),
                  _buildPackageItem(
                    name: 'Tráng & Scan Điện Ảnh ECN-2 (135/36)',
                    detail: 'Tẩy than Remjet thủ công • Không ám mờ • SLA 48h',
                    price: '95.000đ',
                  ),
                  const SizedBox(height: 8),
                  _buildPackageItem(
                    name: 'Scan Độ Phân Giải Cao 16-bit TIFF',
                    detail: 'Độ nét tối đa 4000x6000px TIFF không nén • Phù hợp in ấn',
                    price: '130.000đ',
                  ),
                  const SizedBox(height: 20),

                  // Negative Archival Policy Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Chính sách lưu giữ âm bản & file ảnh:', style: AppTypography.labelCaps.copyWith(color: AppColors.ink)),
                              const SizedBox(height: 2),
                              Text(
                                '• Link tải file scan chất lượng gốc được lưu trên máy chủ MiniLab trong 60 ngày.\n• Âm bản gốc (Negatives) được lưu giữ miễn phí 15 ngày tại tủ bảo quản của tiệm để bạn ghé lấy hoặc yêu cầu gửi bưu điện.',
                                style: AppTypography.bodySmall.copyWith(fontSize: 11, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
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
                  Text('GIÁ TỪ', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                  Text(
                    '70.000đ',
                    style: AppTypography.metric.copyWith(fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateOrderScreen(initialLabId: labId ?? 'llab'),
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
                    const Icon(Icons.add_shopping_cart, size: 16),
                    const SizedBox(width: 8),
                    Text('Đặt tráng scan ngay', style: AppTypography.button),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecLine(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 10, color: AppColors.inkMuted)),
        ),
        Expanded(
          child: Text(value, style: AppTypography.bodySmall.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildPackageItem({required String name, required String detail, required String price}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(detail, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.inkMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: AppTypography.dataMono.copyWith(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
