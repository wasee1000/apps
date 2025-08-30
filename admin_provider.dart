import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/utils/exceptions.dart';
import '../models/admin_dashboard_model.dart';
import '../models/activity_model.dart';
import '../models/popular_content_model.dart';
import '../../auth/providers/auth_provider.dart';

// Admin Dashboard Provider
class AdminDashboardNotifier extends StateNotifier<AsyncValue<AdminDashboardModel>> {
  final SupabaseService _supabaseService;

  AdminDashboardNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadDashboardData() async {
    try {
      state = const AsyncValue.loading();
      final dashboardData = await _supabaseService.getAdminDashboardData();
      state = AsyncValue.data(dashboardData);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load dashboard data: ${e.toString()}');
    }
  }
}

final adminDashboardProvider = StateNotifierProvider<AdminDashboardNotifier, AsyncValue<AdminDashboardModel>>((ref) {
  final supabaseService = SupabaseService();
  return AdminDashboardNotifier(supabaseService);
});

// Admin Shows Provider
class AdminShowsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final SupabaseService _supabaseService;

  AdminShowsNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadShows() async {
    try {
      state = const AsyncValue.loading();
      final shows = await _supabaseService.getAdminShows();
      state = AsyncValue.data(shows);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load shows: ${e.toString()}');
    }
  }

  Future<void> createShow(Map<String, dynamic> showData) async {
    try {
      await _supabaseService.createShow(showData);
      await loadShows();
    } catch (e) {
      throw AdminException('Failed to create show: ${e.toString()}');
    }
  }

  Future<void> updateShow(String showId, Map<String, dynamic> showData) async {
    try {
      await _supabaseService.updateShow(showId, showData);
      await loadShows();
    } catch (e) {
      throw AdminException('Failed to update show: ${e.toString()}');
    }
  }

  Future<void> deleteShow(String showId) async {
    try {
      await _supabaseService.deleteShow(showId);
      await loadShows();
    } catch (e) {
      throw AdminException('Failed to delete show: ${e.toString()}');
    }
  }
}

final adminShowsProvider = StateNotifierProvider<AdminShowsNotifier, AsyncValue<List<dynamic>>>((ref) {
  final supabaseService = SupabaseService();
  return AdminShowsNotifier(supabaseService);
});

// Admin Episodes Provider
class AdminEpisodesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final SupabaseService _supabaseService;

  AdminEpisodesNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadEpisodes({String? showId}) async {
    try {
      state = const AsyncValue.loading();
      final episodes = await _supabaseService.getAdminEpisodes(showId: showId);
      state = AsyncValue.data(episodes);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load episodes: ${e.toString()}');
    }
  }

  Future<void> createEpisode(Map<String, dynamic> episodeData) async {
    try {
      await _supabaseService.createEpisode(episodeData);
      await loadEpisodes(showId: episodeData['show_id']);
    } catch (e) {
      throw AdminException('Failed to create episode: ${e.toString()}');
    }
  }

  Future<void> updateEpisode(String episodeId, Map<String, dynamic> episodeData) async {
    try {
      await _supabaseService.updateEpisode(episodeId, episodeData);
      await loadEpisodes(showId: episodeData['show_id']);
    } catch (e) {
      throw AdminException('Failed to update episode: ${e.toString()}');
    }
  }

  Future<void> deleteEpisode(String episodeId, String showId) async {
    try {
      await _supabaseService.deleteEpisode(episodeId);
      await loadEpisodes(showId: showId);
    } catch (e) {
      throw AdminException('Failed to delete episode: ${e.toString()}');
    }
  }
}

final adminEpisodesProvider = StateNotifierProvider<AdminEpisodesNotifier, AsyncValue<List<dynamic>>>((ref) {
  final supabaseService = SupabaseService();
  return AdminEpisodesNotifier(supabaseService);
});

// Admin Categories Provider
class AdminCategoriesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final SupabaseService _supabaseService;

  AdminCategoriesNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _supabaseService.getAdminCategories();
      state = AsyncValue.data(categories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load categories: ${e.toString()}');
    }
  }

  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    try {
      await _supabaseService.createCategory(categoryData);
      await loadCategories();
    } catch (e) {
      throw AdminException('Failed to create category: ${e.toString()}');
    }
  }

  Future<void> updateCategory(String categoryId, Map<String, dynamic> categoryData) async {
    try {
      await _supabaseService.updateCategory(categoryId, categoryData);
      await loadCategories();
    } catch (e) {
      throw AdminException('Failed to update category: ${e.toString()}');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _supabaseService.deleteCategory(categoryId);
      await loadCategories();
    } catch (e) {
      throw AdminException('Failed to delete category: ${e.toString()}');
    }
  }
}

final adminCategoriesProvider = StateNotifierProvider<AdminCategoriesNotifier, AsyncValue<List<dynamic>>>((ref) {
  final supabaseService = SupabaseService();
  return AdminCategoriesNotifier(supabaseService);
});

// Admin Users Provider
class AdminUsersNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final SupabaseService _supabaseService;

  AdminUsersNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadUsers() async {
    try {
      state = const AsyncValue.loading();
      final users = await _supabaseService.getAdminUsers();
      state = AsyncValue.data(users);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load users: ${e.toString()}');
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _supabaseService.updateUserStatus(userId, isActive);
      await loadUsers();
    } catch (e) {
      throw AdminException('Failed to update user status: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _supabaseService.deleteUser(userId);
      await loadUsers();
    } catch (e) {
      throw AdminException('Failed to delete user: ${e.toString()}');
    }
  }
}

final adminUsersProvider = StateNotifierProvider<AdminUsersNotifier, AsyncValue<List<dynamic>>>((ref) {
  final supabaseService = SupabaseService();
  return AdminUsersNotifier(supabaseService);
});

// Admin Subscribers Provider
class AdminSubscribersNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final SupabaseService _supabaseService;

  AdminSubscribersNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadSubscribers() async {
    try {
      state = const AsyncValue.loading();
      final subscribers = await _supabaseService.getAdminSubscribers();
      state = AsyncValue.data(subscribers);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load subscribers: ${e.toString()}');
    }
  }

  Future<void> updateSubscription(String subscriptionId, Map<String, dynamic> subscriptionData) async {
    try {
      await _supabaseService.updateSubscription(subscriptionId, subscriptionData);
      await loadSubscribers();
    } catch (e) {
      throw AdminException('Failed to update subscription: ${e.toString()}');
    }
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    try {
      await _supabaseService.adminCancelSubscription(subscriptionId);
      await loadSubscribers();
    } catch (e) {
      throw AdminException('Failed to cancel subscription: ${e.toString()}');
    }
  }
}

final adminSubscribersProvider = StateNotifierProvider<AdminSubscribersNotifier, AsyncValue<List<dynamic>>>((ref) {
  final supabaseService = SupabaseService();
  return AdminSubscribersNotifier(supabaseService);
});

// Admin Analytics Provider
class AdminAnalyticsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final SupabaseService _supabaseService;

  AdminAnalyticsNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadAnalytics({String? period}) async {
    try {
      state = const AsyncValue.loading();
      final analytics = await _supabaseService.getAdminAnalytics(period: period);
      state = AsyncValue.data(analytics);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load analytics: ${e.toString()}');
    }
  }
}

final adminAnalyticsProvider = StateNotifierProvider<AdminAnalyticsNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final supabaseService = SupabaseService();
  return AdminAnalyticsNotifier(supabaseService);
});

// Admin Activities Provider
class AdminActivitiesNotifier extends StateNotifier<AsyncValue<List<ActivityModel>>> {
  final SupabaseService _supabaseService;

  AdminActivitiesNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadActivities() async {
    try {
      state = const AsyncValue.loading();
      final activities = await _supabaseService.getAdminActivities();
      state = AsyncValue.data(activities);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to load activities: ${e.toString()}');
    }
  }
}

final adminActivitiesProvider = StateNotifierProvider<AdminActivitiesNotifier, AsyncValue<List<ActivityModel>>>((ref) {
  final supabaseService = SupabaseService();
  return AdminActivitiesNotifier(supabaseService);
});

// Admin Upload Provider
class AdminUploadNotifier extends StateNotifier<AsyncValue<double>> {
  final SupabaseService _supabaseService;

  AdminUploadNotifier(this._supabaseService) : super(const AsyncValue.data(0));

  Future<String> uploadVideo(String filePath, String fileName) async {
    try {
      state = const AsyncValue.data(0);
      
      final videoUrl = await _supabaseService.uploadVideo(
        filePath,
        fileName,
        onProgress: (progress) {
          state = AsyncValue.data(progress);
        },
      );
      
      state = const AsyncValue.data(1);
      return videoUrl;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to upload video: ${e.toString()}');
    }
  }

  Future<String> uploadImage(String filePath, String fileName) async {
    try {
      state = const AsyncValue.data(0);
      
      final imageUrl = await _supabaseService.uploadImage(
        filePath,
        fileName,
        onProgress: (progress) {
          state = AsyncValue.data(progress);
        },
      );
      
      state = const AsyncValue.data(1);
      return imageUrl;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw AdminException('Failed to upload image: ${e.toString()}');
    }
  }
}

final adminUploadProvider = StateNotifierProvider<AdminUploadNotifier, AsyncValue<double>>((ref) {
  final supabaseService = SupabaseService();
  return AdminUploadNotifier(supabaseService);
});

// Is Admin Provider
final isAdminProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authProvider);
  
  if (authState.hasValue && authState.value != null) {
    final supabaseService = SupabaseService();
    return await supabaseService.isAdmin();
  }
  
  return false;
});

