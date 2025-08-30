class PopularContentModel {
  final String id;
  final String title;
  final String type; // 'show' or 'episode'
  final String? thumbnailUrl;
  final int views;
  final int likes;
  final int downloads;
  final double completionRate;
  final int uniqueViewers;
  final Map<String, dynamic>? analytics;

  PopularContentModel({
    required this.id,
    required this.title,
    required this.type,
    this.thumbnailUrl,
    required this.views,
    required this.likes,
    required this.downloads,
    required this.completionRate,
    required this.uniqueViewers,
    this.analytics,
  });

  factory PopularContentModel.fromJson(Map<String, dynamic> json) {
    return PopularContentModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      thumbnailUrl: json['thumbnail_url'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      downloads: json['downloads'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
      uniqueViewers: json['unique_viewers'] ?? 0,
      analytics: json['analytics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'thumbnail_url': thumbnailUrl,
      'views': views,
      'likes': likes,
      'downloads': downloads,
      'completion_rate': completionRate,
      'unique_viewers': uniqueViewers,
      'analytics': analytics,
    };
  }

  // Get formatted completion rate
  String get formattedCompletionRate {
    return '${(completionRate * 100).toStringAsFixed(1)}%';
  }

  // Get engagement score
  double get engagementScore {
    if (views == 0) return 0;
    
    // Calculate engagement score based on likes, downloads, and completion rate
    final likeRatio = views > 0 ? likes / views : 0;
    final downloadRatio = views > 0 ? downloads / views : 0;
    
    return (likeRatio * 0.3) + (downloadRatio * 0.3) + (completionRate * 0.4);
  }

  // Get formatted engagement score
  String get formattedEngagementScore {
    return '${(engagementScore * 100).toStringAsFixed(1)}%';
  }

  // Get content type display name
  String get typeDisplayName {
    switch (type) {
      case 'show':
        return 'Show';
      case 'episode':
        return 'Episode';
      default:
        return type;
    }
  }
}

