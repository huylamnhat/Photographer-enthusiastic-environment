const mockDb = require('../data/mockDb');

exports.getSlaReports = (req, res) => {
  const { period } = req.query;

  return res.status(200).json({
    success: true,
    data: {
      period: period || mockDb.slaAnalytics.period,
      metrics: mockDb.slaAnalytics.metrics,
      dailyStats: mockDb.slaAnalytics.dailyStats,
      shift_summary: {
        active_shifts: 2,
        today_rolls: mockDb.telemetry.today_total_rolls,
        c41_stability: '99.9%',
        noritsu_runtime_hours: 7.2
      }
    }
  });
};

exports.getOrderHistory = (req, res) => {
  const { month } = req.query;

  return res.status(200).json({
    success: true,
    data: {
      total: mockDb.orders.length,
      history: mockDb.orders
    }
  });
};

