import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shared/loading_shimmer.dart';
import '../../widgets/shared/empty_state.dart';
import '../../utils/format_utils.dart';
import '../../utils/responsive_grid_delegate.dart';
import '../../utils/dimension_utils.dart';

/// Web Notifications Screen
class NotificationsScreenWeb extends StatefulWidget {
  const NotificationsScreenWeb({super.key});

  @override
  State<NotificationsScreenWeb> createState() => _NotificationsScreenWebState();
}

class _NotificationsScreenWebState extends State<NotificationsScreenWeb> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String _filter = 'All';
  final List<String> _filters = ['All', 'Unread', 'Read'];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    // TODO: Implement notifications API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _notifications = [];
      _isLoading = false;
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: AppTypography.heading1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: _filters.map((filter) {
                    final isSelected = filter == _filter;
                    return Padding(
                      padding: EdgeInsets.only(left: AppSpacing.small),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _filter = filter);
                        },
                        selectedColor: AppColors.primaryMain,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            
            // Notifications List
            Expanded(
              child: _isLoading
                  ? ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.medium),
                          child: const LoadingShimmer(width: double.infinity, height: 80),
                        );
                      },
                    )
                  : _notifications.isEmpty
                      ? const EmptyState(
                          icon: Icons.notifications_none,
                          title: 'No Notifications',
                          message: 'You\'re all caught up!',
                        )
                      : ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: AppSpacing.small),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryMain.withOpacity(0.1),
                                  child: Icon(
                                    _getNotificationIcon(notification['type']),
                                    color: AppColors.primaryMain,
                                  ),
                                ),
                                title: Text(notification['title'] ?? ''),
                                subtitle: Text(notification['message'] ?? ''),
                                trailing: Text(
                                  _formatTime(notification['created_at']),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                onTap: () {
                                  // TODO: Handle notification tap
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return FormatUtils.formatRelativeTime(date);
    } catch (e) {
      return '';
    }
  }
}

