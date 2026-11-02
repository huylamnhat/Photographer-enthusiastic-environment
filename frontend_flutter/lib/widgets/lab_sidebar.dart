import 'package:flutter/material.dart';
import '../constants/theme.dart';

class LabSidebar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onSelect;

  const LabSidebar({
    super.key,
    required this.activeIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'title': '1. Tiếp nhận & Phân loại', 'code': 'WEB-LAB-03', 'icon': Icons.view_kanban_outlined},
      {'title': '2. Tải file scan & QC', 'code': 'WEB-LAB-04', 'icon': Icons.cloud_upload_outlined},
      {'title': '3. Dịch vụ & Bảng giá', 'code': 'WEB-LAB-05', 'icon': Icons.price_change_outlined},
      {'title': '4. Hồ sơ tiệm công khai', 'code': 'WEB-LAB-06', 'icon': Icons.storefront_outlined},
      {'title': '5. Xử lý khiếu nại', 'code': 'WEB-LAB-07', 'icon': Icons.report_problem_outlined},
      {'title': '6. Lịch sử đơn & SLA', 'code': 'WEB-LAB-08', 'icon': Icons.history_toggle_off_outlined},
    ];

    return Container(
      width: 256,
      color: LabColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Branding Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: LabColors.surfaceContainer,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: LabColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.motion_photos_on, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MINILAB ARCHIVE',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        color: LabColors.onSurface,
                      ),
                    ),
                    Text(
                      'LAB OPS',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: LabColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'VẬN HÀNH TIỆM LAB',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: LabColors.onSurfaceVariant,
              ),
            ),
          ),

          // Nav Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isActive = activeIndex == index;

                return InkWell(
                  onTap: () => onSelect(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? LabColors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 20,
                          color: isActive ? LabColors.onPrimaryContainer : LabColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans',
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                  color: isActive ? LabColors.onPrimaryContainer : LabColors.onSurface,
                                ),
                              ),
                              Text(
                                item['code'] as String,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Mono',
                                  fontSize: 10,
                                  color: isActive ? LabColors.onPrimaryContainer.withOpacity(0.8) : LabColors.outline,
                                ),
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
          ),

          // Station Status Footer
          Container(
            padding: const EdgeInsets.all(12),
            color: LabColors.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HỆ THỐNG TRẠM',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: LabColors.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: LabColors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'v4.8.2-LAB [ONLINE]',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Mono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: LabColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

