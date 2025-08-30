import 'activity_model.dart';
import 'popular_content_model.dart';

class AdminDashboardModel {
  final String adminName;
  final int totalShows;
  final int totalEpisodes;
  final int totalUsers;
  final int totalSubscribers;
  final int activeUsers;
  final int newUsersToday;
  final int viewsToday;
  final double revenueToday;
  final List<ActivityModel> recentActivities;
  final List<PopularContentModel> popularContent;
  final Map<String, dynamic> analytics;

  AdminDashboardModel({
    required this.adminName,
    required this.totalShows,
    required this.totalEpisodes,
    required this.totalUsers,
    required this.totalSubscribers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.viewsToday,
    required this.revenueToday,
    required this.recentActivities,
    required this.popularContent,
    required this.analytics,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardModel(
      adminName: json['admin_name'] ?? 'Admin',
      totalShows: json['total_shows'] ?? 0,
      totalEpisodes: json['total_episodes'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
      totalSubscribers: json['total_subscribers'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      newUsersToday: json['new_users_today'] ?? 0,
      viewsToday: json['views_today'] ?? 0,
      revenueToday: (json['revenue_today'] ?? 0).toDouble(),
      recentActivities: (json['recent_activities'] as List?)
          ?.map((activity) => ActivityModel.fromJson(activity))
          .toList() ?? [],
      popularContent: (json['popular_content'] as List?)
          ?.map((content) => PopularContentModel.fromJson(content))
          .toList() ?? [],
      analytics: json['analytics'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_name': adminName,
      'total_shows': totalShows,
      'total_episodes': totalEpisodes,
      'total_users': totalUsers,
      'total_subscribers': totalSubscribers,
      'active_users': activeUsers,
      'new_users_today': newUsersToday,
      'views_today': viewsToday,
      'revenue_today': revenueToday,
      'recent_activities': recentActivities.map((activity) => activity.toJson()).toList(),
      'popular_content': popularContent.map((content) => content.toJson()).toList(),
      'analytics': analytics,
    };
  }

  // Get formatted revenue
  String get formattedRevenue {
    return '₹${revenueToday.toStringAsFixed(2)}';
  }

  // Get user growth percentage
  double get userGrowthPercentage {
    if (totalUsers == 0) return 0;
    return (newUsersToday / totalUsers) * 100;
  }

  // Get subscriber percentage
  double get subscriberPercentage {
    if (totalUsers == 0) return 0;
    return (totalSubscribers / totalUsers) * 100;
  }

  // Get active users percentage
  double get activeUsersPercentage {
    if (totalUsers == 0) return 0;
    return (activeUsers / totalUsers) * 100;
  }
}

