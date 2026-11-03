import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/lab_provider.dart';
import 'lab_detail_screen.dart';

class LabSearchScreen extends StatefulWidget {
  const LabSearchScreen({super.key});

  @override
  State<LabSearchScreen> createState() => _LabSearchScreenState();
}

class _LabSearchScreenState extends State<LabSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCity = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final labProvider = context.watch<LabProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm & So sánh Film Lab'),
      ),
      body: Column(
        children: [
          // Search Bar & Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surfaceRaised,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => labProvider.search(val),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppColors.inkMuted),
                    hintText: 'Tìm theo tên lab, địa chỉ, máy scan...',
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              labProvider.search('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.inkMuted),
                    const SizedBox(width: 4),
                    const Text('Khu vực: ', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                    const SizedBox(width: 8),
                    _buildCityTab('Tất cả'),
                    const SizedBox(width: 6),
                    _buildCityTab('Hà Nội'),
                    const SizedBox(width: 6),
                    _buildCityTab('TP.HCM'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Lab List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: labProvider.labs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final lab = labProvider.labs[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LabDetailScreen(lab: lab)),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(lab.coverImage, width: 60, height: 60, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(lab.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(lab.address, style: const TextStyle(fontSize: 12, color: AppColors.inkMuted), maxLines: 1),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 14),
                                        Text(' ${lab.rating} (${lab.reviewCount})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        Text(lab.priceRange, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            children: [
                              ...lab.scannerModels.map((s) => _buildBadge(s, Colors.blueGrey)),
                              ...lab.supportedProcesses.map((p) => _buildBadge(p, AppColors.secondary)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityTab(String city) {
    final isSelected = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
        ),
        child: Text(
          city,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? AppColors.primary : AppColors.inkMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

