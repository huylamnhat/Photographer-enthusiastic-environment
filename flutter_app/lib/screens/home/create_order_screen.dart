import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/lab_model.dart';
import 'checkout_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final LabModel lab;

  const CreateOrderScreen({super.key, required this.lab});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _filmNameController = TextEditingController(text: 'Kodak Portra 400');
  int _quantity = 1;
  String _selectedPackageName = 'Tráng & Scan 135 C-41 Chuẩn M';
  double _pricePerRoll = 50000;
  String _pushPullOption = 'Normal (Box speed)';
  String _cutOption = 'Cắt 6 frames/dải bỏ bao';
  String _shippingOption = 'PICKUP'; // PICKUP or DROP_AT_LAB

  @override
  Widget build(BuildContext context) {
    final total = _pricePerRoll * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt dịch vụ tráng & scan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab info chip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.lab.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Roll Film Name
            const Text('TÊN CUỘN PHIM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            TextField(
              controller: _filmNameController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Kodak Portra 400, Fuji C200, Ilford...',
                prefixIcon: Icon(Icons.camera_roll_outlined, color: AppColors.inkMuted),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SỐ LƯỢNG CUỘN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                    Text('Tính theo từng cuộn film', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),

            // Package select
            const Text('GÓI DỊCH VỤ XỬ LÝ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 8),
            _buildOptionTile('Tráng & Scan 135 C-41 Chuẩn M', '50.000đ', 50000),
            _buildOptionTile('Tráng & Scan 135 Cao Cấp L (TIFF)', '85.000đ', 85000),
            _buildOptionTile('Tráng & Scan B&W Đen Trắng Thủ Công', '65.000đ', 65000),
            _buildOptionTile('Tráng & Scan Medium Format 120', '80.000đ', 80000),

            const SizedBox(height: 16),

            // Push/Pull
            const Text('ĐỘ NHẠY SÁNG (PUSH / PULL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _pushPullOption,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'Normal (Box speed)', child: Text('Normal (Đúng ISO hộp)')),
                DropdownMenuItem(value: '+1 Stop (Push)', child: Text('+1 Stop (Push sáng)')),
                DropdownMenuItem(value: '+2 Stops (Push)', child: Text('+2 Stops (Push mạnh ban đêm)')),
                DropdownMenuItem(value: '-1 Stop (Pull)', child: Text('-1 Stop (Pull dịu hạt)')),
              ],
              onChanged: (v) => setState(() => _pushPullOption = v!),
            ),

            const SizedBox(height: 16),

            // Cut negatives
            const Text('XỬ LÝ DẢI FILM GỐC (NEGATIVES)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _cutOption,
              decoration: const InputDecoration(),
              items: const [
                DropdownMenuItem(value: 'Cắt 6 frames/dải bỏ bao', child: Text('Cắt 6 frames/dải bỏ bao lưu trữ')),
                DropdownMenuItem(value: 'Để nguyên cuộn không cắt', child: Text('Để nguyên cuộn không cắt')),
                DropdownMenuItem(value: 'Không lấy lại film gốc', child: Text('Lab tự tiêu hủy film gốc sau 30 ngày')),
              ],
              onChanged: (v) => setState(() => _cutOption = v!),
            ),

            const SizedBox(height: 16),

            // Shipping
            const Text('PHƯƠNG THỨC GỬI CUỘN FILM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Shipper lấy tận nơi'),
                    selected: _shippingOption == 'PICKUP',
                    onSelected: (s) => setState(() => _shippingOption = 'PICKUP'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Tự mang đến lab'),
                    selected: _shippingOption == 'DROP_AT_LAB',
                    onSelected: (s) => setState(() => _shippingOption = 'DROP_AT_LAB'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TỔNG TẠM TÍNH', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                Text(
                  '${total.toInt()}đ',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        lab: widget.lab,
                        filmName: _filmNameController.text,
                        quantity: _quantity,
                        packageName: _selectedPackageName,
                        totalPrice: total,
                        pushPull: _pushPullOption,
                        cutOption: _cutOption,
                        shippingMethod: _shippingOption,
                      ),
                    ),
                  );
                },
                child: const Text('Tiếp tục thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String title, String price, double value) {
    final isSelected = _selectedPackageName == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackageName = title;
          _pricePerRoll = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outline),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
            Text(price, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

