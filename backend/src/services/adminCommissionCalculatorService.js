/**
 * Module tính toán phí duy trì nền tảng (Platform Commission) và đối soát
 * khoản thanh toán trả về cho các đối tác Film Lab dành cho mở rộng Web Admin.
 */

const COMMISSION_TIERS = {
  STANDARD: { rate: 0.08, label: 'Đối tác tiêu chuẩn (8%)' },
  VERIFIED_PARTNER: { rate: 0.06, label: 'Đối tác xác thực (6%)' },
  PREMIUM_LAB: { rate: 0.045, label: 'Đối tác chiến lược (4.5%)' },
};

function calculateOrderSettlement({
  grossOrderAmount = 0,
  shippingFee = 0,
  tierKey = 'STANDARD',
  gatewayFeeRate = 0.015,
} = {}) {
  const gross = Math.max(0, Number(grossOrderAmount) || 0);
  const ship = Math.max(0, Number(shippingFee) || 0);
  const serviceBase = Math.max(0, gross - ship);

  const tier = COMMISSION_TIERS[tierKey] || COMMISSION_TIERS.STANDARD;
  const platformFee = Math.round(serviceBase * tier.rate);
  const gatewayFee = Math.round(gross * Math.max(0, Number(gatewayFeeRate) || 0));
  const netLabPayout = Math.max(0, serviceBase - platformFee - gatewayFee);

  return {
    tierLabel: tier.label,
    commissionRate: tier.rate,
    grossOrderAmount: gross,
    serviceBaseAmount: serviceBase,
    shippingFee: ship,
    platformFee,
    gatewayFee,
    netLabPayout,
  };
}

function aggregateLabSettlementBatch(orders = [], tierKey = 'STANDARD') {
  let totalGross = 0;
  let totalPlatformFee = 0;
  let totalGatewayFee = 0;
  let totalNetPayout = 0;

  for (const item of orders) {
    const breakdown = calculateOrderSettlement({
      grossOrderAmount: item.totalAmount,
      shippingFee: item.shippingFee,
      tierKey,
    });
    totalGross += breakdown.grossOrderAmount;
    totalPlatformFee += breakdown.platformFee;
    totalGatewayFee += breakdown.gatewayFee;
    totalNetPayout += breakdown.netLabPayout;
  }

  return {
    orderCount: orders.length,
    totalGross,
    totalPlatformFee,
    totalGatewayFee,
    totalNetPayout,
  };
}

module.exports = {
  COMMISSION_TIERS,
  calculateOrderSettlement,
  aggregateLabSettlementBatch,
};
