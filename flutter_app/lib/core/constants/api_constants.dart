import 'package:flutter/foundation.dart';

class ApiConstants {
  // IP mạng LAN của máy tính: 192.168.1.7 (Port backend: 5000)
  static const String serverIp = '192.168.1.7';
  static const int port = 5000;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }
    // Khi chạy native app trên điện thoại thật kết nối cùng Wi-Fi với máy tính
    return 'http://$serverIp:$port/api';
  }

  static const String emulatorBaseUrl = 'http://10.0.2.2:5000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
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
