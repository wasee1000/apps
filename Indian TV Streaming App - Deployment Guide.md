# Indian TV Streaming App - Deployment Guide

This guide provides instructions for deploying the Indian TV Streaming App to production environments.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Backend Deployment (Supabase)](#backend-deployment-supabase)
3. [Mobile App Deployment](#mobile-app-deployment)
   - [Android](#android)
   - [iOS](#ios)
4. [CI/CD Setup](#cicd-setup)
5. [Environment Configuration](#environment-configuration)
6. [Post-Deployment Verification](#post-deployment-verification)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying, ensure you have the following:

- Supabase account with a project created
- Google Play Developer account
- Apple Developer account
- GitHub repository with the project code
- Flutter SDK (version 3.10.0 or higher)
- Node.js (version 16 or higher)
- Supabase CLI installed
- GitHub Actions enabled on your repository

## Backend Deployment (Supabase)

### Initial Setup

1. Create a new Supabase project from the [Supabase Dashboard](https://app.supabase.io/)
2. Note your project URL and API keys (available in the API settings)

### Database Setup

1. Apply the database schema:

```bash
cd backend
supabase login
supabase link --project-ref <your-project-id>
supabase db push
```

2. Verify the tables are created correctly in the Supabase Dashboard

### Storage Setup

1. Create the following storage buckets in the Supabase Dashboard:
   - `videos` - For storing video files
   - `thumbnails` - For storing thumbnail images
   - `profile-images` - For storing user profile images

2. Configure the appropriate bucket policies:

```sql
-- For videos bucket
CREATE POLICY "Videos are publicly accessible" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'videos');

CREATE POLICY "Authenticated users can upload videos" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'videos' AND auth.role() = 'authenticated');

CREATE POLICY "Video owners can update their videos" 
ON storage.objects FOR UPDATE 
USING (bucket_id = 'videos' AND auth.uid() = owner);

CREATE POLICY "Video owners can delete their videos" 
ON storage.objects FOR DELETE 
USING (bucket_id = 'videos' AND auth.uid() = owner);

-- Similar policies for thumbnails and profile-images buckets
```

### Edge Functions Deployment

1. Deploy the edge functions:

```bash
cd backend/edge_functions
supabase functions deploy video-upload-handler
supabase functions deploy subscription-webhook
supabase functions deploy notification-sender
supabase functions deploy content-recommendation
```

2. Configure environment variables for the edge functions in the Supabase Dashboard

### Authentication Setup

1. Configure authentication providers in the Supabase Dashboard:
   - Enable Email/Password authentication
   - Configure password reset settings
   - Set up email templates for verification and password reset

2. Configure Row Level Security (RLS) policies:

```bash
cd backend
supabase db push --db-only
```

## Mobile App Deployment

### Android

#### Build Release APK

1. Update the version in `pubspec.yaml`
2. Create a keystore file for signing the app (if not already created)
3. Configure the signing in `android/app/build.gradle`
4. Build the release APK:

```bash
cd mobile_app
flutter build apk --release
```

5. The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

#### Build App Bundle for Play Store

```bash
cd mobile_app
flutter build appbundle --release
```

The AAB will be available at `build/app/outputs/bundle/release/app-release.aab`

#### Deploy to Play Store

1. Create a new app in the [Google Play Console](https://play.google.com/console)
2. Upload the AAB file
3. Fill in the store listing details
4. Set up pricing and distribution
5. Submit for review

### iOS

#### Build Release IPA

1. Update the version in `pubspec.yaml`
2. Configure signing in Xcode:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Set up your team and bundle identifier
   - Configure signing certificates

3. Build the release IPA:

```bash
cd mobile_app
flutter build ipa --release
```

4. The IPA will be available at `build/ios/ipa/`

#### Deploy to App Store

1. Create a new app in [App Store Connect](https://appstoreconnect.apple.com/)
2. Upload the IPA using Xcode or Transporter
3. Fill in the app information
4. Submit for review

## CI/CD Setup

The project includes a GitHub Actions workflow for CI/CD. To set it up:

1. Add the following secrets to your GitHub repository:
   - `SUPABASE_ACCESS_TOKEN` - Your Supabase access token
   - `SUPABASE_PROJECT_ID` - Your Supabase project ID
   - `PLAY_STORE_SERVICE_ACCOUNT_JSON` - Google Play service account JSON
   - `APPLE_ID` - Your Apple ID
   - `APP_STORE_CONNECT_API_KEY_ID` - App Store Connect API key ID
   - `APP_STORE_CONNECT_API_KEY_ISSUER_ID` - App Store Connect API key issuer ID
   - `APP_STORE_CONNECT_API_KEY_CONTENT` - App Store Connect API key content
   - `MATCH_PASSWORD` - Password for the match repository
   - `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` - Apple application-specific password
   - `SLACK_WEBHOOK` - Slack webhook URL for notifications

2. Push to the `main` branch to trigger the workflow

## Environment Configuration

### Production Environment

Create a `.env.production` file in the `mobile_app` directory:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_URL=https://your-project-id.supabase.co/rest/v1
STORAGE_URL=https://your-project-id.supabase.co/storage/v1
```

### Development Environment

Create a `.env.development` file in the `mobile_app` directory:

```
SUPABASE_URL=https://your-dev-project-id.supabase.co
SUPABASE_ANON_KEY=your-dev-anon-key
API_URL=https://your-dev-project-id.supabase.co/rest/v1
STORAGE_URL=https://your-dev-project-id.supabase.co/storage/v1
```

## Post-Deployment Verification

After deployment, perform the following checks:

1. **Authentication**:
   - Sign up with a new account
   - Sign in with existing credentials
   - Reset password flow
   - Social authentication (if configured)

2. **Content Browsing**:
   - Home screen loads correctly
   - Categories display properly
   - Show details page works
   - Video playback functions correctly

3. **Subscription**:
   - Free trial signup
   - Payment processing
   - Access to premium content
   - Subscription management

4. **Admin Panel**:
   - Video upload
   - Content management
   - User management
   - Analytics dashboard

5. **Performance**:
   - App startup time
   - Video loading time
   - Smooth scrolling and navigation
   - Memory usage

## Troubleshooting

### Common Issues

#### Backend Issues

1. **Database Migration Failures**:
   - Check the migration logs
   - Verify the SQL syntax
   - Ensure the tables don't already exist

2. **Edge Function Errors**:
   - Check the function logs in the Supabase Dashboard
   - Verify environment variables
   - Test the function locally using the Supabase CLI

3. **Storage Permission Issues**:
   - Review the bucket policies
   - Check the RLS policies
   - Verify user authentication

#### Mobile App Issues

1. **Build Failures**:
   - Check the Flutter version
   - Update dependencies
   - Clear the build cache: `flutter clean`

2. **Authentication Errors**:
   - Verify the Supabase URL and API key
   - Check network connectivity
   - Review authentication logs

3. **Video Playback Issues**:
   - Check the video URL format
   - Verify the video codec is supported
   - Test with different network conditions

### Support

For additional support:

- Create an issue in the GitHub repository
- Contact the development team at support@indiantvapp.com
- Check the [Supabase documentation](https://supabase.io/docs)
- Refer to the [Flutter documentation](https://flutter.dev/docs)

