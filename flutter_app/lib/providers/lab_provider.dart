import 'package:flutter/material.dart';
import '../models/lab_model.dart';
import '../core/services/api_service.dart';

class LabProvider with ChangeNotifier {
  List<LabModel> _labs = [];
  bool _isLoading = false;
  String _selectedFormat = 'Tất cả';
  String _searchQuery = '';

  List<LabModel> get labs => _labs;
  bool get isLoading => _isLoading;
  String get selectedFormat => _selectedFormat;

  LabProvider() {
    fetchLabs();
  }

  Future<void> fetchLabs() async {
    _isLoading = true;
    notifyListeners();

    _labs = await ApiService().getLabs(search: _searchQuery);
    _isLoading = false;
    notifyListeners();
  }

  void setFormat(String format) {
    _selectedFormat = format;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    fetchLabs();
  }
}

