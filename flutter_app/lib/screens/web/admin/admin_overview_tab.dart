import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AdminOverviewTab extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const AdminOverviewTab({super.key, this.onNavigateTab});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  String _selectedRegion = 'Tất cả';

  final List<Map<String, dynamic>> _labs = [
    {
      'initials': 'LL',
      'name': 'LLab Darkroom & Scan',
      'code': '#LAB-HN-001 · Noritsu HS-1800',
      'region': 'Hà Nội (Ba Đình)',
      'output': 184,
      'sla': '98.6%',
      'status': 'Ổn định',
      'statusColor': AppColors.secondary,
      'statusBg': AppColors.successBg,
    },
    {
      'initials': 'CL',
      'name': 'Cropped Lab Sài Gòn',
      'code': '#LAB-SG-014 · Fuji Frontier SP-3000',
      'region': 'TP.HCM (Quận 1)',
      'output': 210,
      'sla': '99.1%',
      'status': 'Ổn định',
      'statusColor': AppColors.secondary,
      'statusBg': AppColors.successBg,
    },
    {
      'initials': 'NA',
      'name': 'Nadir Analog Atelier',
      'code': '#LAB-HN-028 · Jobo ATL-1500',
      'region': 'Hà Nội (Hoàn Kiếm)',
      'output': 132,
      'sla': '87.2%',
      'status': 'Chậm SLA',
      'statusColor': AppColors.danger,
      'statusBg': AppColors.dangerBg,
    },
    {
      'initials': 'SH',
      'name': 'Sông Hàn Film Studio',
      'code': '#LAB-DN-003 · Noritsu HS-1800',
      'region': 'Đà Nẵng (Hải Châu)',
      'output': 96,
      'sla': '95.8%',
      'status': 'Ổn định',
      'statusColor': AppColors.secondary,
      'statusBg': AppColors.successBg,
    },
    {
      'initials': 'TH',
      'name': 'Tây Hồ Analog Master',
      'code': '#LAB-HN-019 · Durst Epsilon',
      'region': 'Hà Nội (Tây Hồ)',
      'output': 115,
      'sla': '97.4%',
      'status': 'Ổn định',
      'statusColor': AppColors.secondary,
      'statusBg': AppColors.successBg,
    },
    {
      'initials': 'CL',
      'name': 'Chợ Lớn Film Lab',
      'code': '#LAB-SG-008 · Pakon F134+',
      'region': 'TP.HCM (Quận 5)',
      'output': 168,
      'sla': '94.8%',
      'status': 'Theo dõi',
      'statusColor': AppColors.warning,
      'statusBg': AppColors.warningBg,
    },
  ];

  final List<Map<String, dynamic>> _urgentQueue = [
    {
      'tag': 'Khẩn',
      'tagColor': AppColors.danger,
      'tagBg': AppColors.dangerBg,
      'code': '#DISP-2481',
      'time': '14 phút trước',
      'sender': 'Lê Hoàng Nam',
      'action': 'khiếu nại',
      'target': 'Nadir Atelier',
      'detail': 'Lỗi tráng trầy xước cuộn Kodak Portra 400 120',
      'tabIndex': 6, // Navigate to Disputes
    },
    {
      'tag': 'KYC Lab',
      'tagColor': AppColors.secondary,
      'tagBg': AppColors.successBg,
      'code': '#KYC-LB-0194',
      'time': '38 phút trước',
      'sender': 'RetroTone Darkroom',
      'action': 'nộp hồ sơ',
      'target': '',
      'detail': 'Giấy phép ĐKKD & Chứng chỉ xử lý chất thải C-41',
      'tabIndex': 2, // Navigate to Lab approval
    },
    {
      'tag': 'Tin chợ',
      'tagColor': AppColors.inkMuted,
      'tagBg': AppColors.surfaceSunken,
      'code': '#MKT-POST-902',
      'time': '1 giờ trước',
      'sender': 'Leica M6 Classic 0.72x',
      'action': '',
      'target': '(Serial: 2491028)',
      'detail': 'Kiểm định số seri ống kính và xác thực chủ sở hữu',
      'tabIndex': 3, // Navigate to Marketplace
    },
    {
      'tag': 'Khẩn',
      'tagColor': AppColors.danger,
      'tagBg': AppColors.dangerBg,
      'code': '#DISP-2483',
      'time': '2 giờ trước',
      'sender': 'Đỗ Thùy Trang',
      'action': 'khiếu nại',
      'target': 'Chợ Lớn Film Lab',
      'detail': 'Quá hạn trả tệp quét 48 giờ không thông báo',
      'tabIndex': 6, // Navigate to Disputes
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Bar
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
                        'TRẠM ĐIỀU HÀNH TRUNG TÂM / ADM-02',
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSunken,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: AppColors.inkMuted),
                    SizedBox(width: 6),
                    Text('Cập nhật trực tiếp: ', style: AppTypography.caption),
                    Text('2026-10-27 07:06:32 ICT', style: AppTypography.dataMono),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row of 4 Primary KPI Ledger Cards
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
                    title: 'TỔNG NGƯỜI DÙNG',
                    value: '14,820',
                    fontSize: 46, // <-- CỠ SỐ Ô 1 (Thay đổi số 32 ở đây)
                    delta: '+8%',
                    icon: Icons.group_outlined,
                    iconColor: AppColors.inkMuted,
                    subtext: '+124 tài khoản mới hôm nay',
                    footnote: '30 ngày qua',
                    isPositive: true,
                  ),
                  _buildKpiCard(
                    title: 'ĐANG TRÁNG & QUÉT',
                    value: '1,428',
                    fontSize: 46, // <-- CỠ SỐ Ô 2 (Thay đổi số 32 ở đây)
                    delta: 'cuộn phim',
                    icon: Icons.motion_photos_on_outlined,
                    iconColor: AppColors.primary,
                    subtext: 'C-41: 912 | B&W: 340 | E-6: 176',
                    footnote: 'Đúng tiến độ',
                    isPositive: true,
                    deltaIsText: true,
                  ),
                  _buildKpiCard(
                    title: 'TỶ LỆ TUÂN THỦ SLA',
                    value: '96.4%',
                    fontSize: 46, // <-- CỠ SỐ Ô 3 (Thay đổi số 32 ở đây)
                    delta: '+1.2%',
                    icon: Icons.verified_outlined,
                    iconColor: AppColors.secondary,
                    subtext: 'Ngưỡng cảnh báo: <92.0%',
                    footnote: 'Mục tiêu: 95%',
                    isPositive: true,
                  ),
                  _buildKpiCard(
                    title: 'CẦN XỬ LÝ GẤP',
                    value: '23',
                    fontSize: 46, // <-- CỠ SỐ Ô 4 (Thay đổi số 32 ở đây)
                    delta: 'CẦN DUYỆT',
                    icon: Icons.error_outline,
                    iconColor: AppColors.danger,
                    valueColor: AppColors.danger,
                    subtext: '2 tranh chấp khẩn cấp',
                    footnote: 'Hàng chờ ưu tiên',
                    isDangerBadge: true,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Operational Ledger Visual Strip: Chemical & Workload Overview
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
                      Text('Kiểm tra đợt cuối: 06:00 ICT · 14 máy Fuji Frontier / Noritsu HS-1800 trực tuyến', style: AppTypography.caption),
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

          // Main 2-Column Split: Performance (8 cols) vs Urgent Queue (4 cols)
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 950;
              if (!isDesktop) {
                return Column(
                  children: [
                    _buildPerformanceTable(),
                    const SizedBox(height: 24),
                    _buildUrgentQueue(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildPerformanceTable()),
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

  Widget _buildPerformanceTable() {
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
                        child: const Text('185 lab hoạt động', style: AppTypography.caption),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('Giám sát sản lượng bàn giao, chỉ số an toàn hoá chất và cam kết SLA', style: AppTypography.caption),
                ],
              ),
              // Filter tabs
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

          // Table
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
                  _th('SẢN LƯỢNG (CUỘN)', TextAlign.right),
                  _th('TUÂN THỦ SLA', TextAlign.right),
                  _th('TRẠNG THÁI', TextAlign.center),
                ],
              ),
              ..._labs.map((l) {
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
              const Text('Hiển thị 6 / 185 đơn vị xử lý phim đối tác', style: AppTypography.caption),
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
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('23 chờ duyệt', style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Hồ sơ thẩm định, khiếu nại chất lượng và duyệt bài', style: AppTypography.caption),
          const SizedBox(height: 16),

          // Queue Items
          ..._urgentQueue.map((item) {
            return Container(
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
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tồn đọng ưu tiên: 04 / 23 vụ', style: AppTypography.caption),
              TextButton(
                onPressed: () => widget.onNavigateTab?.call(6),
                child: const Text('Xem toàn bộ →'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
