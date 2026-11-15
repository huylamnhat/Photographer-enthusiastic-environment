import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';

class AdminOverviewTab extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const AdminOverviewTab({super.key, this.onNavigateTab});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  String _selectedRegion = 'Tất cả';
  List<Map<String, dynamic>> _labs = [];
  List<Map<String, dynamic>> _urgentQueue = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final dash = await WebApiService().getAdminDashboard();
    final disputes = await WebApiService().getAdminDisputes();
    final pendingLabs = await WebApiService().getAdminPendingLabs();
    final pendingMkt = await WebApiService().getAdminPendingMarketplace();

    final rawLabs = (dash['labs'] as List?) ?? [];
    final mappedLabs = rawLabs.map<Map<String, dynamic>>((l) {
      final name = (l['name'] ?? 'Film Lab').toString();
      final words = name.split(' ').where((w) => w.isNotEmpty).toList();
      final initials = words.length >= 2
          ? '${words[0][0]}${words[1][0]}'.toUpperCase()
          : (name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'FL');
      final isPending = l['status'] == 'PENDING';
      final scanners = (l['scanner_models'] as List?)?.join(', ') ?? 'Noritsu HS-1800';
      return {
        'initials': initials,
        'name': name,
        'code': '#${(l['lab_id'] ?? l['application_id'] ?? 'LAB').toString().toUpperCase()} · $scanners',
        'region': (l['city'] ?? 'Hà Nội').toString(),
        'output': l['review_count'] ?? 0,
        'sla': isPending ? 'Chờ duyệt' : '98.5%',
        'status': isPending ? 'Theo dõi' : 'Ổn định',
        'statusColor': isPending ? AppColors.warning : AppColors.secondary,
        'statusBg': isPending ? AppColors.warningBg : AppColors.successBg,
      };
    }).toList();

    final queue = <Map<String, dynamic>>[];
    for (final d in disputes) {
      final st = (d['status'] ?? '').toString().toUpperCase();
      final isDone = ['RESOLVED', 'REFUNDED', 'COMPENSATED'].contains(st);
      queue.add({
        'tag': isDone
            ? (st == 'REFUNDED' ? 'Đã hoàn tiền' : (st == 'COMPENSATED' ? 'Đã đền bù' : 'Đã hoàn thành'))
            : 'Khẩn',
        'tagColor': isDone ? AppColors.secondary : AppColors.danger,
        'tagBg': isDone ? AppColors.successBg : AppColors.dangerBg,
        'code': '#${d['dispute_id']}',
        'time': isDone ? 'Hoàn thành' : 'Tranh chấp',
        'sender': d['customer_name'] ?? 'Khách hàng',
        'action': 'khiếu nại',
        'target': d['lab_name'] ?? 'Film Lab',
        'detail': d['issue_type'] ?? d['description'] ?? '',
        'tabIndex': 6,
        'isCompleted': isDone,
      });
    }
    for (final l in pendingLabs) {
      final st = (l['status'] ?? 'PENDING').toString().toUpperCase();
      final isDone = st != 'PENDING';
      queue.add({
        'tag': isDone ? 'Đã duyệt' : 'KYC Lab',
        'tagColor': AppColors.secondary,
        'tagBg': AppColors.successBg,
        'code': '#${l['application_id']}',
        'time': isDone ? 'Hoàn thành' : 'Hồ sơ Lab',
        'sender': l['name'] ?? 'Film Lab',
        'action': 'nộp hồ sơ',
        'target': '',
        'detail': l['inspection_note'] ?? 'Chờ thẩm định giấy phép ĐKKD',
        'tabIndex': 2,
        'isCompleted': isDone,
      });
    }
    for (final m in pendingMkt) {
      final st = (m['status'] ?? 'PENDING_REVIEW').toString().toUpperCase();
      final isDone = !['PENDING_REVIEW', 'PENDING_APPROVAL'].contains(st);
      queue.add({
        'tag': isDone ? 'Đã duyệt' : 'Tin chợ',
        'tagColor': isDone ? AppColors.secondary : AppColors.inkMuted,
        'tagBg': isDone ? AppColors.successBg : AppColors.surfaceSunken,
        'code': '#${m['listing_id']}',
        'time': isDone ? 'Hoàn thành' : 'Chờ duyệt',
        'sender': m['title'] ?? 'Thiết bị',
        'action': '',
        'target': '(${m['seller_name'] ?? ''})',
        'detail': m['condition'] ?? 'Chờ kiểm duyệt tiền kiểm 100%',
        'tabIndex': 3,
        'isCompleted': isDone,
      });
    }

    // Đẩy các mục đã hoàn thành xuống dưới cùng
    queue.sort((a, b) {
      final aDone = a['isCompleted'] == true ? 1 : 0;
      final bDone = b['isCompleted'] == true ? 1 : 0;
      return aDone.compareTo(bDone);
    });

    if (!mounted) return;
    setState(() {
      _stats = dash;
      _labs = mappedLabs;
      _urgentQueue = queue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLabs = _selectedRegion == 'Tất cả'
        ? _labs
        : _labs.where((l) => l['region'].toString().contains(_selectedRegion)).toList();
    final pendingUrgentCount = _urgentQueue.where((q) => q['isCompleted'] != true).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'TRẠM ĐIỀU HÀNH TRUNG TÂM / ADM-02 (SQL SERVER)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Tổng quan vận hành', style: AppTypography.pageTitle),
                ],
              ),
              IconButton(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh, color: AppColors.inkMuted),
                tooltip: 'Đồng bộ từ CSDL',
              ),
            ],
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              return GridView.count(
                crossAxisCount: isDesktop ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isDesktop ? 1.45 : 1.25,
                children: [
                  _buildKpiCard(
                    title: 'ĐƠN HÀNG HỆ THỐNG',
                    value: '${_stats['total_orders'] ?? 0}',
                    fontSize: 42,
                    delta: '+8%',
                    icon: Icons.receipt_long_outlined,
                    iconColor: AppColors.inkMuted,
                    subtext: 'Đồng bộ từ bảng Orders',
                    footnote: 'SQL Server',
                    isPositive: true,
                  ),
                  _buildKpiCard(
                    title: 'LAB ĐANG HOẠT ĐỘNG',
                    value: '${_stats['active_labs'] ?? 0}',
                    fontSize: 42,
                    delta: 'đối tác',
                    icon: Icons.motion_photos_on_outlined,
                    iconColor: AppColors.primary,
                    subtext: 'Chờ duyệt: ${_stats['pending_labs'] ?? 0} Lab',
                    footnote: 'Đúng tiến độ',
                    isPositive: true,
                    deltaIsText: true,
                  ),
                  _buildKpiCard(
                    title: 'TỶ LỆ TUÂN THỦ SLA',
                    value: '${_stats['sla_on_time_rate'] ?? '98.4%'}',
                    fontSize: 42,
                    delta: '+1.2%',
                    icon: Icons.verified_outlined,
                    iconColor: AppColors.secondary,
                    subtext: 'Ngưỡng cảnh báo: <92.0%',
                    footnote: 'Mục tiêu: 95%',
                    isPositive: true,
                  ),
                  _buildKpiCard(
                    title: 'CẦN XỬ LÝ GẤP',
                    value: '$pendingUrgentCount',
                    fontSize: 42,
                    delta: 'CẦN DUYỆT',
                    icon: Icons.error_outline,
                    iconColor: AppColors.danger,
                    valueColor: AppColors.danger,
                    subtext: '${_stats['open_disputes'] ?? 0} tranh chấp đang mở',
                    footnote: 'Hàng chờ ưu tiên',
                    isDangerBadge: true,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.science_outlined, size: 20, color: AppColors.inkMuted),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chỉ số kiểm định buồng tráng (Toàn mạng lưới)', style: AppTypography.cardTitle),
                      Text('Dữ liệu đồng bộ trực tiếp từ bảng Lab_Profile, Orders và Dispute_Complaint', style: AppTypography.caption),
                    ],
                  ),
                ),
                _buildChemBadge('Độ pH C-41: 10.05', AppColors.secondary),
                const SizedBox(width: 16),
                _buildChemBadge('Nhiệt độ bể: 37.8°C', AppColors.secondary),
                const SizedBox(width: 16),
                _buildChemBadge('Tải công suất: 82%', AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 950;
              if (!isDesktop) {
                return Column(
                  children: [
                    _buildPerformanceTable(filteredLabs),
                    const SizedBox(height: 24),
                    _buildUrgentQueue(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildPerformanceTable(filteredLabs)),
                  const SizedBox(width: 24),
                  Expanded(flex: 4, child: _buildUrgentQueue()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChemBadge(String text, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: AppTypography.dataMono),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String delta,
    required IconData icon,
    required Color iconColor,
    required String subtext,
    required String footnote,
    Color? valueColor,
    double fontSize = 32,
    bool isPositive = false,
    bool deltaIsText = false,
    bool isDangerBadge = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelCaps),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.metric.copyWith(color: valueColor ?? AppColors.ink, fontSize: fontSize),
              ),
              if (isDangerBadge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    delta,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger),
                  ),
                )
              else if (deltaIsText)
                Text(delta, style: AppTypography.caption)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward, size: 12, color: AppColors.secondary),
                      Text(delta, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ],
                  ),
                ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subtext, style: AppTypography.caption),
              Text(footnote, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTable(List<Map<String, dynamic>> filteredLabs) {
    return Container(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Hiệu suất Lab', style: AppTypography.sectionHeading),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${_labs.length} lab trong CSDL', style: AppTypography.caption),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Giám sát sản lượng bàn giao, chỉ số an toàn hoá chất và cam kết SLA', style: AppTypography.caption),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: ['Tất cả', 'Hà Nội', 'TP.HCM', 'Đà Nẵng'].map((r) {
                    final isSel = _selectedRegion == r;
                    return InkWell(
                      onTap: () => setState(() => _selectedRegion = r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.surfaceRaised : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                            color: isSel ? AppColors.ink : AppColors.inkMuted,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Table(
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                children: [
                  _th('TÊN PHÒNG LAB', TextAlign.left),
                  _th('KHU VỰC', TextAlign.left),
                  _th('ĐÁNH GIÁ / ĐƠN', TextAlign.right),
                  _th('TUÂN THỦ SLA', TextAlign.right),
                  _th('TRẠNG THÁI', TextAlign.center),
                ],
              ),
              ...filteredLabs.map((l) {
                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSunken,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text(l['initials'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(l['code'], style: AppTypography.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Text(l['region'], style: AppTypography.tableCell),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Text(l['output'].toString(), textAlign: TextAlign.right, style: AppTypography.dataMono),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Text(l['sla'], textAlign: TextAlign.right, style: AppTypography.dataMono.copyWith(color: l['statusColor'], fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: l['statusBg'],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            l['status'],
                            style: TextStyle(color: l['statusColor'], fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hiển thị ${filteredLabs.length} / ${_labs.length} đơn vị xử lý phim đối tác', style: AppTypography.caption),
              OutlinedButton.icon(
                onPressed: () => widget.onNavigateTab?.call(2),
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Xem tất cả'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _th(String title, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(title, textAlign: align, style: AppTypography.labelCaps),
    );
  }

  Widget _buildUrgentQueue() {
    return Container(
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
              Row(
                children: [
                  const Text('Hàng chờ xử lý', style: AppTypography.sectionHeading),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _urgentQueue.where((q) => q['isCompleted'] != true).isEmpty ? AppColors.successBg : AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_urgentQueue.where((q) => q['isCompleted'] != true).length} chờ duyệt',
                  style: TextStyle(
                    color: _urgentQueue.where((q) => q['isCompleted'] != true).isEmpty ? AppColors.secondary : AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Hồ sơ thẩm định, khiếu nại chất lượng và duyệt bài', style: AppTypography.caption),
          const SizedBox(height: 16),

          ..._urgentQueue.map((item) {
            final isDone = item['isCompleted'] == true;
            return Opacity(
              opacity: isDone ? 0.72 : 1.0,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: item['tagBg'],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['tag'],
                                style: TextStyle(color: item['tagColor'], fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(item['code'], style: AppTypography.dataMono),
                          ],
                        ),
                        Text(item['time'], style: AppTypography.caption),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: item['sender'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink)),
                          if (item['action'].isNotEmpty) TextSpan(text: ' ${item['action']} ', style: AppTypography.caption),
                          if (item['target'].isNotEmpty) TextSpan(text: item['target'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item['detail'], style: AppTypography.caption),
                    const SizedBox(height: 8),
                    if (!isDone)
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => widget.onNavigateTab?.call(item['tabIndex']),
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text('Xử lý'),
                        ),
                      )
                    else
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
                            SizedBox(width: 4),
                            Text(
                              'Đã hoàn thành',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
