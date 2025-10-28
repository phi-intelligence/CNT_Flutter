# Plus Feature - Complete Flutter Implementation Plan

## React Native iOS App Structure Analysis

### Bottom Navigation (5 tabs):
1. **Home**
2. **Search**  
3. **Live**
4. **Community**
5. **Profile**

**Current Flutter Status:** Using "Live" tab but user wants "Plus/Create" tab instead

### React Native "Plus" Feature Flow:

```
PlusScreen (Modal/Popup)
├── Video Podcast → VideoPodcastCreateScreen → VideoRecordingScreen → VideoPreviewScreen → VideoEditorScreen
├── Audio Podcast → AudioPodcastCreateScreen → AudioRecordingScreen → AudioPreviewScreen → AudioEditorScreen
└── Meeting → MeetingOptionsScreen → MeetingCreatedScreen/MeetingRoomScreen
```

---

## Files to Create/Modify in Flutter:

### 1. PlusScreen Mobile (Main Entry Point)
**File:** `lib/screens/mobile/create_screen_mobile.dart`

**Features:**
- Header: "Create Content" title + close button
- 3 option cards in 2-column grid (48% width each):
  - **Video Podcast** (videocam icon, primary color)
  - **Audio Podcast** (mic icon, accent color)  
  - **Meeting** (group icon, accent color)
- Circle icons (80x80, rounded with shadows)
- Subtitles: "Create video content", "Record audio content", "Start video meeting"
- Navigation to respective create screens

**Navigation:** Closes modal, navigates to VideoPodcastCreate, AudioPodcastCreate, or MeetingOptions

---

### 2. Video Podcast Create Screen
**File:** `lib/screens/creation/video_podcast_create_screen.dart`

**Features:**
- LinearGradient background (primary to accent)
- Header with back button + "Create Video Podcast" title
- 2 option cards:
  - **Record Video** (videocam icon, white semi-transparent card)
  - **Choose from Gallery** (photo-library icon, white semi-transparent card)
- Glassmorphism styling (rgba white 0.15, border rgba white 0.2)
- Rounded icons (70x70, white bg)
- Navigation to VideoRecordingScreen or file picker

---

### 3. Audio Podcast Create Screen  
**File:** `lib/screens/creation/audio_podcast_create_screen.dart`

**Features:**
- Same gradient background
- Header with back button + "Create Audio Podcast" title
- 2 option cards:
  - **Record Audio** (mic icon, 48px)
  - **Upload Audio** (audiotrack icon, 48px)
- Same glassmorphism styling
- Loading overlay when uploading
- Navigation to AudioRecordingScreen or file picker

---

### 4. Video Recording Screen
**File:** `lib/screens/creation/video_recording_screen.dart`

**Features:**
- Full-screen camera view (react-native-vision-camera style)
- Header: Live recording indicator (red dot), timer display
- Bottom controls:
  - Stop/Start recording button (large circular)
  - Flash toggle
  - Switch camera (front/back)
- Permission handling
- Navigation to VideoPreviewScreen on stop

**Note:** Uses `camera` package, needs camera permission

---

### 5. Audio Recording Screen
**File:** `lib/screens/creation/audio_recording_screen.dart`

**Features:**
- Full-screen gradient background
- Large circular record button (48x48, accent color)
- Recording controls: Record, Pause, Resume, Stop
- Timer display (MM:SS format)
- Audio level visualization
- File size display
- Navigation to AudioPreviewScreen on stop

**Note:** Uses audio recording packages, needs microphone permission

---

### 6. Video Preview Screen
**File:** `lib/screens/creation/video_preview_screen.dart` (Already exists but incomplete)

**Features:**
- Preview video thumbnail
- Duration, file size display
- Edit button → VideoEditorScreen
- Publish button
- Delete button

---

### 7. Audio Preview Screen
**File:** `lib/screens/creation/audio_preview_screen.dart` (Already exists but incomplete)

**Features:**
- Preview audio waveform
- Duration, file size display
- Edit button → AudioEditorScreen
- Publish button
- Delete button

---

### 8. Meeting Options Screen
**File:** `lib/screens/mobile/meeting_options_screen_mobile.dart`

**Features:**
- Header: Back button + "Meeting Options" title
- 3 option cards (48% width, 2-column grid):
  - **Instant Meeting** (video-call icon, primary color)
  - **Schedule Meeting** (schedule icon, accent color)
  - **Join Meeting** (login icon, secondary color)
- Navigation to MeetingCreatedScreen, ScheduleMeetingScreen, or JoinMeetingScreen

---

### 9. Replace Live Tab with Plus Tab
**File:** `lib/navigation/mobile_navigation.dart`

**Changes:**
- Replace Live tab with Plus/Create tab
- Icon: `Icons.add_circle` or `Icons.add`
- Label: "Create"
- Navigate to PlusScreen

---

## Implementation Steps:

### Phase 1: Replace Live with Plus
1. Update `mobile_navigation.dart` - replace Live with Plus/Create tab
2. Create `create_screen_mobile.dart` - main Plus screen

### Phase 2: Video Podcast Flow
3. Create `video_podcast_create_screen.dart`
4. Create `video_recording_screen.dart`
5. Complete `video_preview_screen.dart`
6. Create `video_editor_screen.dart` (if needed)

### Phase 3: Audio Podcast Flow
7. Create `audio_podcast_create_screen.dart`
8. Create `audio_recording_screen.dart`
9. Complete `audio_preview_screen.dart`
10. Create `audio_editor_screen.dart` (if needed)

### Phase 4: Meeting Flow
11. Create `meeting_options_screen_mobile.dart`
12. Create `meeting_created_screen_mobile.dart` (if needed)
13. Handle meeting navigation

---

## Packages Needed:
- `camera` - Camera access for video recording
- `permission_handler` - Camera and microphone permissions
- `image_picker` - Gallery selection
- `file_picker` - Audio file selection
- Audio recording: Use Flutter's built-in recording or `record` package

---

## Current Status:

**Missing:**
- Plus/Create screen (instead of Live)
- Video podcast create/recording screens
- Audio podcast create/recording screens
- Meeting options screen

**Exists (but incomplete):**
- `video_preview_screen.dart`
- `audio_preview_screen.dart`
- `video_recording_screen.dart`
- `audio_recording_screen.dart`

**Action:** User wants PLUS/CREATE functionality, NOT Live streams!

