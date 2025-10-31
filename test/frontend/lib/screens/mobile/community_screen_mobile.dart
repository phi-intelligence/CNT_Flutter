import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/community_provider.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/create_post_modal.dart';
import '../../utils/format_utils.dart';

class CommunityScreenMobile extends StatefulWidget {
  const CommunityScreenMobile({super.key});

  @override
  State<CommunityScreenMobile> createState() => _CommunityScreenMobileState();
}

class _CommunityScreenMobileState extends State<CommunityScreenMobile> {
  String _selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('✅ CommunityScreenMobile initState');
    // Fetch posts on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<CommunityProvider>().fetchPosts(refresh: true);
      } catch (e) {
        print('❌ CommunityScreenMobile: Error fetching posts: $e');
      }
    });
    
    // Load more on scroll
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = context.read<CommunityProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.fetchPosts();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePostModal(),
        fullscreenDialog: true,
      ),
    ).then((_) {
      // Refresh posts after creating
      context.read<CommunityProvider>().fetchPosts(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleCreatePost,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: [
                'All',
                'Testimonies',
                'Prayer',
                'Questions',
                'Announcements',
                'General',
              ].map((category) {
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.small),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      context.read<CommunityProvider>().filterByCategory(
                        category == 'All' ? null : category,
                      );
                    },
                    selectedColor: AppColors.primaryMain,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Posts List
          Expanded(
            child: Consumer<CommunityProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.posts.isEmpty) {
                  return ListView.builder(
                    itemCount: 5,
                    padding: EdgeInsets.all(AppSpacing.medium),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.medium),
                        child: const LoadingShimmer(width: double.infinity, height: 200),
                      );
                    },
                  );
                }

                if (provider.posts.isEmpty && !provider.isLoading) {
                  return const EmptyState(
                    icon: Icons.forum,
                    title: 'No Posts Yet',
                    message: 'Be the first to share something with the community!',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchPosts(refresh: true);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(AppSpacing.medium),
                    itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.medium),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final post = provider.posts[index];
                      return _buildPostCard(post, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(dynamic post, CommunityProvider provider) {
    // Extract post data - handle both Map and object types
    final postId = post is Map ? post['id'] : post.id;
    final title = post is Map ? post['title'] : post.title;
    final content = post is Map ? post['content'] : post.content;
    final author = post is Map ? post['author'] : post.author;
    final createdAt = post is Map 
        ? (post['created_at'] != null ? DateTime.parse(post['created_at']) : null)
        : post.createdAt;
    final likes = post is Map ? (post['likes'] ?? 0) : (post.likes ?? 0);
    final comments = post is Map ? (post['comments'] ?? 0) : (post.comments ?? 0);
    final isLiked = post is Map ? (post['is_liked'] ?? false) : false;

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryMain,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.small),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author?.toString() ?? 'Anonymous',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        createdAt != null 
                            ? FormatUtils.formatRelativeTime(createdAt)
                            : 'Recently',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: AppColors.textSecondary,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              title?.toString() ?? 'Post Title',
              style: AppTypography.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (content != null && content.toString().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                content.toString(),
                style: AppTypography.body,
              ),
            ],
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? AppColors.errorMain : null,
                  ),
                  onPressed: () {
                    final id = postId is int ? postId : (postId is String ? int.tryParse(postId) : null);
                    if (id != null) {
                      provider.likePost(id);
                    }
                  },
                ),
                Text('$likes'),
                const SizedBox(width: AppSpacing.large),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {
                    // TODO: Navigate to comments
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comments coming soon')),
                    );
                  },
                ),
                Text('$comments'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implement share
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
