# Navbar Visibility Fix

## Problem
The bottom navigation bar was not visible when the player was in compact mode. It was only showing when no track was playing.

## Solution
Updated the visibility logic to show/hide navbar based on player state:
- **Hide navbar** when player is FULL SCREEN (expanded)
- **Show navbar** when player is MINIMIZED (compact)
- **Show navbar** when no track is playing

## Changes Made

**File:** `test/frontend/lib/navigation/mobile_navigation.dart`

**Before:**
```dart
final shouldShowNav = audioPlayer.currentTrack == null;
```

**After:**
```dart
final playerState = _playerKey.currentState;

// Show navbar if:
// 1. No track playing, OR
// 2. Track playing but player is minimized (not expanded)
final shouldShowNav = audioPlayer.currentTrack == null || 
                      (playerState != null && !playerState.isExpanded);
```

## Behavior

### When Player is Full Screen:
- Navbar: HIDDEN
- Player: Takes full screen

### When Player is Minimized:
- Navbar: VISIBLE
- Player: 80px compact view above navbar

### When No Track Playing:
- Navbar: VISIBLE
- Player: Not shown

## Testing
Run the app and verify:
1. Click podcast → full screen player (navbar hidden)
2. Minimize player → navbar appears
3. Expand player again → navbar disappears
4. Close player → navbar visible

