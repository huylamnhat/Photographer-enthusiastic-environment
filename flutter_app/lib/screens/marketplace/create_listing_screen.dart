import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/marketplace_provider.dart';
import '../../models/listing_model.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController(text: '0912345678');
  String _category = 'Máy ảnh SLR cơ khí';
  String _condition = '95% Hoạt động tốt';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng tin rao bán thiết bị'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image upload box
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline, style: BorderStyle.solid),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 36, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text('Tải lên tối đa 6 hình ảnh thiết bị', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('TIÊU ĐỀ TIN ĐĂNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Ví dụ: Máy ảnh Canon QL17 GIII, Lens 50mm...'),
            ),
            const SizedBox(height: 16),

            const Text('DANH MỤC THIẾT BỊ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'Máy ảnh SLR cơ khí', child: Text('Máy ảnh SLR cơ khí')),
                DropdownMenuItem(value: 'Máy ảnh Rangefinder', child: Text('Máy ảnh Rangefinder')),
                DropdownMenuItem(value: 'Point & Shoot tự động', child: Text('Point & Shoot tự động')),
                DropdownMenuItem(value: 'Ống kính rời (Lens)', child: Text('Ống kính rời (Lens)')),
                DropdownMenuItem(value: 'Cuộn Film 135 / 120', child: Text('Cuộn Film 135 / 120')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            const Text('GIÁ BÁN (VND)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Ví dụ: 3500000'),
            ),
            const SizedBox(height: 16),

            const Text('TÌNH TRẠNG NGOẠI HÌNH & KÍNH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              decoration: const InputDecoration(hintText: 'Ví dụ: 95% Kính trong, cơ tốc hoạt động tốt'),
            ),
            const SizedBox(height: 16),

            const Text('MÔ TẢ CHI TIẾT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Mô tả chi tiết phụ kiện đi kèm, lịch sử bảo dưỡng...'),
            ),
            const SizedBox(height: 16),

            const Text('SỐ ĐIỆN THOẠI & ZALO LIÊN HỆ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(hintText: '09xx xxx xxx'),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final newListing = ListingModel(
                    listingId: 'mkt-${DateTime.now().millisecondsSinceEpoch}',
                    sellerId: 'usr-001',
                    sellerName: 'Nguyễn Hoàng Anh',
                    sellerAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
                    title: _titleController.text.isNotEmpty ? _titleController.text : 'Máy ảnh Film Classic',
                    category: _category,
                    condition: _condition,
                    price: double.tryParse(_priceController.text) ?? 2500000,
                    status: 'ACTIVE',
                    location: 'Hà Nội',
                    phoneContact: _phoneController.text,
                    zaloContact: _phoneController.text,
                    imageUrls: ['https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800'],
                    description: _descController.text,
                    createdAt: DateTime.now().toIso8601String(),
                  );
                  context.read<MarketplaceProvider>().addListing(newListing);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đăng tin bán thiết bị thành công!')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Đăng tin ngay', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
