const { mockUsers, mockCommunityPosts, mockEvents, mockAuditLogs } = require('../data/mockStore');
const { runQuery } = require('../config/db');

function enrichPostWithAuthor(post) {
  if (!post) return post;
  const author = mockUsers.find(u => 
    u.user_id === post.author_id || 
    String(u.db_user_id) === String(post.author_id) || 
    `usr-${u.db_user_id}` === post.author_id
  );
  if (!author) return post;

  const isLocked = author.status === 'LOCKED';
  return {
    ...post,
    author_name: isLocked ? 'Người dùng vi phạm' : author.full_name,
    author_avatar: isLocked
      ? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150'
      : (author.avatar_url || post.author_avatar),
    author_badge: isLocked
      ? 'NGƯỜI DÙNG VI PHẠM'
      : (author.role === 'Expert' ? 'Chuyên gia nhiếp ảnh' : 'Thành viên cộng đồng'),
    author_status: author.status,
    is_author_locked: isLocked,
  };
}

exports.getAllPosts = (req, res) => {
  const { category, search } = req.query;
  // Bỏ các bài bị ẩn thủ công (HIDDEN)
  let posts = mockCommunityPosts.filter(p => p.status !== 'HIDDEN');

  // Tạm thời ẩn các bài viết của những tác giả đang bị ban (LOCKED) trên bảng tin cộng đồng
  posts = posts.filter(p => {
    const author = mockUsers.find(u => 
      u.user_id === p.author_id || 
      String(u.db_user_id) === String(p.author_id) || 
      `usr-${u.db_user_id}` === p.author_id
    );
    if (author && author.status === 'LOCKED') {
      return false;
    }
    return true;
  });

  if (category && category !== 'Tất cả') {
    posts = posts.filter(p => p.category.toLowerCase().includes(category.toLowerCase()));
  }

  if (search) {
    const q = search.toLowerCase();
    posts = posts.filter(p => p.title.toLowerCase().includes(q) || p.content.toLowerCase().includes(q));
  }

  const enrichedPosts = posts.map(enrichPostWithAuthor);

  return res.json({
    success: true,
    count: enrichedPosts.length,
    data: enrichedPosts
  });
};

exports.getPostById = (req, res) => {
  const { id } = req.params;
  const post = mockCommunityPosts.find(p => p.post_id === id);
  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  const author = mockUsers.find(u => 
    u.user_id === post.author_id || 
    String(u.db_user_id) === String(post.author_id) || 
    `usr-${u.db_user_id}` === post.author_id
  );
  if (author && author.status === 'LOCKED' && (!req.user || req.user.role !== 'Admin')) {
    return res.status(403).json({
      success: false,
      message: 'Bài viết này tạm thời bị ẩn do tài khoản tác giả đang bị khóa (ban) vi phạm quy định cộng đồng.'
    });
  }

  return res.json({
    success: true,
    data: enrichPostWithAuthor(post)
  });
};

exports.createPost = (req, res) => {
  const user = req.user || {};
  const { title, content, category, image_url } = req.body;

  if (!title || !content) {
    return res.status(400).json({ success: false, message: 'Vui lòng điền tiêu đề và nội dung bài viết' });
  }

  const now = new Date();
  const newPost = {
    post_id: `post-${Date.now().toString().slice(-5)}`,
    author_id: user.user_id || 'usr-001',
    author_name: user.full_name || 'Nguyễn Hoàng Anh',
    author_avatar: user.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    author_badge: user.role === 'Expert' ? 'Chuyên gia nhiếp ảnh' : 'Thành viên cộng đồng',
    title,
    content,
    category: category || 'Kỹ thuật chụp',
    image_url: image_url || 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    likes_count: 1,
    comments_count: 0,
    status: 'ACTIVE',
    needs_audit: true,
    moderated_by: null,
    moderated_at: null,
    report_count: 0,
    created_at: now.toISOString(),
    comments: []
  };

  mockCommunityPosts.unshift(newPost);

  // Persist new Community Post directly to SQL Server (FilmLabPlatform)
  const safePostCode = newPost.post_id.replace(/'/g, "''");
  const safeTitle = String(newPost.title || '').replace(/'/g, "''");
  const safeContent = String(newPost.content || '').replace(/'/g, "''");
  const safeCover = String(newPost.image_url || '').replace(/'/g, "''");
  const dbAuthorId = Number(user.db_user_id) || 5;
  runQuery(`
    INSERT INTO Post_Article (post_code, author_id, post_category_id, post_type, title, slug, content, cover_image_url, likes_count, comments_count, report_count, status, moderated_by, moderated_at, published_at, created_at)
    VALUES ('${safePostCode}', ${dbAuthorId}, 1, 'ARTICLE', N'${safeTitle}', 'post-${Date.now()}', N'${safeContent}', '${safeCover}', 1, 0, 0, 'ACTIVE', NULL, NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
  `).catch(() => {});

  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${newPost.author_name} (CUSTOMER)`,
    action: 'CREATE_POST',
    entity: `Post_Article #${newPost.post_id}`,
    entity_name: 'Post_Article',
    entity_id: newPost.post_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{}',
    newVal: JSON.stringify({ title: newPost.title, category: newPost.category, status: 'ACTIVE', needs_audit: true })
  });

  return res.status(201).json({
    success: true,
    message: 'Đăng bài viết thành công',
    data: newPost
  });
};

exports.reportPost = (req, res) => {
  const { id } = req.params;
  const { reason } = req.body;
  const post = mockCommunityPosts.find(p => p.post_id === id);

  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  post.status = 'REPORTED';
  post.report_count = (post.report_count || 0) + 1;
  post.report_reason = reason || 'Báo cáo vi phạm nội dung / spam từ người dùng Mobile';

  const safeRepCode = String(post.post_id || '').replace(/'/g, "''");
  const safeRepReason = String(post.report_reason || '').replace(/'/g, "''");
  runQuery(`
    UPDATE Post_Article
    SET status = 'REPORTED',
        report_count = ${Number(post.report_count) || 1},
        report_reason = N'${safeRepReason}'
    WHERE post_code = '${safeRepCode}';
  `).catch(() => {});

  const now = new Date();
  mockAuditLogs.unshift({
    id: `LOG-${Date.now().toString().slice(-5)}`,
    timestamp: now.toISOString().replace('T', ' ').slice(0, 19),
    actor: `${req.user?.full_name || 'Thành viên'} (CUSTOMER)`,
    action: 'REPORT_POST',
    entity: `Post_Article #${post.post_id}`,
    entity_name: 'Post_Article',
    entity_id: post.post_id,
    ip: req.ip || '127.0.0.1',
    oldVal: '{"status":"ACTIVE"}',
    newVal: JSON.stringify({ status: 'REPORTED', reason: post.report_reason })
  });

  return res.json({
    success: true,
    message: 'Đã gửi báo cáo bài viết tới Admin kiểm duyệt!',
    data: post
  });
};

exports.addComment = (req, res) => {
  const { id } = req.params;
  const { content } = req.body;
  const user = req.user;

  const post = mockCommunityPosts.find(p => p.post_id === id);
  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  const newCmt = {
    comment_id: `cmt-${Date.now()}`,
    user_name: user.full_name || 'Khách hàng MiniLab',
    avatar_url: user.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    content: content || 'Bài viết rất hay!',
    created_at: new Date().toISOString()
  };

  post.comments.push(newCmt);
  post.comments_count = post.comments.length;

  return res.json({
    success: true,
    message: 'Bình luận thành công',
    data: newCmt
  });
};

exports.toggleLike = (req, res) => {
  const { id } = req.params;
  const post = mockCommunityPosts.find(p => p.post_id === id);
  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  post.likes_count += 1;
  return res.json({
    success: true,
    likes_count: post.likes_count
  });
};

// Events & Workshops
exports.getAllEvents = (req, res) => {
  return res.json({
    success: true,
    count: mockEvents.length,
    data: mockEvents
  });
};

exports.getEventById = (req, res) => {
  const { id } = req.params;
  const event = mockEvents.find(e => e.event_id === id);
  if (!event) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy sự kiện' });
  }
  return res.json({
    success: true,
    data: event
  });
};

exports.registerEvent = (req, res) => {
  const { id } = req.params;
  const event = mockEvents.find(e => e.event_id === id);
  if (!event) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy sự kiện' });
  }

  event.is_registered = true;
  event.registered_count += 1;

  return res.json({
    success: true,
    message: 'Đăng ký tham gia sự kiện thành công! (Xác nhận nội bộ)',
    data: event
  });
};

