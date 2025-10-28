# Backend Integration Implementation Summary

## Current Status

✅ **Backend Server:** Running on port 8000
- API Base URL: `http://10.0.2.2:8000/api/v1`
- Media Base URL: `http://10.0.2.2:8000`
- Database initialized with 28 podcasts from real audio files

✅ **Database:** SQLite with tables created
- podcasts table with 28 entries
- categories table (Sermons, Bible Study, Devotionals, Prayer, Worship, Gospel)
- users table with default admin

✅ **API Service:** Created (`lib/services/api_service.dart`)
- `getPodcasts()` - Fetch all podcasts
- `getPodcast(id)` - Fetch single podcast
- `getMusicTracks()` - Fetch music tracks
- `getFeaturedPodcasts()` - Get featured podcasts
- `getRecentPodcasts()` - Get recent podcasts
- `getMediaUrl(path)` - Construct full media URL

✅ **API Models:** Created (`lib/models/api_models.dart`)
- `Podcast` model matching backend schema
- `MusicTrack` model matching backend schema

## Next Steps (In Order)

### 1. Update PodcastProvider to use real API ✅ Ready
**File:** `lib/providers/podcast_provider.dart`

**Changes needed:**
```dart
Future<void> fetchPodcasts() async {
  _isLoading = true;
  _error = null;
  notifyListeners();
  
  try {
    // Get podcasts from API
    final podcasts = await _api.getPodcasts();
    
    // Convert Podcast models to ContentItem models
    _podcasts = podcasts.map((podcast) {
      return ContentItem(
        id: podcast.id.toString(),
        title: podcast.title,
        creator: 'Christ Tabernacle', // Could fetch from API
        description: podcast.description,
        coverImage: podcast.coverImage != null 
          ? _api.getMediaUrl(podcast.coverImage!) 
          : null,
        audioUrl: _api.getMediaUrl(podcast.audioUrl),
        duration: Duration(seconds: podcast.duration ?? 0),
        category: _getCategoryName(podcast.categoryId),
        plays: podcast.playsCount,
        createdAt: podcast.createdAt,
      );
    }).toList();
    
    // Get featured podcasts
    final featured = await _api.getFeaturedPodcasts();
    _featuredPodcasts = featured.take(5).map((podcast) {
      return ContentItem.fromPodcast(podcast, _api);
    }).toList();
    
    // Get recent podcasts
    final recent = await _api.getRecentPodcasts();
    _recentPodcasts = recent.take(5).map((podcast) {
      return ContentItem.fromPodcast(podcast, _api);
    }).toList();
    
  } catch (e) {
    _error = 'Failed to load podcasts: $e';
    print('Error fetching podcasts: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### 2. Add helper method to ContentItem
**File:** `lib/models/content_item.dart`

**Add:**
```dart
factory ContentItem.fromPodcast(Podcast podcast, ApiService api) {
  return ContentItem(
    id: podcast.id.toString(),
    title: podcast.title,
    creator: 'Christ Tabernacle',
    description: podcast.description,
    coverImage: podcast.coverImage != null 
      ? api.getMediaUrl(podcast.coverImage!) 
      : null,
    audioUrl: api.getMediaUrl(podcast.audioUrl),
    duration: Duration(seconds: podcast.duration ?? 0),
    category: _getCategoryName(podcast.categoryId),
    plays: podcast.playsCount,
    createdAt: podcast.createdAt,
  );
}

String _getCategoryName(int? categoryId) {
  switch (categoryId) {
    case 1: return 'Sermons';
    case 2: return 'Bible Study';
    case 3: return 'Devotionals';
    case 4: return 'Prayer';
    default: return 'podcast';
  }
}
```

### 3. Update MusicProvider similarly
**File:** `lib/providers/music_provider.dart`

Same pattern as PodcastProvider.

### 4. Implement Audio Player
**File:** `lib/providers/audio_player_provider.dart`

**Already exists but needs real implementation:**
```dart
Future<void> playContent(ContentItem item) async {
  if (item.audioUrl == null) return;
  
  try {
    await _player.setUrl(item.audioUrl!);
    _currentTrack = item;
    await _player.play();
    
    _isPlaying = true;
    notifyListeners();
    
    // Save to recently played
    await _saveToRecentlyPlayed(item);
  } catch (e) {
    print('Error playing audio: $e');
  }
}

void pause() {
  _player.pause();
  _isPlaying = false;
  notifyListeners();
}

void resume() {
  _player.play();
  _isPlaying = true;
  notifyListeners();
}
```

### 5. Update Homepage sections
**File:** `lib/screens/mobile/home_screen_mobile.dart`

The homepage already uses `PodcastProvider`, so once the provider is updated, the UI will automatically show real data.

**Current sections that will populate:**
- ✅ Featured Podcasts - Shows from `provider.featuredPodcasts`
- ✅ Recently Played - Shows from `provider.recentPodcasts`
- ✅ New Podcasts - Shows from `provider.podcasts`
- ✅ Featured Music - Shows from `MusicProvider`

### 6. Add HTTP Package
**File:** `pubspec.yaml`

Already has `http` package, so no changes needed.

### 7. Test the Integration

**Steps:**
1. Ensure backend is running: `cd test/backend && uvicorn app.main:app --reload`
2. Start Flutter app on emulator
3. Check network tab for API calls
4. Verify podcasts load on homepage
5. Test audio playback by clicking play button

## Expected Results

When complete, the homepage will show:
- **28 real podcasts** from the backend
- **Featured section** with top podcasts by plays
- **Recent section** with newest podcasts
- **Audio playback** working with real MP3 files
- **Images** (placeholder for now, can add later)
- **Metadata** (title, duration, plays count) from database

## Known Audio Files

Located in: `test/backend/media/audio/`

Available podcasts include:
- SpreadingTheWord
- MoreThanOneWife
- WhatsSoFunnyAboutFaith
- ReligionInTheTherapyRoom
- ReligiousFreedom
- AyodhyasRamMandirReligionAndPoliticsInIndia
- ArmourOfGod
- MonstersAndGods
- TheGiftOfTheGarden
- FaithfulFeet
- And 18 more...

## Testing Checklist

- [ ] Backend server running on port 8000
- [ ] Database has podcasts
- [ ] API returns JSON from `/api/v1/podcasts/`
- [ ] Flutter app fetches data
- [ ] Homepage displays podcasts
- [ ] Audio files are accessible via HTTP
- [ ] Play button works
- [ ] Duration and metadata display correctly
- [ ] Recently played saves locally
- [ ] Featured section shows top podcasts

