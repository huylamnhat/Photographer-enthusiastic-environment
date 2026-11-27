class LabBatchExportHelper {
  const LabBatchExportHelper._();

  /// Định dạng số tiền sang chuỗi VNĐ dễ đọc cho bảng tổng kết ca trên Web Lab.
  static String formatVnd(num amount) {
    final rounded = amount.round();
    final isNegative = rounded < 0;
    final digits = rounded.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return '${isNegative ? '-' : ''}${buffer.toString()} đ';
  }

  /// Tính tỷ lệ phần trăm sử dụng bể hóa chất (0.0 -> 1.0).
  static double computeTankUsageProgress({
    required int rolls135,
    int rolls120 = 0,
    int maxCapacityRolls = 40,
  }) {
    if (maxCapacityRolls <= 0) return 0;
    final equivalent = (rolls135 < 0 ? 0 : rolls135) +
        ((rolls120 < 0 ? 0 : rolls120) * 1.35);
    final ratio = equivalent / maxCapacityRolls;
    if (ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  /// Trả về nhãn cảnh báo tình trạng hóa chất hiển thị cho kỹ thuật viên Lab.
  static String resolveTankStatusLabel(double progress) {
    if (progress >= 0.95) return 'Cần thay hóa chất mới';
    if (progress >= 0.75) return 'Sắp đầy tải — Cần châm bù thuốc';
    return 'Hóa chất ổn định';
  }

  /// Chuẩn bị nội dung văn bản CSV trên bộ nhớ từ danh sách dòng dữ liệu truyền vào.
  static String buildCsvPreviewText({
    required List<String> columns,
    required List<List<String>> rows,
  }) {
    String escapeCell(String raw) {
      final cleaned = raw.replaceAll('\r\n', ' ').replaceAll('\n', ' ').trim();
      if (cleaned.contains(',') || cleaned.contains('"')) {
        return '"${cleaned.replaceAll('"', '""')}"';
      }
      return cleaned;
    }

    final lines = <String>[
      columns.map(escapeCell).join(','),
      ...rows.map((row) => row.map(escapeCell).join(',')),
    ];
    return lines.join('\n');
  }
}
