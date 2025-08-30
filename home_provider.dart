import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/category_model.dart';
import '../../../core/models/show_model.dart';
import '../../../core/models/episode_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/exceptions.dart';

// Featured Shows Provider
class FeaturedShowsNotifier extends StateNotifier<AsyncValue<List<ShowModel>>> {
  final SupabaseService _supabaseService;

  FeaturedShowsNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadFeaturedShows() async {
    try {
      state = const AsyncValue.loading();
      final shows = await _supabaseService.getFeaturedShows();
      state = AsyncValue.data(shows);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final featuredShowsProvider = StateNotifierProvider<FeaturedShowsNotifier, AsyncValue<List<ShowModel>>>((ref) {
  final supabaseService = SupabaseService();
  return FeaturedShowsNotifier(supabaseService);
});

// Categories Provider
class CategoriesNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final SupabaseService _supabaseService;

  CategoriesNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _supabaseService.getCategories();
      state = AsyncValue.data(categories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  final supabaseService = SupabaseService();
  return CategoriesNotifier(supabaseService);
});

// Trending Shows Provider
class TrendingShowsNotifier extends StateNotifier<AsyncValue<List<ShowModel>>> {
  final SupabaseService _supabaseService;

  TrendingShowsNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadTrendingShows() async {
    try {
      state = const AsyncValue.loading();
      final shows = await _supabaseService.getTrendingShows();
      state = AsyncValue.data(shows);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final trendingShowsProvider = StateNotifierProvider<TrendingShowsNotifier, AsyncValue<List<ShowModel>>>((ref) {
  final supabaseService = SupabaseService();
  return TrendingShowsNotifier(supabaseService);
});

// Recently Added Shows Provider
class RecentlyAddedShowsNotifier extends StateNotifier<AsyncValue<List<ShowModel>>> {
  final SupabaseService _supabaseService;

  RecentlyAddedShowsNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadRecentlyAddedShows() async {
    try {
      state = const AsyncValue.loading();
      final shows = await _supabaseService.getRecentlyAddedShows();
      state = AsyncValue.data(shows);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final recentlyAddedShowsProvider = StateNotifierProvider<RecentlyAddedShowsNotifier, AsyncValue<List<ShowModel>>>((ref) {
  final supabaseService = SupabaseService();
  return RecentlyAddedShowsNotifier(supabaseService);
});

// Continue Watching Provider
class ContinueWatchingNotifier extends StateNotifier<AsyncValue<List<EpisodeModel>>> {
  final SupabaseService _supabaseService;

  ContinueWatchingNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadContinueWatching() async {
    try {
      state = const AsyncValue.loading();
      final episodes = await _supabaseService.getContinueWatchingEpisodes();
      state = AsyncValue.data(episodes);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateWatchProgress(String episodeId, int position) async {
    try {
      await _supabaseService.updateWatchProgress(episodeId, position);
      loadContinueWatching();
    } catch (e) {
      throw DataException('Failed to update watch progress: ${e.toString()}');
    }
  }
}

final continueWatchingProvider = StateNotifierProvider<ContinueWatchingNotifier, AsyncValue<List<EpisodeModel>>>((ref) {
  final supabaseService = SupabaseService();
  return ContinueWatchingNotifier(supabaseService);
});

// Recommended Shows Provider
class RecommendedShowsNotifier extends StateNotifier<AsyncValue<List<ShowModel>>> {
  final SupabaseService _supabaseService;

  RecommendedShowsNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadRecommendedShows() async {
    try {
      state = const AsyncValue.loading();
      final shows = await _supabaseService.getRecommendedShows();
      state = AsyncValue.data(shows);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final recommendedShowsProvider = StateNotifierProvider<RecommendedShowsNotifier, AsyncValue<List<ShowModel>>>((ref) {
  final supabaseService = SupabaseService();
  return RecommendedShowsNotifier(supabaseService);
});

// Shows by Category Provider
class ShowsByCategoryNotifier extends StateNotifier<AsyncValue<List<ShowModel>>> {
  final SupabaseService _supabaseService;
  String? _currentCategoryId;

  ShowsByCategoryNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadShowsByCategory(String categoryId) async {
    if (_currentCategoryId == categoryId) return;
    
    try {
      _currentCategoryId = categoryId;
      state = const AsyncValue.loading();
      final shows = await _supabaseService.getShowsByCategory(categoryId);
      state = AsyncValue.data(shows);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final showsByCategoryProvider = StateNotifierProvider.family<ShowsByCategoryNotifier, AsyncValue<List<ShowModel>>, String>((ref, categoryId) {
  final supabaseService = SupabaseService();
  final notifier = ShowsByCategoryNotifier(supabaseService);
  notifier.loadShowsByCategory(categoryId);
  return notifier;
});

