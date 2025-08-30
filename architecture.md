# Indian TV Streaming App - System Architecture

## Overview
A comprehensive mobile streaming platform for Indian TV serials, daily soaps, and reality shows with admin management capabilities, subscription tiers, and modern UI/UX.

## Tech Stack

### Frontend (Mobile App)
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider/Riverpod
- **Video Player**: video_player / better_player
- **HTTP Client**: dio
- **Local Storage**: shared_preferences, hive
- **Authentication**: supabase_flutter
- **Push Notifications**: firebase_messaging

### Backend
- **BaaS**: Supabase
- **Database**: PostgreSQL (via Supabase)
- **Storage**: Supabase Storage
- **Authentication**: Supabase Auth
- **CDN**: Supabase CDN
- **Real-time**: Supabase Realtime

### Additional Services
- **Push Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics (optional)
- **Crash Reporting**: Firebase Crashlytics (optional)

## System Architecture

### High-Level Architecture
```
[Mobile App (Flutter)] <-> [Supabase Backend] <-> [PostgreSQL Database]
                                |
                                v
                        [Supabase Storage] <-> [CDN]
```

### Core Components

#### 1. Mobile Application (Flutter)
- **Authentication Module**: Login, signup, password reset
- **Content Browser**: Categories, search, recommendations
- **Video Player**: Streaming, offline playback, quality selection
- **User Management**: Profile, watchlist, favorites
- **Subscription**: Plan management, trial activation
- **Admin Panel**: Video upload/management (admin users only)

#### 2. Backend Services (Supabase)
- **Authentication Service**: User management, JWT tokens
- **Database Service**: Content metadata, user data, subscriptions
- **Storage Service**: Video files, thumbnails, user avatars
- **Real-time Service**: Live updates, notifications
- **Edge Functions**: Custom business logic, payment processing

## Database Schema

### Users Table
```sql
users (
  id: uuid (primary key)
  email: text (unique)
  full_name: text
  avatar_url: text
  subscription_plan: text (free, premium, trial)
  trial_start_date: timestamp
  trial_end_date: timestamp
  subscription_end_date: timestamp
  is_admin: boolean (default false)
  created_at: timestamp
  updated_at: timestamp
)
```

### Content Categories Table
```sql
categories (
  id: uuid (primary key)
  name: text (unique)
  description: text
  icon_url: text
  created_at: timestamp
)
```

### Shows Table
```sql
shows (
  id: uuid (primary key)
  title: text
  description: text
  thumbnail_url: text
  banner_url: text
  category_id: uuid (foreign key)
  genre: text[]
  language: text
  rating: decimal
  total_episodes: integer
  status: text (ongoing, completed, upcoming)
  created_at: timestamp
  updated_at: timestamp
)
```

### Episodes Table
```sql
episodes (
  id: uuid (primary key)
  show_id: uuid (foreign key)
  episode_number: integer
  title: text
  description: text
  thumbnail_url: text
  video_url: text
  duration: integer (seconds)
  is_premium: boolean (default false)
  is_trailer: boolean (default false)
  air_date: timestamp
  created_at: timestamp
  updated_at: timestamp
)
```

### User Watchlist Table
```sql
user_watchlist (
  id: uuid (primary key)
  user_id: uuid (foreign key)
  show_id: uuid (foreign key)
  added_at: timestamp
)
```

### User Favorites Table
```sql
user_favorites (
  id: uuid (primary key)
  user_id: uuid (foreign key)
  episode_id: uuid (foreign key)
  added_at: timestamp
)
```

### Watch History Table
```sql
watch_history (
  id: uuid (primary key)
  user_id: uuid (foreign key)
  episode_id: uuid (foreign key)
  watch_progress: integer (seconds)
  completed: boolean (default false)
  last_watched: timestamp
)
```

### Downloads Table
```sql
downloads (
  id: uuid (primary key)
  user_id: uuid (foreign key)
  episode_id: uuid (foreign key)
  download_path: text
  download_status: text (pending, completed, failed)
  downloaded_at: timestamp
  expires_at: timestamp
)
```

## Security & Access Control

### Row Level Security (RLS) Policies
- Users can only access their own data
- Premium content restricted based on subscription
- Admin users have elevated permissions
- Trial users have time-limited access

### Content Access Rules
- **Free Plan**: Limited episodes, ads, basic quality
- **Premium Plan**: All content, no ads, HD quality, downloads
- **Trial Plan**: Full access for 7 days, then reverts to free

## API Endpoints

### Authentication
- POST /auth/signup
- POST /auth/login
- POST /auth/logout
- POST /auth/reset-password

### Content
- GET /shows (with pagination, filtering)
- GET /shows/:id
- GET /shows/:id/episodes
- GET /episodes/:id
- GET /categories

### User Management
- GET /user/profile
- PUT /user/profile
- GET /user/watchlist
- POST /user/watchlist
- DELETE /user/watchlist/:id
- GET /user/favorites
- POST /user/favorites
- DELETE /user/favorites/:id
- GET /user/watch-history

### Subscription
- GET /subscription/plans
- POST /subscription/activate-trial
- POST /subscription/upgrade
- GET /subscription/status

### Admin (Admin users only)
- POST /admin/shows
- PUT /admin/shows/:id
- DELETE /admin/shows/:id
- POST /admin/episodes
- PUT /admin/episodes/:id
- DELETE /admin/episodes/:id
- POST /admin/upload-video

## Performance Considerations

### Video Streaming
- Adaptive bitrate streaming (HLS/DASH)
- CDN distribution for global reach
- Video compression and optimization
- Progressive download for offline viewing

### Mobile Optimization
- Lazy loading for content lists
- Image caching and optimization
- Efficient state management
- Background sync for downloads

### Database Optimization
- Proper indexing on frequently queried columns
- Connection pooling
- Query optimization
- Caching strategies

## Scalability

### Horizontal Scaling
- Supabase handles database scaling automatically
- CDN for global content distribution
- Edge functions for regional processing

### Performance Monitoring
- Real-time analytics
- Error tracking and reporting
- Performance metrics
- User behavior analytics

## Security Measures

### Data Protection
- JWT token authentication
- HTTPS/TLS encryption
- Input validation and sanitization
- SQL injection prevention

### Content Protection
- Signed URLs for video access
- Token-based video streaming
- DRM integration (future enhancement)
- Watermarking (future enhancement)

## Deployment Strategy

### Mobile App
- Flutter build for Android (APK/AAB)
- Flutter build for iOS (IPA)
- App Store and Play Store deployment

### Backend
- Supabase cloud hosting
- Environment-based configuration
- Automated backups
- Monitoring and alerting

