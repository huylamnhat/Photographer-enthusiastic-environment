const mockDb = require('../data/mockDb');

exports.getDisputes = (req, res) => {
  return res.status(200).json({
    success: true,
    data: {
      disputes: mockDb.disputes,
      count_negotiating: mockDb.disputes.filter(d => d.status === 'NEGOTIATING').length,
      success_rate: 92.0
    }
  });
};

exports.getDisputeDetail = (req, res) => {
  const { id } = req.params;
  const dispute = mockDb.disputes.find(d => d.dispute_id === id);
  if (!dispute) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy khiếu nại.' });
  }

  return res.status(200).json({
    success: true,
    data: dispute
  });
};

exports.sendDisputeMessage = (req, res) => {
  const { id } = req.params;
  const { content, offer_amount } = req.body;

  const dispute = mockDb.disputes.find(d => d.dispute_id === id);
  if (!dispute) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy khiếu nại.' });
  }

  if (!content) {
    return res.status(400).json({ success: false, message: 'Nội dung tin nhắn không được để trống.' });
  }

  const newMsg = {
    sender: 'LAB',
    name: 'Lê Hoài Nam (KTV Trưởng)',
    time: 'Vừa xong',
    content
  };

  dispute.messages.push(newMsg);

  if (offer_amount !== undefined) {
    dispute.compensation_offered = Number(offer_amount);
  }

  return res.status(200).json({
    success: true,
    message: 'Đã gửi phản hồi thương lượng đến khách hàng',
    data: {
      message: newMsg,
      dispute
    }
  });
};

exports.settleDispute = (req, res) => {
  const { id } = req.params;
  const { settlement_type, agreed_amount, note } = req.body;

  const dispute = mockDb.disputes.find(d => d.dispute_id === id);
  if (!dispute) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy khiếu nại.' });
  }

  dispute.status = 'SETTLED';
  dispute.settlement_type = settlement_type || 'REFUND_AND_RESCAN';
  dispute.agreed_amount = Number(agreed_amount) || dispute.compensation_offered;
  dispute.settled_at = new Date().toISOString();

  dispute.messages.push({
    sender: 'SYSTEM',
    name: 'Hệ Thống Phán Quyết Tự Chủ',
    time: 'Vừa xong',
    content: `Hai bên đã thống nhất phương án hòa giải: ${dispute.settlement_type}. Mức bồi thường giải ngân: ${dispute.agreed_amount.toLocaleString('vi-VN')} đ. Đơn khiếu nại được đóng thành công.`
  });

  return res.status(200).json({
    success: true,
    message: 'Thương lượng thành công! Quỹ đền bù tự quản đã giải ngân thanh toán cho khách hàng.',
    data: dispute
  });
};

