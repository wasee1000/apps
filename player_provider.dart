import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/episode_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/exceptions.dart';
import '../../../features/auth/providers/auth_provider.dart';

// Current Episode Provider
class CurrentEpisodeNotifier extends StateNotifier<AsyncValue<EpisodeModel?>> {
  final SupabaseService _supabaseService;
  final String episodeId;

  CurrentEpisodeNotifier(this._supabaseService, this.episodeId)
      : super(const AsyncValue.loading());

  Future<void> loadEpisode() async {
    try {
      state = const AsyncValue.loading();
      final episode = await _supabaseService.getEpisodeDetails(episodeId);
      
      // Load show details for the episode
      if (episode != null) {
        final show = await _supabaseService.getShowDetails(episode.showId);
        episode.show = show;
      }
      
      state = AsyncValue.data(episode);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final currentEpisodeProvider = StateNotifierProvider.family<CurrentEpisodeNotifier, AsyncValue<EpisodeModel?>, String>((ref, episodeId) {
  final supabaseService = SupabaseService();
  return CurrentEpisodeNotifier(supabaseService, episodeId);
});

// Player Provider
class PlayerNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseService _supabaseService;

  PlayerNotifier(this._supabaseService) : super(const AsyncValue.data(null));

  Future<void> saveWatchProgress(String episodeId, int position) async {
    try {
      await _supabaseService.updateWatchProgress(episodeId, position);
    } catch (e) {
      throw VideoException('Failed to save watch progress: ${e.toString()}');
    }
  }

  Future<void> addToWatchHistory(String episodeId) async {
    try {
      await _supabaseService.addToWatchHistory(episodeId);
    } catch (e) {
      throw DataException('Failed to add to watch history: ${e.toString()}');
    }
  }

  Future<void> downloadEpisode(String episodeId) async {
    try {
      state = const AsyncValue.loading();
      await _supabaseService.downloadEpisode(episodeId);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      throw DownloadException('Failed to download episode: ${e.toString()}');
    }
  }

  Future<void> cancelDownload(String episodeId) async {
    try {
      await _supabaseService.cancelDownload(episodeId);
    } catch (e) {
      throw DownloadException('Failed to cancel download: ${e.toString()}');
    }
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, AsyncValue<void>>((ref) {
  final supabaseService = SupabaseService();
  return PlayerNotifier(supabaseService);
});

// Next Episode Provider
final nextEpisodeProvider = Provider<EpisodeModel?>((ref) {
  final currentEpisodeAsync = ref.watch(currentEpisodeProvider);
  
  if (currentEpisodeAsync.hasValue && currentEpisodeAsync.value != null) {
    final currentEpisode = currentEpisodeAsync.value!;
    
    // Logic to find next episode
    // In a real app, this would query the database for the next episode
    // For now, we'll return null as a placeholder
    return null;
  }
  
  return null;
});

// Can Access Premium Provider
final canAccessPremiumProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authProvider);
  
  if (authState.hasValue && authState.value != null) {
    final user = authState.value!;
    return user.isPremium || user.isInTrialPeriod;
  }
  
  return false;
});

