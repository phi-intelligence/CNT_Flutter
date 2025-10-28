# Plus Feature Implementation Plan

## Goal
Remove "Live" tab and implement "Plus/Create" tab with audio podcast, video podcast, and meeting features.

## Current State
- Flutter has Live tab (3rd tab in bottom navigation)
- React Native iOS has Plus/Create screen
- Need to replace Live with Plus functionality

## Changes Required

### 1. Navigation Update
**File:** `lib/navigation/mobile_navigation.dart`

Replace Live tab with Plus/Create tab:
- Change icon from `Icons.radio_rounded` to `Icons.add_circle_rounded`
- Change label from 'Live' to 'Create'
- Navigate to `CreateScreenMobile` instead of `LiveScreenMobile`

### 2. Create Plus/Main Screen
**File:** `lib/screens/mobile/create_screen_mobile.dart` (NEW)

Create modal popup screen with:
- Header: "Create Content" title + close button (X)
- 3 options in grid (2 columns, 48% width each):
  1. Video Podcast (videocam icon, primary color)
  2. Audio Podcast (mic icon, accent color)
  3. Meeting (group icon, accent color)
- Each has circular icon (80x80), title, subtitle
- Tap navigates to respective create screen

### 3. Video Podcast Create
**File:** `lib/screens/creation/video_podcast_create_screen.dart` (NEW)

- Gradient background (primary to accent colors)
- Header with back button
- 2 large option cards:
  - "Record Video" → navigate to video recording
  - "Choose from Gallery" → file picker
- Glassmorphism styling

### 4. Audio Podcast Create  
**File:** `lib/screens/creation/audio_podcast_create_screen.dart` (NEW)

- Same gradient background
- Header with back button
- 2 large option cards:
  - "Record Audio" → navigate to audio recording
  - "Upload Audio" → file picker
- Same glassmorphism styling

### 5. Video Recording (Already exists)
**File:** `lib/screens/creation/video_recording_screen.dart`

Complete the implementation:
- Camera view (full screen)
- Recording controls (start/stop)
- Timer display
- Switch camera button
- Flash toggle
- Navigate to preview on stop

### 6. Audio Recording (Already exists)
**File:** `lib/screens/creation/audio_recording_screen.dart`

Complete the implementation:
- Large record button
- Timer display
- Audio level visualization
- Controls: Record, Pause, Resume, Stop
- Navigate to preview on stop

### 7. Meeting Options
**File:** `lib/screens/mobile/meeting_options_screen_mobile.dart` (NEW)

- Header with back button
- 3 option cards (same style as Plus screen):
  - "Instant Meeting"
  - "Schedule Meeting"
  - "Join Meeting"
- Navigate to respective meeting screens

## Implementation Steps

### Step 1: Update Navigation (15 min)
1. Modify `mobile_navigation.dart` to replace Live with Create
2. Update icon and label
3. Test navigation works

### Step 2: Create Plus Screen (30 min)
1. Create `create_screen_mobile.dart`
2. Implement 3 option cards with icons
3. Add navigation to create screens
4. Test UI matches React Native

### Step 3: Create Video Podcast Flow (45 min)
1. Create `video_podcast_create_screen.dart`
2. Implement gradient background
3. Add 2 option cards (record/gallery)
4. Add navigation to video recording

### Step 4: Create Audio Podcast Flow (45 min)
1. Create `audio_podcast_create_screen.dart`
2. Implement gradient background
3. Add 2 option cards (record/upload)
4. Add navigation to audio recording

### Step 5: Complete Recording Screens (60 min each)
1. Complete video recording screen
2. Complete audio recording screen
3. Add camera/audio permissions
4. Add preview functionality

### Step 6: Meeting Options (30 min)
1. Create `meeting_options_screen_mobile.dart`
2. Implement 3 option cards
3. Add navigation to meeting screens

## Estimated Time
- Total: ~4 hours
- Main UI: 1.5 hours (Plus screen + create screens)
- Recording screens: 2 hours
- Meeting: 30 minutes

## Priority Order
1. ✅ Navigation update (replace Live with Create)
2. ✅ Plus screen (main entry point)
3. ✅ Video/Audio create screens
4. ⏳ Recording screens (if needed)
5. ⏳ Meeting options

## Notes
- Focus on UI matching React Native exactly
- Use existing theme colors and spacing
- Gradient backgrounds for create screens
- Glassmorphism for cards
- Navigation flow should be smooth

