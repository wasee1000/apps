class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String interval; // 'month', 'year'
  final int intervalCount;
  final int trialPeriodDays;
  final List<String> features;
  final bool isPopular;
  final bool isActive;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.interval,
    required this.intervalCount,
    required this.trialPeriodDays,
    required this.features,
    required this.isPopular,
    required this.isActive,
    this.imageUrl,
    this.metadata,
  });

  // Factory constructor for free plan
  factory SubscriptionPlanModel.free() {
    return SubscriptionPlanModel(
      id: 'free',
      name: 'Free',
      description: 'Basic access with ads',
      price: 0,
      currency: 'INR',
      interval: 'month',
      intervalCount: 1,
      trialPeriodDays: 0,
      features: [
        'Access to free content',
        'Standard definition (SD) quality',
        'Watch on mobile devices',
        'Ad-supported viewing',
      ],
      isPopular: false,
      isActive: true,
      imageUrl: null,
      metadata: {
        'maxQuality': 'SD',
        'maxDevices': 1,
        'hasAds': true,
        'allowsDownloads': false,
      },
    );
  }

  // Factory constructor for premium plan
  factory SubscriptionPlanModel.premium() {
    return SubscriptionPlanModel(
      id: 'premium',
      name: 'Premium',
      description: 'Full access with no ads',
      price: 199,
      currency: 'INR',
      interval: 'month',
      intervalCount: 1,
      trialPeriodDays: 7,
      features: [
        'Access to all content including premium',
        'High definition (HD) quality',
        'Watch on all devices',
        'Ad-free viewing',
        'Download for offline viewing',
        'Unlimited streaming',
      ],
      isPopular: true,
      isActive: true,
      imageUrl: null,
      metadata: {
        'maxQuality': 'HD',
        'maxDevices': 3,
        'hasAds': false,
        'allowsDownloads': true,
      },
    );
  }

  // Factory constructor from JSON
  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      currency: json['currency'],
      interval: json['interval'],
      intervalCount: json['interval_count'],
      trialPeriodDays: json['trial_period_days'],
      features: List<String>.from(json['features']),
      isPopular: json['is_popular'],
      isActive: json['is_active'],
      imageUrl: json['image_url'],
      metadata: json['metadata'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'interval': interval,
      'interval_count': intervalCount,
      'trial_period_days': trialPeriodDays,
      'features': features,
      'is_popular': isPopular,
      'is_active': isActive,
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }

  // Get formatted price
  String get formattedPrice {
    if (price == 0) {
      return 'Free';
    }
    
    String symbol;
    switch (currency) {
      case 'INR':
        symbol = '₹';
        break;
      case 'USD':
        symbol = '\$';
        break;
      case 'EUR':
        symbol = '€';
        break;
      default:
        symbol = currency;
    }
    
    return '$symbol${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';
  }

  // Get formatted interval
  String get formattedInterval {
    if (price == 0) {
      return '';
    }
    
    String intervalText;
    switch (interval) {
      case 'day':
        intervalText = intervalCount == 1 ? 'day' : 'days';
        break;
      case 'week':
        intervalText = intervalCount == 1 ? 'week' : 'weeks';
        break;
      case 'month':
        intervalText = intervalCount == 1 ? 'month' : 'months';
        break;
      case 'year':
        intervalText = intervalCount == 1 ? 'year' : 'years';
        break;
      default:
        intervalText = interval;
    }
    
    return intervalCount == 1
        ? '/$intervalText'
        : '/${intervalCount} $intervalText';
  }

  // Get formatted price with interval
  String get formattedPriceWithInterval {
    if (price == 0) {
      return 'Free';
    }
    
    return '$formattedPrice$formattedInterval';
  }

  // Get trial period text
  String get trialPeriodText {
    if (trialPeriodDays == 0) {
      return '';
    }
    
    return trialPeriodDays == 1
        ? '1 day free trial'
        : '$trialPeriodDays days free trial';
  }

  // Check if plan allows downloads
  bool get allowsDownloads {
    if (metadata != null && metadata!.containsKey('allowsDownloads')) {
      return metadata!['allowsDownloads'];
    }
    return false;
  }

  // Check if plan has ads
  bool get hasAds {
    if (metadata != null && metadata!.containsKey('hasAds')) {
      return metadata!['hasAds'];
    }
    return true;
  }

  // Get max quality
  String get maxQuality {
    if (metadata != null && metadata!.containsKey('maxQuality')) {
      return metadata!['maxQuality'];
    }
    return 'SD';
  }

  // Get max devices
  int get maxDevices {
    if (metadata != null && metadata!.containsKey('maxDevices')) {
      return metadata!['maxDevices'];
    }
    return 1;
  }
}

