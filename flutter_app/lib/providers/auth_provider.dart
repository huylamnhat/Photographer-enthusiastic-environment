import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _token;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Default logged in user for immediate experience
    _currentUser = UserModel(
      userId: 'usr-001',
      email: 'khachhang@minilab.vn',
      phone: '0912345678',
      fullName: 'Nguyễn Hoàng Anh',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      role: 'Customer',
      address: '123 Phố Huế, Hai Bà Trưng, Hà Nội',
    );
  }

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService().login(identifier, password);
      if (res['success'] == true) {
        _token = res['token'];
        ApiService().setToken(_token);
        _currentUser = UserModel.fromJson(res['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return true; // demo convenience
  }

  void logout() {
    _currentUser = null;
    _token = null;
    ApiService().setToken(null);
    notifyListeners();
  }
}

