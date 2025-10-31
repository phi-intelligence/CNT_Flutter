# Plan to Remove/Refactor PodcastProvider

## Current State:
- PodcastProvider is used in:
  1. `app_router.dart` - Provided to entire app
  2. `home_screen_mobile.dart` - Uses for podcasts/video podcasts display
  3. `podcasts_screen.dart` - Uses for podcast list screen
  4. `podcasts_screen_mobile.dart` - Uses for mobile podcast screen
  5. Potentially web screens

## Step-by-Step Removal Plan:

### Phase 1: Update Video Podcasts Section (DONE ✅)
- ✅ Changed "Video Podcasts" section to show ALL video podcasts (`videoPodcasts` instead of `featuredVideoPodcasts`)

### Phase 2: Replace with Direct API Calls
1. Update `home_screen_mobile.dart`:
   - Remove PodcastProvider dependency
   - Add local state for podcasts using StatefulWidget
   - Call ApiService.getPodcasts() directly
   - Filter audio/video in the widget itself

2. Update `podcasts_screen.dart`:
   - Replace PodcastProvider with direct API calls
   - Use StatefulWidget with setState

3. Update `podcasts_screen_mobile.dart`:
   - Same as above

4. Update `app_router.dart`:
   - Remove PodcastProvider from MultiProvider list

5. Delete `podcast_provider.dart`:
   - After all usages are replaced

### Alternative: Keep but Simplify
- If keeping provider is preferred, simplify it:
  - Remove featured/recent logic (do in UI)
  - Just fetch and separate audio/video
  - Let screens handle sorting/filtering

## Recommendation:
**Direct API Calls Approach** (Phase 2)
- Simpler architecture
- Less abstraction layers
- Easier to maintain
- Screens control their own data fetching

