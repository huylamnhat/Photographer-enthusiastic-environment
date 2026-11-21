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

  Future<Map<String, dynamic>> registerCustomer(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String target, String otp) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.verifyOtp}'),
        headers: _headers(),
        body: jsonEncode({'target': target, 'otp': otp}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ: $e'};
    }
  }

  Future<Map<String, dynamic>> registerLab(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerLab}'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối tới máy chủ: $e'};
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
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) {
        return (data['data'] as List).map((p) => CommunityPostModel.fromJson(p)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<CommunityPostModel?> getCommunityPostById(String postId) async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}/$postId?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) {
        return CommunityPostModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
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

  Future<Map<String, dynamic>?> likeCommunityPost(String postId) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}/$postId/like'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> addCommunityComment(String postId, String content) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}/$postId/comments'),
        headers: _headers(),
        body: jsonEncode({'content': content}),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return null;
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

  // VNPAY Payment Gateway v2.1.0
  Future<Map<String, dynamic>> createVnpayPayment({
    required String orderId,
    required double amount,
    String? orderInfo,
    String? bankCode,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.vnpayCreate}'),
        headers: _headers(),
        body: jsonEncode({
          'order_id': orderId,
          'amount': amount.round(),
          if (orderInfo != null && orderInfo.isNotEmpty) 'order_info': orderInfo,
          if (bankCode != null && bankCode.isNotEmpty) 'bank_code': bankCode,
        }),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối VNPAY: $e'};
    }
    return {'success': false, 'message': 'Không thể khởi tạo giao dịch VNPAY'};
  }

  Future<Map<String, dynamic>> checkVnpayPaymentStatus(String orderId) async {
    try {
      final cleanId = orderId.replaceAll('#', '');
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.vnpayStatus}/$cleanId?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return {'success': false, 'data': {'paid': false}};
  }

  Future<Map<String, dynamic>> getOrderQrInfo(String orderId) async {
    try {
      final cleanId = orderId.replaceAll('#', '');
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.paymentQrInfo}/$cleanId?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối lấy thông tin QR: $e'};
    }
    return {'success': false, 'message': 'Không lấy được thông tin QR thanh toán'};
  }

  // AhaMove Sandbox Shipping
  Future<Map<String, dynamic>> estimateAhamoveFee({
    required String labId,
    required String pickupAddress,
    String? pickupPhone,
    double itemValue = 100000,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ahamoveEstimate}'),
        headers: _headers(),
        body: jsonEncode({
          'lab_id': labId,
          'pickup_address': pickupAddress,
          if (pickupPhone != null && pickupPhone.isNotEmpty) 'pickup_phone': pickupPhone,
          'item_value': itemValue,
        }),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối ước tính phí AhaMove: $e'};
    }
    return {'success': false, 'message': 'Không ước tính được phí ship AhaMove'};
  }

  Future<Map<String, dynamic>> bookAhamovePickup(
    String orderId, {
    String? pickupAddress,
    String? pickupPhone,
    String? remarks,
  }) async {
    try {
      final cleanId = orderId.replaceAll('#', '');
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ahamoveOrders}/$cleanId/book'),
        headers: _headers(),
        body: jsonEncode({
          if (pickupAddress != null && pickupAddress.isNotEmpty) 'pickup_address': pickupAddress,
          if (pickupPhone != null && pickupPhone.isNotEmpty) 'pickup_phone': pickupPhone,
          if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
        }),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi đặt tài xế AhaMove: $e'};
    }
    return {'success': false, 'message': 'Không đặt được tài xế AhaMove'};
  }

  Future<Map<String, dynamic>> getAhamoveShipmentStatus(String orderId) async {
    try {
      final cleanId = orderId.replaceAll('#', '');
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ahamoveOrders}/$cleanId?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
    } catch (_) {}
    return {'success': false};
  }

  Future<Map<String, dynamic>> cancelAhamovePickup(String orderId, {String? comment}) async {
    try {
      final cleanId = orderId.replaceAll('#', '');
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.ahamoveOrders}/$cleanId/cancel'),
        headers: _headers(),
        body: jsonEncode({if (comment != null && comment.isNotEmpty) 'comment': comment}),
      );
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi hủy vận đơn AhaMove: $e'};
    }
    return {'success': false, 'message': 'Không hủy được vận đơn AhaMove'};
  }
}
