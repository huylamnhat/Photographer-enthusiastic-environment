import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/mock/mock_test_assets.dart';
import 'photo_detail_screen.dart';
import 'album_detail_screen.dart';

class ArchiveGalleryScreen extends StatefulWidget {
  const ArchiveGalleryScreen({super.key});

  @override
  State<ArchiveGalleryScreen> createState() => _ArchiveGalleryScreenState();
}

class _ArchiveGalleryScreenState extends State<ArchiveGalleryScreen> {
  final Set<int> _selectedFrames = {0, 1, 2};

  final List<Map<String, dynamic>> _frames = [
    {
      'frame': '#01',
      'ratio': '3:2',
      'film': 'PORTRA 400',
      'mp': '24.1 MP',
      'title': 'Quán cà phê dốc số 4, Đà Lạt',
      'image': MockTestAssets.samplePhoto1,
      'camera': 'Canon AE-1 Program',
      'lens': 'FD 50mm f/1.4',
      'scanner': 'Noritsu HS-1800',
      'exif': '1/250s • f/2.8 • ISO 400',
      'fileSize': '18.4 MB TIFF',
    },
    {
      'frame': '#02',
      'ratio': '3:2',
      'film': 'PORTRA 400',
      'mp': '24.3 MP',
      'title': 'Ban công phố cổ Phan Huy Chú',
      'image': MockTestAssets.samplePhoto2,
      'camera': 'Leica M6 Classic',
      'lens': 'Summicron 35mm f/2 ASPH',
      'scanner': 'Noritsu HS-1800',
      'exif': '1/500s • f/4.0 • ISO 400',
      'fileSize': '19.1 MB TIFF',
    },
    {
      'frame': '#03',
      'ratio': '3:2',
      'film': 'PORTRA 400',
      'mp': '23.8 MP',
      'title': 'Bóng chiều nghiêng Chợ Lớn',
      'image': MockTestAssets.samplePhoto3,
      'camera': 'Contax T2',
      'lens': 'Carl Zeiss Sonnar 38mm f/2.8',
      'scanner': 'Fuji Frontier SP-3000',
      'exif': '1/125s • f/5.6 • ISO 400',
      'fileSize': '16.5 MB TIFF',
    },
    {
      'frame': '#04',
      'ratio': '6:7',
      'film': 'PORTRA 400 120',
      'mp': '48.0 MP',
      'title': 'Tĩnh vật gốm mộc & hoa bưởi',
      'image': MockTestAssets.samplePhoto4,
      'camera': 'Mamiya RB67 Pro SD',
      'lens': 'Sekor C 90mm f/3.8',
      'scanner': 'Noritsu HS-1800 Medium Format',
      'exif': '1/60s • f/8.0 • ISO 400',
      'fileSize': '42.8 MB TIFF',
    },
  ];

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedFrames.contains(index)) {
        _selectedFrames.remove(index);
      } else {
        _selectedFrames.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'KHO ẢNH SỐ (ARCHIVE)',
              style: AppTypography.cardTitle.copyWith(letterSpacing: 1.0, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined, size: 20),
            tooltip: 'Albums',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlbumDetailScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined, size: 20),
            tooltip: 'Tải trọn bộ ZIP',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang xuất gói tệp nén ZIP ảnh gốc TIFF/JPG...')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Storage Gauge Card (Stitch APP-CUS-13)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text('ĐỒNG BỘ TỰ ĐỘNG TỪ LAB', style: AppTypography.labelCaps.copyWith(color: AppColors.secondary)),
                            ],
                          ),
                          Text('14.2 / 50 GB', style: AppTypography.dataMono.copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Kho Lưu Trữ Digital Archive', style: AppTypography.cardTitle),
                      const SizedBox(height: 2),
                      Text('Ảnh quét độ phân giải cao định dạng gốc TIFF & JPEG bảo quản vĩnh viễn', style: AppTypography.bodySmall),
                      const SizedBox(height: 12),

                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 6,
                          color: AppColors.outline,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: 0.284,
                              child: Container(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('28.4% dung lượng đã dùng', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                          Text('Còn trống 35.8 GB', style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Command buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đang nén toàn bộ 4 cuộn phim vào file ZIP...')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.outline),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.archive_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('Tải trọn bộ ZIP', style: AppTypography.button.copyWith(color: AppColors.ink, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AlbumDetailScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined, size: 16),
                            const SizedBox(width: 6),
                            Text('+ Tạo Album Mới', style: AppTypography.button.copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Batch info ribbon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.camera_roll, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text('LÔ PHIM #LL-2024-098', style: AppTypography.labelCaps),
                        ],
                      ),
                      Text('NORITSU HS-1800', style: AppTypography.dataMono.copyWith(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Proof Sheet 2x2 Grid (Stitch APP-CUS-13)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _frames.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final item = _frames[index];
                    final isSelected = _selectedFrames.contains(index);

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoDetailScreen(photoData: item),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.outline,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Frame Image with selection check & sprocket ratio
                            Expanded(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  MockTestAssets.image(item['image'], fit: BoxFit.cover),
                                  if (isSelected)
                                    Container(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                    ),
                                  // Selection tick
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: InkWell(
                                      onTap: () => _toggleSelection(index),
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isSelected ? Icons.check : Icons.crop_square,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Sprocket Code Marking
                                  Positioned(
                                    bottom: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        '${item['frame']} • ${item['ratio']}',
                                        style: AppTypography.dataMono.copyWith(fontSize: 9, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Frame Metadata Strip
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item['film'],
                                        style: AppTypography.dataMono.copyWith(
                                          fontSize: 9,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        item['mp'],
                                        style: AppTypography.labelCaps.copyWith(fontSize: 9, color: AppColors.inkMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['title'],
                                    style: AppTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Sticky Batch Floating Bar (Stitch APP-CUS-13)
          if (_selectedFrames.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '${_selectedFrames.length}',
                          style: AppTypography.dataMono.copyWith(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đã chọn ${_selectedFrames.length} ảnh gốc',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã thêm ${_selectedFrames.length} ảnh vào Album')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(50, 30),
                      ),
                      child: Text('+ Album', style: AppTypography.button.copyWith(color: Colors.white, fontSize: 11)),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đang tải ${_selectedFrames.length} file TIFF gốc...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(50, 30),
                        elevation: 0,
                      ),
                      child: Text('Tải TIFF (${_selectedFrames.length})', style: AppTypography.button.copyWith(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
