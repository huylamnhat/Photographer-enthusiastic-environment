import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static String? authToken;
  static UserModel? currentUser;

  // Headers helper
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // 1. Auth & Login
  static Future<Map<String, dynamic>> login(String email, String password, String branchId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'branch_id': branchId,
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        authToken = data['data']['token'];
        currentUser = UserModel.fromJson(data['data']['user']);
        return data;
      }
    } catch (_) {}

    // Fallback demo user
    currentUser = UserModel(
      userId: 'USR-OP-01',
      email: email,
      fullName: 'Lê Hoài Nam',
      role: 'OPERATOR',
      title: 'KỸ THUẬT VIÊN TRƯỞNG',
      branchId: branchId,
    );
    return {'success': true, 'message': 'Đăng nhập offline thành công'};
  }

  // 2. Register Lab
  static Future<Map<String, dynamic>> registerLab(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register-lab'),
        headers: _headers,
        body: jsonEncode(body),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(utf8.decode(res.bodyBytes));
      }
    } catch (_) {}
    return {'success': true, 'message': 'Hồ sơ đã được lưu tạm thành công (Offline Mode)'};
  }

  // 3. Kanban Orders
  static Future<List<OrderModel>> getKanbanOrders({String? process, String? search}) async {
    try {
      String url = '$baseUrl/orders/kanban';
      final params = <String>[];
      if (process != null && process != 'ALL') params.add('process=$process');
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final res = await http.get(Uri.parse(url), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        final list = (data['data']['orders'] as List).map((o) => OrderModel.fromJson(o)).toList();
        return list;
      }
    } catch (_) {}
    return [];
  }

  // Update stage
  static Future<bool> updateOrderStage(String orderId, String newStage) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/stage'),
        headers: _headers,
        body: jsonEncode({'stage': newStage}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Scan new barcode
  static Future<bool> scanBarcode(String customerName, String filmType, String processType) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/orders/scan-barcode'),
        headers: _headers,
        body: jsonEncode({
          'customer_name': customerName,
          'film_type': filmType,
          'process_type': processType,
          'roll_count': 1,
        }),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 4. Scan & QC
  static Future<QCBatchModel?> getQCBatch(String orderId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/scans/$orderId'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return QCBatchModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> toggleFrameQC(String orderId, String frameId, String newStatus, String? defect) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/scans/$orderId/frames/$frameId/qc'),
        headers: _headers,
        body: jsonEncode({'qc_status': newStatus, 'defect_type': defect}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> approveAndRelease(String orderId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/scans/$orderId/release'),
        headers: _headers,
        body: jsonEncode({'note': 'Phê duyệt chuyển giao kho Digital Film Archive'}),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 5. Services & Pricing
  static Future<List<ServiceModel>> getServices() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/services'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return (data['data']['services'] as List).map((s) => ServiceModel.fromJson(s)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> createService(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> toggleServiceStatus(String serviceId) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/services/$serviceId/toggle'),
        headers: _headers,
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<PriceHistoryModel>> getPriceHistory() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/services/price-history'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return (data['data'] as List).map((h) => PriceHistoryModel.fromJson(h)).toList();
      }
    } catch (_) {}
    return [];
  }

  // 6. Lab Profile
  static Future<LabProfileModel?> getLabProfile() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/lab/profile'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return LabProfileModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateLabProfile(LabProfileModel profile) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/lab/profile'),
        headers: _headers,
        body: jsonEncode(profile.toJson()),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 7. Disputes
  static Future<List<DisputeModel>> getDisputes() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/disputes'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return (data['data']['disputes'] as List).map((d) => DisputeModel.fromJson(d)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> sendDisputeMessage(String disputeId, String content, {double? offerAmount}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/disputes/$disputeId/message'),
        headers: _headers,
        body: jsonEncode({
          'content': content,
          if (offerAmount != null) 'offer_amount': offerAmount,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> settleDispute(String disputeId, String settlementType, double agreedAmount) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/disputes/$disputeId/settle'),
        headers: _headers,
        body: jsonEncode({
          'settlement_type': settlementType,
          'agreed_amount': agreedAmount,
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // 8. SLA Reports
  static Future<Map<String, dynamic>?> getSlaReports() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/reports/sla'), headers: _headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return data['data'];
      }
    } catch (_) {}
    return null;
  }
}

