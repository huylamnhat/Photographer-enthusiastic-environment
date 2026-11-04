import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'home/home_screen.dart';
import 'home/lab_search_screen.dart';
import 'orders/order_list_screen.dart';
import 'archive/archive_gallery_screen.dart';
import 'community/community_feed_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const LabSearchScreen(),
    const OrderListScreen(),
    const ArchiveGalleryScreen(),
    const CommunityFeedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(
            top: BorderSide(color: AppColors.outline, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AppColors.surfaceRaised,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.inkMuted,
          selectedLabelStyle: AppTypography.labelCaps.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTypography.labelCaps.copyWith(
            fontSize: 10,
            color: AppColors.inkMuted,
          ),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined, size: 20),
              activeIcon: Icon(Icons.explore, size: 20),
              label: 'Khám phá',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science_outlined, size: 20),
              activeIcon: Icon(Icons.science, size: 20),
              label: 'Film Lab',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined, size: 20),
              activeIcon: Icon(Icons.receipt_long, size: 20),
              label: 'Đơn hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library_outlined, size: 20),
              activeIcon: Icon(Icons.photo_library, size: 20),
              label: 'Kho ảnh',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined, size: 20),
              activeIcon: Icon(Icons.groups, size: 20),
              label: 'Cộng đồng',
            ),
          ],
        ),
      ),
    );
  }
}
