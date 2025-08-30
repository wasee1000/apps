import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/user_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/utils/exceptions.dart';

// Auth state
enum AuthState {
  initial,
  authenticated,
  unauthenticated,
}

// Auth state class
class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final SupabaseService _supabaseService;
  AuthState _authState = AuthState.initial;

  AuthStateNotifier(this._supabaseService) : super(const AsyncValue.loading()) {
    _init();
  }

  // Initialize auth state
  Future<void> _init() async {
    try {
      final currentUser = _supabaseService.getCurrentUser();
      
      if (currentUser != null) {
        final userProfile = await _supabaseService.getUserProfile();
        state = AsyncValue.data(userProfile);
        _authState = AuthState.authenticated;
      } else {
        state = const AsyncValue.data(null);
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _authState = AuthState.unauthenticated;
    }
  }

  // Get current auth state
  AuthState get authState => _authState;

  // Sign in with email and password
  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const AsyncValue.loading();
      
      final userProfile = await _supabaseService.signIn(
        email: email,
        password: password,
      );
      
      state = AsyncValue.data(userProfile);
      _authState = AuthState.authenticated;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _authState = AuthState.unauthenticated;
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final userProfile = await _supabaseService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      
      state = AsyncValue.data(userProfile);
      _authState = AuthState.authenticated;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      _authState = AuthState.unauthenticated;
      throw AuthException('Failed to sign up: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      state = const AsyncValue.data(null);
      _authState = AuthState.unauthenticated;
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.resetPassword(email);
    } catch (e) {
      throw AuthException('Failed to reset password: ${e.toString()}');
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    try {
      final updatedProfile = await _supabaseService.updateUserProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
        preferredLanguage: preferredLanguage,
      );
      
      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      throw DataException('Failed to update profile: ${e.toString()}');
    }
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    try {
      final userProfile = await _supabaseService.getUserProfile();
      state = AsyncValue.data(userProfile);
    } catch (e) {
      throw DataException('Failed to refresh profile: ${e.toString()}');
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    try {
      return await _supabaseService.isAdmin();
    } catch (e) {
      return false;
    }
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  final supabaseService = SupabaseService();
  return AuthStateNotifier(supabaseService);
});

// Auth state provider
final authStateProvider = Provider<AuthState>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return authNotifier.authState;
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState == AuthState.authenticated;
});

// Is admin provider
final isAdminProvider = FutureProvider<bool>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.isAdmin();
});

