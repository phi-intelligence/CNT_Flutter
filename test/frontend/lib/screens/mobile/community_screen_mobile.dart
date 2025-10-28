import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/community_provider.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';

class CommunityScreenMobile extends StatefulWidget {
  const CommunityScreenMobile({super.key});

  @override
  State<CommunityScreenMobile> createState() => _CommunityScreenMobileState();
}

class _CommunityScreenMobileState extends State<CommunityScreenMobile> {
  String _selectedCategory = 'All';

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
            onPressed: () {
              // TODO: Open create post modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Post - Coming Soon')),
              );
            },
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
                if (provider.isLoading) {
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

                if (provider.posts.isEmpty) {
                  return const EmptyState(
                    icon: Icons.forum,
                    title: 'No Posts Yet',
                    message: 'Be the first to share something with the community!',
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  itemCount: provider.posts.length,
                  itemBuilder: (context, index) {
                    final post = provider.posts[index];
                    return _buildPostCard(post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(dynamic post) {
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
                        post.author ?? 'Anonymous',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '2 hours ago',
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
              post.title ?? 'Post Title',
              style: AppTypography.heading4.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (post.content != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                post.content!,
                style: AppTypography.body,
              ),
            ],
            const SizedBox(height: AppSpacing.medium),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
                Text('24'),
                const SizedBox(width: AppSpacing.large),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: () {},
                ),
                Text('5'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
