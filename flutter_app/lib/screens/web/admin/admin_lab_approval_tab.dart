import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';

class AdminLabApprovalTab extends StatefulWidget {
  const AdminLabApprovalTab({super.key});

  @override
  State<AdminLabApprovalTab> createState() => _AdminLabApprovalTabState();
}

class _AdminLabApprovalTabState extends State<AdminLabApprovalTab> {
  int _categoryTab = 0; // 0: Lab mới, 1: Chuyên gia Verified, 2: Vận chuyển
  int _selectedApplicationIndex = 0;

  final List<Map<String, dynamic>> _labApplications = [
    {
      'id': 'APP-LAB-901',
      'name': 'Retro Hanoi Darkroom',
      'owner': 'Phạm Gia Huy',
      'email': 'retro.hanoi@gmail.com',
      'phone': '0945667788',
      'city': 'Hà Nội',
      'address': 'Số 22 ngõ Huyện, Hàng Trống, Hoàn Kiếm, Hà Nội',
      'businessLicense': 'DKKD-0109923481',
      'wastePermit': 'TNMT-HN-2025-C41',
      'scannerModels': ['Noritsu LS-600', 'Epson V850 Pro'],
      'processes': ['C-41', 'B&W (D-76 / Rodinal)'],
      'darkroomType': 'Buồng tối tuần hoàn khí kín, tủ sấy lọc bụi HEPA',
      'status': 'PENDING',
      'appliedDate': '02/03/2026',
      'photos': [
        MockTestAssets.machineNoritsu,
        MockTestAssets.machineDarkroomSink,
        MockTestAssets.certificateWaste,
      ],
    },
    {
      'id': 'APP-LAB-902',
      'name': 'Analog Saigon Space',
      'owner': 'Võ Thành Nam',
      'email': 'analog.saigon@gmail.com',
      'phone': '0919334455',
      'city': 'TP.HCM',
      'address': '88 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM',
      'businessLicense': 'DKKD-0318829102',
      'wastePermit': 'TNMT-HCM-2024-ECN',
      'scannerModels': ['Fuji Frontier SP-3000'],
      'processes': ['C-41', 'ECN-2 Cine'],
      'darkroomType': 'Máy tráng tự động Noritsu V30, máy tẩy than',
      'status': 'PENDING',
      'appliedDate': '03/03/2026',
      'photos': [
        MockTestAssets.machineFrontier,
        MockTestAssets.machineDarkroomSink,
      ],
    },
  ];

  final List<Map<String, dynamic>> _expertApplications = [
    {
      'id': 'APP-EXP-301',
      'name': 'Nguyễn Trọng Khoa (Chuyên Gia Thẩm Định)',
      'owner': 'Nguyễn Trọng Khoa',
      'email': 'khoa.analog@gmail.com',
      'phone': '0903881122',
      'city': 'TP.HCM',
      'address': '12B Nguyễn Hữu Cảnh, P.19, Bình Thạnh',
      'businessLicense': 'CCN-VN-9921 (Kiểm định cơ học Leica/Hasselblad)',
      'wastePermit': 'Không áp dụng (Chuyên gia cơ khí)',
      'scannerModels': ['Kính quang học Collimator 50mm', 'Đồng hồ đo tốc màn trập Kyoritsu'],
      'processes': ['Cân chỉnh cơ học', 'Thấu kính nấm mốc', 'Đo sáng quang trở'],
      'darkroomType': 'Phòng kỹ thuật sạch tĩnh điện Class 1000',
      'status': 'PENDING',
      'appliedDate': '01/03/2026',
      'photos': [
        MockTestAssets.marketplaceCam1,
        MockTestAssets.certificateWaste,
      ],
    },
  ];

  final List<Map<String, dynamic>> _shippingApplications = [];

  List<Map<String, dynamic>> get _currentList {
    if (_categoryTab == 0) return _labApplications;
    if (_categoryTab == 1) return _expertApplications;
    return _shippingApplications;
  }

  @override
  Widget build(BuildContext context) {
    final list = _currentList;
    final hasItems = list.isNotEmpty;
    final safeIndex = hasItems ? _selectedApplicationIndex.clamp(0, list.length - 1) : 0;
    final activeApp = hasItems ? list[safeIndex] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEB-ADM-04 // THẨM ĐỊNH ĐỐI TÁC', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Trung tâm Phê duyệt & Cấp phép', style: AppTypography.pageTitle),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _buildSubTab(0, 'Tiệm Lab Mới (${_labApplications.length})'),
                    _buildSubTab(1, 'Chuyên gia Verified (${_expertApplications.length})'),
                    _buildSubTab(2, 'Vận chuyển (${_shippingApplications.length})'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Split: Master List (Left) vs Detail Inspection Panel (Right)
          if (!hasItems)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_outlined, size: 48, color: AppColors.inkMuted),
                  const SizedBox(height: 12),
                  Text('Không có hồ sơ nào đang chờ duyệt', style: AppTypography.cardTitle),
                  const SizedBox(height: 4),
                  Text('Tất cả đối tác trong danh mục này đã được xử lý xong.', style: AppTypography.caption),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left List
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final app = list[idx];
                        final isSel = idx == safeIndex;
                        return ListTile(
                          selected: isSel,
                          selectedTileColor: AppColors.surfaceSunken,
                          title: Text(app['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${app['city']} · Đại diện: ${app['owner']}\nNgày nộp: ${app['appliedDate']}', style: AppTypography.caption),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: app['status'] == 'APPROVED' ? AppColors.successBg : AppColors.warningBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              app['status'] == 'APPROVED' ? 'ĐÃ DUYỆT' : 'CHỜ DUYỆT',
                              style: TextStyle(
                                color: app['status'] == 'APPROVED' ? AppColors.secondary : AppColors.warning,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () => setState(() => _selectedApplicationIndex = idx),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Right Detailed Inspection Dossier
                if (activeApp != null)
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(24),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(activeApp['id'], style: AppTypography.dataMono.copyWith(color: AppColors.primary)),
                                  Text(activeApp['name'], style: AppTypography.sectionHeading),
                                ],
                              ),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Đã từ chối hồ sơ ${activeApp['name']} và gửi yêu cầu bổ sung')),
                                      );
                                    },
                                    icon: const Icon(Icons.close, size: 16),
                                    label: const Text('Từ chối'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() => activeApp['status'] = 'APPROVED');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Đã phê duyệt và kích hoạt đối tác ${activeApp['name']} lên sàn MiniLab!')),
                                      );
                                    },
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Duyệt kích hoạt'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Metadata Grid (safe non-expanded children inside Column)
                          Row(
                            children: [
                              Expanded(child: _buildDetailField('CHỦ TIỆM / ĐẠI DIỆN', activeApp['owner'])),
                              Expanded(child: _buildDetailField('SỐ ĐIỆN THOẠI', activeApp['phone'])),
                              Expanded(child: _buildDetailField('EMAIL LIÊN HỆ', activeApp['email'])),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _buildDetailField('GIẤY PHÉP ĐKKD / CCN', activeApp['businessLicense'])),
                              Expanded(child: _buildDetailField('GIẤY PHÉP MÔI TRƯỜNG', activeApp['wastePermit'])),
                              Expanded(child: _buildDetailField('QUY TRÌNH HỖ TRỢ', (activeApp['processes'] as List).join(', '))),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildDetailField('ĐỊA CHỈ PHÒNG TỐI / CƠ SỞ HOẠT ĐỘNG', activeApp['address']),
                          const SizedBox(height: 14),
                          _buildDetailField('MÁY SCAN & HỆ THỐNG PHÒNG TỐI', '${(activeApp['scannerModels'] as List).join(' · ')} | ${activeApp['darkroomType']}'),

                          const SizedBox(height: 20),
                          const Text('ẢNH CHỤP CƠ SỞ THỰC TẾ & MÁY SCAN KIỂM ĐỊNH:', style: AppTypography.labelCaps),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: (activeApp['photos'] as List).map<Widget>((photoUrl) {
                              return Container(
                                width: 130,
                                height: 95,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: MockTestAssets.image(
                                  photoUrl,
                                  width: 130,
                                  height: 95,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSubTab(int idx, String title) {
    final isSel = _categoryTab == idx;
    return InkWell(
      onTap: () {
        setState(() {
          _categoryTab = idx;
          _selectedApplicationIndex = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColors.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
            color: isSel ? AppColors.primary : AppColors.inkMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelCaps),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
