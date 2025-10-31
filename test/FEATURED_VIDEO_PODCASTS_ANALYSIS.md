# Featured Video Podcasts Issue Analysis

## Problem:
- UI shows "Video Podcasts" section (previously "Featured")
- But the logic still fetches/uses featured podcasts (audio podcasts sorted by plays)
- Need to ensure it properly shows VIDEO podcasts only

## Current Flow:
1. `PodcastProvider.fetchPodcasts()`:
   - Fetches all podcasts from API
   - Separates into `_podcasts` (audio only) and `_videoPodcasts` (video only)
   - Creates `_featuredVideoPodcasts` from `_videoPodcasts` sorted by plays

2. Issue: 
   - Filter logic `p.videoUrl != null` should work
   - But might be empty if no video podcasts exist
   - Or `getMediaUrl()` might return empty string for null values

## Solution:
1. Fix filtering to ensure video podcasts are correctly identified
2. Add debug logging to verify video podcasts are being found
3. Ensure `featuredVideoPodcasts` contains actual video podcasts
4. Maybe change to show all video podcasts (not just top 5 by plays)

