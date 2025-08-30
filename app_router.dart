import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/supabase_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/category_screen.dart';
import '../../features/home/screens/show_details_screen.dart';
import '../../features/player/screens/video_player_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/watchlist_screen.dart';
import '../../features/profile/screens/favorites_screen.dart';
import '../../features/profile/screens/watch_history_screen.dart';
import '../../features/profile/screens/subscription_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../features/downloads/screens/downloads_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/video_upload_screen.dart';
import '../../features/admin/screens/content_management_screen.dart';

// Provider for the router
final routerProvider = Provider<GoRouter>((ref) {
  final supabaseService = SupabaseService();

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Check if the user is authenticated
      final isAuthenticated = supabaseService.isAuthenticated();
      final isOnAuthRoute = state.matchedLocation.startsWith('/auth');
      
      // If not authenticated and not on auth route, redirect to login
      if (!isAuthenticated && !isOnAuthRoute) {
        return '/auth/login';
      }
      
      // If authenticated and on auth route, redirect to home
      if (isAuthenticated && isOnAuthRoute) {
        return '/';
      }
      
      // No redirect needed
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main app routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Category routes
          GoRoute(
            path: 'category/:id',
            name: 'category',
            builder: (context, state) {
              final categoryId = state.pathParameters['id']!;
              return CategoryScreen(categoryId: categoryId);
            },
          ),
          
          // Show details route
          GoRoute(
            path: 'show/:id',
            name: 'show-details',
            builder: (context, state) {
              final showId = state.pathParameters['id']!;
              return ShowDetailsScreen(showId: showId);
            },
          ),
          
          // Video player route
          GoRoute(
            path: 'player/:id',
            name: 'video-player',
            builder: (context, state) {
              final episodeId = state.pathParameters['id']!;
              final startPosition = int.tryParse(
                state.queryParameters['position'] ?? '0'
              );
              return VideoPlayerScreen(
                episodeId: episodeId,
                startPosition: startPosition ?? 0,
              );
            },
          ),
          
          // Search route
          GoRoute(
            path: 'search',
            name: 'search',
            builder: (context, state) {
              final query = state.queryParameters['q'];
              return SearchScreen(initialQuery: query);
            },
          ),
          
          // Profile routes
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'watchlist',
                name: 'watchlist',
                builder: (context, state) => const WatchlistScreen(),
              ),
              GoRoute(
                path: 'favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
              GoRoute(
                path: 'history',
                name: 'watch-history',
                builder: (context, state) => const WatchHistoryScreen(),
              ),
              GoRoute(
                path: 'subscription',
                name: 'subscription',
                builder: (context, state) => const SubscriptionScreen(),
              ),
              GoRoute(
                path: 'settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          
          // Downloads route
          GoRoute(
            path: 'downloads',
            name: 'downloads',
            builder: (context, state) => const DownloadsScreen(),
          ),
          
          // Admin routes
          GoRoute(
            path: 'admin',
            name: 'admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
            routes: [
              GoRoute(
                path: 'upload',
                name: 'video-upload',
                builder: (context, state) => const VideoUploadScreen(),
              ),
              GoRoute(
                path: 'content',
                name: 'content-management',
                builder: (context, state) => const ContentManagementScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Oops! The page you are looking for does not exist.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

