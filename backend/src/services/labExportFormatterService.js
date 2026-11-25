/**
 * Module tiện ích định dạng dữ liệu báo cáo ca làm việc & mã lô mẻ tráng (Batch)
 * chuẩn bị cho tính năng xuất phiếu đối soát trên cổng Web Lab (xử lý thuần trên bộ nhớ).
 */
function escapeCsvCell(value) {
  if (value === null || value === undefined) return '';
  const text = String(value).replace(/\r?\n/g, ' ').trim();
  if (/[",]/.test(text)) {
    return `"${text.replace(/"/g, '""')}"`;
  }
  return text;
}
function generateBatchCode(processType = 'C41', dateInput = new Date(), sequence = 1) {
  const cleanProcess = String(processType).toUpperCase().replace(/[^A-Z0-9]/g, '') || 'C41';
  const dateObj = dateInput instanceof Date ? dateInput : new Date(dateInput);
  const yyyy = dateObj.getFullYear();
  const mm = String(dateObj.getMonth() + 1).padStart(2, '0');
  const dd = String(dateObj.getDate()).padStart(2, '0');
  const seq = String(Math.max(1, Number(sequence) || 1)).padStart(2, '0');
  return `BATCH-${cleanProcess}-${yyyy}${mm}${dd}-${seq}`;
}
function formatShiftSummaryCsv(rows = []) {
  const headers = [
    'MaDon',
    'KhachHang',
    'QuyTrinhTrang',
    'SoCuon',
    'DoPhanGiaiScan',
    'TrangThai',
    'ThanhTienVND',
  ];
  const lines = [headers.join(',')];
  for (const item of rows) {
    const line = [
      escapeCsvCell(item.orderCode),
      escapeCsvCell(item.customerName),
      escapeCsvCell(item.processType || 'C-41'),
      escapeCsvCell(item.rollCount || 1),
      escapeCsvCell(item.scanResolution || 'Tiêu chuẩn'),
      escapeCsvCell(item.statusLabel || 'Chờ xử lý'),
      escapeCsvCell(item.totalAmount || 0),
    ].join(',');
    lines.push(line);
  }
  // Thêm UTF-8 BOM để mở trực tiếp trên Excel giữ nguyên tiếng Việt
  return `\uFEFF${lines.join('\n')}`;
}
function summarizeRollsByProcess(rows = []) {
  const summary = { 'C-41': 0, 'ECN-2': 0, 'B&W': 0, OTHER: 0, totalRolls: 0 };
  for (const item of rows) {
    const rolls = Math.max(0, Number(item.rollCount) || 0);
    const proc = String(item.processType || '').toUpperCase();
    summary.totalRolls += rolls;
    if (proc.includes('C-41') || proc.includes('C41')) {
      summary['C-41'] += rolls;
    } else if (proc.includes('ECN')) {
      summary['ECN-2'] += rolls;
    } else if (proc.includes('BW') || proc.includes('B&W')) {
      summary['B&W'] += rolls;
    } else {
      summary.OTHER += rolls;
    }
  }
  return summary;
}
module.exports = {
  escapeCsvCell,
  generateBatchCode,
  formatShiftSummaryCsv,
  summarizeRollsByProcess,
};
