const { mockUsers, mockCommunityPosts, mockEvents, mockAuditLogs } = require('../data/mockStore');
const { runQuery } = require('../config/db');

function enrichPostWithAuthor(post, currentUserId = '') {
  if (!post) return post;
  const author = mockUsers.find(u => 
    u.user_id === post.author_id || 
    String(u.db_user_id) === String(post.author_id) || 
    `usr-${u.db_user_id}` === post.author_id
  );
  const isLiked = Boolean(currentUserId && Array.isArray(post.liked_user_ids) && post.liked_user_ids.includes(currentUserId));
  const safeComments = Array.isArray(post.comments) ? post.comments : [];
  if (!author) {
    return {
      ...post,
      is_liked: isLiked,
      comments: safeComments,
      comments_count: safeComments.length,
    };
  }

  const isLocked = author.status === 'LOCKED';
  return {
    ...post,
    is_liked: isLiked,
    comments: safeComments,
    comments_count: safeComments.length,
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
  res.set('Cache-Control', 'no-store');
  const { category, search } = req.query;
  const currentUserId = req.user?.user_id || '';
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

  const enrichedPosts = posts.map(p => enrichPostWithAuthor(p, currentUserId));

  return res.json({
    success: true,
    count: enrichedPosts.length,
    data: enrichedPosts
  });
};

exports.getPostById = (req, res) => {
  res.set('Cache-Control', 'no-store');
  const { id } = req.params;
  const currentUserId = req.user?.user_id || '';
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
    data: enrichPostWithAuthor(post, currentUserId)
  });
};

exports.createPost = async (req, res) => {
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
  await runQuery(`
    INSERT INTO Post_Article (post_code, author_id, post_category_id, post_type, title, slug, content, cover_image_url, likes_count, comments_count, report_count, status, moderated_by, published_at, created_at)
    VALUES ('${safePostCode}', ${dbAuthorId}, 1, 'ARTICLE', N'${safeTitle}', 'post-${Date.now()}', N'${safeContent}', '${safeCover}', 0, 0, 0, 'ACTIVE', NULL, SYSUTCDATETIME(), SYSUTCDATETIME());
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

exports.addComment = async (req, res) => {
  const { id } = req.params;
  const { content } = req.body;
  const user = req.user || {};

  const post = mockCommunityPosts.find(p => p.post_id === id);
  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  const cleanContent = String(content || '').trim();
  if (!cleanContent) {
    return res.status(400).json({ success: false, message: 'Vui lòng nhập nội dung bình luận' });
  }

  const commentCode = `cmt-${Date.now()}`;
  const nowIso = new Date().toISOString();
  const newCmt = {
    comment_id: commentCode,
    user_id: user.user_id || '',
    user_name: user.full_name || 'Khách hàng MiniLab',
    avatar_url: user.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    content: cleanContent,
    created_at: nowIso
  };

  if (!Array.isArray(post.comments)) post.comments = [];
  post.comments.push(newCmt);
  post.comments_count = post.comments.length;

  const esc = (v) => String(v || '').replace(/'/g, "''");
  const safePostCode = esc(post.post_id);
  const safeUserCode = esc(user.user_id || '');
  const dbUserId = Number(user.db_user_id) || 0;
  await runQuery(`
    DECLARE @targetPostId BIGINT = (SELECT TOP 1 post_id FROM Post_Article WHERE post_code = '${safePostCode}');
    DECLARE @targetUserId INT = ${dbUserId > 0 ? dbUserId : `(SELECT TOP 1 user_id FROM Users WHERE user_code = '${safeUserCode}')`};
    IF @targetPostId IS NOT NULL AND @targetUserId IS NOT NULL
    BEGIN
      INSERT INTO Post_Comment (comment_code, post_id, user_id, content, status)
      VALUES ('${esc(commentCode)}', @targetPostId, @targetUserId, N'${esc(cleanContent)}', 'VISIBLE');
      UPDATE Post_Article
      SET comments_count = ${Number(post.comments_count)}
      WHERE post_id = @targetPostId;
    END
  `).catch(() => {});

  return res.json({
    success: true,
    message: 'Bình luận thành công',
    data: newCmt,
    comments_count: post.comments_count,
    comments: post.comments
  });
};

exports.toggleLike = async (req, res) => {
  const { id } = req.params;
  const userId = req.user?.user_id || 'anon';
  const post = mockCommunityPosts.find(p => p.post_id === id);
  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  if (!Array.isArray(post.liked_user_ids)) post.liked_user_ids = [];
  const alreadyLiked = post.liked_user_ids.includes(userId);

  if (alreadyLiked) {
    post.liked_user_ids = post.liked_user_ids.filter(u => u !== userId);
    post.likes_count = Math.max(0, Number(post.likes_count || 1) - 1);
  } else {
    post.liked_user_ids.push(userId);
    post.likes_count = Number(post.likes_count || 0) + 1;
  }
  const isLikedNow = !alreadyLiked;

  const esc = (v) => String(v || '').replace(/'/g, "''");
  const safePostCode = esc(post.post_id);
  const safeUserCode = esc(userId);
  await runQuery(`
    IF OBJECT_ID('dbo.Post_Like', 'U') IS NULL
    BEGIN
      CREATE TABLE dbo.Post_Like (
        post_code VARCHAR(40) NOT NULL,
        user_code VARCHAR(40) NOT NULL,
        created_at DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Post_Like PRIMARY KEY (post_code, user_code)
      );
    END
    ${isLikedNow
      ? `IF NOT EXISTS (SELECT 1 FROM dbo.Post_Like WHERE post_code = '${safePostCode}' AND user_code = '${safeUserCode}')
           INSERT INTO dbo.Post_Like (post_code, user_code) VALUES ('${safePostCode}', '${safeUserCode}');`
      : `DELETE FROM dbo.Post_Like WHERE post_code = '${safePostCode}' AND user_code = '${safeUserCode}';`}
    UPDATE Post_Article SET likes_count = ${Number(post.likes_count)} WHERE post_code = '${safePostCode}';
  `).catch(() => {});

  return res.json({
    success: true,
    is_liked: isLikedNow,
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

