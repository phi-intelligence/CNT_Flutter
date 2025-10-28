# Player Visibility Fix - No Longer Showing on All Pages

## Problem
The audio player was appearing on all pages even when no track was playing.

## Root Cause
The player was wrapped in a `Positioned` widget inside a `Consumer`, but the check for whether a track was playing happened inside the `SlidingAudioPlayer` widget itself. The `Positioned` wrapper was always created, even when empty.

## Solution
Added a check in the `Consumer` builder to return `SizedBox.shrink()` if there's no current track. This prevents the `Positioned` widget from being created when no track is playing.

## Changes Made

**File:** `test/frontend/lib/navigation/mobile_navigation.dart`

**Before:**
```dart
Consumer<AudioPlayerState>(
  builder: (context, audioPlayer, child) {
    final playerState = _playerKey.currentState;
    final isExpanded = audioPlayer.currentTrack != null && 
                     (playerState?.isExpanded ?? false);
    
    return Positioned(
      bottom: isExpanded ? 0 : 60,
      left: 0,
      right: 0,
      child: SlidingAudioPlayer(key: _playerKey),
    );
  },
),
```

**After:**
```dart
Consumer<AudioPlayerState>(
  builder: (context, audioPlayer, child) {
    // Only show if there's a current track
    if (audioPlayer.currentTrack == null) {
      return const SizedBox.shrink();
    }
    
    final playerState = _playerKey.currentState;
    final isExpanded = playerState?.isExpanded ?? false;
    
    return Positioned(
      bottom: isExpanded ? 0 : 60,
      left: 0,
      right: 0,
      child: SlidingAudioPlayer(key: _playerKey),
    );
  },
),
```

## Behavior Now

✅ Player only shows when a track is playing
✅ Player hidden on all pages when no track is active
✅ Player appears when user clicks a podcast
✅ Player stays visible across page navigation while track is playing
✅ Player disappears when track finishes or is cleared

