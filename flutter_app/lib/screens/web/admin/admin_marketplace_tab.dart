import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';
import '../../../core/services/web_api_service.dart';

class AdminMarketplaceTab extends StatefulWidget {
  const AdminMarketplaceTab({super.key});

  @override
  State<AdminMarketplaceTab> createState() => _AdminMarketplaceTabState();
}

class _AdminMarketplaceTabState extends State<AdminMarketplaceTab> {
  List<Map<String, dynamic>> _queue = [];
  int _selectedListingIdx = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingMarketplace();
  }

  Future<void> _loadPendingMarketplace() async {
    final pending = await WebApiService().getAdminPendingMarketplace();
    if (!mounted) return;
    final mapped = pending.map<Map<String, dynamic>>((m) {
      final rawStatus = (m['status'] ?? 'PENDING_REVIEW').toString().toUpperCase();
      final modStatus = (m['moderation_status'] ?? '').toString().toUpperCase();
      final isApproved = rawStatus == 'ACTIVE' || rawStatus == 'APPROVED' || modStatus == 'APPROVED';
      final isRejected = rawStatus == 'REJECTED' || modStatus == 'REJECTED';
      final isCompleted = isApproved || isRejected;
      final imgs = (m['image_urls'] as List?)?.map((e) => e.toString()).where((s) => s.isNotEmpty).toList() ?? [];
      final checklistRaw = m['mechanical_checklist'];
      final checklist = <String, dynamic>{
        'Tình trạng khai báo': (m['condition'] ?? 'Hoạt động chuẩn xác').toString(),
        if (checklistRaw is Map)
          ...checklistRaw.map((k, v) => MapEntry(k.toString(), v.toString()))
        else
          'Bộ đo sáng & Cơ tốc': 'Đã kiểm tra thông tin mô tả thiết bị',
      };
      return {
        'id': (m['listing_id'] ?? '').toString(),
        'title': (m['title'] ?? '').toString(),
        'seller': (m['seller_name'] ?? '').toString(),
        'sellerPhone': (m['phone_contact'] ?? '').toString(),
        'serialNumber': 'SN-${(m['listing_id'] ?? '').toString().toUpperCase()}',
        'category': (m['category'] ?? '').toString(),
        'price': m['price'] ?? 0,
        'status': isApproved ? 'APPROVED' : (isRejected ? 'REJECTED' : 'PENDING_REVIEW'),
        'isApproved': isApproved,
        'isRejected': isRejected,
        'isCompleted': isCompleted,
        'rejectionReason': (m['rejection_reason'] ?? '').toString(),
        'location': (m['location'] ?? 'Việt Nam').toString(),
        'photos': imgs.isNotEmpty ? imgs : [MockTestAssets.equipLeicaM6],
        'mechanicalChecklist': checklist,
        'description': (m['description'] ?? '').toString(),
      };
    }).toList();

    mapped.sort((a, b) {
      final aDone = a['isCompleted'] == true ? 1 : 0;
      final bDone = b['isCompleted'] == true ? 1 : 0;
      return aDone.compareTo(bDone);
    });

    setState(() {
      _queue = mapped;
      if (_queue.isEmpty) {
        _selectedListingIdx = 0;
      } else if (_selectedListingIdx >= _queue.length) {
        _selectedListingIdx = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasItems = _queue.isNotEmpty;
    final safeIdx = hasItems ? _selectedListingIdx.clamp(0, _queue.length - 1) : 0;
    final item = hasItems ? _queue[safeIdx] : null;

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
                  Text('WEB-ADM-05 // TIỀN KIỂM SÀN MUA BÁN (SQL SERVER)', style: AppTypography.labelCaps),
                  SizedBox(height: 4),
                  Text('Hàng chờ Kiểm định Tin rao bán Thiết bị', style: AppTypography.pageTitle),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _loadPendingMarketplace,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Đồng bộ Hàng chờ'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (!hasItems)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Center(child: Text('Không có tin đăng nào đang chờ duyệt', style: AppTypography.cardTitle)),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        final isSel = idx == safeIdx;
                        return ListTile(
                          selected: isSel,
                          selectedTileColor: AppColors.surfaceSunken,
                          title: Text(q['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('${q['category']} · Giá: ${q['price']}đ\nNgười bán: ${q['seller']}', style: AppTypography.caption),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: q['isApproved'] == true
                                  ? AppColors.successBg
                                  : (q['isRejected'] == true ? AppColors.dangerBg : AppColors.warningBg),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              q['isApproved'] == true
                                  ? 'ĐÃ DUYỆT'
                                  : (q['isRejected'] == true ? 'ĐÃ TỪ CHỐI' : 'CHỜ DUYỆT'),
                              style: TextStyle(
                                color: q['isApproved'] == true
                                    ? AppColors.secondary
                                    : (q['isRejected'] == true ? AppColors.danger : AppColors.warning),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () => setState(() => _selectedListingIdx = idx),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                if (item != null)
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['id'], style: AppTypography.dataMono.copyWith(color: AppColors.primary)),
                                    Text(item['title'], style: AppTypography.sectionHeading),
                                  ],
                                ),
                              ),
                              if (item['isCompleted'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: item['isApproved'] == true ? AppColors.successBg : AppColors.dangerBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['isApproved'] == true ? 'ĐÃ DUYỆT HIỂN THỊ' : 'ĐÃ TỪ CHỐI TIN ĐĂNG',
                                    style: TextStyle(
                                      color: item['isApproved'] == true ? AppColors.secondary : AppColors.danger,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                      onPressed: () async {
                                        final ok = await WebApiService().moderateMarketplace(item['id'], 'REJECT');
                                        if (!context.mounted) return;
                                        if (ok) {
                                          await _loadPendingMarketplace();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Đã từ chối tin đăng ${item['title']}')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text('Từ chối'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final ok = await WebApiService().moderateMarketplace(item['id'], 'APPROVE');
                                        if (!context.mounted) return;
                                        if (ok) {
                                          await _loadPendingMarketplace();
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Đã duyệt tin ${item['title']} hiển thị lên sàn Marketplace!')),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Duyệt tin đăng'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          if (item['isRejected'] == true && (item['rejectionReason'] as String).isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.dangerBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Lý do từ chối: ${item['rejectionReason']}',
                                style: AppTypography.caption.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              _buildDetailField('GIÁ BÁN NIÊM YẾT', '${item['price']} đ'),
                              _buildDetailField('MÃ ĐỊNH DANH', item['serialNumber']),
                              _buildDetailField('NGƯỜI BÁN & SĐT', '${item['seller']} (${item['sellerPhone']})'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text('MÔ TẢ CHI TIẾT CỦA NGƯỜI BÁN:', style: AppTypography.labelCaps),
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
                                      Expanded(child: Text(e.value.toString(), style: AppTypography.caption)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Text('ẢNH CHỤP THẬT MÁY:', style: AppTypography.labelCaps),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: (item['photos'] as List).map<Widget>((photoUrl) {
                              return Container(
                                width: 120,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: MockTestAssets.image(
                                  photoUrl.toString(),
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
