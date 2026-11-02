import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../services/api_service.dart';

class LabHeader extends StatelessWidget {
  final VoidCallback? onLogout;

  const LabHeader({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: LabColors.surface.withOpacity(0.95),
        border: const Border(
          bottom: BorderSide(color: LabColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Location & Search
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LabColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: LabColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Saigon Darkroom - Chi nhánh Q.3',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: LabColors.onSurface,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.expand_more, color: LabColors.outline, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: LabColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: LabColors.outlineVariant, width: 0.5),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: LabColors.outline, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tìm roll ID, khách hàng...',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 13,
                          color: LabColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      '⌘K',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Mono',
                        fontSize: 11,
                        color: LabColors.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right: Notifications & Profile
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: LabColors.onSurfaceVariant, size: 22),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        user?.fullName ?? 'Lê Hoài Nam',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: LabColors.onSurface,
                        ),
                      ),
                      Text(
                        user?.title ?? 'KỸ THUẬT VIÊN TRƯỞNG',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: LabColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: LabColors.primary,
                    child: const Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  if (onLogout != null) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Đăng xuất trạm',
                      icon: const Icon(Icons.logout, size: 18, color: LabColors.outline),
                      onPressed: onLogout,
                    ),
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

