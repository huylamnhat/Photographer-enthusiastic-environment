const { mockReviews, mockLabs } = require('../data/mockStore');

exports.getLabReviews = (req, res) => {
  const { labId } = req.params;
  const reviews = mockReviews.filter(r => r.lab_id === labId);
  return res.json({
    success: true,
    data: reviews
  });
};

exports.createReview = (req, res) => {
  const user = req.user;
  const { lab_id, rating, comment, service_name } = req.body;

  if (!lab_id || !rating) {
    return res.status(400).json({ success: false, message: 'Vui lòng chọn lab và số sao đánh giá' });
  }

  const now = new Date();
  const formattedDate = `${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getFullYear()}`;

  const newReview = {
    review_id: `rev-${Date.now()}`,
    lab_id,
    user_name: user.full_name || 'Khách hàng MiniLab',
    rating: Number(rating),
    date: formattedDate,
    comment: comment || 'Dịch vụ rất tốt, màu scan đẹp!',
    service_name: service_name || 'Tráng & Scan Film'
  };

  mockReviews.unshift(newReview);

  // Update lab review stats
  const lab = mockLabs.find(l => l.lab_id === lab_id);
  if (lab) {
    lab.review_count = (lab.review_count || 0) + 1;
  }

  return res.status(201).json({
    success: true,
    message: 'Gửi đánh giá thành công! Cảm ơn bạn đã phản hồi.',
    data: newReview
  });
};

