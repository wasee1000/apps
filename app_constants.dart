class AppConstants {
  // App Information
  static const String appName = 'Indian TV Streaming';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Premium Indian TV serials and shows';
  
  // Supabase Configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Storage Buckets
  static const String videosBucket = 'videos';
  static const String thumbnailsBucket = 'thumbnails';
  static const String avatarsBucket = 'avatars';
  
  // API Endpoints
  static const String baseApiUrl = 'YOUR_SUPABASE_URL/rest/v1';
  
  // Subscription Plans
  static const Map<String, dynamic> subscriptionPlans = {
    'free': {
      'name': 'Free',
      'price': 0,
      'currency': 'INR',
      'features': [
        'Limited episodes access',
        'Ad-supported viewing',
        'Standard definition (480p)',
        'Basic recommendations',
      ],
    },
    'premium': {
      'name': 'Premium',
      'price': 299,
      'currency': 'INR',
      'duration': 'month',
      'features': [
        'Unlimited access to all content',
        'Ad-free experience',
        'HD streaming (1080p)',
        'Offline downloads (up to 10 episodes)',
        'Advanced recommendations',
        'Early access to new episodes',
      ],
    },
    'trial': {
      'name': '7-Day Free Trial',
      'price': 0,
      'currency': 'INR',
      'duration': '7 days',
      'features': [
        'Full premium features',
        'Unlimited access',
        'HD streaming',
        'Offline downloads',
        'No ads',
      ],
    },
  };
  
  // Video Quality Options
  static const List<Map<String, dynamic>> videoQualities = [
    {'label': 'Auto', 'value': 'auto'},
    {'label': '1080p HD', 'value': '1080p'},
    {'label': '720p HD', 'value': '720p'},
    {'label': '480p', 'value': '480p'},
    {'label': '360p', 'value': '360p'},
  ];
  
  // Content Categories
  static const List<Map<String, String>> contentCategories = [
    {'id': 'drama', 'name': 'Drama', 'icon': '🎭'},
    {'id': 'comedy', 'name': 'Comedy', 'icon': '😄'},
    {'id': 'romance', 'name': 'Romance', 'icon': '💕'},
    {'id': 'mythology', 'name': 'Mythology', 'icon': '🕉️'},
    {'id': 'reality', 'name': 'Reality', 'icon': '📺'},
  ];
  
  // Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
  ];
  
  // App Settings
  static const int maxDownloads = 10;
  static const int downloadExpiryDays = 30;
  static const int watchHistoryLimit = 100;
  static const int searchHistoryLimit = 20;
  
  // Network Settings
  static const int connectionTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;
  
  // Cache Settings
  static const int imageCacheMaxAge = 7; // days
  static const int videoCacheMaxAge = 1; // days
  static const int apiCacheMaxAge = 5; // minutes
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  
  // Video Player Settings
  static const int bufferDuration = 30; // seconds
  static const int maxBufferDuration = 60; // seconds
  static const double playbackSpeed = 1.0;
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  
  // Notification Settings
  static const String notificationChannelId = 'indian_tv_streaming';
  static const String notificationChannelName = 'Indian TV Streaming';
  static const String notificationChannelDescription = 'Notifications for new episodes and updates';
  
  // Analytics Events
  static const String eventVideoPlay = 'video_play';
  static const String eventVideoPause = 'video_pause';
  static const String eventVideoComplete = 'video_complete';
  static const String eventVideoSeek = 'video_seek';
  static const String eventVideoQualityChange = 'video_quality_change';
  static const String eventSubscriptionUpgrade = 'subscription_upgrade';
  static const String eventTrialActivated = 'trial_activated';
  static const String eventContentSearch = 'content_search';
  static const String eventContentView = 'content_view';
  static const String eventDownloadStart = 'download_start';
  static const String eventDownloadComplete = 'download_complete';
  
  // Error Messages
  static const String errorNetworkConnection = 'Please check your internet connection';
  static const String errorVideoPlayback = 'Unable to play video. Please try again';
  static const String errorSubscriptionRequired = 'Premium subscription required to access this content';
  static const String errorTrialExpired = 'Your free trial has expired. Upgrade to premium to continue';
  static const String errorDownloadFailed = 'Download failed. Please try again';
  static const String errorUploadFailed = 'Upload failed. Please try again';
  static const String errorGeneric = 'Something went wrong. Please try again';
  
  // Success Messages
  static const String successTrialActivated = 'Free trial activated successfully!';
  static const String successSubscriptionUpgraded = 'Subscription upgraded successfully!';
  static const String successDownloadComplete = 'Download completed successfully';
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successPasswordChanged = 'Password changed successfully';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxReviewLength = 1000;
  
  // File Size Limits
  static const int maxVideoSizeMB = 500;
  static const int maxImageSizeMB = 10;
  static const int maxAvatarSizeMB = 5;
  
  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^[+]?[0-9]{10,15}$';
  static const String passwordRegex = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$';
  
  // Social Media Links
  static const String facebookUrl = 'https://facebook.com/indiantvstreaming';
  static const String twitterUrl = 'https://twitter.com/indiantvstreaming';
  static const String instagramUrl = 'https://instagram.com/indiantvstreaming';
  static const String youtubeUrl = 'https://youtube.com/indiantvstreaming';
  
  // Legal Links
  static const String privacyPolicyUrl = 'https://indiantvstreaming.com/privacy';
  static const String termsOfServiceUrl = 'https://indiantvstreaming.com/terms';
  static const String supportUrl = 'https://indiantvstreaming.com/support';
  static const String contactEmail = 'support@indiantvstreaming.com';
  
  // App Store Links
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.indiantvstreaming.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/indian-tv-streaming/id123456789';
  
  // Feature Flags
  static const bool enableOfflineDownloads = true;
  static const bool enablePushNotifications = true;
  static const bool enableSocialSharing = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableBiometricAuth = true;
  static const bool enableDarkMode = true;
  
  // Development Settings
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableNetworkLogging = true;
  static const bool enablePerformanceMonitoring = true;
}

