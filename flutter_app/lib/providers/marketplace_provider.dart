import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../core/services/api_service.dart';

class MarketplaceProvider with ChangeNotifier {
  List<ListingModel> _listings = [];
  bool _isLoading = false;

  List<ListingModel> get listings => _listings;
  bool get isLoading => _isLoading;

  MarketplaceProvider() {
    fetchListings();
  }

  Future<void> fetchListings() async {
    _isLoading = true;
    notifyListeners();

    _listings = await ApiService().getMarketplaceListings();
    _isLoading = false;
    notifyListeners();
  }

  void addListing(ListingModel item) {
    _listings.insert(0, item);
    notifyListeners();
  }
}

