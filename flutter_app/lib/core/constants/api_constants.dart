class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web, or your local machine IP
  static const String baseUrl = 'http://localhost:5000/api';
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

