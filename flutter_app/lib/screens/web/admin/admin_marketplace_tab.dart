import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';

class AdminMarketplaceTab extends StatefulWidget {
  const AdminMarketplaceTab({super.key});

  @override
  State<AdminMarketplaceTab> createState() => _AdminMarketplaceTabState();
}

class _AdminMarketplaceTabState extends State<AdminMarketplaceTab> {
  final List<Map<String, dynamic>> _queue = [
    {
      'id': 'MKT-POST-902',
      'title': 'Leica M6 Classic 0.72x (Black)',
      'seller': 'Phạm Hoàng Khôi',
      'sellerPhone': '0912883344',
      'serialNumber': '2491028',
      'category': 'Máy ảnh Rangefinder',
      'price': 65000000,
      'status': 'PENDING',
      'location': 'Hoàn Kiếm, Hà Nội',
      'photos': [
        MockTestAssets.equipLeicaM6,
        MockTestAssets.equipCanonQL17,
        MockTestAssets.equipOlympusOM1,
      ],
      'mechanicalChecklist': {
        'Tốc độ màn trập B - 1/1000s': 'Hoạt động chuẩn xác, không kẹt rèm vải',
        'Bộ đo sáng quang học': 'Đo sáng LED nhấp nháy chuẩn so với đo sáng cầm tay',
        'Thấu kính & Kính ngắm': 'Kính trong vắt, không mốc xước, lấy nét điểm vàng sáng rõ',
        'Buồng kín sáng': 'Nẹp xốp chắn sáng đã được thay mới tại Thợ già Tràng Thi',
      },
      'description': 'Máy sưu tầm gia đình để tủ chống ẩm lâu năm. Kèm dây đeo da và bao da cổ.',
    },
    {
      'id': 'MKT-POST-903',
      'title': 'Canon Canonet QL17 GIII',
      'seller': 'Đỗ Hữu Nghĩa',
      'sellerPhone': '0933991122',
      'serialNumber': '884920',
      'category': 'Máy ảnh Rangefinder',
      'price': 4800000,
      'status': 'PENDING',
      'location': 'Quận 1, TP.HCM',
      'photos': [
        MockTestAssets.equipCanonQL17,
        MockTestAssets.equipOlympusOM1,
        MockTestAssets.equipKodakPortra400,
      ],
      'mechanicalChecklist': {
        'Tốc độ màn trập': 'Chạy chuẩn mọi nấc 1/4s - 1/500s',
        'Đo sáng tự động Auto A': 'Hoạt động tốt với pin PX625 chuyển đổi',
        'Ống kính 40mm f/1.7': 'Kính đẹp, lá khẩu nảy tanh tách không dính dầu',
        'Cơ chế Quick Load QL': 'Nạp phim 35mm nuốt phim êm ái',
      },
      'description': 'Máy ngoại hình 95%, kính trong, thấu kính không xước mốc.',
    },
  ];

  int _selectedListingIdx = 0;

  @override
  Widget build(BuildContext context) {
    final item = _queue[_selectedListingIdx];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WEB-ADM-05 // TIỀN KIỂM SÀN MUA BÁN', style: AppTypography.labelCaps),
              SizedBox(height: 4),
              Text('Hàng chờ Kiểm định Tin rao bán Thiết bị', style: AppTypography.pageTitle),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Queue List
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
                    itemCount: _queue.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, idx) {
                      final q = _queue[idx];
                      final isSel = idx == _selectedListingIdx;
                      return ListTile(
                        selected: isSel,
                        selectedTileColor: AppColors.surfaceSunken,
                        title: Text(q['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('${q['category']} · Giá: ${q['price']}đ\nNgười bán: ${q['seller']}', style: AppTypography.caption),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('CHỜ DUYỆT', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        onTap: () => setState(() => _selectedListingIdx = idx),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Drawer / Inspection Panel
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
                              Text(item['id'], style: AppTypography.dataMono.copyWith(color: AppColors.primary)),
                              Text(item['title'], style: AppTypography.sectionHeading),
                            ],
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã từ chối tin đăng ${item['title']}')),
                                  );
                                },
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Từ chối'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() => item['status'] = 'APPROVED');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã duyệt tin ${item['title']} hiển thị lên sàn Marketplace!')),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Duyệt tin đăng'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _buildDetailField('GIÁ BÁN NIÊM YẾT', '${item['price']} đ'),
                          _buildDetailField('SỐ SERI MÁY', item['serialNumber']),
                          _buildDetailField('NGƯỜI BÁN & SĐT', '${item['seller']} (${item['sellerPhone']})'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('MÔ TẢ CHI TIẾT CỦA NGƯỜI BÁN:', style: AppTypography.labelCaps),
                      const SizedBox(height: 4),
                      Text(item['description'], style: AppTypography.body),

                      const SizedBox(height: 20),
                      const Text('BẢNG CHECKLIST KIỂM ĐỊNH TÌNH TRẠNG CƠ HỌC BẮT BUỘC:', style: AppTypography.labelCaps),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Column(
                          children: (item['mechanicalChecklist'] as Map<String, dynamic>).entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Text('${e.key}: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Expanded(child: Text(e.value, style: AppTypography.caption)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text('ẢNH CHỤP THẬT MÁY (TỐI THIỂU 3 ẢNH CÁC GÓC):', style: AppTypography.labelCaps),
                      const SizedBox(height: 10),
                      Row(
                        children: (item['photos'] as List).map<Widget>((photoUrl) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 120,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: MockTestAssets.image(
                              photoUrl,
                              width: 120,
                              height: 90,
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

  Widget _buildDetailField(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelCaps),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
        ],
      ),
    );
  }
}
