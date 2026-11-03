import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/community_provider.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cộng đồng & Diễn đàn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_outlined),
            tooltip: 'Sự kiện Photowalk',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Cá nhân & Cài đặt',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: () => community.fetchPosts(),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: community.posts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final post = community.posts[index];
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(post.authorAvatar),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(post.authorBadge, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: AppColors.neutralBg, borderRadius: BorderRadius.circular(4)),
                            child: Text(post.category, style: const TextStyle(fontSize: 10, color: AppColors.inkMuted)),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title & Excerpt
                      Text(
                        post.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkMuted, height: 1.4),
                      ),
                      const SizedBox(height: 12),

                      // Image attachment if any
                      if (post.imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Action bar (Like / Comment)
                      Row(
                        children: [
                          InkWell(
                            onTap: () => community.toggleLike(post.postId),
                            child: Row(
                              children: [
                                const Icon(Icons.favorite_border, size: 18, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text('${post.likesCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.inkMuted)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.inkMuted),
                              const SizedBox(width: 4),
                              Text('${post.commentsCount} bình luận', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

