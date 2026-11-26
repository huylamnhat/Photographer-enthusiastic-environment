/**
 * Module đánh giá mức độ ưu tiên xử lý khiếu nại đơn hàng (Dispute Triage)
 * và kiểm tra độ hoàn thiện hồ sơ đăng ký Film Lab mới trên cổng Admin.
 */

const HIGH_RISK_TERMS = [
  'hong phim',
  'hỏng phim',
  'rach phim',
  'mất cuộn phim',
  'mat cuon phim',
  'lo sang',
  'lộ sáng',
  'chua nhan tien',
  'trừ tiền hai lần',
];

function evaluateDisputePriority({
  reasonText = '',
  orderValueVnd = 0,
  hoursPending = 0,
} = {}) {
  const normalized = String(reasonText).toLowerCase();
  const matchedKeywords = HIGH_RISK_TERMS.filter((term) => normalized.includes(term));

  let score = 10;
  if (matchedKeywords.length > 0) score += 50;
  if (Number(orderValueVnd) >= 500000) score += 20;
  if (Number(hoursPending) >= 48) score += 25;

  let severity = 'NORMAL';
  let suggestedAction = 'Phản hồi và đối chiếu lịch sử trạng thái đơn trong 24 giờ.';

  if (score >= 70) {
    severity = 'CRITICAL';
    suggestedAction = 'Ưu tiên liên hệ trực tiếp Film Lab và khách hàng để xác minh tình trạng cuộn phim gốc.';
  } else if (score >= 40) {
    severity = 'HIGH';
    suggestedAction = 'Yêu cầu Film Lab cung cấp ảnh biên nhận / nhật ký mẻ tráng trong 12 giờ.';
  }

  return {
    score,
    severity,
    matchedKeywords,
    suggestedAction,
  };
}

function scoreLabOnboardingChecklist(profile = {}) {
  const missingFields = [];

  if (!profile.labName || String(profile.labName).trim().length < 3) {
    missingFields.push('Tên thương hiệu Film Lab');
  }
  if (!profile.address || String(profile.address).trim().length < 10) {
    missingFields.push('Địa chỉ nhận phim chi tiết');
  }
  if (!profile.phone || !/^0\d{9,10}$/.test(String(profile.phone).trim())) {
    missingFields.push('Số điện thoại liên hệ hợp lệ');
  }
  if (!Array.isArray(profile.supportedProcesses) || profile.supportedProcesses.length === 0) {
    missingFields.push('Danh sách quy trình tráng hỗ trợ (C-41 / ECN-2 / B&W)');
  }

  const totalChecks = 4;
  const passedChecks = totalChecks - missingFields.length;

  return {
    readinessPercent: Math.round((passedChecks / totalChecks) * 100),
    isReadyForApproval: missingFields.length === 0,
    missingFields,
  };
}

module.exports = {
  evaluateDisputePriority,
  scoreLabOnboardingChecklist,
};
