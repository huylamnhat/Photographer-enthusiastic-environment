import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class PortalNotificationBell extends StatelessWidget {
  final List<dynamic> notifications;
  final Future<List<dynamic>> Function() onRefresh;
  final void Function(int tabIndex) onNavigateTab;
  final String title;

  const PortalNotificationBell({
    super.key,
    required this.notifications,
    required this.onRefresh,
    required this.onNavigateTab,
    this.title = 'Thông báo hệ thống',
  });

  Color _severityColor(String? severity) {
    switch (severity) {
      case 'danger':
        return const Color(0xFFB91C1C);
      case 'warning':
        return const Color(0xFFD97706);
      default:
        return AppColors.primary;
    }
  }

  IconData _severityIcon(String? type) {
    switch (type) {
      case 'LAB_APPROVAL':
      case 'EXPERT_APPROVAL':
        return Icons.verified_user_outlined;
      case 'MARKETPLACE_APPROVAL':
        return Icons.storefront_outlined;
      case 'COMMUNITY_REPORT':
      case 'COMMUNITY_AUDIT':
        return Icons.forum_outlined;
      case 'DISPUTE':
      case 'LAB_DISPUTE':
        return Icons.gavel_outlined;
      case 'NEEDS_DRIVE_LINK':
        return Icons.add_to_drive_outlined;
      case 'ORDER_QUEUE':
        return Icons.inbox_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }

  Future<void> _openDialog(BuildContext context) async {
    final initialItems = await onRefresh();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        List<dynamic> currentItems = List<dynamic>.from(initialItems);
        bool refreshing = false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> handleManualRefresh() async {
              setDialogState(() => refreshing = true);
              final freshItems = await onRefresh();
              if (!ctx.mounted) return;
              setDialogState(() {
                currentItems = List<dynamic>.from(freshItems);
                refreshing = false;
              });
            }

            return Dialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Container(
                width: 480,
                constraints: const BoxConstraints(maxHeight: 520),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_outlined, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$title (${currentItems.length})',
                            style: AppTypography.cardTitle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (refreshing)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 18),
                            tooltip: 'Làm mới',
                            onPressed: handleManualRefresh,
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Đóng',
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.outline, height: 20),
                    if (currentItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 42, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                'Hiện không có thông báo mới',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: currentItems.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, idx) {
                            final item = currentItems[idx] as Map<String, dynamic>;
                            final accent = _severityColor(item['severity']?.toString());
                            final icon = _severityIcon(item['type']?.toString());
                            final tabIdx = item['tab_index'];

                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.of(dialogCtx).pop();
                                if (tabIdx is int) {
                                  onNavigateTab(tabIdx);
                                } else if (tabIdx is num) {
                                  onNavigateTab(tabIdx.toInt());
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSunken,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(icon, size: 18, color: accent),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title']?.toString() ?? 'Thông báo',
                                            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                          if ((item['subtitle']?.toString() ?? '').isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item['subtitle'].toString(),
                                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 20),
          tooltip: title,
          onPressed: () => _openDialog(context),
        ),
        if (notifications.isNotEmpty)
          Positioned(
            right: 5,
            top: 5,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  notifications.length > 99 ? '99+' : '${notifications.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
