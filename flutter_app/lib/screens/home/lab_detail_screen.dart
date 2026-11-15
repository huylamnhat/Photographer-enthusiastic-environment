import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/lab_model.dart';
import 'create_order_screen.dart';

class LabDetailScreen extends StatefulWidget {
  final LabModel? lab;
  final String? labId;

  const LabDetailScreen({super.key, this.lab, this.labId});

  @override
  State<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends State<LabDetailScreen> {
  final ApiService _apiService = ApiService();
  LabModel? _resolvedLab;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _resolvedLab = widget.lab;
    _loadLabDetail();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadLabDetail(silent: true),
    );
  }

  @override
  void reassemble() {
    super.reassemble();
    _loadLabDetail(silent: true);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _resolveTargetLabId() {
    final raw = (widget.lab?.labId.isNotEmpty == true ? widget.lab!.labId : widget.labId) ?? 'lab-001';
    final lower = raw.trim().toLowerCase();
    if (lower == 'croplab' || lower.contains('croplab')) return 'lab-001';
    if (lower == 'llab' || lower.contains('llab') || lower.contains('saigon') || lower.contains('sài gòn')) return 'lab-002';
    if (lower == 'nadar' || lower.contains('nadar')) return 'lab-003';
    return raw;
  }

  Future<void> _loadLabDetail({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final targetId = _resolveTargetLabId();
    try {
      final fetched = await _apiService.getLabById(targetId);
      if (!mounted) return;
      setState(() {
        if (fetched != null) {
          _resolvedLab = fetched;
        }
        _isLoading = false;
        if (_resolvedLab == null) {
          _errorMessage = 'Không tìm thấy thông tin tiệm Lab ($targetId).';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (_resolvedLab == null) {
          _errorMessage = 'Không thể tải dữ liệu tiệm Lab từ máy chủ.';
        }
      });
    }
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

  double? _getMinPackagePrice(LabModel lab) {
    if (lab.packages.isEmpty) return null;
    double minPrice = lab.packages.first.price;
    for (final pkg in lab.packages) {
      if (pkg.price < minPrice) minPrice = pkg.price;
    }
    return minPrice;
  }

  void _openCreateOrder(LabModel lab, {String? initialPackageId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOrderScreen(
          lab: lab,
          initialLabId: lab.labId,
          initialPackageId: initialPackageId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lab = _resolvedLab;

    if (_isLoading && lab == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceRaised,
          foregroundColor: AppColors.ink,
          elevation: 0,
          title: const Text('Thông tin Lab'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (lab == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceRaised,
          foregroundColor: AppColors.ink,
          elevation: 0,
          title: const Text('Thông tin Lab'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.store_mall_directory_outlined, size: 48, color: AppColors.inkMuted),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Không có dữ liệu tiệm Lab.',
                  style: AppTypography.bodyMuted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _loadLabDetail();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Thử lại', style: TextStyle(color: AppColors.onPrimary)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final minPrice = _getMinPackagePrice(lab);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: AppColors.surfaceRaised,
            foregroundColor: AppColors.ink,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised.withAlpha(235),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.ink, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised.withAlpha(235),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outline),
                ),
                child: IconButton(
                  tooltip: 'Làm mới bảng giá & quy trình',
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                  onPressed: _loadLabDetail,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (lab.coverImage.isNotEmpty)
                    Image.network(
                      lab.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildCoverFallback(lab),
                    )
                  else
                    _buildCoverFallback(lab),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(45),
                          Colors.black.withAlpha(155),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: lab.logoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(
                                    lab.logoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.camera_roll,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.camera_roll, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      lab.name,
                                      style: AppTypography.sectionHeading.copyWith(
                                        color: Colors.white,
                                        fontSize: 19,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (lab.isVerified) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: Color(0xFF4ADE80), size: 18),
                                  ],
                                ],
                              ),
                              if (lab.tagline.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  lab.tagline,
                                  style: AppTypography.caption.copyWith(color: Colors.white.withAlpha(230)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(lab),
                  const SizedBox(height: 18),
                  Text(
                    'THÔNG SỐ BUỒNG TỐI & MÁY QUÉT',
                    style: AppTypography.sectionHeading.copyWith(fontSize: 13, letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 10),
                  _buildEquipmentCard(lab),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BẢNG TRÁNG & QUY TRÌNH HÓA CHẤT',
                        style: AppTypography.sectionHeading.copyWith(fontSize: 13, letterSpacing: 0.4),
                      ),
                      Text(
                        '${lab.processTable.length} quy trình',
                        style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildProcessTableSection(lab),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BẢNG GIÁ DỊCH VỤ TRÁNG & SCAN',
                        style: AppTypography.sectionHeading.copyWith(fontSize: 13, letterSpacing: 0.4),
                      ),
                      Text(
                        '${lab.packages.length} gói',
                        style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildPackagesSection(lab),
                ],
              ),
            ),
          ),
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
                      minPrice != null ? 'Giá dịch vụ từ' : 'Bảng giá Lab',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      minPrice != null ? '${_formatVnd(minPrice)} / cuộn' : (lab.priceRange.isNotEmpty ? lab.priceRange : 'Liên hệ Lab'),
                      style: AppTypography.sectionHeading.copyWith(
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openCreateOrder(lab),
                icon: const Icon(Icons.add_a_photo_outlined, size: 18, color: AppColors.onPrimary),
                label: const Text(
                  'Tạo Đơn Tráng',
                  style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverFallback(LabModel lab) {
    return Container(
      color: AppColors.ink,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_enhance_outlined, size: 44, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            lab.name,
            style: AppTypography.cardTitle.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(LabModel lab) {
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
          Row(
            children: [
              _buildMetricPill(
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFD97706),
                label: '${lab.rating.toStringAsFixed(1)} (${lab.reviewCount} đánh giá)',
              ),
              const SizedBox(width: 8),
              _buildMetricPill(
                icon: Icons.schedule_rounded,
                iconColor: AppColors.secondary,
                label: 'SLA ${lab.turnaroundHours}h',
              ),
              const SizedBox(width: 8),
              if (lab.city.isNotEmpty)
                _buildMetricPill(
                  icon: Icons.location_city_rounded,
                  iconColor: AppColors.primary,
                  label: lab.city,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (lab.description.isNotEmpty) ...[
            Text(lab.description, style: AppTypography.bodyMuted),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(child: Text(lab.address, style: AppTypography.body)),
            ],
          ),
          if (lab.phone.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(lab.phone, style: AppTypography.dataMono),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricPill({required IconData icon, required Color iconColor, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEquipmentCard(LabModel lab) {
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
          _buildSpecRow(
            'Máy quét film',
            lab.scannerModels.isNotEmpty ? lab.scannerModels.join(' • ') : 'Đang cập nhật',
          ),
          const Divider(height: 18, color: AppColors.outline),
          _buildSpecRow(
            'Khổ film nhận tráng',
            lab.supportedFormats.isNotEmpty ? lab.supportedFormats.join(', ') : '135 / 120',
          ),
          const Divider(height: 18, color: AppColors.outline),
          _buildSpecRow(
            'Quy trình hóa chất',
            lab.supportedProcesses.isNotEmpty ? lab.supportedProcesses.join(', ') : 'C-41',
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 132,
          child: Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessTableSection(LabModel lab) {
    if (lab.processTable.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          'Lab đang cập nhật thông số bảng tráng kỹ thuật.',
          style: AppTypography.bodyMuted,
        ),
      );
    }

    return Column(
      children: lab.processTable.map((row) {
        final code = (row['process_code'] ?? row['process'] ?? 'C-41').toString();
        final name = (row['process_name'] ?? 'Quy trình tráng').toString();
        final chemistry = (row['chemistry'] ?? '').toString();
        final temp = (row['temperature'] ?? '').toString();
        final devMachine = (row['dev_machine'] ?? '').toString();
        final scanner = (row['scanner'] ?? '').toString();
        final sla = row['turnaround_hours']?.toString() ?? lab.turnaroundHours.toString();
        final pushPull = (row['push_pull_policy'] ?? '').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(24),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withAlpha(80)),
                    ),
                    child: Text(
                      code,
                      style: AppTypography.monoSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                    ),
                  ),
                  Text(
                    'SLA ${sla}h',
                    style: AppTypography.dataMono.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (chemistry.isNotEmpty)
                _buildProcessDetailLine('Hóa chất', chemistry),
              if (temp.isNotEmpty)
                _buildProcessDetailLine('Nhiệt độ', temp),
              if (devMachine.isNotEmpty)
                _buildProcessDetailLine('Máy tráng', devMachine),
              if (scanner.isNotEmpty)
                _buildProcessDetailLine('Máy quét', scanner),
              if (pushPull.isNotEmpty)
                _buildProcessDetailLine('Push / Pull', pushPull),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProcessDetailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text('$label:', style: AppTypography.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection(LabModel lab) {
    if (lab.packages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          'Lab chưa niêm yết gói dịch vụ nào.',
          style: AppTypography.bodyMuted,
        ),
      );
    }

    return Column(
      children: lab.packages.map((pkg) {
        return InkWell(
          onTap: () => _openCreateOrder(lab, initialPackageId: pkg.packageId),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pkg.name,
                        style: AppTypography.cardTitle,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                    _buildTag(pkg.filmFormat),
                    _buildTag(pkg.processType),
                    _buildTag(pkg.scanResolution),
                    _buildTag('SLA ${pkg.estimatedHours}h', isAccent: true),
                  ],
                ),
                if (pkg.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(pkg.description, style: AppTypography.caption),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Chọn gói này để đặt đơn →',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTag(String label, {bool isAccent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAccent ? AppColors.successBg : AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isAccent ? AppColors.secondary.withAlpha(60) : AppColors.outline),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: isAccent ? AppColors.secondary : AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
