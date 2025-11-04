import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../providers/search_provider.dart';
import '../../widgets/web/content_card_web.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../providers/audio_player_provider.dart';
import '../../models/content_item.dart';
import '../../utils/responsive_grid_delegate.dart';
import '../../utils/dimension_utils.dart';

/// Web Search Screen - Full implementation
class SearchScreenWeb extends StatefulWidget {
  const SearchScreenWeb({super.key});

  @override
  State<SearchScreenWeb> createState() => _SearchScreenWebState();
}

class _SearchScreenWebState extends State<SearchScreenWeb> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Podcasts', 'Music', 'Videos', 'Posts', 'Users'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.read<SearchProvider>().clearResults();
      return;
    }

    final type = _selectedFilter == 'All' ? null : _selectedFilter.toLowerCase();
    context.read<SearchProvider>().search(query, type: type);
  }

  void _handlePlay(ContentItem item) {
    if (item.audioUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No audio available for ${item.title}')),
      );
      return;
    }

    context.read<AudioPlayerState>().playContent(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        padding: ResponsiveGridDelegate.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
                    'Search',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search podcasts, music, and more...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundSecondary,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.large,
                        vertical: AppSpacing.medium,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.medium),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = filter == _selectedFilter;
                        return Padding(
                          padding: EdgeInsets.only(right: AppSpacing.small),
                          child: FilterChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = filter;
                              });
                              _performSearch();
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
                  
                  const SizedBox(height: AppSpacing.large),
                  
                  // Search Results
                  Expanded(
                    child: Consumer<SearchProvider>(
                      builder: (context, provider, child) {
                        if (_searchController.text.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 80,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                const SizedBox(height: AppSpacing.large),
                                Text(
                                  'Search for content',
                                  style: AppTypography.heading3.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.small),
                                Text(
                                  'Find podcasts, music, videos, and more',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (provider.isLoading) {
                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate: ResponsiveGridDelegate.getResponsiveGridDelegate(
                              context,
                              desktop: 5,
                              tablet: 3,
                              mobile: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: AppSpacing.medium,
                              mainAxisSpacing: AppSpacing.medium,
                            ),
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return const LoadingShimmer(width: double.infinity, height: 250);
                            },
                          );
                        }

                        if (provider.results.isEmpty) {
                          return const EmptyState(
                            icon: Icons.search_off,
                            title: 'No Results Found',
                            message: 'Try different keywords or filters',
                          );
                        }

                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate: ResponsiveGridDelegate.getResponsiveGridDelegate(
                            context,
                            desktop: 5,
                            tablet: 3,
                            mobile: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: AppSpacing.medium,
                            mainAxisSpacing: AppSpacing.medium,
                          ),
                          itemCount: provider.results.length,
                          itemBuilder: (context, index) {
                            final item = provider.results[index];
                            return ContentCardWeb(
                              item: item,
                              onTap: () => _handlePlay(item),
                              onPlay: () => _handlePlay(item),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

