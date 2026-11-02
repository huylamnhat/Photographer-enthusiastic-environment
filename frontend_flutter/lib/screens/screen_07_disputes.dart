import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  List<DisputeModel> disputes = [];
  DisputeModel? selectedDispute;
  bool isLoading = true;

  final messageCtrl = TextEditingController();
  final offerCtrl = TextEditingController(text: '200000');

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() => isLoading = true);
    final list = await ApiService.getDisputes();
    setState(() {
      disputes = list;
      if (list.isNotEmpty) selectedDispute = list.first;
      isLoading = false;
    });
  }

  void _sendMessage() async {
    if (selectedDispute == null || messageCtrl.text.trim().isEmpty) return;

    final content = messageCtrl.text.trim();
    final offer = double.tryParse(offerCtrl.text);

    final success = await ApiService.sendDisputeMessage(selectedDispute!.disputeId, content, offerAmount: offer);
    if (success) {
      setState(() {
        selectedDispute!.messages.add(
          DisputeMessageModel(sender: 'LAB', name: 'Lê Hoài Nam (KTV Trưởng)', time: 'Vừa xong', content: content),
        );
        if (offer != null) selectedDispute!.compensationOffered = offer;
        messageCtrl.clear();
      });
    }
  }

  void _settle() async {
    if (selectedDispute == null) return;

    final amount = double.tryParse(offerCtrl.text) ?? selectedDispute!.compensationOffered;
    final success = await ApiService.settleDispute(selectedDispute!.disputeId, 'REFUND_AND_RESCAN', amount);

    if (success) {
      setState(() {
        selectedDispute!.status = 'SETTLED';
        selectedDispute!.messages.add(
          DisputeMessageModel(
            sender: 'SYSTEM',
            name: 'Hệ Thống Phán Quyết',
            time: 'Vừa xong',
            content: 'Hai bên đã thống nhất phương án hòa giải. Đơn khiếu nại được đóng thành công.',
          ),
        );
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: LabColors.secondary),
                SizedBox(width: 8),
                Text('Đã Giải Quyết Xong Khiếu Nại'),
              ],
            ),
            content: Text(
              'Số tiền đền bù: ${amount.toStringAsFixed(0)} đ đã được giải ngân tự động từ Quỹ đền bù tự quản của Lab cho khách hàng.',
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: LabColors.secondary, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final d = selectedDispute;

    return Scaffold(
      backgroundColor: LabColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Telemetry Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xử lý Khiếu nại & Thương lượng Đền bù',
                      style: TextStyle(fontFamily: 'IBM Plex Sans', fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: LabColors.errorContainer, borderRadius: BorderRadius.circular(9999)),
                      child: const Row(
                        children: [
                          Icon(Icons.hourglass_top, color: LabColors.error, size: 16),
                          SizedBox(width: 6),
                          Text('02 CA ĐANG THƯƠNG LƯỢNG', style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, fontWeight: FontWeight.bold, color: LabColors.onErrorContainer)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: LabColors.secondaryContainer, borderRadius: BorderRadius.circular(9999)),
                      child: const Text('TỶ LỆ TỰ THƯƠNG LƯỢNG: 92%', style: TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 11, fontWeight: FontWeight.bold, color: LabColors.onSecondaryContainer)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stat Cards Row
            Row(
              children: [
                _buildStat('Tổng khiếu nại tháng', '14 ca', '-30% MoM', LabColors.secondary),
                _buildStat('Quỹ đền bù tự quản', '4.850.000 đ', 'Hạn mức 10M', LabColors.primary),
                _buildStat('SLA phản hồi TB', '3.4 giờ', 'Chuẩn < 6h', LabColors.secondary),
                _buildStat('Admin can thiệp', '01 ca', 'Kiểm toán tự động', LabColors.outline),
              ],
            ),
            const SizedBox(height: 24),

            // Split View: Ticket list & Live chat
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket list (Left)
                Expanded(
                  flex: 2,
                  child: Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: disputes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = disputes[index];
                        final isSelected = item.disputeId == selectedDispute?.disputeId;

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: LabColors.primaryContainer.withOpacity(0.1),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(item.customerAvatar),
                            radius: 18,
                          ),
                          title: Text(item.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${item.category}\n${item.filmType} • Đơn #${item.orderId}'),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.status == 'SETTLED' ? LabColors.secondaryContainer : LabColors.errorContainer,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              item.status == 'SETTLED' ? 'ĐÃ GIẢI QUYẾT' : 'THƯƠNG LƯỢNG',
                              style: TextStyle(
                                fontFamily: 'IBM Plex Mono',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: item.status == 'SETTLED' ? LabColors.onSecondaryContainer : LabColors.onErrorContainer,
                              ),
                            ),
                          ),
                          onTap: () => setState(() => selectedDispute = item),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Live negotiation chat (Right)
                if (d != null)
                  Expanded(
                    flex: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(backgroundImage: NetworkImage(d.customerAvatar), radius: 18),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(d.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text('Yêu cầu bồi thường: ${d.claimAmount.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 12, color: LabColors.error)),
                                      ],
                                    ),
                                  ],
                                ),
                                if (d.status != 'SETTLED')
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: LabColors.secondary, foregroundColor: Colors.white),
                                    icon: const Icon(Icons.handshake, size: 16),
                                    label: const Text('Thống nhất bồi thường'),
                                    onPressed: _settle,
                                  ),
                              ],
                            ),
                            const Divider(height: 24),

                            // Chat Messages Log
                            Container(
                              height: 320,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: LabColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ListView.separated(
                                itemCount: d.messages.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final msg = d.messages[index];
                                  final isLab = msg.sender == 'LAB';
                                  final isSys = msg.sender == 'SYSTEM';

                                  if (isSys) {
                                    return Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(color: LabColors.secondaryContainer, borderRadius: BorderRadius.circular(9999)),
                                        child: Text(msg.content, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: LabColors.onSecondaryContainer)),
                                      ),
                                    );
                                  }

                                  return Align(
                                    alignment: isLab ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 400),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isLab ? LabColors.primaryContainer : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(msg.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isLab ? Colors.white : LabColors.onSurface)),
                                              const SizedBox(width: 8),
                                              Text(msg.time, style: TextStyle(fontSize: 9, color: isLab ? Colors.white70 : LabColors.outline)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(msg.content, style: TextStyle(fontSize: 12, color: isLab ? Colors.white : LabColors.onSurface)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Message Composer
                            if (d.status != 'SETTLED') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: messageCtrl,
                                      decoration: const InputDecoration(
                                        hintText: 'Nhập nội dung phản hồi, phương án khắc phục hoặc đề xuất đền bù...',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 120,
                                    child: TextField(
                                      controller: offerCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Đề xuất (đ)', border: OutlineInputBorder()),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filled(
                                    style: IconButton.styleFrom(backgroundColor: LabColors.primaryContainer),
                                    icon: const Icon(Icons.send, color: Colors.white),
                                    onPressed: _sendMessage,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, String sub, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LabColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LabColors.outlineVariant, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'IBM Plex Mono', fontSize: 10, color: LabColors.outline)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

