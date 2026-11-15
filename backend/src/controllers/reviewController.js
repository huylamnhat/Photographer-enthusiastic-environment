const { mockReviews, mockLabs, mockOrders } = require('../data/mockStore');
const { runQuery } = require('../config/db');

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
  const { lab_id, order_id, rating, comment, service_name } = req.body;
  const cleanOrderId = String(order_id || '').replace(/^#/, '').trim();
  const matchedOrder = cleanOrderId
    ? mockOrders.find(o => String(o.order_id || '').toUpperCase() === cleanOrderId.toUpperCase())
    : null;
  const resolvedLabId = lab_id || matchedOrder?.lab_id;

  if (!resolvedLabId || !rating) {
    return res.status(400).json({ success: false, message: 'Vui lòng chọn lab và số sao đánh giá' });
  }

  const now = new Date();
  const formattedDate = `${now.getDate().toString().padStart(2, '0')}/${(now.getMonth() + 1).toString().padStart(2, '0')}/${now.getFullYear()}`;
  const numRating = Number(rating);
  const reviewComment = String(comment || '').trim();
  const reviewService = String(service_name || '').trim() || 'Tráng & Scan Film';

  let existing = cleanOrderId
    ? mockReviews.find(r => String(r.order_id || '').replace(/^#/, '').trim().toUpperCase() === cleanOrderId.toUpperCase())
    : null;

  let savedReview;
  if (existing) {
    existing.rating = numRating;
    existing.comment = reviewComment;
    existing.service_name = reviewService;
    existing.date = formattedDate;
    savedReview = existing;
  } else {
    savedReview = {
      review_id: `rev-${Date.now()}`,
      order_id: matchedOrder?.order_id || cleanOrderId,
      lab_id: resolvedLabId,
      user_id: user?.user_id || '',
      user_name: user?.full_name || 'Khách hàng MiniLab',
      rating: numRating,
      date: formattedDate,
      comment: reviewComment,
      service_name: reviewService,
      created_at: now.toISOString(),
    };
    mockReviews.unshift(savedReview);

    // Update lab review stats
    const lab = mockLabs.find(l => l.lab_id === resolvedLabId);
    if (lab) {
      lab.review_count = (lab.review_count || 0) + 1;
    }
  }

  // Persist to SQL Server Review table when order exists
  if (savedReview.order_id) {
    const safeRevCode = String(savedReview.review_id).replace(/'/g, "''");
    const safeOrdCode = String(savedReview.order_id).replace(/'/g, "''");
    const safeSvc = String(reviewService).replace(/'/g, "''");
    const safeComment = String(reviewComment).replace(/'/g, "''");
    const dbUserId = Number(user?.db_user_id) || 5;
    runQuery(`
      DECLARE @ordId BIGINT = (SELECT TOP 1 order_id FROM Orders WHERE order_code = '${safeOrdCode}');
      IF @ordId IS NOT NULL
      BEGIN
        IF EXISTS (SELECT 1 FROM Review WHERE order_id = @ordId)
          UPDATE Review SET rating = ${numRating}, comment = N'${safeComment}', service_name = N'${safeSvc}' WHERE order_id = @ordId;
        ELSE
          INSERT INTO Review (review_code, reviewer_id, review_type, order_id, service_name, rating, comment, status)
          VALUES ('${safeRevCode}', ${dbUserId}, 'LAB', @ordId, N'${safeSvc}', ${numRating}, N'${safeComment}', 'VISIBLE');
      END
    `).catch(() => {});
  }

  return res.status(201).json({
    success: true,
    message: 'Gửi đánh giá thành công! Cảm ơn bạn đã phản hồi.',
    data: savedReview
  });
};

