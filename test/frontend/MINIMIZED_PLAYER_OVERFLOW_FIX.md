# Minimized Player Overflow Fix

## Problem
The minimized player was causing a layout overflow error: "A RenderFlex overflowed by 298 pixels on the bottom."

## Root Cause
The minimized player had padding that was too large:
```dart
padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
```

This added:
- 8px top padding
- 8px bottom padding
- Total: 16px additional height

With the player fixed at 80px height, and a 64px image inside, plus the padding, it overflowed.

## Solution
Removed vertical padding and kept only horizontal padding:

**Before:**
```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
  child: Row(...)
)
```

**After:**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12.0),
  child: Row(...)
)
```

Now the player fits within the 80px height constraint without overflow.

## Player Structure
```
AnimatedContainer (height: 80)
  └── GestureDetector
      └── Container (padding: horizontal only)
          └── Row
              ├── Album Art (64x64)
              ├── Track Info (Expanded)
              ├── Previous Button
              ├── Play/Pause Button
              └── Next Button
```

## Status
✅ No overflow errors
✅ Player fits within 80px height
✅ Just above navbar with no gap
✅ All content visible

