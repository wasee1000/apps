import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/show_model.dart';
import '../../../core/models/episode_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/exceptions.dart';

// Show Details Provider
class ShowDetailsNotifier extends StateNotifier<AsyncValue<ShowModel>> {
  final SupabaseService _supabaseService;
  final String showId;

  ShowDetailsNotifier(this._supabaseService, this.showId)
      : super(const AsyncValue.loading());

  Future<void> loadShowDetails() async {
    try {
      state = const AsyncValue.loading();
      final show = await _supabaseService.getShowDetails(showId);
      state = AsyncValue.data(show);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> toggleWatchlist() async {
    try {
      final isInWatchlist = await _supabaseService.toggleWatchlist(showId);
      return isInWatchlist;
    } catch (e) {
      throw DataException('Failed to update watchlist: ${e.toString()}');
    }
  }

  Future<bool> toggleFavorite() async {
    try {
      final isInFavorites = await _supabaseService.toggleFavorite(showId);
      return isInFavorites;
    } catch (e) {
      throw DataException('Failed to update favorites: ${e.toString()}');
    }
  }
}

final showDetailsProvider = StateNotifierProvider.family<ShowDetailsNotifier, AsyncValue<ShowModel>, String>((ref, showId) {
  final supabaseService = SupabaseService();
  return ShowDetailsNotifier(supabaseService, showId);
});

// Show Episodes Provider
class ShowEpisodesNotifier extends StateNotifier<AsyncValue<List<EpisodeModel>>> {
  final SupabaseService _supabaseService;
  final String showId;
  List<EpisodeModel> _allEpisodes = [];
  int _currentSeason = 1;

  ShowEpisodesNotifier(this._supabaseService, this.showId)
      : super(const AsyncValue.loading());

  Future<void> loadEpisodes() async {
    try {
      state = const AsyncValue.loading();
      _allEpisodes = await _supabaseService.getShowEpisodes(showId);
      
      // Filter by current season
      _filterBySeason();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void filterBySeason(int season) {
    _currentSeason = season;
    _filterBySeason();
  }

  void _filterBySeason() {
    final filteredEpisodes = _allEpisodes
        .where((episode) => episode.seasonNumber == _currentSeason)
        .toList();
    
    // Sort by episode number
    filteredEpisodes.sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
    
    state = AsyncValue.data(filteredEpisodes);
  }
}

final showEpisodesProvider = StateNotifierProvider.family<ShowEpisodesNotifier, AsyncValue<List<EpisodeModel>>, String>((ref, showId) {
  final supabaseService = SupabaseService();
  return ShowEpisodesNotifier(supabaseService, showId);
});

// Similar Shows Provider
class SimilarShowsNotifier extends StateNotifier<AsyncValue<List<ShowModel>>> {
  final SupabaseService _supabaseService;
  final String showId;

  SimilarShowsNotifier(this._supabaseService, this.showId)
      : super(const AsyncValue.loading());

  Future<void> loadSimilarShows() async {
    try {
      state = const AsyncValue.loading();
      final shows = await _supabaseService.getSimilarShows(showId);
      state = AsyncValue.data(shows);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final similarShowsProvider = StateNotifierProvider.family<SimilarShowsNotifier, AsyncValue<List<ShowModel>>, String>((ref, showId) {
  final supabaseService = SupabaseService();
  return SimilarShowsNotifier(supabaseService, showId);
});

// Is Show In Watchlist Provider
final isShowInWatchlistProvider = FutureProvider.family<bool, String>((ref, showId) async {
  final supabaseService = SupabaseService();
  return await supabaseService.isShowInWatchlist(showId);
});

// Is Show In Favorites Provider
final isShowInFavoritesProvider = FutureProvider.family<bool, String>((ref, showId) async {
  final supabaseService = SupabaseService();
  return await supabaseService.isShowInFavorites(showId);
});

