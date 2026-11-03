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
    return EventModel(
      eventId: json['event_id'] ?? '',
      organizerName: json['organizer_name'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      registeredCount: json['registered_count'] ?? 0,
      maxSlots: json['max_slots'] ?? 30,
      fee: json['fee'] ?? 'Miễn phí',
      coverImage: json['cover_image'] ?? '',
      description: json['description'] ?? '',
      isRegistered: json['is_registered'] ?? false,
    );
  }
}

