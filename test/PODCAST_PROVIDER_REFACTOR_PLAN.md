# Podcast Provider Refactor Plan

## Current Usage:
1. `app_router.dart` - Provides PodcastProvider to app
2. `home_screen_mobile.dart` - Uses for podcasts and video podcasts
3. `podcasts_screen.dart` - Uses for podcast list screen
4. `podcasts_screen_mobile.dart` - Uses for mobile podcast screen
5. Potentially other screens

## Current Functionality:
- Fetches podcasts from API
- Separates audio vs video podcasts
- Provides featured, recent, video podcast lists
- Handles loading states

## Refactoring Options:

### Option 1: Move to Direct API Calls
- Remove PodcastProvider
- Call ApiService directly in screens
- Use StatefulWidget with setState for loading
- Pros: Simpler, less abstraction
- Cons: More code duplication, no shared state

### Option 2: Split into Audio/Video Providers
- Create AudioPodcastProvider
- Create VideoPodcastProvider  
- Each handles its own domain
- Pros: Better separation of concerns
- Cons: More providers to manage

### Option 3: Create ContentProvider
- Generic ContentProvider for all media
- Handles podcasts, music, videos
- Single source of truth
- Pros: Centralized state management
- Cons: More complex, larger provider

### Option 4: Use Riverpod (as already imported)
- Convert to Riverpod providers
- Better state management
- Pros: More powerful, better performance
- Cons: Migration effort

## Recommendation:
Start with Option 1 (Direct API calls) for simplicity, then consider Option 4 (Riverpod) for better state management if needed.

