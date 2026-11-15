import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/lab_model.dart';
import '../../models/order_model.dart';
import '../../models/archive_photo_model.dart';
import '../../models/listing_model.dart';
import '../../models/community_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  void setToken(String? token) => _token = token;

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Auth
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}'),
        headers: _headers(),
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối tới máy chủ Backend & SQL Server: $e',
      };
    }
  }

  // Labs
  Future<List<LabModel>> getLabs({String? search, String? city}) async {
    try {
      String url = '${ApiConstants.baseUrl}${ApiConstants.labs}';
      final params = <String>['_t=${DateTime.now().millisecondsSinceEpoch}'];
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (city != null && city.isNotEmpty) params.add('city=$city');
      url += '?${params.join('&')}';

      final res = await http.get(Uri.parse(url), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((l) => LabModel.fromJson(l)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<LabModel?> getLabById(String labId) async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.labs}/$labId?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] != null) {
        return LabModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  // Orders
  Future<List<OrderModel>> getOrders() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((o) => OrderModel.fromJson(o)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Create Order
  Future<OrderModel?> createOrder(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createOrder}'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] != null) {
        return OrderModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  // Get Order By Id
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final cleanId = orderId.replaceAll('#', '');
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}/$cleanId?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] != null) {
        return OrderModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  // Create Order Dispute (Mobile -> Lab & Admin)
  Future<bool> createOrderDispute(String orderId, Map<String, dynamic> body) async {
    try {
      final cleanId = orderId.replaceAll('#', '');
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}/$cleanId/dispute'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }

  // Submit Lab Review
  Future<bool> submitReview(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/reviews/create'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }

  // Customer Notifications (Compensation, Refunds, Google Drive Scan Links)
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}/notifications'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((n) => Map<String, dynamic>.from(n as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Archive Photos
  Future<List<ArchivePhotoModel>> getArchivePhotos({String? album}) async {
    try {
      String url = '${ApiConstants.baseUrl}${ApiConstants.archivePhotos}';
      if (album != null) url += '?album=$album';
      final res = await http.get(Uri.parse(url), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((p) => ArchivePhotoModel.fromJson(p)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Google Drive API Config & Upload
  Future<Map<String, dynamic>> getGoogleDriveConfig() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/archive/google-drive/config'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) {
        return data['data'];
      }
    } catch (_) {}
    return {};
  }

  Future<bool> saveGoogleDriveConfig(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/archive/google-drive/config'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>> uploadPhotoToGoogleDrive(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/archive/google-drive/upload'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // Marketplace
  Future<List<ListingModel>> getMarketplaceListings() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.marketplaceListings}?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((l) => ListingModel.fromJson(l)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<ListingModel>> getMyMarketplaceListings() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/marketplace/my-listings?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((l) => ListingModel.fromJson(l)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<ListingModel?> createMarketplaceListing(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createListing}'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] != null) {
        return ListingModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  // Community Posts
  Future<List<CommunityPostModel>> getCommunityPosts() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((p) => CommunityPostModel.fromJson(p)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<CommunityPostModel?> createCommunityPost(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/community/posts/create'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] != null) {
        return CommunityPostModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> reportCommunityPost(String postId, String reason) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}/$postId/report'),
        headers: _headers(),
        body: jsonEncode({'reason': reason}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }

  Future<bool> likeCommunityPost(String postId) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}/$postId/like'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }

  Future<bool> addCommunityComment(String postId, String content) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}/$postId/comments'),
        headers: _headers(),
        body: jsonEncode({'content': content}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }

  // Community Events (Workshops & Photowalks)
  Future<List<EventModel>> getEvents() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((e) => EventModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> registerForEvent(String eventId) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.events}/$eventId/register'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }

  // Film Lab Portal Live Interaction
  Future<Map<String, dynamic>> getLabKanban({String? labId}) async {
    try {
      String url = '${ApiConstants.baseUrl}/lab/kanban';
      if (labId != null && labId.isNotEmpty) {
        url += '?lab_id=$labId';
      }
      final res = await http.get(
        Uri.parse(url),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  Future<bool> updateKanbanStep(String orderId, String column, {String? note}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/lab/kanban/$orderId/step'),
        headers: _headers(),
        body: jsonEncode({'column': column, 'note': note}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {}
    return false;
  }
}
