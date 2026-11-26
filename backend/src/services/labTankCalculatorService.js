/**
 * Module tính toán công suất bể hóa chất (Chemical Tank) và ước tính thời gian
 * hoàn thành hàng đợi tráng/scan dành cho mở rộng vận hành Web Lab.
 */

const DEFAULT_TANK_LIMITS = {
  'C-41': { maxEquivalentRolls: 40, devTempCelsius: 37.8 },
  'ECN-2': { maxEquivalentRolls: 30, devTempCelsius: 41.1 },
  'B&W': { maxEquivalentRolls: 25, devTempCelsius: 20.0 },
};

function calculateChemicalTankHealth({
  processType = 'C-41',
  rolls135Processed = 0,
  rolls120Processed = 0,
  customMaxRolls = null,
} = {}) {
  const config = DEFAULT_TANK_LIMITS[processType] || DEFAULT_TANK_LIMITS['C-41'];
  const maxRolls = customMaxRolls && customMaxRolls > 0 ? customMaxRolls : config.maxEquivalentRolls;

  // Quy đổi: 1 cuộn 120 Medium Format tiêu hao hóa chất tương đương ~1.35 cuộn 135mm
  const equivalentUsed =
    Math.max(0, Number(rolls135Processed) || 0) +
    Math.max(0, Number(rolls120Processed) || 0) * 1.35;

  const usageRatio = Math.min(1, equivalentUsed / maxRolls);
  const remainingRolls = Math.max(0, Math.floor(maxRolls - equivalentUsed));

  let status = 'GOOD';
  let recommendation = 'Hóa chất ổn định, có thể tiếp tục chạy mẻ mới.';

  if (usageRatio >= 0.95) {
    status = 'REPLACE_REQUIRED';
    recommendation = 'Đã chạm ngưỡng bão hòa, cần pha mới hóa chất trước mẻ tráng tiếp theo.';
  } else if (usageRatio >= 0.75) {
    status = 'REPLENISH_SOON';
    recommendation = 'Cần châm bù thuốc hiện (Replenisher) và kiểm tra nhiệt độ bể tráng.';
  }

  return {
    processType,
    targetTempCelsius: config.devTempCelsius,
    equivalentUsed: Number(equivalentUsed.toFixed(1)),
    maxEquivalentRolls: maxRolls,
    usagePercent: Math.round(usageRatio * 100),
    remainingRolls,
    status,
    recommendation,
  };
}

function estimateLabQueueTurnaround({
  pendingRolls = 0,
  activeScanners = 1,
  minutesPerRoll = 12,
} = {}) {
  const scanners = Math.max(1, Number(activeScanners) || 1);
  const rolls = Math.max(0, Number(pendingRolls) || 0);
  const totalMinutes = Math.ceil((rolls * minutesPerRoll) / scanners);
  const estimatedHours = Number((totalMinutes / 60).toFixed(1));

  return {
    pendingRolls: rolls,
    activeScanners: scanners,
    estimatedMinutes: totalMinutes,
    estimatedHours,
    loadLevel: estimatedHours > 6 ? 'HIGH' : estimatedHours > 2.5 ? 'MODERATE' : 'LOW',
  };
}

module.exports = {
  calculateChemicalTankHealth,
  estimateLabQueueTurnaround,
};
