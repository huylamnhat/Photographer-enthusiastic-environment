class CommunityPostModel {
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String authorBadge;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  int likesCount;
  bool isLiked;
  int commentsCount;
  final String createdAt;
  final List<CommentModel> comments;

  CommunityPostModel({
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.authorBadge,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.likesCount,
    this.isLiked = false,
    required this.commentsCount,
    required this.createdAt,
    this.comments = const [],
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      postId: json['post_id'] ?? '',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'] ?? 'Tác giả',
      authorAvatar: json['author_avatar'] ?? '',
      authorBadge: json['author_badge'] ?? 'Thành viên',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'Thảo luận',
      imageUrl: json['image_url'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] == true,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class CommentModel {
  final String commentId;
  final String userName;
  final String avatarUrl;
  final String content;
  final String createdAt;

  CommentModel({
    required this.commentId,
    required this.userName,
    required this.avatarUrl,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      commentId: json['comment_id'] ?? '',
      userName: json['user_name'] ?? 'Người dùng',
      avatarUrl: json['avatar_url'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class EventModel {
  final String eventId;
  final String organizerName;
  final String type;
  final String title;
  final String date;
  final String location;
  int registeredCount;
  final int maxSlots;
  final String fee;
  final String coverImage;
  final String description;
  bool isRegistered;

  EventModel({
    required this.eventId,
    required this.organizerName,
    this.type = 'PHOTOWALK',
    required this.title,
    required this.date,
    required this.location,
    required this.registeredCount,
    required this.maxSlots,
    required this.fee,
    required this.coverImage,
    required this.description,
    required this.isRegistered,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawFee = json['fee'];
    final feeStr = (rawFee == null || rawFee == 0 || rawFee == '0')
        ? 'MIỄN PHÍ'
        : (rawFee is num ? '${rawFee.toInt()}đ / người' : rawFee.toString());
    return EventModel(
      eventId: (json['event_id'] ?? '').toString(),
      organizerName: (json['organizer_name'] ?? json['host_name'] ?? '').toString(),
      type: (json['type'] ?? 'PHOTOWALK').toString(),
      title: (json['title'] ?? '').toString(),
      date: (json['date'] ?? '').toString().split('T').first,
      location: (json['location'] ?? '').toString(),
      registeredCount: (json['registered_count'] ?? json['current_participants'] ?? 0) as int,
      maxSlots: (json['max_slots'] ?? json['max_participants'] ?? 30) as int,
      fee: feeStr,
      coverImage: (json['cover_image'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      isRegistered: json['is_registered'] == true,
    );
  }
}

