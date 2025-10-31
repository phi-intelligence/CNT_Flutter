# Video Podcasts Section - Implementation Plan

## Current State:
- "Video Podcasts" section shows `featuredVideoPodcasts` (top 5 by plays)
- Uses same horizontal card design as featured
- Video podcasts are already in database
- PodcastProvider handles fetching and filtering

## Request:
1. Create a NEW section for ALL video podcasts (not just featured)
2. Use same design/style as featured section (horizontal cards)
3. Plan to remove/refactor podcast_provider.dart

## Analysis:
- Video podcasts are fetched via PodcastProvider
- Currently only showing "featured" (top by plays)
- Need a section showing ALL video podcasts
- Can reuse same ContentSection widget with horizontal layout

## Implementation:
1. Add new "Video Podcasts" section showing ALL video podcasts
2. Keep existing "Video Podcasts" section (featured) OR replace it?
3. Simplify PodcastProvider logic if needed

## Questions:
- Should we keep both "Featured Video Podcasts" and "All Video Podcasts"?
- Or replace "Video Podcasts" section to show ALL instead of just featured?
- What does "remove podcast provider file" mean? Refactor? Move logic?

