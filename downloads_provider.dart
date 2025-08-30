import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/episode_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/exceptions.dart';
import '../models/download_progress_model.dart';
import '../models/storage_info_model.dart';

// Downloads Provider
class DownloadsNotifier extends StateNotifier<AsyncValue<List<EpisodeModel>>> {
  final SupabaseService _supabaseService;

  DownloadsNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadDownloads() async {
    try {
      state = const AsyncValue.loading();
      final downloads = await _supabaseService.getDownloadedEpisodes();
      state = AsyncValue.data(downloads);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteDownloads(List<String> episodeIds) async {
    try {
      await _supabaseService.deleteDownloads(episodeIds);
      
      // Refresh downloads list
      loadDownloads();
    } catch (e) {
      throw DownloadException('Failed to delete downloads: ${e.toString()}');
    }
  }
}

final downloadsProvider = StateNotifierProvider<DownloadsNotifier, AsyncValue<List<EpisodeModel>>>((ref) {
  final supabaseService = SupabaseService();
  return DownloadsNotifier(supabaseService);
});

// Download Progress Provider
class DownloadProgressNotifier extends StateNotifier<AsyncValue<List<DownloadProgressModel>>> {
  final SupabaseService _supabaseService;

  DownloadProgressNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadDownloadProgress() async {
    try {
      state = const AsyncValue.loading();
      final progress = await _supabaseService.getDownloadProgress();
      state = AsyncValue.data(progress);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> cancelDownload(String episodeId) async {
    try {
      await _supabaseService.cancelDownload(episodeId);
      
      // Refresh download progress
      loadDownloadProgress();
    } catch (e) {
      throw DownloadException('Failed to cancel download: ${e.toString()}');
    }
  }
}

final downloadProgressProvider = StateNotifierProvider<DownloadProgressNotifier, AsyncValue<List<DownloadProgressModel>>>((ref) {
  final supabaseService = SupabaseService();
  return DownloadProgressNotifier(supabaseService);
});

// Storage Info Provider
class StorageInfoNotifier extends StateNotifier<AsyncValue<StorageInfoModel>> {
  final SupabaseService _supabaseService;

  StorageInfoNotifier(this._supabaseService) : super(const AsyncValue.loading());

  Future<void> loadStorageInfo() async {
    try {
      state = const AsyncValue.loading();
      final storageInfo = await _supabaseService.getStorageInfo();
      state = AsyncValue.data(storageInfo);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final storageInfoProvider = StateNotifierProvider<StorageInfoNotifier, AsyncValue<StorageInfoModel>>((ref) {
  final supabaseService = SupabaseService();
  return StorageInfoNotifier(supabaseService);
});

