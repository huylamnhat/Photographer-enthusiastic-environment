import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class LabRegisterScreen extends StatefulWidget {
  const LabRegisterScreen({super.key});

  @override
  State<LabRegisterScreen> createState() => _LabRegisterScreenState();
}

class _LabRegisterScreenState extends State<LabRegisterScreen> {
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _labNameController = TextEditingController();
  final _districtController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _licenseController = TextEditingController();
  final _noteController = TextEditingController();

  String _city = 'Hà Nội';
  final Set<String> _selectedScanners = {'Noritsu HS-1800'};
  final Set<String> _selectedProcesses = {'C-41', 'B&W'};

  bool _obscurePassword = true;
  bool _submitting = false;
  bool _submitted = false;
  String _createdLabId = '';
  String? _errorMessage;

  static const List<String> _cities = ['Hà Nội', 'TP.HCM', 'Đà Nẵng', 'Đà Lạt', 'Khác'];
  static const List<String> _scannerOptions = [
    'Noritsu HS-1800',
    'Fuji Frontier SP-3000',
    'Noritsu LS-600',
    'Hasselblad Flextight X5',
  ];
  static const List<String> _processOptions = ['C-41', 'B&W', 'E-6', 'ECN-2'];

  @override
  void dispose() {
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _labNameController.dispose();
    _districtController.dispose();
    _streetAddressController.dispose();
    _licenseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    final owner = _ownerNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final labName = _labNameController.text.trim();
    final address = _streetAddressController.text.trim();

    if (owner.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || labName.isEmpty || address.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng điền đầy đủ thông tin chủ tiệm, tên Tiệm Lab, địa chỉ và mật khẩu.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final res = await ApiService().registerLab({
      'owner_name': owner,
      'email': email,
      'phone': phone,
      'password': password,
      'lab_name': labName,
      'city': _city,
      'district': _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : 'Trung tâm',
      'street_address': address,
      if (_licenseController.text.trim().isNotEmpty) 'business_license': _licenseController.text.trim(),
      'scanner_models': _selectedScanners.toList(),
      'supported_processes': _selectedProcesses.toList(),
      if (_noteController.text.trim().isNotEmpty) 'inspection_note': _noteController.text.trim(),
    });

    if (!mounted) return;
    if (res['success'] == true) {
      final data = res['data'] is Map ? res['data'] as Map : {};
      setState(() {
        _submitting = false;
        _submitted = true;
        _createdLabId = (data['application_id'] ?? '').toString();
      });
    } else {
      setState(() {
        _submitting = false;
        _errorMessage = res['message']?.toString() ?? 'Không thể gửi hồ sơ đăng ký Tiệm Lab.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_outlined, size: 54, color: AppColors.secondary),
                const SizedBox(height: 16),
                Text('Đã gửi hồ sơ đăng ký Tiệm Film Lab!', style: AppTypography.pageTitle, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                if (_createdLabId.isNotEmpty)
                  Text(
                    'Mã hồ sơ: $_createdLabId • Email: ${_emailController.text.trim()}',
                    style: AppTypography.dataMono.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 12),
                Text(
                  'Hồ sơ của bạn đã chuyển đến mục Thẩm định đối tác (Admin). Sau khi Admin phê duyệt mở tiệm, bạn có thể đăng nhập ngay vào Cổng Vận Hành Film Lab.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Quay lại Trang Đăng Nhập Web'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outline, height: 1),
        ),
        title: const Text('ĐĂNG KÝ MỞ TIỆM FILM LAB ĐỐI TÁC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('ĐỐI TÁC FILM LAB MỚI', style: AppTypography.labelCaps),
                const SizedBox(height: 4),
                const Text('Đăng ký Tiệm Film Lab', style: AppTypography.pageTitle),
                const SizedBox(height: 6),
                const Text(
                  'Điền thông tin tiệm và thiết bị để được xét duyệt mở gian hàng.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 20),

                const Text('1. TÀI KHOẢN CHỦ TIỆM ĐĂNG NHẬP LAB PORTAL', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ownerNameController,
                        decoration: const InputDecoration(
                          labelText: 'HỌ VÀ TÊN CHỦ TIỆM',
                          hintText: 'VD: Nguyễn Minh Khoa',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'SỐ ĐIỆN THOẠI LIÊN HỆ',
                          hintText: '09xxxxxxxx',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'EMAIL ĐĂNG NHẬP LAB',
                          hintText: 'labcuatoi@gmail.com',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'MẬT KHẨU ĐĂNG NHẬP (>= 6 KÝ TỰ)',
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                const Text('2. THÔNG TIN TIỆM LAB & THIẾT BỊ KIỂM ĐỊNH', style: AppTypography.sectionHeading),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _labNameController,
                        decoration: const InputDecoration(
                          labelText: 'TÊN TIỆM FILM LAB',
                          hintText: 'VD: Analog Station Lab',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _city,
                        decoration: const InputDecoration(labelText: 'TỈNH / THÀNH PHỐ'),
                        items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _city = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _districtController,
                        decoration: const InputDecoration(
                          labelText: 'QUẬN / HUYỆN',
                          hintText: 'VD: Đống Đa / Quận 3',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _streetAddressController,
                        decoration: const InputDecoration(
                          labelText: 'ĐỊA CHỈ CHI TIẾT',
                          hintText: 'Số nhà, đường, phường...',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    labelText: 'SỐ ĐKKD / CHỨNG NHẬN XỬ LÝ HÓA CHẤT (TÙY CHỌN)',
                    hintText: 'VD: GPKD-0108923412',
                  ),
                ),
                const SizedBox(height: 16),

                const Text('MÁY SCAN PHIM SỞ HỮU', style: AppTypography.labelCaps),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _scannerOptions.map((s) {
                    final selected = _selectedScanners.contains(s);
                    return FilterChip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedScanners.add(s);
                          } else if (_selectedScanners.length > 1) {
                            _selectedScanners.remove(s);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                const Text('QUY TRÌNH TRÁNG HỖ TRỢ', style: AppTypography.labelCaps),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _processOptions.map((p) {
                    final selected = _selectedProcesses.contains(p);
                    return FilterChip(
                      label: Text(p, style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedProcesses.add(p);
                          } else if (_selectedProcesses.length > 1) {
                            _selectedProcesses.remove(p);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'GHI CHÚ BUỒNG TỐI / CAM KẾT CHẤT LƯỢNG',
                    hintText: 'Mô tả quy trình xử lý hóa chất, bảo quản film âm bản...',
                  ),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.4)),
                    ),
                    child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.errorRed)),
                  ),
                ],
                const SizedBox(height: 22),

                SizedBox(
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submitApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.storefront, size: 18),
                    label: Text(
                      _submitting ? 'Đang gửi hồ sơ thẩm định...' : 'Gửi Hồ Sơ Đăng Ký Mở Tiệm Lab',
                      style: AppTypography.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
