import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/community_provider.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/create_post_modal.dart';
import '../../widgets/community/instagram_post_card.dart';
import '../../utils/format_utils.dart';
import '../community/comment_screen.dart';

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
                    padding: EdgeInsets.zero,
                    itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.medium),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final post = provider.posts[index];
                      // Convert post to Map if needed
                      final postMap = post is Map<String, dynamic>
                          ? post
                          : {
                              'id': post.id,
                              'user_id': post.user_id,
                              'user_name': post.user_name ?? 'User',
                              'user_avatar': post.user_avatar,
                              'title': post.title,
                              'content': post.content,
                              'image_url': post.image_url,
                              'category': post.category,
                              'likes_count': post.likes_count,
                              'comments_count': post.comments_count,
                              'is_liked': post.is_liked,
                              'created_at': post.created_at.toString(),
                            };
                      
                      return InstagramPostCard(
                        post: postMap,
                        onLike: () {
                          final postId = postMap['id'];
                          if (postId != null) {
                            final id = postId is int 
                                ? postId 
                                : int.tryParse(postId.toString());
                            if (id != null) {
                              provider.likePost(id);
                            }
                          }
                        },
                        onComment: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommentScreen(post: postMap),
                            ),
                          );
                        },
                        onShare: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share coming soon')),
                          );
                        },
                        onBookmark: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bookmark coming soon')),
                          );
                        },
                      );
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

}
