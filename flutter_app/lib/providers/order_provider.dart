import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../core/services/api_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  OrderProvider() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    _orders = await ApiService().getOrders();
    _isLoading = false;
    notifyListeners();
  }

  Future<OrderModel?> addOrder(Map<String, dynamic> body) async {
    _isLoading = true;
    notifyListeners();

    final order = await ApiService().createOrder(body);
    if (order != null) {
      _orders.insert(0, order);
    }
    _isLoading = false;
    notifyListeners();
    return order;
  }
}

