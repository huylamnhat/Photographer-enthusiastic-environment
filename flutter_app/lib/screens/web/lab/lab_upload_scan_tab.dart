import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/mock/mock_test_assets.dart';
import '../../../core/services/web_api_service.dart';
import '../../../core/utils/local_image_picker.dart';

class LabUploadScanTab extends StatefulWidget {
  const LabUploadScanTab({super.key});

  @override
  State<LabUploadScanTab> createState() => _LabUploadScanTabState();
}

class _LabUploadScanTabState extends State<LabUploadScanTab> {
  final _orderIdController = TextEditingController();
  final _rollCodeController = TextEditingController();
  final _scannerController = TextEditingController(text: 'Fuji Frontier SP-3000');
  final _driveLinkController = TextEditingController();
  String _scanResolution = 'JPG HD (1080x720)';
  bool _qcColorBalance = true;
  bool _qcDustScratch = true;
  bool _isUploading = false;
  bool _isDone = false;
  bool _isLoadingCustomers = true;
  String _generatedDriveLink = '';
  final List<Map<String, String>> _sentLinksHistory = [];
  Map<String, dynamic> _driveConfig = {};
  String _selectedCustomerUserId = '';
  String _selectedOrderId = '';

  final Map<String, List<Map<String, String>>> _customerOrdersMap = {};
  final Map<String, List<Map<String, String>>> _customerInProgressMap = {};

  List<Map<String, String>> _customers = [];

  Map<String, String> get _currentCustomer => _customers.isEmpty
      ? {'user_id': '', 'full_name': '', 'email': '', 'order_id': ''}
      : _customers.firstWhere((c) => c['user_id'] == _selectedCustomerUserId, orElse: () => _customers.first);

  List<Map<String, String>> get _currentCustomerOrders =>
      _customerOrdersMap[_selectedCustomerUserId] ?? const [];

  List<Map<String, String>> get _currentCustomerInProgressOrders =>
      _customerInProgressMap[_selectedCustomerUserId] ?? const [];

  // Khởi tạo trống, chỉ hiển thị ảnh thật do Lab tải lên từ máy tính
  final List<Map<String, dynamic>> _frames = [];

  int get _selectedCount => _frames.where((f) => f['selected'] == true).length;

  @override
  void initState() {
    super.initState();
    _loadDriveConfig();
  }

  void _syncOrderFieldsForSelectedCustomer() {
    final availOrders = _currentCustomerOrders.where((o) => o['has_drive_link'] != 'true').toList();
    if (availOrders.isNotEmpty) {
      if (!availOrders.any((o) => o['order_id'] == _selectedOrderId)) {
        _selectedOrderId = availOrders.first['order_id']!;
      }
      final matched = availOrders.firstWhere(
        (o) => o['order_id'] == _selectedOrderId,
        orElse: () => availOrders.first,
      );
      _orderIdController.text = matched['order_id'] ?? '';
      _rollCodeController.text = matched['roll_code'] ?? '';
    } else {
      _selectedOrderId = '';
      _orderIdController.clear();
      _rollCodeController.clear();
    }
  }

  Future<void> _loadDriveConfig() async {
    final cfg = await WebApiService().getGoogleDriveConfig();
    if (!mounted) return;
    setState(() {
      _driveConfig = cfg;
      _isLoadingCustomers = false;
      if (cfg['customers'] is List && (cfg['customers'] as List).isNotEmpty) {
        final rawList = cfg['customers'] as List;
        final loaded = <Map<String, String>>[];
        _customerOrdersMap.clear();
        _customerInProgressMap.clear();
        for (final item in rawList) {
          if (item is Map) {
            final uid = (item['user_id'] ?? '').toString();
            loaded.add({
              'user_id': uid,
              'full_name': (item['full_name'] ?? '').toString(),
              'email': (item['email'] ?? '').toString(),
              'order_id': (item['order_id'] ?? '').toString(),
            });

            final ordList = <Map<String, String>>[];
            if (item['orders'] is List) {
              for (final o in (item['orders'] as List)) {
                if (o is Map) {
                  final oid = (o['order_id'] ?? '').toString();
                  final fn = (o['film_name'] ?? 'Kodak Portra 400').toString();
                  final rc = (o['roll_code'] ?? 'ROLL-135-01').toString();
                  final hasLink = o['has_drive_link'] == true;
                  final lbl = (o['label'] ?? '#$oid • $fn ($rc)').toString();
                  if (oid.isNotEmpty) {
                    ordList.add({
                      'order_id': oid,
                      'film_name': fn,
                      'roll_code': rc,
                      'step_label': (o['step_label'] ?? '5. Hoàn tất').toString(),
                      'has_drive_link': hasLink ? 'true' : 'false',
                      'drive_link': (o['drive_link'] ?? '').toString(),
                      'label': lbl,
                    });
                  }
                }
              }
            }
            _customerOrdersMap[uid] = ordList;

            final progList = <Map<String, String>>[];
            if (item['in_progress_orders'] is List) {
              for (final o in (item['in_progress_orders'] as List)) {
                if (o is Map) {
                  final oid = (o['order_id'] ?? '').toString();
                  if (oid.isNotEmpty) {
                    progList.add({
                      'order_id': oid,
                      'step_label': (o['step_label'] ?? '1. Tiếp nhận').toString(),
                      'film_name': (o['film_name'] ?? '').toString(),
                    });
                  }
                }
              }
            }
            _customerInProgressMap[uid] = progList;
          }
        }
        if (loaded.isNotEmpty) {
          _customers = loaded;
          if (!_customers.any((c) => c['user_id'] == _selectedCustomerUserId)) {
            _selectedCustomerUserId = _customers.first['user_id']!;
          }
          _syncOrderFieldsForSelectedCustomer();
        } else {
          _customers = [];
          _selectedCustomerUserId = '';
          _syncOrderFieldsForSelectedCustomer();
        }
      } else {
        _customers = [];
        _selectedCustomerUserId = '';
        _customerOrdersMap.clear();
        _customerInProgressMap.clear();
        _syncOrderFieldsForSelectedCustomer();
      }
      if (cfg['sent_links_history'] is List) {
        _sentLinksHistory.clear();
        for (final h in (cfg['sent_links_history'] as List)) {
          if (h is Map) {
            final link = (h['drive_link'] ?? '').toString().trim();
            if (link.isEmpty) continue;
            final cname = (h['customer_name'] ?? 'Khách hàng').toString();
            final cemail = (h['recipient_email'] ?? '').toString();
            final oid = (h['order_id'] ?? '').toString();
            final cnt = (h['photo_count'] ?? 1).toString();
            _sentLinksHistory.add({
              'customer': cemail.isNotEmpty
                  ? '$cname ($cemail) • Đơn #$oid'
                  : '$cname • Đơn #$oid',
              'link': link,
              'count': '$cnt ảnh',
            });
          }
        }
      }
    });
  }

  Future<void> _pickPhotosFromComputer({bool replaceAll = false}) async {
    final picked = await pickLocalImagesFromComputer(multiple: true);
    if (!mounted || picked.isEmpty) return;
    setState(() {
      if (replaceAll) {
        _frames.clear();
      }
      for (final p in picked) {
        _frames.add({
          'name': p.name,
          'title': p.name.replaceAll(RegExp(r'\.[^.]+$'), ''),
          'url': p.dataUrl,
          'selected': true,
          'isCustom': true,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary,
        content: Text('Đã tải lên ${picked.length} ảnh từ máy tính của bạn (tự động chuẩn hóa 1080x720) và tích chọn sẵn!'),
      ),
    );
  }

  void _showGoogleDriveConfigDialog() {
    final emailCtrl = TextEditingController(text: (_driveConfig['account_email'] ?? '').toString());
    final folderUrlCtrl = TextEditingController(text: (_driveConfig['folder_url'] ?? '').toString());
    final accessTokenCtrl = TextEditingController();
    final clientIdCtrl = TextEditingController();
    final clientSecretCtrl = TextEditingController();
    final refreshTokenCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.add_to_drive, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Cấu hình Tài khoản Google Drive API', style: AppTypography.cardTitle),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kết nối tài khoản Google Drive của Tiệm Lab để lưu trữ file ảnh Scan (1080x720) và tự động tạo Link chia sẻ gửi tới khách hàng.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'EMAIL TÀI KHOẢN GOOGLE DRIVE',
                    hintText: 'tenban@gmail.com',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: folderUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'LINK THƯ MỤC GOOGLE DRIVE HOẶC FOLDER ID',
                    hintText: 'https://drive.google.com/drive/folders/...',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: accessTokenCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GOOGLE DRIVE ACCESS TOKEN (NẾU DÙNG TRỰC TIẾP)',
                    hintText: 'ya29.a0AfH6SM...',
                  ),
                ),
                const SizedBox(height: 10),
                const Text('HOẶC CẤU HÌNH OAUTH2 REFRESH TOKEN VĨNH VIỄN:', style: AppTypography.labelCaps),
                const SizedBox(height: 6),
                TextField(
                  controller: clientIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GOOGLE CLIENT ID',
                    hintText: 'xxxx.apps.googleusercontent.com',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: clientSecretCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GOOGLE CLIENT SECRET',
                    hintText: 'GOCSPX-...',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: refreshTokenCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GOOGLE REFRESH TOKEN',
                    hintText: '1//04...',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final payload = <String, dynamic>{
                'account_email': emailCtrl.text.trim(),
                'folder_url': folderUrlCtrl.text.trim(),
                if (accessTokenCtrl.text.trim().isNotEmpty) 'access_token': accessTokenCtrl.text.trim(),
                if (clientIdCtrl.text.trim().isNotEmpty) 'client_id': clientIdCtrl.text.trim(),
                if (clientSecretCtrl.text.trim().isNotEmpty) 'client_secret': clientSecretCtrl.text.trim(),
                if (refreshTokenCtrl.text.trim().isNotEmpty) 'refresh_token': refreshTokenCtrl.text.trim(),
              };
              final ok = await WebApiService().saveGoogleDriveConfig(payload);
              await _loadDriveConfig();
              if (!mounted || !ctx.mounted) return;
              setState(() {
                _driveLinkController.text = folderUrlCtrl.text.trim();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: ok ? AppColors.secondary : AppColors.danger,
                  content: Text(
                    ok
                        ? 'Đã lưu cấu hình Google Drive API (${emailCtrl.text.trim()}) vào hệ thống & file .env!'
                        : 'Không thể lưu cấu hình Google Drive.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Lưu cấu hình Google Drive'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitUpload() async {
    final targetOrdId = _orderIdController.text.trim().isNotEmpty
        ? _orderIdController.text.trim()
        : _selectedOrderId;
    if (_currentCustomerOrders.isEmpty || targetOrdId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('Khách hàng này chưa có đơn nào sẵn sàng ở bước 5 (Hoàn tất). Vui lòng chuyển đơn sang Hoàn tất trước.'),
        ),
      );
      return;
    }

    final selectedFrames = _frames.where((f) => f['selected'] == true).toList();
    if (selectedFrames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('Vui lòng tích chọn ít nhất 1 tấm ảnh để gửi lên Google Drive!'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    final selectedPayload = selectedFrames.map((f) {
      final urlStr = f['url'].toString();
      return {
        'file_name': f['name'].toString(),
        'title': f['title'].toString(),
        'image_url': urlStr,
        if (urlStr.startsWith('data:image')) 'file_base64': urlStr,
      };
    }).toList();

    final selectedCustomer = _currentCustomer;
    final res = await WebApiService().uploadLabScanWithResult(
      targetOrdId,
      {
        'order_id': targetOrdId,
        'roll_code': _rollCodeController.text.trim(),
        'scanner_model': _scannerController.text.trim(),
        'photo_title': 'Ảnh scan đơn $targetOrdId ($_scanResolution)',
        'image_url': selectedFrames.first['url'].toString(),
        'drive_link': _driveLinkController.text.trim(),
        'selected_photos': selectedPayload,
        'recipient_user_id': selectedCustomer['user_id'],
        'recipient_email': selectedCustomer['email'],
        'recipient_name': selectedCustomer['full_name'],
      },
    );
    if (!mounted) return;
    final ok = res['success'] == true;
    final link = (res['drive_link'] ?? _driveLinkController.text).toString();
    setState(() {
      _isUploading = false;
      _isDone = ok;
      if (ok && link.isNotEmpty) {
        _generatedDriveLink = link;
        _driveLinkController.text = link;
        _sentLinksHistory.insert(0, {
          'customer': '${selectedCustomer['full_name']} (${selectedCustomer['email']}) • Đơn #$targetOrdId',
          'link': link,
          'count': '${selectedFrames.length} ảnh',
        });
      }
    });
    if (ok) {
      await _loadDriveConfig();
      if (!mounted) return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Đã đẩy ${selectedFrames.length} ảnh (1080x720) lên Google Drive cho Đơn #$targetOrdId của ${selectedCustomer['full_name']} (${selectedCustomer['email']})!'
              : (res['message']?.toString() ?? 'Lỗi khi tải ảnh scan lên máy chủ.'),
        ),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gửi ảnh cho khách hàng', style: AppTypography.pageTitle),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _showGoogleDriveConfigDialog,
                    icon: const Icon(Icons.add_to_drive, size: 16, color: AppColors.primary),
                    label: Text(
                      (_driveConfig['account_email'] != null &&
                              _driveConfig['account_email'].toString().isNotEmpty &&
                              _driveConfig['account_email'] != 'Chưa cấu hình email')
                          ? 'Google Drive: ${_driveConfig['account_email']}'
                          : 'Liên kết Google Drive',
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickPhotosFromComputer(replaceAll: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                    label: const Text('+ Tải ảnh từ máy tính của tôi'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Upload Form & QC Checklist (Flex 5)
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              '1. CHỌN KHÁCH HÀNG & ĐƠN HÀNG ĐÃ HOÀN TẤT',
                              style: AppTypography.labelCaps,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Làm mới danh sách đơn',
                            icon: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
                            onPressed: _loadDriveConfig,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isLoadingCustomers)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(minHeight: 2),
                        )
                      else if (_customers.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: const Text(
                            'Tiệm Lab hiện tại chưa có đơn hàng từ khách hàng nào.',
                            style: AppTypography.bodySmall,
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: _customers.any((c) => c['user_id'] == _selectedCustomerUserId)
                              ? _selectedCustomerUserId
                              : _customers.first['user_id'],
                          decoration: const InputDecoration(
                            labelText: 'TÀI KHOẢN KHÁCH HÀNG CỦA LAB NHẬN LINK & ẢNH SCAN',
                            prefixIcon: Icon(Icons.person_pin_outlined, color: AppColors.primary),
                          ),
                          items: _customers.map((c) {
                            return DropdownMenuItem<String>(
                              value: c['user_id'],
                              child: Text('${c['full_name']} (${c['email']})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCustomerUserId = val;
                                _selectedOrderId = '';
                                _syncOrderFieldsForSelectedCustomer();
                              });
                              _loadDriveConfig();
                            }
                          },
                        ),
                      const SizedBox(height: 12),
                      if (_isLoadingCustomers)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(minHeight: 2),
                        )
                      else if (_currentCustomerOrders.isNotEmpty)
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            'order-dd-$_selectedCustomerUserId-$_selectedOrderId-${_currentCustomerOrders.where((o) => o['has_drive_link'] == 'true').length}',
                          ),
                          value: (_selectedOrderId.isNotEmpty &&
                                  _currentCustomerOrders.any(
                                    (o) => o['order_id'] == _selectedOrderId && o['has_drive_link'] != 'true',
                                  ))
                              ? _selectedOrderId
                              : null,
                          isExpanded: true,
                          hint: Text(
                            _currentCustomerOrders.any((o) => o['has_drive_link'] != 'true')
                                ? 'Chọn đơn hàng chưa gửi link...'
                                : 'Tất cả đơn bước 5 đã gửi link (đã khóa chọn)',
                            style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                          ),
                          decoration: const InputDecoration(
                            labelText: 'CHỌN ĐƠN HÀNG ĐÃ HOÀN TẤT',
                            prefixIcon: Icon(Icons.receipt_long_outlined, color: AppColors.secondary),
                          ),
                          items: _currentCustomerOrders.map((o) {
                            final isSent = o['has_drive_link'] == 'true';
                            return DropdownMenuItem<String>(
                              value: o['order_id'],
                              enabled: !isSent,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      o['label'] ?? '#${o['order_id']} • ${o['film_name']}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSent
                                            ? AppColors.inkMuted.withValues(alpha: 0.45)
                                            : AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  if (isSent) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Đã up link',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (ordVal) {
                            if (ordVal != null) {
                              final matchedOrd = _currentCustomerOrders.firstWhere(
                                (o) => o['order_id'] == ordVal,
                                orElse: () => _currentCustomerOrders.first,
                              );
                              if (matchedOrd['has_drive_link'] == 'true') return;
                              setState(() {
                                _selectedOrderId = ordVal;
                                _orderIdController.text = ordVal;
                                if (matchedOrd['roll_code'] != null && matchedOrd['roll_code']!.isNotEmpty) {
                                  _rollCodeController.text = matchedOrd['roll_code']!;
                                }
                              });
                            }
                          },
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: AppColors.warning),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Khách hàng này chưa có đơn nào ở bước 5 (Hoàn tất). Vui lòng chuyển đơn sang Hoàn tất trước khi gửi ảnh.',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.ink, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_currentCustomerInProgressOrders.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(
                            'Đơn khác của khách giữ nguyên bước đang làm: ${_currentCustomerInProgressOrders.map((o) => '#${o['order_id']} (${o['step_label']})').join(', ')}',
                            style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Text('2. THÔNG TIN ĐƠN & THIẾT BỊ QUÉT', style: AppTypography.labelCaps),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _orderIdController,
                              readOnly: true,
                              decoration: const InputDecoration(labelText: 'MÃ ĐƠN HÀNG'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _rollCodeController,
                              decoration: const InputDecoration(labelText: 'MÃ CUỘN PHIM'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _scannerController,
                              decoration: const InputDecoration(labelText: 'MÁY SCAN SỬ DỤNG'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _scanResolution,
                              decoration: const InputDecoration(labelText: 'ĐỘ PHÂN GIẢI & ĐỊNH DẠNG'),
                              items: const [
                                DropdownMenuItem(value: 'JPG HD (1080x720)', child: Text('JPG HD (1080x720)')),
                                DropdownMenuItem(value: 'JPG Standard (3000x2000)', child: Text('JPG Standard')),
                                DropdownMenuItem(value: 'TIFF 16-bit (4800 dpi)', child: Text('TIFF 16-bit Master')),
                              ],
                              onChanged: (v) => setState(() => _scanResolution = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _driveLinkController,
                        decoration: InputDecoration(
                          labelText: 'LINK THƯ MỤC GOOGLE DRIVE GỬI KHÁCH HÀNG',
                          hintText: 'https://drive.google.com/drive/folders/...',
                          prefixIcon: const Icon(Icons.add_to_drive, size: 18, color: AppColors.primary),
                          suffixIcon: IconButton(
                            tooltip: 'Cấu hình tài khoản Google Drive API',
                            icon: const Icon(Icons.settings_outlined, size: 18),
                            onPressed: _showGoogleDriveConfigDialog,
                          ),
                        ),
                      ),
                      if (_sentLinksHistory.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ..._sentLinksHistory.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final hItem = entry.value;
                          final isLatest = idx == 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isLatest
                                  ? AppColors.secondary.withValues(alpha: 0.08)
                                  : AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isLatest ? AppColors.secondary : AppColors.outline,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_done,
                                  size: 18,
                                  color: isLatest ? AppColors.secondary : AppColors.inkMuted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${isLatest ? "[LINK MỚI NHẤT]" : "[LINK CŨ #${_sentLinksHistory.length - idx}]"} ${hItem['customer']} • ${hItem['count']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isLatest ? AppColors.secondary : AppColors.inkMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      SelectableText(
                                        sanitizeGoogleDriveUrl(hItem['link'] ?? ''),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Mở trực tiếp trên Google Drive',
                                  icon: Icon(
                                    Icons.open_in_new,
                                    size: 16,
                                    color: isLatest ? AppColors.secondary : AppColors.inkMuted,
                                  ),
                                  onPressed: () {
                                    openUrlInNewTab(hItem['link'] ?? '');
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Sao chép link Google Drive',
                                  icon: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: isLatest ? AppColors.secondary : AppColors.inkMuted,
                                  ),
                                  onPressed: () async {
                                    final clean = await copyTextSafe(hItem['link'] ?? '');
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã sao chép link Google Drive: $clean')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      const SizedBox(height: 20),

                      // Clickable Upload Area from Computer
                      InkWell(
                        onTap: () => _pickPhotosFromComputer(replaceAll: false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, size: 38, color: AppColors.primary),
                                const SizedBox(height: 8),
                                const Text(
                                  'BẤM VÀO ĐÂY ĐỂ CHỌN ẢNH TỪ MÁY TÍNH CỦA BẠN (CHỌN 1 HOẶC NHIỀU TẤM)',
                                  style: AppTypography.cardTitle,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tự động chuẩn hóa độ phân giải 1080x720 · Tích chọn các tấm bên phải để đẩy lên Google Drive',
                                  style: AppTypography.caption,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text('KIỂM TRA CHẤT LƯỢNG TRƯỚC KHI GỬI:', style: AppTypography.labelCaps),
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _qcColorBalance,
                        onChanged: (v) => setState(() => _qcColorBalance = v!),
                        title: const Text('Màu sắc và ánh sáng đạt chuẩn'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: AppColors.secondary,
                      ),
                      CheckboxListTile(
                        value: _qcDustScratch,
                        onChanged: (v) => setState(() => _qcDustScratch = v!),
                        title: const Text('Ảnh sạch, không bụi xước'),
                        controlAffinity: ListTileControlAffinity.leading,
                        dense: true,
                        activeColor: AppColors.secondary,
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          if (_isDone)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                              onPressed: () {
                                setState(() => _isDone = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã thu hồi gói scan trong cửa sổ 24 giờ!')),
                                );
                              },
                              icon: const Icon(Icons.undo, size: 16),
                              label: const Text('Thu hồi & Ghi đè (24h)'),
                            ),
                          const Spacer(),
                          Builder(
                            builder: (context) {
                              final hasPendingOrder = _selectedOrderId.isNotEmpty &&
                                  _currentCustomerOrders.any(
                                    (o) => o['order_id'] == _selectedOrderId && o['has_drive_link'] != 'true',
                                  );
                              final hasPhotos = _selectedCount >= 1;
                              final canSubmit = !_isUploading && hasPendingOrder && hasPhotos;
                              return ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  backgroundColor: canSubmit ? AppColors.primary : Colors.grey.shade400,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  disabledForegroundColor: Colors.grey.shade600,
                                ),
                                onPressed: canSubmit ? _submitUpload : null,
                                icon: _isUploading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.cloud_upload, size: 16),
                                label: Text(
                                  _currentCustomerOrders.isEmpty
                                      ? 'Chưa có đơn hoàn tất để gửi ảnh'
                                      : (!hasPendingOrder
                                          ? 'Đơn đã gửi link Drive (chọn đơn chưa gửi)'
                                          : (!hasPhotos
                                              ? 'Chưa chọn ảnh (chọn từ 1 tấm trở lên)'
                                              : (_isUploading
                                                  ? 'Đang đẩy $_selectedCount ảnh cho Đơn #${_orderIdController.text.trim()}...'
                                                  : 'Đẩy $_selectedCount ảnh chọn lên Drive → Gửi cho ${_currentCustomer['full_name']} (Đơn #${_orderIdController.text.trim()})'))),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Right: Selectable Frame-by-Frame Grid Preview (Flex 5)
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _frames.isEmpty
                                  ? 'CHỌN TẤM ẢNH ĐỂ GỬI (CHƯA CÓ ẢNH • 1080x720)'
                                  : 'CHỌN TẤM ẢNH ĐỂ GỬI (ĐÃ CHỌN $_selectedCount/${_frames.length} TẤM - 1080x720)',
                              style: AppTypography.labelCaps.copyWith(color: AppColors.primary),
                            ),
                          ),
                          if (_frames.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      for (final f in _frames) {
                                        f['selected'] = true;
                                      }
                                    });
                                  },
                                  child: const Text('Chọn tất cả', style: TextStyle(fontSize: 12)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      for (final f in _frames) {
                                        f['selected'] = false;
                                      }
                                    });
                                  },
                                  child: const Text('Bỏ chọn', style: TextStyle(fontSize: 12)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _frames.clear();
                                    });
                                  },
                                  child: const Text('Xóa tất cả', style: TextStyle(fontSize: 12, color: AppColors.danger)),
                                ),
                                TextButton.icon(
                                  onPressed: () => _pickPhotosFromComputer(replaceAll: false),
                                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 14),
                                  label: const Text('Thêm ảnh', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            )
                          else
                            TextButton.icon(
                              onPressed: () => _pickPhotosFromComputer(replaceAll: false),
                              icon: const Icon(Icons.folder_open, size: 14),
                              label: const Text('Chọn ảnh từ máy tính', style: TextStyle(fontSize: 12)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_frames.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSunken,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_outlined, size: 44, color: AppColors.inkMuted),
                              const SizedBox(height: 12),
                              Text(
                                'Chưa có tấm ảnh nào được tải lên',
                                style: AppTypography.cardTitle.copyWith(color: AppColors.ink),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Hãy tải ảnh từ máy tính của bạn lên — các tấm ảnh bạn chọn sẽ hiển thị tại đây để tích chọn gửi cho khách hàng.',
                                style: AppTypography.caption.copyWith(color: AppColors.inkMuted),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _pickPhotosFromComputer(replaceAll: false),
                                icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                                label: const Text('+ Chọn ảnh từ máy tính'),
                              ),
                            ],
                          ),
                        )
                      else
                        GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.15,
                        ),
                        itemCount: _frames.length,
                        itemBuilder: (ctx, idx) {
                          final item = _frames[idx];
                          final isSelected = item['selected'] == true;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                item['selected'] = !isSelected;
                              });
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.outline,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  MockTestAssets.image(
                                    item['url'].toString(),
                                    fit: BoxFit.cover,
                                  ),
                                  if (!isSelected)
                                    Container(
                                      color: Colors.black.withValues(alpha: 0.35),
                                    ),
                                  // Top-left frame index + resolution badge
                                  Positioned(
                                    left: 4,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        '#${(idx + 1).toString().padLeft(2, '0')} • 1080x720',
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  // Top-right delete button
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _frames.removeAt(idx);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  // Bottom filename & checkbox
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      color: Colors.black.withValues(alpha: 0.7),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item['name'].toString(),
                                              style: const TextStyle(color: Colors.white, fontSize: 9),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.secondary : Colors.transparent,
                                              border: Border.all(color: Colors.white, width: 1.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      if (_frames.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Bấm vào từng tấm ảnh để Chọn / Bỏ chọn. Chỉ $_selectedCount tấm ảnh được tích chọn mới được tải lên thư mục Google Drive gửi cho khách hàng.',
                          style: AppTypography.caption,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
