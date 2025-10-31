# Instagram-like Community Page - Implementation Plan

## Overview
Transform the community page to have an Instagram-like UI with photo posts, 
like/dislike functionality, and proper user interactions.

## Backend Changes

### 1. Database Schema Updates
- Add `image_url` field to `CommunityPost` model
- Ensure user info (name, avatar) is included in responses
- Support for user avatars in posts

### 2. API Updates
- Update `CommunityPostResponse` to include:
  - `image_url` (optional)
  - `user_name` (from user relationship)
  - `user_avatar` (from user relationship)
  - `is_liked` (check if current user liked the post)

### 3. Seed Data (init_db.py)
- Create mock users (Samuel, Grace, etc.)
- Create community posts with images:
  - Use images from `frontend/assets/images/` folder
  - Reference as `images/thumbnail1.jpg`, etc.
  - Add mock captions and content
- Add mock likes to posts
- Add mock comments

## Frontend Changes

### 1. Create InstagramPostCard Widget
- Header section:
  - Circular profile picture
  - Username
  - Three dots menu (on right)
- Image section:
  - Full-width image with aspect ratio
  - Tap to view fullscreen (optional)
- Footer section:
  - Heart icon (like/dislike with animation)
  - Comment icon
  - Share icon
  - Bookmark icon (on right)
- Likes section:
  - "Liked by [username] and [N] others"
  - Small profile pictures of users who liked
- Caption section:
  - Username (bold) + caption text
  - Timestamp below

### 2. Update CommunityScreenMobile
- Replace current post cards with InstagramPostCard
- Keep category filter
- Add create post button (FAB or app bar)

### 3. Like/Dislike Functionality
- Toggle like on tap
- Show filled heart when liked
- Update likes count immediately
- Animate heart icon on like

## Theme Integration
- Use app theme colors (warm browns, cream backgrounds)
- Match Instagram layout but with app's aesthetic
- Dark text on light background

## Mock Data Structure
Posts will include:
- User name and avatar
- Image URL
- Caption/content
- Like count
- Comment count
- Timestamp
- Category

