# Backend Integration Plan - Audio Files & Podcasts

## Current Backend API Endpoints

### 1. Podcasts API (`/api/v1/podcasts`)
- `GET /api/v1/podcasts/` - List all podcasts
  - Query params: `skip`, `limit` (default: 100)
  - Returns: `List[PodcastResponse]`
  
- `GET /api/v1/podcasts/{podcast_id}` - Get specific podcast
  - Returns: `PodcastResponse`

- `POST /api/v1/podcasts/` - Create podcast
- `DELETE /api/v1/podcasts/{podcast_id}` - Delete podcast

### 2. Music API (`/api/v1/music`)
- `GET /api/v1/music/tracks` - List music tracks
  - Query params: `skip`, `limit`, `genre`, `artist`
  - Returns: `List[MusicTrackResponse]`

- `GET /api/v1/music/tracks/{track_id}` - Get specific track

### 3. Static Media Files
- `GET /media/audio/*.mp3` - Access audio files
- `GET /media/images/*` - Access images
- `GET /media/video/*` - Access videos

### Podcast Data Model
```python
{
  "id": int,
  "title": str,
  "description": Optional[str],
  "audio_url": Optional[str],      # Path to audio file
  "video_url": Optional[str],       # Path to video file
  "cover_image": Optional[str],     # Path to cover image
  "creator_id": Optional[int],
  "category_id": Optional[int],
  "duration": Optional[int],        # Duration in seconds
  "status": str,                    # "pending", "approved", "rejected"
  "plays_count": int,
  "created_at": datetime
}
```

### Current Audio Files Available
Located in: `test/backend/media/audio/`
- 30+ Beyond Belief podcast episodes
- MP3 format
- Filenames: BeyondBelief-YYYYMMDD-Title.mp3

## Implementation Plan

### Phase 1: Create API Service Layer

**File:** `lib/services/api_service.dart`

**Requirements:**
1. Create `ApiService` class with:
   - Base URL configuration
   - HTTP client (using `dio` or `http`)
   - GET methods for podcasts and music
   - Error handling
   - Response parsing

2. Endpoints to implement:
   - `getPodcasts(skip, limit)` - Fetch podcasts list
   - `getPodcast(id)` - Fetch single podcast
   - `getMusicTracks(skip, limit, genre, artist)` - Fetch music
   - `getMediaUrl(path)` - Construct full media URL

3. Models:
   - `Podcast` model matching backend schema
   - `MusicTrack` model
   - Convert API response to Flutter models

### Phase 2: Update Providers

**Files to update:**
- `lib/providers/podcast_provider.dart`
- `lib/providers/music_provider.dart`

**Changes needed:**
1. Replace mock data with API calls
2. Implement `fetchPodcasts()` using ApiService
3. Implement `fetchTracks()` using ApiService
4. Parse and store real data from backend
5. Handle loading and error states
6. Cache recently played data locally

### Phase 3: Implement Audio Player

**File:** `lib/providers/audio_player_provider.dart` (already exists)

**Updates needed:**
1. Connect to real audio URLs from backend
2. Implement playback controls (play, pause, seek)
3. Track playing state
4. Save recently played items
5. Handle media metadata (title, artist, duration)
6. Background playback support

### Phase 4: Update Homepage Sections

**File:** `lib/screens/mobile/home_screen_mobile.dart`

**Sections to populate with real data:**
1. **Featured Podcasts** - Fetch featured/approved podcasts
2. **Recently Played** - Load from local storage
3. **New Podcasts** - Fetch latest podcasts by created_at
4. **Featured Music** - Fetch music tracks

### Phase 5: Implement Media Player

**File:** Need to create or update audio player screen

**Requirements:**
1. Full-screen audio player
2. Play/pause controls
3. Seek bar
4. Time display
5. Volume control
6. Media metadata display
7. Next/Previous track
8. Progress indicator

## Detailed Implementation Steps

### Step 1: Create API Service

```dart
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
  // For real device: 'http://YOUR_SERVER_IP:8000/api/v1'
  
  static Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  
  // Get podcasts
  static Future<List<Podcast>> getPodcasts({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _dio.get('/podcasts/', queryParameters: {
        'skip': skip,
        'limit': limit,
      });
      // Parse response
    } catch (e) {
      // Error handling
    }
  }
  
  // Get media URL
  static String getMediaUrl(String path) {
    return 'http://10.0.2.2:8000/media/$path';
  }
}
```

### Step 2: Create Backend Models

```dart
class Podcast {
  final int id;
  final String title;
  final String? description;
  final String? audioUrl;
  final String? videoUrl;
  final String? coverImage;
  final int? creatorId;
  final int? categoryId;
  final int? duration; // seconds
  final String status;
  final int playsCount;
  final DateTime createdAt;
  
  // Constructor and fromJson
  factory Podcast.fromJson(Map<String, dynamic> json) => ...
}
```

### Step 3: Update Providers

```dart
class PodcastProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Future<void> fetchPodcasts() async {
    isLoading = true;
    notifyListeners();
    
    try {
      final data = await _apiService.getPodcasts(limit: 20);
      podcasts = data;
      featuredPodcasts = data.where((p) => p.status == 'approved').take(5).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

### Step 4: Implement Audio Player

```dart
class AudioPlayerProvider with ChangeNotifier {
  late AudioPlayer _audioPlayer;
  Podcast? _currentTrack;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  
  Future<void> playPodcast(Podcast podcast) async {
    try {
      final url = ApiService.getMediaUrl(podcast.audioUrl!);
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      
      _currentTrack = podcast;
      _isPlaying = true;
      notifyListeners();
      
      // Track recently played
      await _saveToRecentlyPlayed(podcast);
    } catch (e) {
      // Error handling
    }
  }
  
  void pause() {
    _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }
}
```

### Step 5: Update Homepage

```dart
// In home_screen_mobile.dart
Consumer<PodcastProvider>(
  builder: (context, provider, child) {
    if (provider.podcasts.isEmpty && !provider.isLoading) {
      return EmptyState(...);
    }
    
    return ContentSection(
      title: 'Featured',
      items: provider.featuredPodcasts.map((p) => ContentItem(
        id: p.id.toString(),
        title: p.title,
        subtitle: p.creator,
        imageUrl: p.coverImage != null 
          ? ApiService.getMediaUrl(p.coverImage!) 
          : null,
        // ... map podcast to ContentItem
      )).toList(),
      onItemPlay: (item) {
        final podcast = provider.podcasts.firstWhere(
          (p) => p.id.toString() == item.id
        );
        context.read<AudioPlayerProvider>().playPodcast(podcast);
      },
    );
  },
)
```

## Backend Server Setup

**Current Status:** FastAPI backend with SQLite database

**Access:**
- Base URL: `http://10.0.2.2:8000` (Android emulator)
- API Docs: `http://10.0.2.2:8000/docs`

**To Start Backend:**
```bash
cd test/backend
source venv/bin/activate
uvicorn app.main:app --reload
```

**Database:**
- SQLite file: `test/backend/cnt_db.sqlite`
- Check if podcasts are seeded in database

## Key Files to Create/Update

### New Files:
1. `lib/services/api_service.dart` - API integration layer
2. `lib/models/podcast_model.dart` - Podcast data model
3. `lib/models/music_track_model.dart` - Music track model

### Files to Update:
1. `lib/providers/podcast_provider.dart` - Add real API calls
2. `lib/providers/music_provider.dart` - Add real API calls
3. `lib/providers/audio_player_provider.dart` - Implement playback
4. `lib/screens/mobile/home_screen_mobile.dart` - Use real data
5. `lib/widgets/shared/content_section.dart` - Handle image loading

## Testing Steps

1. **Start Backend Server:**
   ```bash
   cd test/backend
   uvicorn app.main:app --reload
   ```

2. **Check Database:**
   ```bash
   sqlite3 cnt_db.sqlite
   SELECT * FROM podcasts;
   ```

3. **Test API:**
   ```bash
   curl http://localhost:8000/api/v1/podcasts/
   ```

4. **Test in Flutter:**
   - Build and run app
   - Check network tab for API calls
   - Verify images load
   - Test audio playback

## Known Issues to Address

1. **CORS:** Backend already configured for CORS
2. **Image Loading:** Use `cached_network_image` for thumbnails
3. **Audio Streaming:** Ensure audio URLs are accessible
4. **Offline Mode:** Cache data locally for offline access
5. **Error Handling:** Show user-friendly error messages
6. **Loading States:** Show shimmer loaders while fetching

## Success Criteria

✅ Homepage displays real podcasts from backend
✅ Featured, Recently Played, and New sections populated
✅ Audio files play correctly
✅ Images load from backend
✅ Recently played saved locally
✅ Smooth audio playback with controls
✅ Error handling for network issues

