import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../providers/podcast_provider.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/content_section.dart';

class PodcastsScreenMobile extends StatelessWidget {
  const PodcastsScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        title: const Text('Podcasts'),
      ),
      body: Consumer<PodcastProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return GridView.builder(
              padding: EdgeInsets.all(AppSpacing.medium),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: AppSpacing.medium,
                mainAxisSpacing: AppSpacing.medium,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const LoadingShimmer(width: double.infinity, height: 200);
              },
            );
          }

          return Column(
            children: [
              // Search and filters
              Padding(
                padding: EdgeInsets.all(AppSpacing.medium),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search podcasts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundSecondary,
                  ),
                ),
              ),

              // Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                child: Row(
                  children: ['All', 'Sermons', 'Teaching', 'Prayer', 'Worship', 'Testimony', 'Bible Study']
                      .map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: AppSpacing.small),
                      child: FilterChip(
                        label: Text(category),
                        onSelected: (selected) {},
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.medium),

              // Podcasts Grid
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppSpacing.medium,
                    mainAxisSpacing: AppSpacing.medium,
                  ),
                  itemCount: provider.podcasts.length,
                  itemBuilder: (context, index) {
                    final podcast = provider.podcasts[index];
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSecondary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.headphones,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(AppSpacing.small),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  podcast.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  podcast.creator ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
