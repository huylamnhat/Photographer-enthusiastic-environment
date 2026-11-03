const { mockCommunityPosts, mockEvents } = require('../data/mockStore');

exports.getAllPosts = (req, res) => {
  const { category, search } = req.query;
  let posts = [...mockCommunityPosts];

  if (category) {
    posts = posts.filter(p => p.category.toLowerCase() === category.toLowerCase());
  }

  if (search) {
    const q = search.toLowerCase();
    posts = posts.filter(p => p.title.toLowerCase().includes(q) || p.content.toLowerCase().includes(q));
  }

  return res.json({
    success: true,
    count: posts.length,
    data: posts
  });
};

exports.getPostById = (req, res) => {
  const { id } = req.params;
  const post = mockCommunityPosts.find(p => p.post_id === id);
  if (!post) {
    return res.status(404).json({ success: false, message: 'Không tìm thấy bài viết' });
  }

  return res.json({
    success: true,
    data: post
  });
};

exports.createPost = (req, res) => {
  const user = req.user;
  const { title, content, category, image_url } = req.body;

  if (!title || !content) {
    return res.status(400).json({ success: false, message: 'Vui lòng điền tiêu đề và nội dung bài viết' });
  }

  const newPost = {
    post_id: `post-${Date.now()}`,
    author_id: user.user_id,
    author_name: user.full_name || 'Nhiếp ảnh gia',
    author_avatar: user.avatar_url || 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    author_badge: user.role === 'Expert' ? 'Chuyên gia nhiếp ảnh' : 'Thành viên cộng đồng',
    title,
    content,
    category: category || 'Chia sẻ kinh nghiệm',
    image_url: image_url || 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800',
    likes_count: 1,
    comments_count: 0,
    created_at: new Date().toISOString(),
    comments: []
  };

  mockCommunityPosts.unshift(newPost);

  return res.status(201).json({
    success: true,
    message: 'Đăng bài viết thành công',
    data: newPost
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

