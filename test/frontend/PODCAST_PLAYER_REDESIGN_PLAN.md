# Podcast Player Redesign - Voice Bubble Animation

## Goal
Create a podcast player with a voice bubble animation that syncs with audio playback, sliding up from bottom to full screen, then can be minimized to compact view above navbar.

## Design Concept

### Full Screen Player (Default when track starts)
**Visual Elements:**
- Large voice bubble (animated circle) in center
- 5-bar sound visualization inside bubble (synced to audio)
- Pulsing wave animation around bubble (only when playing)
- Gradient background (podcast-themed colors)
- Track info (title, artist/podcast name, episode)
- Seek bar with time display
- Audio controls: play/pause, next, previous, shuffle, repeat
- Minimize button (top)

**Voice Bubble Animation:**
- Main circle: 200-250px diameter
- Sound bars: 5 animated bars inside bubble, pulse with audio
- Outer wave: Pulsing rings when audio is playing
- Microphone icon in center (only when paused)
- Active state: Bars animate continuously when playing
- Inactive state: Subtle idle animation when paused

### Compact Player (Minimized View)
**Layout (above navbar):**
```
┌───────────────────────────────────────────────┐
│ [Icon] Title - Podcast Name    [⏮][▶][⏭] ⬇ │
└───────────────────────────────────────────────┘
```
- Small thumbnail (left)
- Title and artist on single line (ellipsis)
- Previous, Play/Pause, Next buttons (right)
- Down arrow to expand (optional)

## Animation Behavior

### 1. Slide Up (Track Starts)
- Trigger: User clicks play on podcast card
- Action: Player slides up from bottom to full screen
- Duration: 300-400ms
- Curve: Curves.easeOutCubic
- Shows voice bubble animation immediately

### 2. Minimize (Full Screen → Compact)
- Trigger: User clicks minimize button
- Action: Player slides down to 80px compact view
- Duration: 300ms
- Curve: Curves.easeInOut
- Voice bubble shrinks to minimal display

### 3. Expand (Compact → Full Screen)
- Trigger: User taps compact player
- Action: Player expands to full screen
- Duration: 300ms
- Curve: Curves.easeInOut
- Voice bubble returns to large size

## Technical Implementation

### 1. Create Voice Bubble Player Widget
**File:** `test/frontend/lib/widgets/media/voice_bubble_player.dart`

**Components:**
- Main voice bubble circle (animated)
- 5-bar sound visualization (from existing VoiceBubble widget)
- Pulsing wave rings (when playing)
- Audio sync logic (pulse intensity based on audio state)

### 2. Update Sliding Audio Player
**File:** `test/frontend/lib/widgets/media/sliding_audio_player.dart`

**Changes:**
- Replace vinyl disc with voice bubble animation
- Add slide up animation on track start
- Add minimize/expand functionality
- Ensure no overflow issues
- Sync animations with `AudioPlayerState.isPlaying`

### 3. Animation States
```dart
enum PlayerState {
  hidden,      // Not shown (no track playing)
  slidingUp,   // Transitioning from bottom
  fullScreen,  // Full screen with voice bubble
  slidingDown, // Transitioning to compact
  minimized,   // Compact view above navbar
}
```

### 4. Voice Bubble Animation Logic
```dart
// When playing:
- Sound bars pulse continuously
- Outer wave rings expand/contract
- Bubble scales slightly (1.0 → 1.05)
- Microphone icon hidden

// When paused:
- Sound bars at idle state
- No outer wave animation
- Bubble scale returns to 1.0
- Microphone icon visible
```

## User Flow

1. **User clicks podcast play button**
   - Track loads in background
   - Player slides up from bottom (300ms animation)
   - Voice bubble appears and starts animating
   - Track begins playing

2. **Full screen player active**
   - Voice bubble pulses with audio
   - Sound bars animate
   - Play/pause controls functional
   - Seek bar shows progress
   - User can minimize or skip

3. **User clicks minimize**
   - Player slides down to compact view
   - Shows minimal controls above navbar
   - Audio continues playing
   - Voice bubble hidden but sound bars visible

4. **User taps compact player**
   - Player expands back to full screen
   - Voice bubble returns
   - All controls visible

5. **User clicks next/previous**
   - Voice bubble animates
   - New track info appears
   - Sound bars reset and start fresh

## Layout Structure

### Full Screen Layout
```
Scaffold
└── Stack
    ├── Gradient Background
    └── Column
        ├── Minimize Button
        ├── Voice Bubble (animated)
        ├── Track Info
        ├── Seek Bar
        ├── Controls (previous, play, next, etc.)
        └── Support Button
```

### Compact Player Layout
```
Container (80px height)
└── Row
    ├── Thumbnail (64x64)
    ├── Column (title, artist)
    ├── Previous Button
    ├── Play/Pause Button
    ├── Next Button
    └── Expand Button
```

## Voice Bubble Component
**Reuse from:** `test/frontend/lib/widgets/voice/voice_bubble.dart`

**Adaptations:**
- Increase size for player (200-250px vs 80px)
- Make sound bars larger and more visible
- Add audio-synced pulsing (react to audio intensity)
- Add outer wave rings (expand outward)
- Position microphone icon at center
- Start/stop animations based on `isPlaying`

## Files to Modify

1. **sliding_audio_player.dart**
   - Add voice bubble as main visual element
   - Replace vinyl disc references
   - Implement slide up/down animations
   - Add state management for player modes

2. **Create new voice bubble animation**
   - Enhance existing VoiceBubble widget
   - Add audio-reactive animations
   - Add wave rings for pulsing effect

3. **Update mobile_navigation.dart**
   - Ensure player sits above navbar
   - Handle different heights for states
   - No overflow issues

## Testing Checklist

- [ ] Slide up animation works smoothly
- [ ] Voice bubble animates when playing
- [ ] Sound bars pulse correctly
- [ ] Minimize button works
- [ ] Compact player displays correctly
- [ ] Expand from compact works
- [ ] No overflow errors
- [ ] Audio playback continues when minimized
- [ ] Next/previous buttons work
- [ ] Play/pause updates animations
- [ ] Seek bar functional

## Next Steps

1. Create/modify VoiceBubble component for player
2. Update SlidingAudioPlayer with voice bubble
3. Implement slide animations
4. Add minimize/expand functionality
5. Test and refine
6. Remove vinyl disc components

