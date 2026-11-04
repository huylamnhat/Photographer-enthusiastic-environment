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
import 'screens/navigation_shell.dart';
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
        // On Web or Desktop: Start with Unified Web Login (Auto-routes to Admin, Lab, or Customer)
        home: kIsWeb ? const WebLoginScreen() : const NavigationShell(),
      ),
    );
  }
}
