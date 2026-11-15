import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/web_api_service.dart';

class LabServicesTab extends StatefulWidget {
  const LabServicesTab({super.key});

  @override
  State<LabServicesTab> createState() => _LabServicesTabState();
}

class _LabServicesTabState extends State<LabServicesTab> {
  String _labName = 'Film Lab';
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _processTable = [];
  List<Map<String, dynamic>> _priceAuditTrail = [];

  @override
  void initState() {
    super.initState();
    _loadLabServices();
  }

  Future<void> _loadLabServices() async {
    final res = await WebApiService().getLabServicesWithAudit();
    final rawPkgs = (res['packages'] as List?) ?? [];
    final rawProcesses = (res['process_table'] as List?) ?? [];
    final rawAudit = (res['audit_trail'] as List?) ?? [];
    final loadedLabName = (res['lab_name'] ?? '').toString();

    if (!mounted) return;
    setState(() {
      if (loadedLabName.isNotEmpty) {
        _labName = loadedLabName;
      }
      _packages = rawPkgs.map<Map<String, dynamic>>((p) {
        return {
          'package_id': (p['package_id'] ?? '').toString(),
          'name': (p['name'] ?? '').toString(),
          'film_format': (p['film_format'] ?? '135').toString(),
          'process_type': (p['process_type'] ?? 'C-41').toString(),
          'scan_resolution': (p['scan_resolution'] ?? '').toString(),
          'process': '${p['process_type'] ?? 'C-41'} · Khổ ${p['film_format'] ?? '135'} · ${p['scan_resolution'] ?? ''}',
          'price': p['price'] ?? 0,
          'estimated_hours': p['estimated_hours'] ?? 12,
          'sla': '${p['estimated_hours'] ?? 12} giờ',
          'status': (p['status'] ?? 'ACTIVE').toString(),
          'description': (p['description'] ?? '').toString(),
        };
      }).toList();

      _processTable = rawProcesses.map<Map<String, dynamic>>((pt) {
        return Map<String, dynamic>.from(pt as Map);
      }).toList();

      _priceAuditTrail = rawAudit.map<Map<String, dynamic>>((a) {
        return {
          'service': (a['entity'] ?? 'Service_Package').toString(),
          'oldPrice': (a['oldVal'] ?? '').toString(),
          'newPrice': (a['newVal'] ?? '').toString(),
          'date': (a['timestamp'] ?? '').toString(),
          'reason': 'Cập nhật trên bảng Audit_Log',
          'changedBy': (a['actor'] ?? 'Lab Owner').toString(),
        };
      }).toList();
    });
  }

  void _showAddServiceModal() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '70000');
    final slaCtrl = TextEditingController(text: '12');
    final resCtrl = TextEditingController(text: 'M (3000x2000px)');
    final descCtrl = TextEditingController();
    String selectedFormat = '135';
    String selectedProcess = 'C-41';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.surfaceRaised,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Thêm Gói Dịch Vụ Mới ($_labName)', style: AppTypography.cardTitle),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên gói dịch vụ')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedFormat,
                          decoration: const InputDecoration(labelText: 'Khổ phim'),
                          items: const [
                            DropdownMenuItem(value: '135', child: Text('135 (35mm)')),
                            DropdownMenuItem(value: '120', child: Text('120 (Medium)')),
                            DropdownMenuItem(value: '4x5', child: Text('4x5 (Large)')),
                          ],
                          onChanged: (v) => setModalState(() => selectedFormat = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedProcess,
                          decoration: const InputDecoration(labelText: 'Quy trình tráng'),
                          items: const [
                            DropdownMenuItem(value: 'C-41', child: Text('C-41 (Màu âm bản)')),
                            DropdownMenuItem(value: 'B&W', child: Text('B&W (Đen trắng)')),
                            DropdownMenuItem(value: 'ECN-2', child: Text('ECN-2 (Cine film)')),
                            DropdownMenuItem(value: 'E-6', child: Text('E-6 (Slide dương bản)')),
                          ],
                          onChanged: (v) => setModalState(() => selectedProcess = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: resCtrl, decoration: const InputDecoration(labelText: 'Độ phân giải Scan')),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá niêm yết (VNĐ)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: slaCtrl, decoration: const InputDecoration(labelText: 'SLA trả file (giờ)'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô tả quy trình')),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && priceCtrl.text.isNotEmpty) {
                  await WebApiService().createLabService({
                    'name': nameCtrl.text.trim(),
                    'film_format': selectedFormat,
                    'process_type': selectedProcess,
                    'scan_resolution': resCtrl.text.trim(),
                    'price': int.tryParse(priceCtrl.text.trim()) ?? 70000,
                    'estimated_hours': int.tryParse(slaCtrl.text.trim()) ?? 12,
                    'description': descCtrl.text.trim(),
                  });
                  if (!mounted || !ctx.mounted) return;
                  Navigator.pop(ctx);
                  _loadLabServices();
                }
              },
              child: const Text('Lưu gói dịch vụ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPackageModal(Map<String, dynamic> pkg) {
    final nameCtrl = TextEditingController(text: pkg['name'].toString());
    final priceCtrl = TextEditingController(text: pkg['price'].toString());
    final slaCtrl = TextEditingController(text: pkg['estimated_hours'].toString());
    final resCtrl = TextEditingController(text: pkg['scan_resolution'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Chỉnh sửa Gói Dịch Vụ & Giá', style: AppTypography.cardTitle),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên gói dịch vụ')),
              const SizedBox(height: 12),
              TextField(controller: resCtrl, decoration: const InputDecoration(labelText: 'Độ phân giải Scan')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá niêm yết (VNĐ)'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: slaCtrl, decoration: const InputDecoration(labelText: 'SLA cam kết (giờ)'))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final ok = await WebApiService().updateLabService(
                pkg['package_id'].toString(),
                {
                  'name': nameCtrl.text.trim(),
                  'scan_resolution': resCtrl.text.trim(),
                  'price': int.tryParse(priceCtrl.text.trim()) ?? pkg['price'],
                  'estimated_hours': int.tryParse(slaCtrl.text.trim()) ?? pkg['estimated_hours'],
                },
              );
              if (!mounted || !ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) {
                _loadLabServices();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật gói dịch vụ & đồng bộ lên App Khách hàng!')),
                );
              }
            },
            child: const Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _showEditProcessRowModal(int index) {
    final row = _processTable[index];
    final nameCtrl = TextEditingController(text: (row['process_name'] ?? '').toString());
    final chemCtrl = TextEditingController(text: (row['chemistry'] ?? '').toString());
    final tempCtrl = TextEditingController(text: (row['temperature'] ?? '').toString());
    final machineCtrl = TextEditingController(text: (row['dev_machine'] ?? '').toString());
    final scannerCtrl = TextEditingController(text: (row['scanner'] ?? '').toString());
    final slaCtrl = TextEditingController(text: (row['turnaround_hours'] ?? 12).toString());
    final policyCtrl = TextEditingController(text: (row['push_pull_policy'] ?? '').toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Cập nhật Bảng Tráng: ${row['process_code']}', style: AppTypography.cardTitle),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên quy trình tráng')),
                const SizedBox(height: 10),
                TextField(controller: chemCtrl, decoration: const InputDecoration(labelText: 'Hóa chất sử dụng')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: tempCtrl, decoration: const InputDecoration(labelText: 'Nhiệt độ chuẩn'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: slaCtrl, decoration: const InputDecoration(labelText: 'SLA (giờ)'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: machineCtrl, decoration: const InputDecoration(labelText: 'Thiết bị / Tank tráng')),
                const SizedBox(height: 10),
                TextField(controller: scannerCtrl, decoration: const InputDecoration(labelText: 'Máy Scan đi kèm')),
                const SizedBox(height: 10),
                TextField(controller: policyCtrl, decoration: const InputDecoration(labelText: 'Chính sách Push / Pull')),
              ],
            ),
          ),
        ),
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final updated = List<Map<String, dynamic>>.from(_processTable);
              updated[index] = {
                ...row,
                'process_name': nameCtrl.text.trim(),
                'chemistry': chemCtrl.text.trim(),
                'temperature': tempCtrl.text.trim(),
                'dev_machine': machineCtrl.text.trim(),
                'scanner': scannerCtrl.text.trim(),
                'turnaround_hours': int.tryParse(slaCtrl.text.trim()) ?? 12,
                'push_pull_policy': policyCtrl.text.trim(),
              };
              final ok = await WebApiService().updateLabProcessTable(updated);
              if (!mounted || !ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) {
                setState(() => _processTable = updated);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật Bảng Tráng & đồng bộ sang App Khách hàng!')),
                );
              }
            },
            child: const Text('Lưu bảng tráng'),
          ),
        ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WEB-LAB-05 // $_labName — DỊCH VỤ & BẢNG TRÁNG (SQL SERVER)', style: AppTypography.labelCaps),
                  const SizedBox(height: 4),
                  const Text('Cấu hình Gói Dịch Vụ, Bảng Tráng & Lịch Sử Đổi Giá', style: AppTypography.pageTitle),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddServiceModal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tạo gói dịch vụ mới (+)'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceSunken,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('DANH MỤC GÓI CỦA $_labName (${_packages.length})'.toUpperCase(), style: AppTypography.labelCaps),
                            const Text('GIÁ & TRẠNG THÁI', style: AppTypography.labelCaps),
                          ],
                        ),
                      ),
                      if (_packages.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('Tiệm Lab chưa có gói dịch vụ nào.', style: AppTypography.bodySmall),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _packages.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (ctx, idx) {
                            final pkg = _packages[idx];
                            final isActive = pkg['status'] == 'ACTIVE';
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(pkg['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Text('${pkg['process']} · Cam kết: ${pkg['sla']}', style: AppTypography.caption),
                                      ],
                                    ),
                                  ),
                                  Text('${pkg['price']} đ', style: AppTypography.dataMono.copyWith(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    tooltip: 'Sửa giá & cấu hình gói',
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.inkMuted),
                                    onPressed: () => _showEditPackageModal(pkg),
                                  ),
                                  Switch(
                                    value: isActive,
                                    activeThumbColor: AppColors.secondary,
                                    onChanged: (v) async {
                                      await WebApiService().updateLabService(
                                        pkg['package_id'],
                                        {'status': v ? 'ACTIVE' : 'INACTIVE'},
                                      );
                                      if (!mounted) return;
                                      setState(() => pkg['status'] = v ? 'ACTIVE' : 'INACTIVE');
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history_edu_outlined, size: 18, color: AppColors.primary),
                          SizedBox(width: 8),
                          Text('LỊCH SỬ ĐỔI GIÁ (AUDIT TRAIL)', style: AppTypography.cardTitle),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Mọi biến động giá được ghi vết minh bạch theo từng Lab', style: AppTypography.caption),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),

                      if (_priceAuditTrail.isEmpty)
                        const Text('Chưa có lịch sử điều chỉnh giá gần đây.', style: AppTypography.caption)
                      else
                        ..._priceAuditTrail.map((audit) {
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
                                    Text(audit['service'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(audit['date'], style: AppTypography.caption),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('${audit['oldPrice']} → ${audit['newPrice']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text('Bởi: ${audit['changedBy']}', style: const TextStyle(fontSize: 10, color: AppColors.outline)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Process Table (Bảng Tráng Kỹ Thuật riêng của Lab)
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSunken,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('BẢNG TRÁNG & QUY TRÌNH HÓA CHẤT RIÊNG ($_labName)'.toUpperCase(), style: AppTypography.labelCaps),
                      const Text('ĐỒNG BỘ TRỰC TIẾP TRÊN APP KHÁCH HÀNG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    ],
                  ),
                ),
                if (_processTable.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Chưa có dữ liệu bảng tráng.', style: AppTypography.caption),
                  )
                else
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(2.6),
                      2: FlexColumnWidth(2.5),
                      3: FlexColumnWidth(1.5),
                      4: FlexColumnWidth(2.4),
                      5: FlexColumnWidth(2.4),
                      6: FlexColumnWidth(0.9),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline))),
                        children: [
                          Padding(padding: EdgeInsets.all(12), child: Text('QUY TRÌNH', style: AppTypography.labelCaps)),
                          Padding(padding: EdgeInsets.all(12), child: Text('TÊN BẢNG TRÁNG', style: AppTypography.labelCaps)),
                          Padding(padding: EdgeInsets.all(12), child: Text('HÓA CHẤT & NHIỆT ĐỘ', style: AppTypography.labelCaps)),
                          Padding(padding: EdgeInsets.all(12), child: Text('SLA', style: AppTypography.labelCaps)),
                          Padding(padding: EdgeInsets.all(12), child: Text('MÁY TRÁNG & SCANNER', style: AppTypography.labelCaps)),
                          Padding(padding: EdgeInsets.all(12), child: Text('CHÍNH SÁCH PUSH/PULL', style: AppTypography.labelCaps)),
                          Padding(padding: EdgeInsets.all(12), child: Text('SỬA', style: AppTypography.labelCaps)),
                        ],
                      ),
                      ..._processTable.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final row = entry.value;
                        return TableRow(
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outline, width: 0.5))),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  (row['process_code'] ?? '').toString(),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text((row['process_name'] ?? '').toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('${row['chemistry'] ?? ''}\n(${row['temperature'] ?? ''})', style: AppTypography.caption),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('${row['turnaround_hours'] ?? 12} giờ', style: AppTypography.dataMono.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('${row['dev_machine'] ?? ''}\nScan: ${row['scanner'] ?? ''}', style: AppTypography.caption),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text((row['push_pull_policy'] ?? '').toString(), style: AppTypography.caption),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: IconButton(
                                tooltip: 'Sửa dòng bảng tráng',
                                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                                onPressed: () => _showEditProcessRowModal(idx),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
