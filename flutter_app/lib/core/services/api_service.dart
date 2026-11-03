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
      // Mock fallback if backend offline
      return {
        'success': true,
        'token': 'mock-offline-token',
        'user': {
          'user_id': 'usr-001',
          'email': identifier.contains('@') ? identifier : 'khachhang@minilab.vn',
          'phone': '0912345678',
          'full_name': 'Nguyễn Hoàng Anh',
          'role': 'Customer',
          'avatar_url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
          'address': '123 Phố Huế, Hai Bà Trưng, Hà Nội',
        }
      };
    }
  }

  // Labs
  Future<List<LabModel>> getLabs({String? search, String? city}) async {
    try {
      String url = '${ApiConstants.baseUrl}${ApiConstants.labs}';
      final params = <String>[];
      if (search != null && search.isNotEmpty) params.add('search=$search');
      if (city != null && city.isNotEmpty) params.add('city=$city');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final res = await http.get(Uri.parse(url), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((l) => LabModel.fromJson(l)).toList();
      }
    } catch (_) {}

    // Fallback data
    return [
      LabModel(
        labId: 'lab-001',
        name: 'CropLab Hà Nội',
        tagline: 'Chuyên gia tráng & scan chất lượng cao từ năm 2014',
        address: 'Số 10 ngõ 12 Đặng Thai Mai, Tây Hồ, Hà Nội',
        city: 'Hà Nội',
        phone: '0904567890',
        email: 'hanoi@croplab.vn',
        rating: 4.9,
        reviewCount: 328,
        turnaroundHours: 12,
        scannerModels: ['Noritsu HS-1800', 'Fuji Frontier SP-3000'],
        supportedFormats: ['135', '120', '220', '4x5'],
        supportedProcesses: ['C-41', 'B&W', 'ECN-2', 'E-6 Slide'],
        coverImage: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
        logoUrl: 'https://images.unsplash.com/photo-1495745966610-2a67f2297e5e?w=200',
        isVerified: true,
        priceRange: '45.000đ - 120.000đ',
        description: 'CropLab cung cấp dịch vụ tráng và scan phim màu C-41, đen trắng B&W thủ công với hóa chất chuẩn Kodak & Ilford.',
        packages: [
          ServicePackageModel(
            packageId: 'pkg-001',
            labId: 'lab-001',
            name: 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
            filmFormat: '135',
            processType: 'C-41',
            scanResolution: 'M (3000x2000px)',
            price: 50000,
            estimatedHours: 12,
            description: 'Gói tráng và scan tiêu chuẩn cho cuộn film 35mm màu.',
          ),
          ServicePackageModel(
            packageId: 'pkg-002',
            labId: 'lab-001',
            name: 'Tráng & Scan 135 Color (C-41) - Scan Cao Cấp L (TIFF/JPG)',
            filmFormat: '135',
            processType: 'C-41',
            scanResolution: 'L (6000x4000px TIFF)',
            price: 85000,
            estimatedHours: 16,
            description: 'Độ phân giải lớn nhất từ Noritsu HS-1800.',
          ),
        ],
      ),
      LabModel(
        labId: 'lab-002',
        name: 'LLab Film Sài Gòn',
        tagline: 'Màu sắc ấm áp, tốc độ siêu nhanh trong ngày',
        address: '40/2 Phan Văn Trị, Phường 12, Bình Thạnh, TP.HCM',
        city: 'TP.HCM',
        phone: '0938112233',
        email: 'saigon@llab.vn',
        rating: 4.8,
        reviewCount: 512,
        turnaroundHours: 8,
        scannerModels: ['Fuji Frontier SP-3000'],
        supportedFormats: ['135', '120'],
        supportedProcesses: ['C-41', 'B&W', 'ECN-2'],
        coverImage: 'https://images.unsplash.com/photo-1452784444945-3f422708fe5e?w=800',
        logoUrl: 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=200',
        isVerified: true,
        priceRange: '50.000đ - 110.000đ',
        description: 'LLab là điểm đến quen thuộc của cộng đồng film Sài Gòn với phong cách chỉnh màu Frontier tươi tắn.',
        packages: [],
      ),
    ];
  }

  // Orders
  Future<List<OrderModel>> getOrders() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.orders}'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((o) => OrderModel.fromJson(o)).toList();
      }
    } catch (_) {}

    return [
      OrderModel(
        orderId: 'ORD-2026-8801',
        userId: 'usr-001',
        labId: 'lab-001',
        labName: 'CropLab Hà Nội',
        orderDate: '2026-03-01T09:30:00Z',
        status: 'READY_FOR_DOWNLOAD',
        totalAmount: 135000,
        shippingMethod: 'PICKUP',
        pickupAddress: '123 Phố Huế, Hai Bà Trưng, Hà Nội',
        paymentStatus: 'PAID',
        paymentMethod: 'MOMO',
        items: [
          OrderItemModel(
            itemId: 'item-101',
            name: 'Tráng & Scan 135 Color (C-41) - Chuẩn M',
            filmName: 'Kodak Portra 400',
            quantity: 1,
            price: 50000,
          ),
          OrderItemModel(
            itemId: 'item-102',
            name: 'Tráng & Scan 135 Color - Scan Cao Cấp L',
            filmName: 'Fujifilm Pro 400H',
            quantity: 1,
            price: 85000,
          ),
        ],
        timeline: [
          TimelineStepModel(step: 1, name: 'Tạo đơn & Đã thanh toán', status: 'COMPLETED', time: '09:30', note: 'MoMo'),
          TimelineStepModel(step: 2, name: 'Đã nhận cuộn film tại Lab', status: 'COMPLETED', time: '11:15', note: 'Quầy tiếp nhận'),
          TimelineStepModel(step: 3, name: 'Tráng hóa chất C-41', status: 'COMPLETED', time: '14:20', note: 'Nhiệt độ 38°C'),
          TimelineStepModel(step: 4, name: 'Rửa sạch & Sấy buồng kín', status: 'COMPLETED', time: '15:10', note: 'Sấy phòng kín'),
          TimelineStepModel(step: 5, name: 'Scan máy Noritsu HS-1800', status: 'COMPLETED', time: '16:40', note: 'Scan độ phân giải cao'),
          TimelineStepModel(step: 6, name: 'Kiểm định chất lượng QC', status: 'COMPLETED', time: '17:05', note: 'Màu chuẩn'),
          TimelineStepModel(step: 7, name: 'File sẵn sàng trong Archive', status: 'COMPLETED', time: '17:15', note: 'Đã lưu trữ'),
        ],
      )
    ];
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
      if (data['success'] == true) {
        return OrderModel.fromJson(data['data']);
      }
    } catch (_) {}
    return null;
  }

  // Archive Photos
  Future<List<ArchivePhotoModel>> getArchivePhotos({String? album}) async {
    try {
      String url = '${ApiConstants.baseUrl}${ApiConstants.archivePhotos}';
      if (album != null) url += '?album=$album';
      final res = await http.get(Uri.parse(url), headers: _headers());
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((p) => ArchivePhotoModel.fromJson(p)).toList();
      }
    } catch (_) {}

    return [
      ArchivePhotoModel(
        photoId: 'pho-001',
        userId: 'usr-001',
        orderId: 'ORD-2026-8801',
        rollCode: 'ROLL-PORTRA400-01',
        title: 'Nắng chiều Phố Cổ Hà Nội',
        imageUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=1200',
        thumbnailUrl: 'https://images.unsplash.com/photo-1528127269322-539801943592?w=400',
        albumName: 'Mùa thu Hà Nội 2026',
        isFavorite: true,
        createdAt: '2026-03-01T17:15:00Z',
        metadata: PhotoMetadataModel(
          camera: 'Leica M6 Classic',
          lens: 'Summicron 35mm f/2 ASPH',
          filmStock: 'Kodak Portra 400',
          iso: 400,
          aperture: 'f/2.8',
          shutterSpeed: '1/250s',
          focalLength: '35mm',
          process: 'C-41 Noritsu HS-1800',
          lab: 'CropLab Hà Nội',
          dimensions: '6048 x 4032',
          fileSize: '18.4 MB TIFF',
        ),
      ),
      ArchivePhotoModel(
        photoId: 'pho-002',
        userId: 'usr-001',
        orderId: 'ORD-2026-8801',
        rollCode: 'ROLL-PORTRA400-01',
        title: 'Gánh hoa góc đường',
        imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=1200',
        thumbnailUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400',
        albumName: 'Mùa thu Hà Nội 2026',
        isFavorite: false,
        createdAt: '2026-03-01T17:15:00Z',
        metadata: PhotoMetadataModel(
          camera: 'Leica M6 Classic',
          lens: 'Summicron 35mm f/2 ASPH',
          filmStock: 'Kodak Portra 400',
          iso: 400,
          aperture: 'f/4.0',
          shutterSpeed: '1/500s',
          focalLength: '35mm',
          process: 'C-41 Noritsu HS-1800',
          lab: 'CropLab Hà Nội',
          dimensions: '6048 x 4032',
          fileSize: '16.8 MB TIFF',
        ),
      ),
    ];
  }

  // Marketplace
  Future<List<ListingModel>> getMarketplaceListings() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.marketplaceListings}'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((l) => ListingModel.fromJson(l)).toList();
      }
    } catch (_) {}

    return [
      ListingModel(
        listingId: 'mkt-001',
        sellerId: 'usr-001',
        sellerName: 'Nguyễn Hoàng Anh',
        sellerAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        title: 'Máy ảnh Film Canon QL17 GIII (Black Limited Edition)',
        category: 'Máy ảnh Rangefinder',
        condition: '98% Sưu tầm, đo sáng hoàn hảo',
        price: 4800000,
        status: 'ACTIVE',
        location: 'Hoàn Kiếm, Hà Nội',
        phoneContact: '0912345678',
        zaloContact: '0912345678',
        imageUrls: ['https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800'],
        description: 'Cần nhượng lại Canon QL17 GIII bản đen hiếm. Kính trong vắt, không mốc xước.',
        createdAt: '2026-02-28T10:00:00Z',
      ),
    ];
  }

  // Community Posts
  Future<List<CommunityPostModel>> getCommunityPosts() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.posts}'),
        headers: _headers(),
      );
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((p) => CommunityPostModel.fromJson(p)).toList();
      }
    } catch (_) {}

    return [
      CommunityPostModel(
        postId: 'post-001',
        authorId: 'usr-003',
        authorName: 'Lê Quang Huy',
        authorAvatar: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150',
        authorBadge: 'Chuyên gia nhiếp ảnh',
        title: 'Bí quyết chọn điểm đo sáng khi chụp phim âm bản màu',
        content: 'Phim âm bản màu có khả năng giữ chi tiết highlight ấn tượng, lên đến +3 hoặc +4 stops...',
        category: 'Kỹ thuật chụp',
        imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
        likesCount: 89,
        commentsCount: 14,
        createdAt: '2026-03-01T10:00:00Z',
      ),
    ];
  }
}

