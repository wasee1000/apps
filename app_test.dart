import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:indian_tv_streaming_app/main.dart' as app;
import 'package:indian_tv_streaming_app/core/services/supabase_service.dart';
import 'package:indian_tv_streaming_app/features/auth/providers/auth_provider.dart';

class MockSupabaseService extends Mock implements SupabaseService {
  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return {
      'id': 'test-user-id',
      'email': 'test@example.com',
      'name': 'Test User',
      'avatar_url': null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    return {
      'id': 'test-user-id',
      'email': email,
      'name': 'Test User',
      'avatar_url': null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<List<dynamic>> getHomePageContent() async {
    return [
      {
        'id': 'featured-1',
        'title': 'Featured Show 1',
        'description': 'This is a featured show',
        'thumbnail_url': 'https://example.com/thumbnail1.jpg',
        'is_premium': false,
      },
      {
        'id': 'featured-2',
        'title': 'Featured Show 2',
        'description': 'This is another featured show',
        'thumbnail_url': 'https://example.com/thumbnail2.jpg',
        'is_premium': true,
      },
    ];
  }

  @override
  Future<List<dynamic>> getCategories() async {
    return [
      {
        'id': 'category-1',
        'name': 'Drama',
        'icon': 'theater_comedy',
      },
      {
        'id': 'category-2',
        'name': 'Comedy',
        'icon': 'sentiment_very_satisfied',
      },
      {
        'id': 'category-3',
        'name': 'Romance',
        'icon': 'favorite',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getShowDetails(String showId) async {
    return {
      'id': showId,
      'title': 'Show Title',
      'description': 'This is a show description',
      'thumbnail_url': 'https://example.com/thumbnail.jpg',
      'is_premium': false,
      'episodes': [
        {
          'id': 'episode-1',
          'episode_title': 'Episode 1',
          'description': 'This is episode 1',
          'thumbnail_url': 'https://example.com/episode1.jpg',
          'video_url': 'https://example.com/episode1.mp4',
          'duration': 1800, // 30 minutes
          'is_premium': false,
        },
        {
          'id': 'episode-2',
          'episode_title': 'Episode 2',
          'description': 'This is episode 2',
          'thumbnail_url': 'https://example.com/episode2.jpg',
          'video_url': 'https://example.com/episode2.mp4',
          'duration': 1800, // 30 minutes
          'is_premium': true,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>?> getSubscription() async {
    return {
      'id': 'subscription-1',
      'status': 'active',
      'plan_id': 'plan-premium',
      'current_period_end': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    };
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseService mockSupabaseService;
  late ProviderContainer container;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    
    container = ProviderContainer(
      overrides: [
        supabaseServiceProvider.overrideWithValue(mockSupabaseService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('App Navigation Tests', () {
    testWidgets('App starts with splash screen and navigates to home when user is logged in',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify that we're on the home screen
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Bottom navigation bar navigates between main screens',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify that we're on the home screen
      expect(find.text('Home'), findsOneWidget);
      
      // Navigate to Categories tab
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Categories screen
      expect(find.text('Drama'), findsOneWidget);
      expect(find.text('Comedy'), findsOneWidget);
      expect(find.text('Romance'), findsOneWidget);
      
      // Navigate to Downloads tab
      await tester.tap(find.text('Downloads'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Downloads screen
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('No downloads yet'), findsOneWidget);
      
      // Navigate to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Profile screen
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      
      // Navigate back to Home tab
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      
      // Verify that we're back on the Home screen
      expect(find.text('Featured Shows'), findsOneWidget);
    });

    testWidgets('Show details screen displays show information and episodes',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Tap on a featured show
      await tester.tap(find.text('Featured Show 1'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Show Details screen
      expect(find.text('Show Title'), findsOneWidget);
      expect(find.text('This is a show description'), findsOneWidget);
      
      // Verify that episodes are displayed
      expect(find.text('Episodes'), findsOneWidget);
      expect(find.text('Episode 1'), findsOneWidget);
      expect(find.text('Episode 2'), findsOneWidget);
      
      // Tap on an episode
      await tester.tap(find.text('Episode 1'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Video Player screen
      expect(find.byType(VideoPlayer), findsOneWidget);
      
      // Navigate back to Show Details screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verify that we're back on the Show Details screen
      expect(find.text('Show Title'), findsOneWidget);
      
      // Navigate back to Home screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verify that we're back on the Home screen
      expect(find.text('Featured Shows'), findsOneWidget);
    });

    testWidgets('Premium content shows subscription prompt for free users',
        (WidgetTester tester) async {
      // Override the getSubscription method to return null (free user)
      when(mockSupabaseService.getSubscription()).thenAnswer((_) async => null);
      
      // Start the app
      app.main();
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Tap on a premium featured show
      await tester.tap(find.text('Featured Show 2'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Show Details screen
      expect(find.text('Show Title'), findsOneWidget);
      
      // Tap on a premium episode
      await tester.tap(find.text('Episode 2'));
      await tester.pumpAndSettle();
      
      // Verify that subscription prompt is displayed
      expect(find.text('Premium Content'), findsOneWidget);
      expect(find.text('Subscribe to access premium content'), findsOneWidget);
      expect(find.text('View Plans'), findsOneWidget);
      
      // Tap on View Plans button
      await tester.tap(find.text('View Plans'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Subscription Plans screen
      expect(find.text('Subscription Plans'), findsOneWidget);
    });

    testWidgets('User can access profile settings',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      // Tap on Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Settings screen
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('App Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      
      // Tap on Account
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Account screen
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
      
      // Navigate back to Settings screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Navigate back to Profile screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // Verify that we're back on the Profile screen
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('User can sign out',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      
      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Navigate to Profile tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      
      // Tap on Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();
      
      // Verify confirmation dialog
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      
      // Confirm sign out
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      
      // Verify that we're on the Login screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });
  });
}

// Mock VideoPlayer widget for testing
class VideoPlayer extends StatelessWidget {
  const VideoPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Video Player'),
      ),
    );
  }
}

