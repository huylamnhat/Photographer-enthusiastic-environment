import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'screens/screen_01_lab_register.dart';
import 'screens/screen_02_lab_login.dart';
import 'screens/screen_03_kanban_board.dart';
import 'screens/screen_04_scan_qc.dart';
import 'screens/screen_05_services_pricing.dart';
import 'screens/screen_06_public_profile.dart';
import 'screens/screen_07_disputes.dart';
import 'screens/screen_08_sla_reports.dart';
import 'widgets/lab_header.dart';
import 'widgets/lab_sidebar.dart';

void main() {
  runApp(const MiniLabApp());
}

class MiniLabApp extends StatelessWidget {
  const MiniLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiniLab Film Lab Ops Portal',
      debugShowCheckedModeBanner: false,
      theme: LabTheme.lightTheme,
      darkTheme: LabTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainPortalFlow(),
    );
  }
}

class MainPortalFlow extends StatefulWidget {
  const MainPortalFlow({super.key});

  @override
  State<MainPortalFlow> createState() => _MainPortalFlowState();
}

class _MainPortalFlowState extends State<MainPortalFlow> {
  bool isLoggedIn = false;
  bool isRegisterView = false;
  int activeIndex = 0;
  String currentQCOrderId = 'ORD-2024-88412';

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      if (isRegisterView) {
        return LabRegisterScreen(
          onNavigateToLogin: () => setState(() => isRegisterView = false),
        );
      }
      return LabLoginScreen(
        onLoginSuccess: () => setState(() => isLoggedIn = true),
        onNavigateToRegister: () => setState(() => isRegisterView = true),
      );
    }

    // Authenticated Portal Layout
    return Scaffold(
      body: Row(
        children: [
          // Left persistent navigation sidebar
          LabSidebar(
            activeIndex: activeIndex,
            onSelect: (index) => setState(() => activeIndex = index),
          ),

          // Main Screen area with Top Header
          Expanded(
            child: Column(
              children: [
                LabHeader(
                  onLogout: () => setState(() {
                    isLoggedIn = false;
                    activeIndex = 0;
                  }),
                ),
                Expanded(
                  child: _buildActiveScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveScreen() {
    switch (activeIndex) {
      case 0:
        return KanbanBoardScreen(
          onOpenQC: (orderId) {
            setState(() {
              currentQCOrderId = orderId;
              activeIndex = 1; // Switch to QC screen
            });
          },
        );
      case 1:
        return ScanQCScreen(orderId: currentQCOrderId);
      case 2:
        return const ServicesPricingScreen();
      case 3:
        return const PublicProfileScreen();
      case 4:
        return const DisputesScreen();
      case 5:
        return const SlaReportsScreen();
      default:
        return const KanbanBoardScreen();
    }
  }
}

