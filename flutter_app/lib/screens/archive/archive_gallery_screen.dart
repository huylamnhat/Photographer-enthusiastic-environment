import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/local_image_picker.dart';
import '../../models/order_model.dart';

class ArchiveGalleryScreen extends StatefulWidget {
  final String? initialOrderId;
  const ArchiveGalleryScreen({super.key, this.initialOrderId});

  @override
  State<ArchiveGalleryScreen> createState() => _ArchiveGalleryScreenState();
}

class _ArchiveGalleryScreenState extends State<ArchiveGalleryScreen> {
  bool _loading = false;
  List<OrderModel> _orders = [];
  Timer? _refreshTimer;

  String _lastSignature = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) {
        if (mounted && (ModalRoute.of(context)?.isCurrent ?? true)) {
          _loadOrders(silent: true);
        }
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders({bool silent = false}) async {
    if (!silent) {
      setState(() => _loading = true);
    }
    final list = await ApiService().getOrders();
    if (!mounted) return;

    final sig = list.map((o) => '${o.orderId}:${o.driveLink ?? ""}:${o.driveLinkHistory.length}').join('|');
    if (silent && sig == _lastSignature) return;
    _lastSignature = sig;

    final sorted = List<OrderModel>.from(list);
    if (widget.initialOrderId != null && widget.initialOrderId!.isNotEmpty) {
      sorted.sort((a, b) {
        final aMatch = a.orderId == widget.initialOrderId ? 0 : 1;
        final bMatch = b.orderId == widget.initialOrderId ? 0 : 1;
        return aMatch.compareTo(bMatch);
      });
    }

    setState(() {
      _orders = sorted;
      _loading = false;
    });
  }

  List<String> _resolveOrderLinks(OrderModel order) {
    final result = <String>[];
    for (final link in order.driveLinkHistory) {
      final clean = sanitizeGoogleDriveUrl(link);
      if (clean.isNotEmpty && !result.contains(clean)) {
        result.add(clean);
      }
    }
    if (order.driveLink != null && order.driveLink!.trim().isNotEmpty) {
      final clean = sanitizeGoogleDriveUrl(order.driveLink!);
      if (clean.isNotEmpty && !result.contains(clean)) {
        result.insert(0, clean);
      }
    }
    return result;
  }

  String _formatFilms(OrderModel order) {
    if (order.items.isEmpty) return 'Dịch vụ tráng & scan phim';
    return order.items.map((i) {
      final title = i.filmName.isNotEmpty ? i.filmName : i.name;
      if (i.name.isNotEmpty && i.filmName.isNotEmpty && i.name != i.filmName) {
        return '${i.quantity}x $title (${i.name})';
      }
      return '${i.quantity}x $title';
    }).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final linkedCount = _orders.where((o) => _resolveOrderLinks(o).isNotEmpty).length;

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
              'KHO ẢNH CỦA TÔI',
              style: AppTypography.cardTitle.copyWith(letterSpacing: 1.0, fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 20, color: AppColors.primary),
            tooltip: 'Làm mới',
            onPressed: _loadOrders,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LINK ẢNH THEO ĐƠN HÀNG',
                      style: AppTypography.labelCaps.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$linkedCount / ${_orders.length} đơn đã có ảnh',
                      style: AppTypography.dataMono.copyWith(
                        fontSize: 11,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (_loading && _orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (_orders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.link_off, size: 36, color: AppColors.inkMuted),
                      const SizedBox(height: 8),
                      Text(
                        'Bạn chưa có đơn tráng phim nào.',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final links = _resolveOrderLinks(order);
                    final isHighlighted = widget.initialOrderId != null &&
                        widget.initialOrderId == order.orderId;
                    final hasLinks = links.isNotEmpty;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isHighlighted ? AppColors.primary : AppColors.outline,
                          width: isHighlighted ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${order.orderId}',
                                style: AppTypography.dataMono.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 13,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: hasLinks
                                      ? AppColors.secondary.withValues(alpha: 0.12)
                                      : AppColors.surfaceSunken,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  hasLinks ? 'ĐÃ CÓ LINK DRIVE' : 'CHỜ LAB TRẢ LINK',
                                  style: AppTypography.dataMono.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: hasLinks ? AppColors.secondary : AppColors.inkMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order.labName,
                            style: AppTypography.cardTitle.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatFilms(order),
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (!hasLinks)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.outline),
                              ),
                              child: Text(
                                'Lab chưa gửi link Google Drive cho đơn #${order.orderId}.',
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            )
                          else
                            ...links.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final url = entry.value;
                              final isLatest = idx == 0;
                              return Container(
                                margin: EdgeInsets.only(bottom: idx < links.length - 1 ? 8 : 0),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isLatest ? const Color(0xFFF3F8FF) : AppColors.surfaceSunken,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isLatest
                                        ? const Color(0xFF90CAF9)
                                        : AppColors.outline,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLatest
                                          ? 'LINK GOOGLE DRIVE CHÍNH THỨC'
                                          : 'LINK BỔ SUNG #${links.length - idx}',
                                      style: AppTypography.labelCaps.copyWith(
                                        fontSize: 9,
                                        color: isLatest ? const Color(0xFF1565C0) : AppColors.inkMuted,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SelectableText(
                                      url,
                                      style: AppTypography.dataMono.copyWith(
                                        fontSize: 11,
                                        color: isLatest ? const Color(0xFF0D47A1) : AppColors.ink,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            final clean = await copyTextSafe(url);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Đã sao chép link: $clean')),
                                            );
                                          },
                                          icon: const Icon(Icons.copy, size: 14),
                                          label: const Text('Sao chép link', style: TextStyle(fontSize: 11)),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () => openUrlInNewTab(url),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1565C0),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          ),
                                          icon: const Icon(Icons.open_in_new, size: 14),
                                          label: const Text('Mở Drive', style: TextStyle(fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
