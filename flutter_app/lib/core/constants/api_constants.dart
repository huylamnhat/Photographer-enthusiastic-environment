import 'package:flutter/foundation.dart';

class ApiConstants {
  // Truyền qua --dart-define=API_BASE_URL=https://xxx.trycloudflare.com/api khi build Web/APK
  static const String envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // IP mạng LAN của máy tính: 192.168.1.7 (Port backend: 5000)
  static const String serverIp = '192.168.1.7';
  static const int port = 5000;

  static String get baseUrl {
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl.replaceAll(RegExp(r'/+$'), '');
    }
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:$port/api';
    }
    // Khi chạy native app trên điện thoại thật kết nối cùng Wi-Fi với máy tính
    return 'http://$serverIp:$port/api';
  }

  static const String emulatorBaseUrl = 'http://10.0.2.2:5000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerLab = '/auth/register-lab';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String me = '/auth/me';

  // Lab & Service endpoints
  static const String labs = '/labs';
  
  // Orders & Payment
  static const String orders = '/orders';
  static const String createOrder = '/orders/create';
  static const String payments = '/payments/process';
  static const String receipt = '/payments/receipt';
  static const String vnpayCreate = '/payments/vnpay/create';
  static const String vnpayStatus = '/payments/vnpay/status';
  static const String vnpayConfigStatus = '/payments/vnpay/config-status';
  static const String paymentQrInfo = '/payments/qr-info';

  // Shipping (AhaMove Sandbox)
  static const String ahamoveEstimate = '/shipping/ahamove/estimate';
  static const String ahamoveOrders = '/shipping/ahamove/orders';

  // Archive
  static const String archivePhotos = '/archive/photos';
  static const String albums = '/archive/albums';

  // Marketplace
  static const String marketplaceListings = '/marketplace/listings';
  static const String createListing = '/marketplace/create';
  static const String myListings = '/marketplace/my-listings';

  // Community
  static const String posts = '/community/posts';
  static const String events = '/community/events';

  // Reviews
  static const String reviews = '/reviews';
}
