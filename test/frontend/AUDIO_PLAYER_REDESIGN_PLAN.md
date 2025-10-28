# Audio Player Redesign Plan

## Goal
Create a full-screen vinyl disc player that slides up from bottom when user clicks a podcast card, then can be minimized to a compact player above the navigation bar.

## Current State Analysis
- `SlidingAudioPlayer` widget exists but shows minimized by default
- It's positioned above bottom navigation bar
- Has expand/collapse functionality but not working as intended
- Overflow issues when expanded

## Required Changes

### 1. Full Screen Player (Default State When Track Starts)
**Behavior:**
- When user clicks play on a podcast card, the player should immediately slide up from bottom to full screen
- Show full vinyl disc animation in center
- All controls visible (play/pause, next, previous, shuffle, repeat, progress bar)
- Minimize button at top to collapse to compact view

**Components needed:**
- Use existing `AudioPlayerFullScreen` component or enhance `SlidingAudioPlayer`
- Add slide up animation
- Full screen takes 85-90% of screen height
- Shows above navbar when expanded

### 2. Minimized Player (Compact View Above NavBar)
**Behavior:**
- Shows when user clicks "minimize" from full screen
- Compact horizontal bar above bottom navigation
- Height: ~80-90px
- Shows: Thumbnail (left) → Title/Artist (center) → Play/Pause, Next, Previous buttons (right)
- Clicking minimized player expands it back to full screen

**Layout:**
```
┌───────────────────────────────────────┐
│ [Icon] Title - Artist    [⏮][▶][⏭]   │
└───────────────────────────────────────┘
┌───────────────────────────────────────┐
│     Bottom Navigation Bar             │
└───────────────────────────────────────┘
```

### 3. State Management
- Track `_isMinimized` boolean in `SlidingAudioPlayerState`
- Default to `false` (full screen) when track starts
- User can toggle between full screen and minimized
- Both states should persist across screen navigation

### 4. Animation Behavior
**Slide Up Animation:**
- When track starts playing → Slide up from bottom to full screen
- Duration: 300-400ms
- Curve: Curves.easeOutCubic (smooth start, gentle end)

**Minimize Animation:**
- When minimize button clicked → Slide down to compact view
- Duration: 300ms
- Curve: Curves.easeInOut

**Expand Animation:**
- When compact player clicked → Slide up to full screen
- Duration: 300ms
- Curve: Curves.easeInOut

### 5. Layout Structure
```
Scaffold
├── Body Stack
│   ├── Current Screen (Home, Search, etc.)
│   └── Positioned SlidingAudioPlayer
│       ├── If Minimized: Compact Player (80px height)
│       └── If Expanded: Full Screen (85% height)
└── Bottom Navigation Bar
```

### 6. Player Controls in Different States

**Full Screen Controls:**
- Back/M minimize button (top left)
- Donate/Menu buttons (top right)
- Vinyl disc in center
- Track info (title, artist, album)
- Progress slider with time
- Previous, Play/Pause, Next (large buttons)
- Shuffle, Repeat (smaller buttons)
- "Support Artist" button at bottom

**Minimized Player Controls:**
- Thumbnail (64x64, left)
- Title and Artist (ellipsis on overflow)
- Previous button
- Play/Pause button
- Next button
- Expand arrow (up arrow)

### 7. File Structure Changes
- Modify `sliding_audio_player.dart` to handle both states properly
- Remove overflow issues by using proper constraints
- Add gesture support to swipe down to minimize
- Add swipe up on minimized player to expand

### 8. Implementation Steps
1. Modify `SlidingAudioPlayer` to start in full screen mode (not minimized)
2. Add proper expand/collapse animation between states
3. Implement compact player layout with controls
4. Fix overflow issues with proper constraints
5. Add swipe gestures for better UX
6. Ensure player stays visible across different tabs
7. Test audio playback in both states
8. Ensure no layout conflicts with bottom navigation

### 9. Technical Considerations
- Use `AnimatedContainer` for smooth transitions
- Implement proper constraints for buttons in both states
- Use `SafeArea` for proper padding
- Handle keyboard and screen rotation
- Ensure vinyl disc rotates only when playing
- Sync play/pause state across both views

### 10. User Experience Flow
1. User clicks play button on podcast card
2. Player slides up to full screen with vinyl disc
3. Track starts playing immediately
4. User can tap minimize button to collapse
5. Player slides down to compact view above navbar
6. User can tap compact player to expand again
7. User can navigate between tabs and player stays visible
8. Player disappears when track ends or user closes it

## Next Steps
1. Review and approve this plan
2. Implement the changes step by step
3. Test on emulator
4. Refine based on feedback

