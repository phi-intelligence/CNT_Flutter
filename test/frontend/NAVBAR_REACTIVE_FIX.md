# Navbar Visibility - Reactive Fix Implementation

## Problem
The bottom navigation bar was not updating when the player state changed. The navbar stayed hidden even when the player was minimized.

## Root Cause
The `Builder` widget in mobile_navigation.dart was only listening to `AudioPlayerState` changes, not to the player's expansion state. When the player minimized, the navbar didn't rebuild to show itself.

## Solution
Implemented a `ValueNotifier` pattern to make the navbar reactive to player state changes.

## Changes Made

### 1. SlidingAudioPlayerState (`sliding_audio_player.dart`)
- Added static `ValueNotifier<bool> expansionStateNotifier` to track expansion state
- Updated in `initState()` to set initial value
- Updated in `minimizePlayer()` when player is minimized
- Updated in `_toggleExpanded()` when user toggles expansion

### 2. MobileNavigationLayout (`mobile_navigation.dart`)
- Replaced direct state access with `ValueListenableBuilder`
- Listens to `SlidingAudioPlayerState.expansionStateNotifier`
- Automatically rebuilds navbar when player state changes

## How It Works

```dart
// In SlidingAudioPlayerState
static final ValueNotifier<bool> expansionStateNotifier = ValueNotifier<bool>(true);

// In minimize/expand methods
expansionStateNotifier.value = _isExpanded;

// In MobileNavigationLayout
return ValueListenableBuilder<bool>(
  valueListenable: SlidingAudioPlayerState.expansionStateNotifier,
  builder: (context, isExpanded, child) {
    final shouldShowNav = audioPlayer.currentTrack == null || !isExpanded;
    return shouldShowNav ? Container(...) : const SizedBox.shrink();
  },
);
```

## Behavior Now

1. **Track starts playing:**
   - Player expands to full screen
   - `expansionStateNotifier.value = true`
   - ValueListenableBuilder rebuilds
   - Navbar HIDDEN

2. **User minimizes player:**
   - `minimizePlayer()` called
   - `expansionStateNotifier.value = false`
   - ValueListenableBuilder rebuilds
   - Navbar VISIBLE

3. **User expands player again:**
   - `_toggleExpanded()` called
   - `expansionStateNotifier.value = true`
   - ValueListenableBuilder rebuilds
   - Navbar HIDDEN

## Testing
Run the app and verify:
✅ Click podcast → navbar hidden (full screen)
✅ Minimize player → navbar appears
✅ Expand player → navbar disappears again
✅ Multiple times should work smoothly

