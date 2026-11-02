const mockDb = require('../data/mockDb');

exports.getServices = (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      services: mockDb.services,
      total_count: mockDb.services.length,
      active_count: mockDb.services.filter(s => s.status === 'ACTIVE').length,
      avg_sla_hours: 28.5
    }
  });
};

exports.createService = (req, res) => {
  const {
    name,
    film_format,
    process_type,
    scanner,
    base_price,
    push_pull_fee,
    high_res_fee,
    sla_hours,
    output_format,
    description
  } = req.body;

  if (!name || !base_price || !process_type) {
    return res.status(400).json({ success: false, message: 'Vui lòng cung cấp tên gói, giá cơ bản và loại quy trình tráng.' });
  }

  const newServiceId = `SVC-${process_type.replace(/[^A-Z0-9]/gi, '')}-${Date.now().toString().slice(-4)}`;

  const newService = {
    service_id: newServiceId,
    name,
    film_format: film_format || '135 (35mm)',
    process_type,
    scanner: scanner || 'Noritsu HS-1800',
    base_price: Number(base_price),
    push_pull_fee: Number(push_pull_fee) || 25000,
    high_res_fee: Number(high_res_fee) || 25000,
    sla_hours: Number(sla_hours) || 48,
    status: 'ACTIVE',
    output_format: output_format || 'JPEG Hi-Res',
    description: description || 'Gói dịch vụ xử lý phim analog chuyên nghiệp',
    created_at: new Date().toISOString()
  };

  mockDb.services.unshift(newService);

  // Log to price history audit log
  mockDb.priceHistory.unshift({
    history_id: `PRC-LOG-${Date.now().toString().slice(-4)}`,
    service_name: newService.name,
    old_price: 0,
    new_price: newService.base_price,
    effective_date: new Date().toISOString().split('T')[0],
    changed_by: 'Nguyễn Văn An Khang (Chủ Lab)',
    reason: 'Khởi tạo gói dịch vụ mới niêm yết'
  });

  return res.status(201).json({
    success: true,
    message: `Đã thêm gói dịch vụ mới: ${newService.name}`,
    data: newService
  });
};

exports.updateService = (req, res) => {
  const { id } = req.params;
  const { name, base_price, push_pull_fee, high_res_fee, sla_hours, description, reason } = req.body;

  const service = mockDb.services.find(s => s.service_id === id);
  if (!service) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy gói dịch vụ.' });
  }

  const oldPrice = service.base_price;
  if (base_price !== undefined && Number(base_price) !== oldPrice) {
    service.base_price = Number(base_price);
    // Add audit log
    mockDb.priceHistory.unshift({
      history_id: `PRC-LOG-${Date.now().toString().slice(-4)}`,
      service_name: service.name,
      old_price: oldPrice,
      new_price: service.base_price,
      effective_date: new Date().toISOString().split('T')[0],
      changed_by: 'Nguyễn Văn An Khang (Chủ Lab)',
      reason: reason || 'Điều chỉnh bảng giá định kỳ theo chi phí hóa chất'
    });
  }

  if (name) service.name = name;
  if (push_pull_fee !== undefined) service.push_pull_fee = Number(push_pull_fee);
  if (high_res_fee !== undefined) service.high_res_fee = Number(high_res_fee);
  if (sla_hours !== undefined) service.sla_hours = Number(sla_hours);
  if (description) service.description = description;

  return res.status(200).json({
    success: true,
    message: `Đã cập nhật dịch vụ: ${service.name}`,
    data: service
  });
};

exports.toggleServiceStatus = (req, res) => {
  const { id } = req.params;
  const service = mockDb.services.find(s => s.service_id === id);
  if (!service) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy dịch vụ.' });
  }

  // Week 1 rule: Only PAUSED or ACTIVE, never delete while active references exist
  service.status = service.status === 'ACTIVE' ? 'PAUSED' : 'ACTIVE';

  return res.status(200).json({
    success: true,
    message: `Dịch vụ ${service.name} hiện đang ở trạng thái: ${service.status}`,
    data: service
  });
};

exports.getPriceHistory = (req, res) => {
  return res.status(200).json({
    success: true,
    data: mockDb.priceHistory
  });
};

