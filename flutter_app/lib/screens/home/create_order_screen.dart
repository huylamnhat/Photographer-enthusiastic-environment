import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/lab_model.dart';
import 'checkout_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final LabModel? lab;
  final String? initialLabId;
  final String? initialPackageId;

  const CreateOrderScreen({
    super.key,
    this.lab,
    this.initialLabId,
    this.initialPackageId,
  });

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _filmNameController =
      TextEditingController(text: 'Kodak Gold 200');

  LabModel? _selectedLab;
  ServicePackageModel? _selectedPackage;
  bool _isLoadingLabs = true;
  Timer? _refreshTimer;

  String _filmFormat = '135';
  String _process = 'C-41';
  String _scanner = 'Noritsu HS-1800';
  String _resolution = 'Standard JPG';
  String _pushPull = 'Box Speed';
  String _negativeHandling = 'STORE_15D';
  String _shippingMethod = 'Gửi trực tiếp tại quầy Lab';
  int _quantity = 1;

  static const List<String> _filmPresets = [
    'Kodak Gold 200',
    'Kodak Portra 400',
    'Kodak ColorPlus 200',
    'Fujifilm C200',
    'CineStill 800T',
    'Ilford HP5 Plus 400',
  ];

  static const List<String> _pushPullOptions = [
    'Box Speed',
    'Push +1 Stop',
    'Push +2 Stops',
    'Pull -1 Stop',
  ];

  static const Map<String, String> _negativeHandlingOptions = {
    'STORE_15D': 'Lưu tại Lab 15 ngày rồi nhận cùng ảnh',
    'CUT_SLEEVE': 'Cắt 6 frame lồng sleeve bảo quản',
    'NO_CUT_ROLL': 'Giữ nguyên cuộn âm bản không cắt',
  };

  static const List<String> _shippingOptions = [
    'Gửi trực tiếp tại quầy Lab',
    'Shipper / GrabExpress giao tận Lab',
    'Gửi chuyển phát nhanh bưu điện',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.lab != null) {
      _selectedLab = widget.lab;
      _applyLabDefaults(widget.lab!, preferredPackageId: widget.initialPackageId);
    }
    _loadLabsAndDetail();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadLabsAndDetail(silent: true),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadLabsAndDetail(silent: true);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _filmNameController.dispose();
    super.dispose();
  }

  String _resolveCanonicalLabId(String? raw) {
    final val = (raw ?? 'lab-001').trim().toLowerCase();
    if (val == 'croplab' || val.contains('croplab')) return 'lab-001';
    if (val == 'llab' || val.contains('llab') || val.contains('sài gòn') || val.contains('saigon')) return 'lab-002';
    if (val == 'nadar' || val.contains('nadar')) return 'lab-003';
    return (raw != null && raw.trim().isNotEmpty) ? raw.trim() : 'lab-001';
  }

  Future<void> _loadLabsAndDetail({bool silent = false}) async {
    try {
      final currentIdSource = _selectedLab?.labId.isNotEmpty == true
          ? _selectedLab!.labId
          : (widget.lab?.labId.isNotEmpty == true ? widget.lab!.labId : widget.initialLabId);
      final targetId = _resolveCanonicalLabId(currentIdSource);

      LabModel? matched = await _apiService.getLabById(targetId);
      if (matched == null) {
        final fallbackLabs = await _apiService.getLabs();
        if (fallbackLabs.isNotEmpty) {
          matched = fallbackLabs.first;
        } else {
          matched = _selectedLab ?? widget.lab;
        }
      }

      if (!mounted) return;
      final preferredPkgId = _selectedPackage?.packageId ?? widget.initialPackageId;
      setState(() {
        _selectedLab = matched;
        _isLoadingLabs = false;
        if (matched != null) {
          if (silent) {
            if (matched.packages.isNotEmpty) {
              if (preferredPkgId != null && preferredPkgId.isNotEmpty) {
                _selectedPackage = matched.packages.firstWhere(
                  (p) => p.packageId == preferredPkgId,
                  orElse: () => matched!.packages.first,
                );
              } else {
                _selectedPackage ??= matched.packages.first;
              }
            }
          } else {
            _applyLabDefaults(matched, preferredPackageId: preferredPkgId);
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingLabs = false;
      });
    }
  }

  void _applyLabDefaults(LabModel lab, {String? preferredPackageId}) {
    ServicePackageModel? chosenPkg;
    if (lab.packages.isNotEmpty) {
      if (preferredPackageId != null && preferredPackageId.isNotEmpty) {
        chosenPkg = lab.packages.firstWhere(
          (p) => p.packageId == preferredPackageId,
          orElse: () => lab.packages.first,
        );
      } else {
        chosenPkg = lab.packages.first;
      }
    }

    _selectedPackage = chosenPkg;
    if (chosenPkg != null) {
      _filmFormat = chosenPkg.filmFormat;
      _process = chosenPkg.processType;
      _resolution = chosenPkg.scanResolution;
    } else {
      _filmFormat = lab.supportedFormats.isNotEmpty ? lab.supportedFormats.first : '135';
      _process = lab.supportedProcesses.isNotEmpty ? lab.supportedProcesses.first : 'C-41';
      _resolution = 'Standard JPG';
    }

    if (lab.scannerModels.isNotEmpty) {
      _scanner = lab.scannerModels.first;
    }
  }

  void _selectPackage(ServicePackageModel pkg) {
    setState(() {
      _selectedPackage = pkg;
      _filmFormat = pkg.filmFormat;
      _process = pkg.processType;
      _resolution = pkg.scanResolution;
    });
  }

  String _normalizeCode(String raw) =>
      raw.toUpperCase().replaceAll('-', '').replaceAll('&', '').replaceAll(' ', '');

  Map<String, dynamic>? _findMatchingProcessRow(LabModel? lab) {
    if (lab == null || lab.processTable.isEmpty) return null;
    final target = _normalizeCode(_process);
    for (final row in lab.processTable) {
      final code = _normalizeCode((row['process_code'] ?? row['process'] ?? '').toString());
      if (code == target) return row;
    }
    return null;
  }

  int _fallbackBasePrice() {
    switch (_normalizeCode(_process)) {
      case 'BW':
        return 85000;
      case 'ECN2':
        return 95000;
      case 'E6':
        return 140000;
      default:
        return 60000;
    }
  }

  int _pushPullExtraPerRoll() {
    if (_pushPull == 'Box Speed') return 0;
    if (_pushPull.contains('+2')) return 30000;
    return 20000;
  }

  double _calculateTotal() {
    final baseUnit = _selectedPackage?.price ?? _fallbackBasePrice();
    final extra = _pushPullExtraPerRoll();
    return ((baseUnit + extra) * _quantity).toDouble();
  }

  String _formatVnd(num amount) {
    final str = amount.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buf.write('.');
      }
      buf.write(str[i]);
    }
    return '${buf.toString()}đ';
  }

  void _proceedToCheckout() {
    final lab = _selectedLab;
    if (lab == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn tiệm Lab trước khi tiếp tục.')),
      );
      return;
    }

    final filmName = _filmNameController.text.trim().isNotEmpty
        ? _filmNameController.text.trim()
        : 'Kodak Gold 200';
    final packageName = _selectedPackage != null
        ? '${_selectedPackage!.name} (${_selectedPackage!.filmFormat} • ${_selectedPackage!.processType})'
        : '$_process ($_filmFormat • $_resolution)';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          lab: lab,
          filmName: filmName,
          quantity: _quantity,
          packageName: packageName,
          totalPrice: _calculateTotal(),
          pushPull: _pushPull,
          cutOption: _negativeHandlingOptions[_negativeHandling] ?? _negativeHandling,
          shippingMethod: _shippingMethod,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lab = _selectedLab;
    final matchingProcess = _findMatchingProcessRow(lab);
    final totalPrice = _calculateTotal();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceRaised,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text('Tạo Đơn Tráng Film'),
        actions: [
          IconButton(
            tooltip: 'Làm mới gói dịch vụ',
            icon: _isLoadingLabs
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadLabsAndDetail,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outline),
        ),
      ),
      body: _isLoadingLabs && lab == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                if (lab != null) ...[
                  _buildSelectedLabHeaderCard(lab),
                  const SizedBox(height: 20),
                ],

                _buildSectionHeader('1. BẢNG DỊCH VỤ CỦA LAB'),
                const SizedBox(height: 6),
                if (lab != null)
                  Text(
                    'Hiển thị bảng giá riêng của ${lab.name}',
                    style: AppTypography.caption,
                  ),
                const SizedBox(height: 10),
                _buildPackageSelector(lab),
                const SizedBox(height: 20),

                _buildSectionHeader('2. BẢNG TRÁNG KỸ THUẬT CỦA LAB'),
                const SizedBox(height: 10),
                _buildProcessTableCard(lab, matchingProcess),
                const SizedBox(height: 20),

                _buildSectionHeader('3. THÔNG TIN CUỘN FILM & QUÉT'),
                const SizedBox(height: 10),
                _buildFilmAndTechCard(lab),
                const SizedBox(height: 20),

                _buildSectionHeader('4. ÂM BẢN & GIAO NHẬN'),
                const SizedBox(height: 10),
                _buildLogisticsCard(),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_quantity cuộn • ${_selectedPackage?.scanResolution ?? _resolution}',
                      style: AppTypography.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatVnd(totalPrice),
                      style: AppTypography.sectionHeading.copyWith(
                        color: AppColors.primary,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: lab == null ? null : _proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Tiếp tục thanh toán →',
                  style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.labelCaps.copyWith(
        color: AppColors.ink,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSelectedLabHeaderCard(LabModel lab) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(90)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(24),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lab.name,
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  lab.address,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outline),
            ),
            child: Text(
              'SLA ${lab.turnaroundHours}h',
              style: AppTypography.monoSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageSelector(LabModel? lab) {
    if (_isLoadingLabs && (lab == null || lab.packages.isEmpty)) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (lab == null || lab.packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          'Lab này chưa cập nhật bảng gói dịch vụ riêng. Hệ thống sẽ dùng đơn giá mặc định.',
          style: AppTypography.bodyMuted,
        ),
      );
    }

    return Column(
      children: lab.packages.map((pkg) {
        final isSelected = _selectedPackage?.packageId == pkg.packageId;
        return GestureDetector(
          onTap: () => _selectPackage(pkg),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withAlpha(18) : AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.outline,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      size: 18,
                      color: isSelected ? AppColors.primary : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(pkg.name, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                    ),
                    Text(
                      _formatVnd(pkg.price),
                      style: AppTypography.cardTitle.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildMiniBadge(pkg.filmFormat),
                    _buildMiniBadge(pkg.processType),
                    _buildMiniBadge(pkg.scanResolution),
                    _buildMiniBadge('SLA ${pkg.estimatedHours}h'),
                  ],
                ),
                if (pkg.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(pkg.description, style: AppTypography.caption),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcessTableCard(LabModel? lab, Map<String, dynamic>? matchingRow) {
    if (lab == null || lab.processTable.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          'Lab đang cập nhật thông số hóa chất & quy trình tráng.',
          style: AppTypography.bodyMuted,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (matchingRow != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.secondary.withAlpha(70)),
              ),
              child: Text(
                'Đang áp dụng cho gói chọn: ${matchingRow['process_code'] ?? _process} • '
                '${matchingRow['chemistry'] ?? ''} (${matchingRow['temperature'] ?? ''})',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ...lab.processTable.map((row) {
            final code = (row['process_code'] ?? '').toString();
            final isActive = _normalizeCode(code) == _normalizeCode(_process);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withAlpha(14) : AppColors.surfaceSunken,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: AppTypography.monoSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (row['process_name'] ?? '').toString(),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${row['turnaround_hours'] ?? lab.turnaroundHours}h',
                        style: AppTypography.monoSm.copyWith(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hóa chất: ${row['chemistry'] ?? '-'} • Nhiệt độ: ${row['temperature'] ?? '-'}',
                    style: AppTypography.caption,
                  ),
                  Text(
                    'Máy tráng: ${row['dev_machine'] ?? '-'} • Scanner: ${row['scanner'] ?? '-'}',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilmAndTechCard(LabModel? lab) {
    final formats = (lab != null && lab.supportedFormats.isNotEmpty)
        ? lab.supportedFormats
        : ['135', '120'];
    final scanners = (lab != null && lab.scannerModels.isNotEmpty)
        ? lab.scannerModels
        : ['Noritsu HS-1800'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tên cuộn film', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _filmNameController,
            decoration: InputDecoration(
              hintText: 'VD: Kodak Portra 400, Ilford HP5...',
              filled: true,
              fillColor: AppColors.surfaceSunken,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _filmPresets.map((preset) {
              return ActionChip(
                label: Text(preset, style: AppTypography.caption.copyWith(fontSize: 11)),
                backgroundColor: AppColors.surfaceSunken,
                side: const BorderSide(color: AppColors.outline),
                onPressed: () {
                  setState(() {
                    _filmNameController.text = preset;
                  });
                },
              );
            }).toList(),
          ),
          const Divider(height: 22, color: AppColors.outline),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Số lượng cuộn', style: AppTypography.cardTitle.copyWith(fontSize: 14)),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.primary,
                  ),
                  Text('$_quantity', style: AppTypography.sectionHeading.copyWith(fontSize: 16)),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Khổ film Lab hỗ trợ', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: formats.map((f) {
              final selected = f == _filmFormat;
              return ChoiceChip(
                label: Text(f),
                selected: selected,
                selectedColor: AppColors.primary.withAlpha(32),
                onSelected: (_) => setState(() => _filmFormat = f),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text('Máy quét tại Lab', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: scanners.map((s) {
              final selected = s == _scanner;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                selectedColor: AppColors.primary.withAlpha(32),
                onSelected: (_) => setState(() => _scanner = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text('Yêu cầu Push / Pull', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _pushPullOptions.map((opt) {
              final selected = opt == _pushPull;
              return ChoiceChip(
                label: Text(opt),
                selected: selected,
                selectedColor: AppColors.primary.withAlpha(32),
                onSelected: (_) => setState(() => _pushPull = opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogisticsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Xử lý âm bản sau tráng', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._negativeHandlingOptions.entries.map((entry) {
            final selected = _negativeHandling == entry.key;
            return InkWell(
              onTap: () => setState(() => _negativeHandling = entry.key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: selected ? AppColors.primary : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.value, style: AppTypography.body)),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 20, color: AppColors.outline),
          Text('Cách gửi film đến Lab', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ..._shippingOptions.map((method) {
            final selected = _shippingMethod == method;
            return InkWell(
              onTap: () => setState(() => _shippingMethod = method),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 18,
                      color: selected ? AppColors.primary : AppColors.inkMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(method, style: AppTypography.body)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(fontSize: 11, color: AppColors.ink),
      ),
    );
  }
}
