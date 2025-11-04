import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/shared/empty_state.dart';
import '../../utils/format_utils.dart';
import '../../utils/responsive_grid_delegate.dart';
import '../../utils/dimension_utils.dart';

/// Web Prayer Screen - Prayer requests and community prayers
class PrayerScreenWeb extends StatefulWidget {
  const PrayerScreenWeb({super.key});

  @override
  State<PrayerScreenWeb> createState() => _PrayerScreenWebState();
}

class _PrayerScreenWebState extends State<PrayerScreenWeb> {
  List<Map<String, dynamic>> _prayers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  Future<void> _loadPrayers() async {
    setState(() => _isLoading = true);
    // TODO: Implement prayer requests API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _prayers = [];
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
                  'Prayer Requests',
                  style: AppTypography.heading1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showCreatePrayerDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Submit Prayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMain,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            
            // Prayers List
            Expanded(
              child: _prayers.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite,
                      title: 'No Prayer Requests',
                      message: 'Submit a prayer request to share with the community',
                    )
                  : ListView.builder(
                      itemCount: _prayers.length,
                      itemBuilder: (context, index) {
                        final prayer = _prayers[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: AppSpacing.medium),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.large),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primaryMain.withOpacity(0.1),
                                      child: Icon(Icons.person, color: AppColors.primaryMain),
                                    ),
                                    const SizedBox(width: AppSpacing.medium),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prayer['author'] ?? 'Anonymous',
                                            style: AppTypography.body.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            _formatTime(prayer['created_at']),
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.favorite_border),
                                      onPressed: () {
                                        // TODO: Like prayer
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.medium),
                                Text(
                                  prayer['request'] ?? '',
                                  style: AppTypography.body,
                                ),
                              ],
                            ),
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

  void _showCreatePrayerDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Prayer Request'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your prayer request...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Submit prayer
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prayer request submitted')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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

