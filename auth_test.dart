import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:indian_tv_streaming_app/core/services/supabase_service.dart';
import 'package:indian_tv_streaming_app/features/auth/providers/auth_provider.dart';
import 'package:indian_tv_streaming_app/core/utils/exceptions.dart';

// Generate mock classes
@GenerateMocks([SupabaseService])
import 'auth_test.mocks.dart';

void main() {
  late MockSupabaseService mockSupabaseService;
  late ProviderContainer container;
  late AuthNotifier authNotifier;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    authNotifier = AuthNotifier(mockSupabaseService);
    
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => authNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier Tests', () {
    test('Initial state should be loading', () {
      expect(container.read(authProvider), const AsyncValue<dynamic>.loading());
    });

    test('signIn should update state with user data on success', () async {
      // Arrange
      final mockUser = {'id': '123', 'email': 'test@example.com', 'name': 'Test User'};
      when(mockSupabaseService.signIn('test@example.com', 'password123'))
          .thenAnswer((_) async => mockUser);

      // Act
      await authNotifier.signIn('test@example.com', 'password123');

      // Assert
      expect(container.read(authProvider).value, mockUser);
    });

    test('signIn should update state with error on failure', () async {
      // Arrange
      when(mockSupabaseService.signIn('test@example.com', 'password123'))
          .thenThrow(AuthException('Invalid credentials'));

      // Act
      try {
        await authNotifier.signIn('test@example.com', 'password123');
      } catch (_) {}

      // Assert
      expect(container.read(authProvider).hasError, true);
      expect(
        container.read(authProvider).error,
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Invalid credentials',
        ),
      );
    });

    test('signUp should update state with user data on success', () async {
      // Arrange
      final mockUser = {'id': '123', 'email': 'test@example.com', 'name': 'Test User'};
      when(mockSupabaseService.signUp('test@example.com', 'password123', 'Test User'))
          .thenAnswer((_) async => mockUser);

      // Act
      await authNotifier.signUp('test@example.com', 'password123', 'Test User');

      // Assert
      expect(container.read(authProvider).value, mockUser);
    });

    test('signUp should update state with error on failure', () async {
      // Arrange
      when(mockSupabaseService.signUp('test@example.com', 'password123', 'Test User'))
          .thenThrow(AuthException('Email already exists'));

      // Act
      try {
        await authNotifier.signUp('test@example.com', 'password123', 'Test User');
      } catch (_) {}

      // Assert
      expect(container.read(authProvider).hasError, true);
      expect(
        container.read(authProvider).error,
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Email already exists',
        ),
      );
    });

    test('signOut should update state to null on success', () async {
      // Arrange
      final mockUser = {'id': '123', 'email': 'test@example.com', 'name': 'Test User'};
      authNotifier.state = AsyncValue.data(mockUser);
      when(mockSupabaseService.signOut()).thenAnswer((_) async {});

      // Act
      await authNotifier.signOut();

      // Assert
      expect(container.read(authProvider).value, null);
    });

    test('signOut should update state with error on failure', () async {
      // Arrange
      final mockUser = {'id': '123', 'email': 'test@example.com', 'name': 'Test User'};
      authNotifier.state = AsyncValue.data(mockUser);
      when(mockSupabaseService.signOut())
          .thenThrow(AuthException('Failed to sign out'));

      // Act
      try {
        await authNotifier.signOut();
      } catch (_) {}

      // Assert
      expect(container.read(authProvider).hasError, true);
      expect(
        container.read(authProvider).error,
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Failed to sign out',
        ),
      );
    });

    test('resetPassword should complete without error on success', () async {
      // Arrange
      when(mockSupabaseService.resetPassword('test@example.com'))
          .thenAnswer((_) async {});

      // Act & Assert
      expect(
        authNotifier.resetPassword('test@example.com'),
        completes,
      );
    });

    test('resetPassword should throw exception on failure', () async {
      // Arrange
      when(mockSupabaseService.resetPassword('test@example.com'))
          .thenThrow(AuthException('Invalid email'));

      // Act & Assert
      expect(
        authNotifier.resetPassword('test@example.com'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Invalid email',
          ),
        ),
      );
    });

    test('getCurrentUser should update state with user data on success', () async {
      // Arrange
      final mockUser = {'id': '123', 'email': 'test@example.com', 'name': 'Test User'};
      when(mockSupabaseService.getCurrentUser())
          .thenAnswer((_) async => mockUser);

      // Act
      await authNotifier.getCurrentUser();

      // Assert
      expect(container.read(authProvider).value, mockUser);
    });

    test('getCurrentUser should update state to null when no user is logged in', () async {
      // Arrange
      when(mockSupabaseService.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      await authNotifier.getCurrentUser();

      // Assert
      expect(container.read(authProvider).value, null);
    });

    test('updateUserProfile should update state with updated user data on success', () async {
      // Arrange
      final mockUser = {'id': '123', 'email': 'test@example.com', 'name': 'Test User'};
      final updatedUser = {'id': '123', 'email': 'test@example.com', 'name': 'Updated User'};
      authNotifier.state = AsyncValue.data(mockUser);
      
      when(mockSupabaseService.updateUserProfile({'name': 'Updated User'}))
          .thenAnswer((_) async => updatedUser);

      // Act
      await authNotifier.updateUserProfile({'name': 'Updated User'});

      // Assert
      expect(container.read(authProvider).value, updatedUser);
    });

    test('updateUserProfile should update state with error on failure', () async {
      // Arrange
      final mockUser = {'id': '123', 'email': 'test@example.com', 'name': 'Test User'};
      authNotifier.state = AsyncValue.data(mockUser);
      
      when(mockSupabaseService.updateUserProfile({'name': 'Updated User'}))
          .thenThrow(AuthException('Failed to update profile'));

      // Act
      try {
        await authNotifier.updateUserProfile({'name': 'Updated User'});
      } catch (_) {}

      // Assert
      expect(container.read(authProvider).hasError, true);
      expect(
        container.read(authProvider).error,
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Failed to update profile',
        ),
      );
    });
  });
}

