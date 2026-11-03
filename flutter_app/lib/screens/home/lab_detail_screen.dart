import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/lab_model.dart';
import 'create_order_screen.dart';

class LabDetailScreen extends StatelessWidget {
  final LabModel lab;

  const LabDetailScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                lab.coverImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lab.name,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text('Đối tác xác thực', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(lab.tagline, style: const TextStyle(color: AppColors.inkMuted, fontSize: 13, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(' ${lab.rating} ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('(${lab.reviewCount} đánh giá)', style: const TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                      const Spacer(),
                      const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('Xử lý: ~${lab.turnaroundHours}h', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  const Text('Giới thiệu tiệm Lab', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(lab.description, style: const TextStyle(fontSize: 13, color: AppColors.inkMuted, height: 1.4)),

                  const SizedBox(height: 16),
                  const Text('Trang thiết bị máy scan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: lab.scannerModels.map((m) => Chip(
                      label: Text(m, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(Icons.scanner, size: 16),
                      backgroundColor: AppColors.surfaceRaised,
                    )).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text('Bảng giá dịch vụ Tráng & Scan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  if (lab.packages.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: const Text('Gói cơ bản: 50.000đ / cuộn 135 C-41 • 65.000đ / B&W'),
                    )
                  else
                    ...lab.packages.map((pkg) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text('${pkg.filmFormat} • ${pkg.processType} • ${pkg.scanResolution}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${pkg.price.toInt()}đ',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        )),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreateOrderScreen(lab: lab)),
              );
            },
            child: const Text('Đặt dịch vụ tráng / scan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

