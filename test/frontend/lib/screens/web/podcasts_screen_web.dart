import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../widgets/web/content_card_web.dart';
import '../../services/api_service.dart';
import '../../models/api_models.dart';
import '../../models/content_item.dart';
import '../../providers/audio_player_provider.dart';
import '../../utils/responsive_grid_delegate.dart';
import '../../utils/dimension_utils.dart';

/// Web Podcasts Screen - Full implementation
class PodcastsScreenWeb extends StatefulWidget {
  const PodcastsScreenWeb({super.key});

  @override
  State<PodcastsScreenWeb> createState() => _PodcastsScreenWebState();
}

class _PodcastsScreenWebState extends State<PodcastsScreenWeb> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<ContentItem> _podcasts = [];
  List<ContentItem> _filteredPodcasts = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Sermons', 'Teaching', 'Prayer', 'Worship', 'Testimony', 'Bible Study'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchPodcasts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterPodcasts();
  }

  void _filterPodcasts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPodcasts = _podcasts.where((podcast) {
        final matchesSearch = query.isEmpty || 
            podcast.title.toLowerCase().contains(query) ||
            (podcast.description?.toLowerCase().contains(query) ?? false);
        
        final matchesCategory = _selectedCategory == 'All' ||
            podcast.category?.toLowerCase() == _selectedCategory.toLowerCase();
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _fetchPodcasts() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final podcastsData = await _api.getPodcasts();
      
      _podcasts = podcastsData.map((podcast) {
        final audioUrl = podcast.audioUrl != null && podcast.audioUrl!.isNotEmpty
            ? _api.getMediaUrl(podcast.audioUrl!)
            : null;
        
        return ContentItem(
          id: podcast.id.toString(),
          title: podcast.title,
          creator: 'Christ Tabernacle',
          description: podcast.description,
          coverImage: podcast.coverImage != null 
            ? _api.getMediaUrl(podcast.coverImage!) 
            : null,
          audioUrl: audioUrl,
          videoUrl: null,
          duration: podcast.duration != null 
            ? Duration(seconds: podcast.duration!)
            : null,
          category: _getCategoryName(podcast.categoryId),
          plays: podcast.playsCount,
          createdAt: podcast.createdAt,
        );
      }).where((p) => p.audioUrl != null && p.audioUrl!.isNotEmpty).toList();
      
      _filteredPodcasts = List.from(_podcasts);
    } catch (e) {
      print('Error fetching podcasts: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getCategoryName(int? categoryId) {
    switch (categoryId) {
      case 1: return 'Sermons';
      case 2: return 'Bible Study';
      case 3: return 'Devotionals';
      case 4: return 'Prayer';
      case 5: return 'Worship';
      case 6: return 'Gospel';
      default: return 'Podcast';
    }
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

  void _handleItemTap(ContentItem item) {
    _handlePlay(item);
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
                    'Podcasts',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search podcasts...',
                      prefixIcon: const Icon(Icons.search),
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
                  ),
                  
                  const SizedBox(height: AppSpacing.medium),
                  
                  // Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
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
                              _filterPodcasts();
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
                  
                  // Podcasts Grid
                  Expanded(
                    child: _isLoading
                        ? GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate: ResponsiveGridDelegate.getResponsiveGridDelegate(
                              context,
                              desktop: 4,
                              tablet: 3,
                              mobile: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: AppSpacing.medium,
                              mainAxisSpacing: AppSpacing.medium,
                            ),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return const LoadingShimmer(width: double.infinity, height: 250);
                            },
                          )
                        : _filteredPodcasts.isEmpty
                            ? const EmptyState(
                                icon: Icons.podcasts,
                                title: 'No Podcasts Found',
                                message: 'Try adjusting your search or filters',
                              )
                            : GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: ResponsiveGridDelegate.getResponsiveGridDelegate(
                                  context,
                                  desktop: 4,
                                  tablet: 3,
                                  mobile: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: AppSpacing.medium,
                                  mainAxisSpacing: AppSpacing.medium,
                                ),
                                itemCount: _filteredPodcasts.length,
                                itemBuilder: (context, index) {
                                  final podcast = _filteredPodcasts[index];
                                  return ContentCardWeb(
                                    item: podcast,
                                    onTap: () => _handleItemTap(podcast),
                                    onPlay: () => _handlePlay(podcast),
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

