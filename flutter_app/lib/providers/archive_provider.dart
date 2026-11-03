import 'package:flutter/material.dart';
import '../models/archive_photo_model.dart';
import '../core/services/api_service.dart';

class ArchiveProvider with ChangeNotifier {
  List<ArchivePhotoModel> _photos = [];
  bool _isLoading = false;
  String _selectedAlbum = 'Tất cả';

  List<ArchivePhotoModel> get photos => _photos;
  bool get isLoading => _isLoading;
  String get selectedAlbum => _selectedAlbum;

  ArchiveProvider() {
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    _isLoading = true;
    notifyListeners();

    _photos = await ApiService().getArchivePhotos(
      album: _selectedAlbum == 'Tất cả' ? null : _selectedAlbum,
    );
    _isLoading = false;
    notifyListeners();
  }

  void selectAlbum(String album) {
    _selectedAlbum = album;
    fetchPhotos();
  }

  void toggleFavorite(String photoId) {
    final idx = _photos.indexWhere((p) => p.photoId == photoId);
    if (idx != -1) {
      _photos[idx].isFavorite = !_photos[idx].isFavorite;
      notifyListeners();
    }
  }
}

