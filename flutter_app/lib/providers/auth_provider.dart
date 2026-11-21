import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/web_api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _token;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  UserModel? get user => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage;

  AuthProvider();

  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService().login(identifier, password);
      if (res['success'] == true && res['user'] != null) {
        _token = res['token'];
        ApiService().setToken(_token);
        WebApiService().setToken(_token);
        _currentUser = UserModel.fromJson(res['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = res['message']?.toString() ?? 'Tài khoản hoặc mật khẩu không chính xác';
      }
    } catch (e) {
      _errorMessage = 'Không thể kết nối tới máy chủ: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void setAuthenticatedUser(String token, Map<String, dynamic> userJson) {
    _token = token;
    ApiService().setToken(_token);
    WebApiService().setToken(_token);
    _currentUser = UserModel.fromJson(userJson);
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _token = null;
    _errorMessage = null;
    ApiService().setToken(null);
    WebApiService().setToken(null);
    notifyListeners();
  }
}
