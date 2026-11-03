import 'package:flutter/material.dart';
import '../models/community_model.dart';
import '../core/services/api_service.dart';

class CommunityProvider with ChangeNotifier {
  List<CommunityPostModel> _posts = [];
  bool _isLoading = false;

  List<CommunityPostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  CommunityProvider() {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    _posts = await ApiService().getCommunityPosts();
    _isLoading = false;
    notifyListeners();
  }

  void addPost(CommunityPostModel post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final idx = _posts.indexWhere((p) => p.postId == postId);
    if (idx != -1) {
      _posts[idx].likesCount += 1;
      notifyListeners();
    }
  }
}

