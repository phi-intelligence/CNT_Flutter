import 'package:flutter/material.dart';
import '../../models/content_item.dart';
import '../../utils/platform_helper.dart';
import '../mobile/content_card_mobile.dart';
import '../mobile/horizontal_content_card_mobile.dart';
import '../web/content_card_web.dart';

class ContentSection extends StatelessWidget {
  final String title;
  final List<ContentItem> items;
  final VoidCallback? onViewAll;
  final bool isHorizontal;
  final Function(ContentItem)? onItemTap;
  final Function(ContentItem)? onItemPlay;

  const ContentSection({
    super.key,
    required this.title,
    required this.items,
    this.onViewAll,
    this.isHorizontal = false,
    this.onItemTap,
    this.onItemPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final isWeb = PlatformHelper.isWebPlatform();

    if (isHorizontal && isWeb) {
      return _buildHorizontalWeb(context);
    } else if (isHorizontal) {
      return _buildHorizontalMobile(context);
    } else if (isWeb) {
      return _buildGridWeb(context);
    } else {
      return _buildVerticalMobile(context);
    }
  }

  Widget _buildHorizontalMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View All'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: _buildCard(context, items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalWeb(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 180,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildCard(context, items[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCard(context, item),
            )),
      ],
    );
  }

  Widget _buildGridWeb(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200 ? 4 : screenWidth > 800 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildCard(context, items[index]);
          },
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, ContentItem item) {
    if (PlatformHelper.isWebPlatform()) {
      return ContentCardWeb(
        item: item,
        onTap: onItemTap != null ? () => onItemTap!(item) : null,
        onPlay: onItemPlay != null ? () => onItemPlay!(item) : null,
      );
    } else {
      // Use horizontal card for horizontal layouts, regular card for vertical
      if (isHorizontal) {
        return HorizontalContentCardMobile(
          item: item,
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
          onPlay: onItemPlay != null ? () => onItemPlay!(item) : null,
      );
    } else {
      return ContentCardMobile(
        item: item,
          onTap: onItemTap != null ? () => onItemTap!(item) : null,
          onPlay: onItemPlay != null ? () => onItemPlay!(item) : null,
      );
      }
    }
  }
}

