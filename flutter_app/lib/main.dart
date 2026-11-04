import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/lab_provider.dart';
import 'providers/order_provider.dart';
import 'providers/archive_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/community_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/web/web_login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiniLabApp());
}

class MiniLabApp extends StatelessWidget {
  const MiniLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LabProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ArchiveProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
      ],
      child: MaterialApp(
        title: 'MiniLab - Nền tảng Nhiếp ảnh Phim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // Tự động nhận diện thiết bị:
        // - Màn hình máy tính (PC / Laptop / Web >= 720px): Vào Cổng Quản Trị Admin & Film Lab
        // - Màn hình điện thoại (Mobile App hoặc Trình duyệt điện thoại < 720px): Vào App Khách Hàng
        home: const PlatformAdaptiveGate(),
      ),
    );
  }
}

class PlatformAdaptiveGate extends StatelessWidget {
  const PlatformAdaptiveGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const LoginScreen();
    }
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 720) {
      return const LoginScreen();
    }
    return const WebLoginScreen();
  }
}
