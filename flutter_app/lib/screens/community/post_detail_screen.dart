import 'package:flutter/material.dart';
import '../../core/mock/mock_test_assets.dart';
import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/community_model.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPostModel? post;
  final Map<String, dynamic>? postData;

  const PostDetailScreen({super.key, this.post, this.postData});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  CommunityPostModel? _livePost;
  List<CommentModel> _comments = [];
  int _likesCount = 0;
  bool _isLiked = false;
  bool _loading = true;
  bool _sendingComment = false;

  String get _postId =>
      _livePost?.postId ??
      widget.post?.postId ??
      (widget.postData?['id']?.toString() ?? '');

  @override
  void initState() {
    super.initState();
    _livePost = widget.post;
    _likesCount = widget.post?.likesCount ?? ((widget.postData?['likes'] as num?)?.toInt() ?? 0);
    _isLiked = widget.post?.isLiked ?? (widget.postData?['isLiked'] == true);
    _comments = List<CommentModel>.from(widget.post?.comments ?? const []);
    _loadPostDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPostDetail() async {
    final id = _postId;
    if (id.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    final fetched = await ApiService().getCommunityPostById(id);
    if (!mounted) return;
    setState(() {
      if (fetched != null) {
        _livePost = fetched;
        _likesCount = fetched.likesCount;
        _isLiked = fetched.isLiked;
        _comments = List<CommentModel>.from(fetched.comments);
      }
      _loading = false;
    });
  }

  Future<void> _toggleLike() async {
    final id = _postId;
    if (id.isEmpty) return;
    final res = await ApiService().likeCommunityPost(id);
    if (!mounted || res == null) return;
    setState(() {
      _isLiked = res['is_liked'] == true;
      _likesCount = (res['likes_count'] as num?)?.toInt() ?? _likesCount;
    });
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    final id = _postId;
    if (text.isEmpty || id.isEmpty || _sendingComment) return;

    setState(() => _sendingComment = true);
    final res = await ApiService().addCommunityComment(id, text);
    if (!mounted) return;

    if (res != null) {
      _commentController.clear();
      if (res['comments'] is List) {
        setState(() {
          _comments = (res['comments'] as List)
              .map((c) => CommentModel.fromJson(Map<String, dynamic>.from(c as Map)))
              .toList();
          _sendingComment = false;
        });
      } else if (res['data'] is Map) {
        final newCmt = CommentModel.fromJson(Map<String, dynamic>.from(res['data'] as Map));
        setState(() {
          _comments.add(newCmt);
          _sendingComment = false;
        });
      } else {
        await _loadPostDetail();
        if (mounted) setState(() => _sendingComment = false);
      }
    } else {
      setState(() => _sendingComment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('Không thể gửi bình luận. Vui lòng thử lại.'),
        ),
      );
    }
  }

  String _formatCommentTime(String raw) {
    if (raw.isEmpty) return 'Vừa xong';
    if (raw.contains('T')) {
      final parts = raw.split('T');
      final timePart = parts[1].length >= 5 ? parts[1].substring(0, 5) : '';
      return '${parts[0]} $timePart';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final post = _livePost ?? widget.post;
    final title = post?.title ?? (widget.postData?['title']?.toString() ?? '');
    final author = post?.authorName ?? (widget.postData?['author']?.toString() ?? 'Thành viên MiniLab');
    final avatar = post?.authorAvatar.isNotEmpty == true
        ? post!.authorAvatar
        : (widget.postData?['avatar']?.toString() ?? MockTestAssets.avatarCustomer);
    final badge = post?.authorBadge ?? (widget.postData?['badge']?.toString() ?? 'THÀNH VIÊN');
    final category = post?.category ?? (widget.postData?['category']?.toString() ?? 'Cộng đồng');
    final content = post?.content ?? (widget.postData?['content']?.toString() ?? '');
    final image = post?.imageUrl.isNotEmpty == true
        ? post!.imageUrl
        : (widget.postData?['image']?.toString() ?? MockTestAssets.samplePhoto2);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: AppColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outline, height: 1),
        ),
        title: Text(
          'CHI TIẾT BÀI VIẾT & THẢO LUẬN',
          style: AppTypography.cardTitle.copyWith(fontSize: 13),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
            onPressed: _loadPostDetail,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadPostDetail,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: MockTestAssets.image(avatar, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(author, style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceSunken,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      badge.toUpperCase(),
                                      style: AppTypography.labelCaps.copyWith(
                                        fontSize: 8,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Chuyên mục $category',
                                style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.inkMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(title, style: AppTypography.pageTitle.copyWith(fontSize: 18)),
                    const SizedBox(height: 12),
                    Text(content, style: AppTypography.bodySmall.copyWith(fontSize: 13, height: 1.5)),
                    const SizedBox(height: 14),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 220,
                        child: MockTestAssets.image(image, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _toggleLike,
                            child: Row(
                              children: [
                                Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border,
                                  size: 18,
                                  color: _isLiked ? Colors.redAccent : AppColors.inkMuted,
                                ),
                                const SizedBox(width: 6),
                                Text('$_likesCount Lượt thích', style: AppTypography.dataMono.copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(
                            '${_comments.length} Bình luận',
                            style: AppTypography.dataMono.copyWith(fontSize: 11, color: AppColors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text('BÌNH LUẬN & THẢO LUẬN', style: AppTypography.sectionHeading.copyWith(fontSize: 12)),
                    const SizedBox(height: 10),
                    if (_loading && _comments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                      )
                    else if (_comments.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Text(
                          'Chưa có bình luận nào. Hãy là người đầu tiên chia sẻ góc nhìn của bạn!',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.inkMuted),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final cmt = _comments[index];
                          final cmtAvatar = cmt.avatarUrl.isNotEmpty
                              ? cmt.avatarUrl
                              : MockTestAssets.avatarCustomer;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: MockTestAssets.image(cmtAvatar, fit: BoxFit.cover),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(cmt.userName, style: AppTypography.cardTitle.copyWith(fontSize: 11)),
                                    const Spacer(),
                                    Text(
                                      _formatCommentTime(cmt.createdAt),
                                      style: AppTypography.dataMono.copyWith(fontSize: 9, color: AppColors.inkMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(cmt.content, style: AppTypography.bodySmall.copyWith(fontSize: 11, height: 1.3)),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: TextField(
                        controller: _commentController,
                        style: AppTypography.bodySmall,
                        decoration: const InputDecoration(
                          hintText: 'Viết phản hồi hoặc chia sẻ góc nhìn...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendingComment ? null : _addComment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: Text(
                      _sendingComment ? '...' : 'Gửi',
                      style: AppTypography.button.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
