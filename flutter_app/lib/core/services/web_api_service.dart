import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class WebApiService {
  static final WebApiService _instance = WebApiService._internal();
  factory WebApiService() => _instance;
  WebApiService._internal();

  String? _token;
  void setToken(String? token) => _token = token;

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // ================= ADMIN CONSOLE APIS =================
  Future<Map<String, dynamic>> getAdminDashboard() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/dashboard?_t=$ts'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) {
        return data['data'];
      }
    } catch (_) {}
    return {};
  }

  Future<List<dynamic>> getAdminPendingLabs() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/pending-labs'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<bool> reviewLabApplication(String id, String action, {String? note}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/pending-labs/$id/review'),
        headers: _headers(),
        body: jsonEncode({'action': action, 'note': note}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getAdminExpertApplications() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/expert-applications'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<bool> reviewExpertApplication(String id, String action) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/expert-applications/$id/review'),
        headers: _headers(),
        body: jsonEncode({'action': action}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getAdminUsers() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/users'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<bool> updateAdminUser(String userId, {String? status, String? role}) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/admin/users/$userId'),
        headers: _headers(),
        body: jsonEncode({
          if (status != null) 'status': status,
          if (role != null) 'role': role,
        }),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getAdminPendingMarketplace() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/marketplace/pending?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<bool> moderateMarketplace(String id, String action, {String? reason}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/marketplace/$id/moderate'),
        headers: _headers(),
        body: jsonEncode({'action': action, 'reason': reason}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getAdminReportedPosts() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/community/reports'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<bool> moderateCommunityPost(String id, String action) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/community/$id/moderate'),
        headers: _headers(),
        body: jsonEncode({'action': action}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getAdminDisputes() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/disputes?_t=$ts'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<bool> resolveDispute(String id, String resolution) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/admin/disputes/$id/resolve'),
        headers: _headers(),
        body: jsonEncode({'resolution': resolution}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getAdminAuditLogs() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/audit-logs'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>> getAdminServices() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/services'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) return data['data'];
    } catch (_) {}
    return {'standards': [], 'packages': []};
  }

  // ================= LAB MANAGEMENT PORTAL APIS =================
  Future<Map<String, dynamic>> getLabKanban() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/kanban'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) return data['data'];
    } catch (_) {}
    return {};
  }

  Future<bool> updateKanbanStep(String orderId, String column, {String? note}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/orders/$orderId/kanban-step'),
        headers: _headers(),
        body: jsonEncode({'column': column, 'note': note}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getLabSlaReport() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/sla-report?_t=$ts'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) return data['data'];
    } catch (_) {}
    return {};
  }

  Future<List<dynamic>> getLabServices() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/services'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<Map<String, dynamic>> getLabServicesWithAudit() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/services'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return {
          'lab_id': data['lab_id'] ?? '',
          'lab_name': data['lab_name'] ?? '',
          'packages': data['data'] ?? [],
          'process_table': data['process_table'] ?? [],
          'audit_trail': data['audit_trail'] ?? [],
        };
      }
    } catch (_) {}
    return {'lab_id': '', 'lab_name': '', 'packages': [], 'process_table': [], 'audit_trail': []};
  }

  Future<bool> updateLabProcessTable(List<Map<String, dynamic>> processTable) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/process-table'),
        headers: _headers(),
        body: jsonEncode({'process_table': processTable}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateLabService(String packageId, Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/services/$packageId'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createLabService(Map<String, dynamic> body) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/services'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getLabProfile() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/profile'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is Map<String, dynamic>) return data['data'];
    } catch (_) {}
    return {};
  }

  Future<bool> updateLabProfile(Map<String, dynamic> body) async {
    try {
      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/profile'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getLabDisputes() async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/disputes?_t=$ts'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true && data['data'] is List) return data['data'];
    } catch (_) {}
    return [];
  }

  Future<bool> replyLabDispute(String disputeId, String replyText, {bool escalate = false}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/disputes/$disputeId/reply'),
        headers: _headers(),
        body: jsonEncode({'reply_text': replyText, 'escalate': escalate}),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> uploadLabScan(String orderId, Map<String, dynamic> body) async {
    try {
      final cleanId = orderId.replaceAll('#', '').trim();
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/orders/$cleanId/upload-scans'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      return data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> uploadLabScanWithResult(String orderId, Map<String, dynamic> body) async {
    try {
      final cleanId = orderId.replaceAll('#', '').trim();
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/lab-portal/orders/$cleanId/upload-scans'),
        headers: _headers(),
        body: jsonEncode(body),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

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
    } catch (_) {
      return false;
    }
  }
}
