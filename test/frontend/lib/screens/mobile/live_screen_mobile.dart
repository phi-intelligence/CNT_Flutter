import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Live Screen - Exact replica of React Native implementation
/// Features tabs for Live, Upcoming, and Past streams
class LiveScreenMobile extends StatefulWidget {
  const LiveScreenMobile({super.key});

  @override
  State<LiveScreenMobile> createState() => _LiveScreenMobileState();
}

class StreamData {
  final String id;
  final String title;
  final String hostName;
  final int? viewerCount;
  final String status; // 'live', 'scheduling', 'ended', 'archived'

  StreamData({
    required this.id,
    required this.title,
    required this.hostName,
    this.viewerCount,
    required this.status,
  });
}

class _LiveScreenMobileState extends State<LiveScreenMobile> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0 = live, 1 = upcoming, 2 = past
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  late TabController _tabController;
  
  // Mock data
  final List<StreamData> _liveStreams = [
    StreamData(
      id: '1',
      title: 'Sunday Service - Morning Worship',
      hostName: 'Pastor John',
      viewerCount: 245,
      status: 'live',
    ),
    StreamData(
      id: '2',
      title: 'Bible Study - Book of Genesis',
      hostName: 'Elder Mary',
      viewerCount: 189,
      status: 'live',
    ),
  ];
  
  final List<StreamData> _upcomingStreams = [
    StreamData(
      id: '3',
      title: 'Evening Prayer Meeting',
      hostName: 'Brother James',
      status: 'scheduling',
    ),
    StreamData(
      id: '4',
      title: 'Youth Fellowship',
      hostName: 'Sister Sarah',
      status: 'scheduling',
    ),
  ];
  
  final List<StreamData> _pastStreams = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchStreams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchStreams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchStreams();
    setState(() {
      _isRefreshing = false;
    });
  }

  void _handleGoLive() {
    // Navigate to stream creation
  }

  void _handleJoinStream(String streamId) {
    // Navigate to stream viewer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(AppSpacing.large),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderPrimary, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Streaming',
                        style: AppTypography.heading2.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Broadcast to your community',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _handleGoLive,
                  icon: const Icon(Icons.videocam, size: 20),
                  label: const Text('Go Live'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMain,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium,
                      vertical: AppSpacing.small,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error message
          if (_error != null)
            Container(
              margin: EdgeInsets.all(AppSpacing.medium),
              padding: EdgeInsets.all(AppSpacing.medium),
              decoration: BoxDecoration(
                color: AppColors.errorMain.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.errorMain.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppColors.errorMain, size: 20),
                  const SizedBox(width: AppSpacing.small),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _error!,
                          style: AppTypography.body.copyWith(
                            color: AppColors.errorMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _error = null;
                            });
                          },
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Tab Navigation
          Container(
            margin: EdgeInsets.only(top: AppSpacing.medium),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderPrimary, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _activeTab = index;
                });
              },
              labelColor: AppColors.primaryMain,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryMain,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam, size: 16),
                      const SizedBox(width: 4),
                      const Text('Live'),
                      const SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.tiny,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMain,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '0', // Stream count
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 16),
                      const SizedBox(width: 4),
                      const Text('Upcoming'),
                      const SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.tiny,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMain,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '0',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.archive, size: 16),
                      const SizedBox(width: 4),
                      const Text('Past'),
                      const SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.tiny,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMain,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '0',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryMain),
            const SizedBox(height: AppSpacing.medium),
            Text(
              'Loading streams...',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Get streams for current tab
    List<StreamData> streams;
    String emptyMessage;
    IconData emptyIcon;

    switch (_activeTab) {
      case 0:
        streams = _liveStreams;
        emptyMessage = 'No live streams right now';
        emptyIcon = Icons.videocam_off;
        break;
      case 1:
        streams = _upcomingStreams;
        emptyMessage = 'No upcoming streams';
        emptyIcon = Icons.schedule;
        break;
      default:
        streams = _pastStreams;
        emptyMessage = 'No past recordings';
        emptyIcon = Icons.archive;
    }

    // Show empty state if no streams
    if (streams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text(
              emptyMessage,
              style: AppTypography.heading3.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Display stream cards
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.medium),
      child: Column(
        children: streams.map((stream) {
          return _buildStreamCard(
            title: stream.title,
            hostName: stream.hostName,
            isLive: stream.status == 'live',
            isUpcoming: stream.status == 'scheduling',
            viewerCount: stream.viewerCount,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStreamCard({
    required String title,
    required String hostName,
    bool isLive = false,
    bool isUpcoming = false,
    int? viewerCount,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusMedium),
              ),
            ),
            child: Center(
              child: Icon(
                Icons.videocam,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(AppSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.tiny),
                Text(
                  hostName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                
                // Status badge and viewer count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.small,
                        vertical: AppSpacing.tiny,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? AppColors.errorMain.withOpacity(0.2)
                            : isUpcoming
                                ? AppColors.primaryMain.withOpacity(0.2)
                                : AppColors.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          if (isLive) ...[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.errorMain,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: AppColors.errorMain,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (isUpcoming) ...[
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: AppColors.primaryMain,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'UPCOMING',
                              style: TextStyle(
                                color: AppColors.primaryMain,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (viewerCount != null && isLive)
                      Text(
                        '$viewerCount viewers',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                
                // Action button
                const SizedBox(height: AppSpacing.medium),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Join stream
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMain,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSpacing.small,
                      ),
                    ),
                    child: Text(
                      isLive ? 'Join Stream' : 'Set Reminder',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
