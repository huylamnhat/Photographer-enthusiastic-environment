class CommunityHelperService {
  const CommunityHelperService._();
  /// Định dạng thời gian đăng bài viết hoặc bình luận sang tiếng Việt tự nhiên.
  static String formatRelativeTime(DateTime? createdAt, {DateTime? now}) {
    if (createdAt == null) return 'Không rõ thời gian';
    final reference = now ?? DateTime.now();
    final diff = reference.difference(createdAt);
    if (diff.isNegative || diff.inSeconds < 60) {
      return 'Vừa xong';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    }
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    return '$day/$month/${createdAt.year}';
  }
  /// Ước tính số phút đọc bài chia sẻ kỹ thuật nhiếp ảnh.
  static int estimateReadingMinutes(String content, {int wordsPerMinute = 200}) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return 1;
    final wordCount = trimmed.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / wordsPerMinute).ceil();
    return minutes < 1 ? 1 : minutes;
  }
  /// Trích xuất danh sách hashtag không trùng lặp từ nội dung bài viết.
  static List<String> extractHashtags(String content) {
    final regex = RegExp(r'#([a-zA-Z0-9_\u00C0-\u1EF9]{2,30})');
    final seen = <String>{};
    final result = <String>[];
    for (final match in regex.allMatches(content)) {
      final tag = match.group(1);
      if (tag != null && seen.add(tag.toLowerCase())) {
        result.add('#$tag');
      }
    }
    return result;
  }
  /// Tính trạng thái hiển thị của sự kiện Workshop / Photowalk cộng đồng.
  static String resolveEventAvailabilityLabel({
    required DateTime startAt,
    DateTime? endAt,
    int? maxParticipants,
    int currentParticipants = 0,
  }) {
    final now = DateTime.now();
    final effectiveEnd = endAt ?? startAt.add(const Duration(hours: 3));
    if (now.isAfter(effectiveEnd)) {
      return 'Đã kết thúc';
    }
    if (now.isAfter(startAt) && now.isBefore(effectiveEnd)) {
      return 'Đang diễn ra';
    }
    if (maxParticipants != null && maxParticipants > 0) {
      final remaining = maxParticipants - currentParticipants;
      if (remaining <= 0) return 'Đã đủ người tham gia';
      if (remaining <= 5) return 'Sắp hết chỗ (còn $remaining suất)';
    }
    return 'Đang mở đăng ký';
  }
}

