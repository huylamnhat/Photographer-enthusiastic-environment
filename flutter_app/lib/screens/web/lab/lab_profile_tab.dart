import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LabProfileTab extends StatefulWidget {
  const LabProfileTab({super.key});

  @override
  State<LabProfileTab> createState() => _LabProfileTabState();
}

class _LabProfileTabState extends State<LabProfileTab> {
  final _nameController = TextEditingController(text: 'CropLab Hà Nội');
  final _taglineController = TextEditingController(text: 'Chuyên gia tráng & scan chất lượng cao từ năm 2014');
  final _addressController = TextEditingController(text: 'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ, Hà Nội');
  final _phoneController = TextEditingController(text: '0904567890');
  final _scannersController = TextEditingController(text: 'Noritsu HS-1800, Fuji Frontier SP-3000');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cấu Hình Hồ Sơ Tiệm Film Lab Công Khai', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('Thông tin hiển thị cho nhiếp ảnh gia khi tìm kiếm, xem bảng giá và đặt lịch pickup giao nhận phim',
                style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
            const SizedBox(height: 24),

            Container(
              constraints: const BoxConstraints(maxWidth: 720),
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
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network('https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800', width: 90, height: 90, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ảnh đại diện tiệm Lab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 4),
                          Text('Định dạng JPG, PNG kích thước tối thiểu 800x800px', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                          SizedBox(height: 8),
                          Text('Đã xác thực giấy phép DKKD • SLA 12 giờ', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text('TÊN FILM LAB HIỂN THỊ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 6),
                  TextField(controller: _nameController),
                  const SizedBox(height: 16),

                  const Text('SLOGAN / LỜI GIỚI THIỆU NGẮN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 6),
                  TextField(controller: _taglineController),
                  const SizedBox(height: 16),

                  const Text('ĐỊA CHỈ PHÒNG TỐI & QUẦY TIẾP NHẬN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 6),
                  TextField(controller: _addressController),
                  const SizedBox(height: 16),

                  const Text('HOTLINE / ZALO TIẾP NHẬN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 6),
                  TextField(controller: _phoneController),
                  const SizedBox(height: 16),

                  const Text('DANH SÁCH MÁY SCAN TRANG BỊ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                  const SizedBox(height: 6),
                  TextField(controller: _scannersController),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã lưu hồ sơ tiệm Film Lab thành công!'), backgroundColor: AppColors.success),
                        );
                      },
                      child: const Text('Lưu thông tin hồ sơ tiệm', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

