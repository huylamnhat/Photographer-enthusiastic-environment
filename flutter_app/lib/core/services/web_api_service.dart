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
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/dashboard'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) return data['data'];
    } catch (_) {}
    return {
      'total_orders': 1284,
      'total_revenue': 148500000,
      'platform_commission': 14850000,
      'active_labs': 18,
      'pending_labs': 2,
      'pending_marketplace': 3,
      'open_disputes': 1,
      'sla_on_time_rate': '98.4%'
    };
  }

  Future<List<dynamic>> getAdminPendingLabs() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/pending-labs'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) return data['data'];
    } catch (_) {}
    return [
      {
        'application_id': 'app-lab-901',
        'name': 'Retro Hanoi Darkroom',
        'owner_name': 'Phạm Gia Huy',
        'email': 'retro.hanoi@gmail.com',
        'phone': '0945667788',
        'city': 'Hà Nội',
        'address': 'Số 22 ngõ Huyện, Hàng Trống, Hoàn Kiếm, Hà Nội',
        'business_license': 'DKKD-0109923481',
        'scanner_models': ['Noritsu LS-600', 'Epson V850 Pro'],
        'supported_processes': ['C-41', 'B&W'],
        'applied_date': '2026-03-02',
        'status': 'PENDING',
        'inspection_note': 'Đã nộp đầy đủ giấy phép kinh doanh hóa chất tráng ảnh và hợp đồng xử lý chất thải.'
      },
      {
        'application_id': 'app-lab-902',
        'name': 'Analog Saigon Space',
        'owner_name': 'Võ Thành Nam',
        'email': 'analog.saigon@gmail.com',
        'phone': '0919334455',
        'city': 'TP.HCM',
        'address': '88 Nguyễn Đình Chiểu, Phường Đa Kao, Quận 1, TP.HCM',
        'business_license': 'DKKD-0318829102',
        'scanner_models': ['Fuji Frontier SP-3000'],
        'supported_processes': ['C-41', 'ECN-2 Cine'],
        'applied_date': '2026-03-03',
        'status': 'PENDING',
        'inspection_note': 'Hồ sơ chờ xác minh máy scan thực tế và phòng tối sấy buồng kín.'
      }
    ];
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
      return true;
    }
  }

  Future<List<dynamic>> getAdminUsers() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/users'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) return data['data'];
    } catch (_) {}
    return [
      {
        'user_id': 'usr-000',
        'full_name': 'Quản trị viên Hệ thống',
        'email': 'admin@minilab.vn',
        'role': 'Admin',
        'status': 'ACTIVE',
        'created_at': '01/01/2026'
      },
      {
        'user_id': 'usr-002',
        'full_name': 'Trần Văn Đức (CropLab Owner)',
        'email': 'labowner@croplab.vn',
        'role': 'LabOwner',
        'status': 'ACTIVE',
        'created_at': '05/01/2026'
      },
      {
        'user_id': 'usr-001',
        'full_name': 'Nguyễn Hoàng Anh',
        'email': 'khachhang@minilab.vn',
        'role': 'Customer',
        'status': 'ACTIVE',
        'created_at': '10/01/2026'
      },
      {
        'user_id': 'usr-003',
        'full_name': 'Lê Quang Huy',
        'email': 'chuyengia@film.vn',
        'role': 'Expert',
        'status': 'ACTIVE',
        'created_at': '02/01/2026'
      }
    ];
  }

  Future<List<dynamic>> getAdminDisputes() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/admin/disputes'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) return data['data'];
    } catch (_) {}
    return [
      {
        'dispute_id': 'DSP-2026-001',
        'order_id': 'ORD-2026-8801',
        'customer_name': 'Nguyễn Hoàng Anh',
        'lab_name': 'CropLab Hà Nội',
        'issue_type': 'Trầy xước phim / Lỗi scan màu',
        'description': 'Cuộn Portra 400 có 2 khung hình bị vệt xước dọc, muốn thương lượng scan lại độ phân giải TIFF hoặc hoàn phí tráng 50k.',
        'amount_requested': 50000,
        'status': 'NEGOTIATING',
        'created_at': '02/03/2026'
      }
    ];
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
      return true;
    }
  }

  // ================= LAB MANAGEMENT PORTAL APIS =================
  Future<Map<String, dynamic>> getLabKanban() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/kanban'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) return data['data'];
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
      return true;
    }
  }

  Future<Map<String, dynamic>> getLabSlaReport() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/sla-report'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) return data['data'];
    } catch (_) {}
    return {
      'lab_name': 'CropLab Hà Nội',
      'sla_target_hours': 12,
      'on_time_delivery_rate': '98.7%',
      'total_completed_orders': 1284,
      'delayed_orders': 17,
      'average_turnaround_hours': 9.4,
      'daily_capacity': '80 cuộn / ngày',
      'qc_pass_rate': '99.2%'
    };
  }

  Future<List<dynamic>> getLabServices() async {
    try {
      final res = await http.get(Uri.parse('${ApiConstants.baseUrl}/lab-portal/services'), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) return data['data'];
    } catch (_) {}
    return [
      {
        'package_id': 'pkg-001',
        'name': 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
        'film_format': '135',
        'process_type': 'C-41',
        'scan_resolution': 'M (3000x2000px)',
        'price': 50000,
        'estimated_hours': 12,
        'status': 'ACTIVE'
      },
      {
        'package_id': 'pkg-002',
        'name': 'Tráng & Scan 135 Color - Scan Cao Cấp L (TIFF/JPG)',
        'film_format': '135',
        'process_type': 'C-41',
        'scan_resolution': 'L (6000x4000px TIFF)',
        'price': 85000,
        'estimated_hours': 16,
        'status': 'ACTIVE'
      },
      {
        'package_id': 'pkg-003',
        'name': 'Tráng & Scan 135 B&W (Đen Trắng Thủ Công)',
        'film_format': '135',
        'process_type': 'B&W',
        'scan_resolution': 'M (3000x2000px)',
        'price': 65000,
        'estimated_hours': 24,
        'status': 'ACTIVE'
      },
      {
        'package_id': 'pkg-004',
        'name': 'Tráng & Scan Cine Film ECN-2 (Tẩy than)',
        'film_format': '135',
        'process_type': 'ECN-2',
        'scan_resolution': 'M (3000x2000px)',
        'price': 75000,
        'estimated_hours': 24,
        'status': 'ACTIVE'
      },
      {
        'package_id': 'pkg-005',
        'name': 'Tráng & Scan Medium Format 120 (C-41)',
        'film_format': '120',
        'process_type': 'C-41',
        'scan_resolution': 'L (4800x4800px)',
        'price': 80000,
        'estimated_hours': 12,
        'status': 'ACTIVE'
      }
    ];
  }
}

