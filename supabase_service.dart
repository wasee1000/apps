import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/show_model.dart';
import '../models/episode_model.dart';
import '../models/category_model.dart';
import '../models/subscription_model.dart';
import '../models/notification_model.dart';
import '../utils/exceptions.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  
  factory SupabaseService() => _instance;
  
  SupabaseService._internal();
  
  SupabaseClient get client => Supabase.instance.client;
  
  // Authentication Methods
  
  /// Sign up with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );
      
      if (response.user == null) {
        throw AuthException('Failed to create account');
      }
      
      return UserModel.fromJson({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'subscription_plan': 'free',
      });
    } catch (e) {
      throw AuthException('Failed to sign up: ${e.toString()}');
    }
  }
  
  /// Sign in with email and password
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw AuthException('Invalid credentials');
      }
      
      // Fetch user profile
      final profile = await getUserProfile();
      
      return profile;
    } catch (e) {
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }
  
  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Failed to reset password: ${e.toString()}');
    }
  }
  
  /// Get current user
  User? getCurrentUser() {
    return client.auth.currentUser;
  }
  
  /// Check if user is authenticated
  bool isAuthenticated() {
    return client.auth.currentUser != null;
  }
  
  /// Get user profile
  Future<UserModel> getUserProfile() async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw DataException('Failed to get user profile: ${e.toString()}');
    }
  }
  
  /// Update user profile
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final updates = <String, dynamic>{};
      
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (preferredLanguage != null) updates['preferred_language'] = preferredLanguage;
      
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await client
          .from('user_profiles')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw DataException('Failed to update user profile: ${e.toString()}');
    }
  }
  
  /// Upload avatar image
  Future<String> uploadAvatar(File imageFile) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final fileExt = path.extension(imageFile.path);
      final fileName = '${user.id}/${const Uuid().v4()}$fileExt';
      
      await client.storage.from('avatars').upload(
        fileName,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
      
      final imageUrl = client.storage.from('avatars').getPublicUrl(fileName);
      
      // Update user profile with new avatar URL
      await updateUserProfile(avatarUrl: imageUrl);
      
      return imageUrl;
    } catch (e) {
      throw StorageException('Failed to upload avatar: ${e.toString()}');
    }
  }
  
  // Content Methods
  
  /// Get all categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);
      
      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DataException('Failed to get categories: ${e.toString()}');
    }
  }
  
  /// Get shows by category
  Future<List<ShowModel>> getShowsByCategory(String categoryId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from('shows')
          .select()
          .eq('category_id', categoryId)
          .eq('status', 'published')
          .order('title', ascending: true)
          .range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) => ShowModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DataException('Failed to get shows by category: ${e.toString()}');
    }
  }
  
  /// Get show details
  Future<ShowModel> getShowDetails(String showId) async {
    try {
      final response = await client
          .from('shows')
          .select()
          .eq('id', showId)
          .single();
      
      return ShowModel.fromJson(response);
    } catch (e) {
      throw DataException('Failed to get show details: ${e.toString()}');
    }
  }
  
  /// Get episodes by show
  Future<List<EpisodeModel>> getEpisodesByShow(String showId, {
    int? seasonNumber,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      var query = client
          .from('episodes')
          .select()
          .eq('show_id', showId)
          .eq('status', 'published')
          .order('season_number', ascending: true)
          .order('episode_number', ascending: true);
      
      if (seasonNumber != null) {
        query = query.eq('season_number', seasonNumber);
      }
      
      final response = await query.range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) => EpisodeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DataException('Failed to get episodes: ${e.toString()}');
    }
  }
  
  /// Get episode details
  Future<EpisodeModel> getEpisodeDetails(String episodeId) async {
    try {
      final response = await client
          .from('episodes')
          .select()
          .eq('id', episodeId)
          .single();
      
      return EpisodeModel.fromJson(response);
    } catch (e) {
      throw DataException('Failed to get episode details: ${e.toString()}');
    }
  }
  
  /// Search content
  Future<Map<String, dynamic>> searchContent(String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Search shows
      final showsResponse = await client
          .from('shows')
          .select()
          .eq('status', 'published')
          .ilike('title', '%$query%')
          .order('title', ascending: true)
          .range((page - 1) * limit, page * limit - 1);
      
      // Search episodes
      final episodesResponse = await client
          .from('episodes')
          .select('*, shows(*)')
          .eq('status', 'published')
          .ilike('title', '%$query%')
          .order('title', ascending: true)
          .range((page - 1) * limit, page * limit - 1);
      
      final shows = (showsResponse as List)
          .map((json) => ShowModel.fromJson(json))
          .toList();
      
      final episodes = (episodesResponse as List)
          .map((json) {
            final episode = EpisodeModel.fromJson(json);
            episode.show = ShowModel.fromJson(json['shows']);
            return episode;
          })
          .toList();
      
      return {
        'shows': shows,
        'episodes': episodes,
      };
    } catch (e) {
      throw DataException('Failed to search content: ${e.toString()}');
    }
  }
  
  /// Get trending shows
  Future<List<ShowModel>> getTrendingShows({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await client
          .from('shows')
          .select()
          .eq('status', 'published')
          .order('rating', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) => ShowModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DataException('Failed to get trending shows: ${e.toString()}');
    }
  }
  
  /// Get new releases
  Future<List<EpisodeModel>> getNewReleases({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await client
          .from('episodes')
          .select('*, shows(*)')
          .eq('status', 'published')
          .order('air_date', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) {
            final episode = EpisodeModel.fromJson(json);
            episode.show = ShowModel.fromJson(json['shows']);
            return episode;
          })
          .toList();
    } catch (e) {
      throw DataException('Failed to get new releases: ${e.toString()}');
    }
  }
  
  /// Get personalized recommendations
  Future<List<ShowModel>> getRecommendations({
    String type = 'personalized',
    int limit = 10,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      // Call the recommendation edge function
      final response = await client.functions.invoke(
        'content-recommendation',
        body: {
          'user_id': user.id,
          'limit': limit,
          'exclude_watched': true,
          'recommendation_type': type,
        },
      );
      
      if (response.status != 200) {
        throw DataException('Failed to get recommendations: ${response.data}');
      }
      
      return (response.data['recommendations'] as List)
          .map((json) => ShowModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DataException('Failed to get recommendations: ${e.toString()}');
    }
  }
  
  // User Content Interaction Methods
  
  /// Add show to watchlist
  Future<void> addToWatchlist(String showId) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      await client.from('user_watchlist').insert({
        'user_id': user.id,
        'show_id': showId,
      });
    } catch (e) {
      throw DataException('Failed to add to watchlist: ${e.toString()}');
    }
  }
  
  /// Remove show from watchlist
  Future<void> removeFromWatchlist(String showId) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      await client
          .from('user_watchlist')
          .delete()
          .eq('user_id', user.id)
          .eq('show_id', showId);
    } catch (e) {
      throw DataException('Failed to remove from watchlist: ${e.toString()}');
    }
  }
  
  /// Get user watchlist
  Future<List<ShowModel>> getWatchlist({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client
          .from('user_watchlist')
          .select('show_id, shows(*)')
          .eq('user_id', user.id)
          .order('added_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) => ShowModel.fromJson(json['shows']))
          .toList();
    } catch (e) {
      throw DataException('Failed to get watchlist: ${e.toString()}');
    }
  }
  
  /// Add episode to favorites
  Future<void> addToFavorites(String episodeId) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      await client.from('user_favorites').insert({
        'user_id': user.id,
        'episode_id': episodeId,
      });
    } catch (e) {
      throw DataException('Failed to add to favorites: ${e.toString()}');
    }
  }
  
  /// Remove episode from favorites
  Future<void> removeFromFavorites(String episodeId) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      await client
          .from('user_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('episode_id', episodeId);
    } catch (e) {
      throw DataException('Failed to remove from favorites: ${e.toString()}');
    }
  }
  
  /// Get user favorites
  Future<List<EpisodeModel>> getFavorites({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client
          .from('user_favorites')
          .select('episode_id, episodes(*), episodes.shows(*)')
          .eq('user_id', user.id)
          .order('added_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) {
            final episode = EpisodeModel.fromJson(json['episodes']);
            episode.show = ShowModel.fromJson(json['episodes']['shows']);
            return episode;
          })
          .toList();
    } catch (e) {
      throw DataException('Failed to get favorites: ${e.toString()}');
    }
  }
  
  /// Update watch progress
  Future<void> updateWatchProgress({
    required String episodeId,
    required int progress,
    required int duration,
    bool completed = false,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      // Calculate percentage watched
      final percentage = (progress / duration) * 100;
      
      // Check if watch history entry exists
      final existing = await client
          .from('watch_history')
          .select()
          .eq('user_id', user.id)
          .eq('episode_id', episodeId)
          .maybeSingle();
      
      if (existing == null) {
        // Create new entry
        await client.from('watch_history').insert({
          'user_id': user.id,
          'episode_id': episodeId,
          'watch_progress': progress,
          'watch_percentage': percentage,
          'completed': completed,
          'last_watched': DateTime.now().toIso8601String(),
          'device_info': {
            'platform': Platform.operatingSystem,
            'version': Platform.operatingSystemVersion,
          },
        });
      } else {
        // Update existing entry
        await client
            .from('watch_history')
            .update({
              'watch_progress': progress,
              'watch_percentage': percentage,
              'completed': completed,
              'last_watched': DateTime.now().toIso8601String(),
              'device_info': {
                'platform': Platform.operatingSystem,
                'version': Platform.operatingSystemVersion,
              },
            })
            .eq('id', existing['id']);
      }
    } catch (e) {
      throw DataException('Failed to update watch progress: ${e.toString()}');
    }
  }
  
  /// Get watch history
  Future<List<Map<String, dynamic>>> getWatchHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client
          .from('watch_history')
          .select('*, episodes(*), episodes.shows(*)')
          .eq('user_id', user.id)
          .order('last_watched', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) {
            final episode = EpisodeModel.fromJson(json['episodes']);
            episode.show = ShowModel.fromJson(json['episodes']['shows']);
            
            return {
              'episode': episode,
              'watch_progress': json['watch_progress'],
              'watch_percentage': json['watch_percentage'],
              'completed': json['completed'],
              'last_watched': json['last_watched'],
            };
          })
          .toList();
    } catch (e) {
      throw DataException('Failed to get watch history: ${e.toString()}');
    }
  }
  
  /// Get continue watching
  Future<List<Map<String, dynamic>>> getContinueWatching({
    int limit = 10,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client
          .from('watch_history')
          .select('*, episodes(*), episodes.shows(*)')
          .eq('user_id', user.id)
          .eq('completed', false)
          .gt('watch_percentage', 5) // At least started watching (5%)
          .lt('watch_percentage', 95) // Not almost finished (95%)
          .order('last_watched', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) {
            final episode = EpisodeModel.fromJson(json['episodes']);
            episode.show = ShowModel.fromJson(json['episodes']['shows']);
            
            return {
              'episode': episode,
              'watch_progress': json['watch_progress'],
              'watch_percentage': json['watch_percentage'],
              'last_watched': json['last_watched'],
            };
          })
          .toList();
    } catch (e) {
      throw DataException('Failed to get continue watching: ${e.toString()}');
    }
  }
  
  // Subscription Methods
  
  /// Get subscription status
  Future<SubscriptionModel> getSubscriptionStatus() async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client.rpc(
        'get_subscription_status',
        params: {'user_uuid': user.id},
      );
      
      return SubscriptionModel.fromJson(response[0]);
    } catch (e) {
      throw DataException('Failed to get subscription status: ${e.toString()}');
    }
  }
  
  /// Activate free trial
  Future<bool> activateFreeTrial() async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client.rpc(
        'activate_free_trial',
        params: {'user_uuid': user.id},
      );
      
      return response as bool;
    } catch (e) {
      throw DataException('Failed to activate free trial: ${e.toString()}');
    }
  }
  
  /// Upgrade to premium
  Future<bool> upgradeToPremium(int durationMonths) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      // In a real app, this would integrate with a payment gateway
      // For this example, we'll simulate a successful payment
      
      // Record transaction
      await client.from('subscription_transactions').insert({
        'user_id': user.id,
        'transaction_id': 'sim_${const Uuid().v4()}',
        'plan_type': 'premium',
        'amount': 299 * durationMonths,
        'currency': 'INR',
        'payment_method': 'credit_card',
        'payment_status': 'completed',
        'payment_gateway': 'simulation',
      });
      
      // Update subscription
      final response = await client.rpc(
        'upgrade_to_premium',
        params: {
          'user_uuid': user.id,
          'duration_months': durationMonths,
        },
      );
      
      return response as bool;
    } catch (e) {
      throw DataException('Failed to upgrade to premium: ${e.toString()}');
    }
  }
  
  /// Check content access
  Future<bool> canAccessContent(String episodeId) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final response = await client.rpc(
        'can_access_content',
        params: {'episode_uuid': episodeId},
      );
      
      return response as bool;
    } catch (e) {
      throw DataException('Failed to check content access: ${e.toString()}');
    }
  }
  
  // Notification Methods
  
  /// Get user notifications
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      var query = client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      if (unreadOnly) {
        query = query.eq('is_read', false);
      }
      
      final response = await query.range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw DataException('Failed to get notifications: ${e.toString()}');
    }
  }
  
  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);
    } catch (e) {
      throw DataException('Failed to mark notification as read: ${e.toString()}');
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      await client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      throw DataException('Failed to mark all notifications as read: ${e.toString()}');
    }
  }
  
  // Download Methods
  
  /// Add episode to downloads
  Future<void> addToDownloads(String episodeId, String downloadPath, String quality) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      // Check if user has premium access for premium content
      final canAccess = await canAccessContent(episodeId);
      if (!canAccess) {
        throw DataException('Premium subscription required to download this content');
      }
      
      // Calculate expiry date (30 days from now)
      final expiryDate = DateTime.now().add(const Duration(days: 30));
      
      await client.from('downloads').insert({
        'user_id': user.id,
        'episode_id': episodeId,
        'download_path': downloadPath,
        'download_quality': quality,
        'download_status': 'pending',
        'expires_at': expiryDate.toIso8601String(),
      });
    } catch (e) {
      throw DataException('Failed to add to downloads: ${e.toString()}');
    }
  }
  
  /// Update download status
  Future<void> updateDownloadStatus(String episodeId, String status, {int? fileSize}) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      final updates = <String, dynamic>{
        'download_status': status,
      };
      
      if (status == 'completed') {
        updates['downloaded_at'] = DateTime.now().toIso8601String();
      }
      
      if (fileSize != null) {
        updates['file_size'] = fileSize;
      }
      
      await client
          .from('downloads')
          .update(updates)
          .eq('user_id', user.id)
          .eq('episode_id', episodeId);
    } catch (e) {
      throw DataException('Failed to update download status: ${e.toString()}');
    }
  }
  
  /// Get user downloads
  Future<List<Map<String, dynamic>>> getDownloads({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      var query = client
          .from('downloads')
          .select('*, episodes(*), episodes.shows(*)')
          .eq('user_id', user.id);
      
      if (status != null) {
        query = query.eq('download_status', status);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .range((page - 1) * limit, page * limit - 1);
      
      return (response as List)
          .map((json) {
            final episode = EpisodeModel.fromJson(json['episodes']);
            episode.show = ShowModel.fromJson(json['episodes']['shows']);
            
            return {
              'episode': episode,
              'download_path': json['download_path'],
              'download_quality': json['download_quality'],
              'download_status': json['download_status'],
              'file_size': json['file_size'],
              'downloaded_at': json['downloaded_at'],
              'expires_at': json['expires_at'],
            };
          })
          .toList();
    } catch (e) {
      throw DataException('Failed to get downloads: ${e.toString()}');
    }
  }
  
  /// Remove download
  Future<void> removeDownload(String episodeId) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      await client
          .from('downloads')
          .delete()
          .eq('user_id', user.id)
          .eq('episode_id', episodeId);
    } catch (e) {
      throw DataException('Failed to remove download: ${e.toString()}');
    }
  }
  
  // Admin Methods
  
  /// Check if user is admin
  Future<bool> isAdmin() async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        return false;
      }
      
      final response = await client
          .from('user_profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();
      
      return response['is_admin'] ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Upload video (admin only)
  Future<Map<String, dynamic>> uploadVideo(
    File videoFile,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final user = client.auth.currentUser;
      
      if (user == null) {
        throw AuthException('User not authenticated');
      }
      
      // Check if user is admin
      final isAdminUser = await isAdmin();
      if (!isAdminUser) {
        throw AuthException('Admin access required');
      }
      
      // In a real app, this would upload the video file to storage
      // For this example, we'll call the edge function directly
      
      // Call the video upload handler edge function
      final response = await client.functions.invoke(
        'video-upload-handler',
        body: {
          'videoFile': 'simulated_video_file',
          'metadata': metadata,
        },
        headers: {
          'Authorization': 'Bearer ${client.auth.currentSession?.accessToken}',
        },
      );
      
      if (response.status != 200) {
        throw DataException('Failed to upload video: ${response.data}');
      }
      
      return response.data;
    } catch (e) {
      throw DataException('Failed to upload video: ${e.toString()}');
    }
  }
}

