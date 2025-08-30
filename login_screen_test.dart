import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:indian_tv_streaming_app/features/auth/screens/login_screen.dart';
import 'package:indian_tv_streaming_app/features/auth/providers/auth_provider.dart';
import 'package:indian_tv_streaming_app/core/utils/exceptions.dart';

// Generate mock classes
@GenerateMocks([AuthNotifier, GoRouter])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockGoRouter mockGoRouter;
  late ProviderContainer container;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    mockGoRouter = MockGoRouter();
    
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('LoginScreen displays all required elements', (WidgetTester tester) async {
    // Build the LoginScreen widget
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify that the app logo is displayed
    expect(find.byType(Image), findsOneWidget);
    
    // Verify that the welcome text is displayed
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    
    // Verify that the email and password fields are displayed
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    
    // Verify that the forgot password link is displayed
    expect(find.text('Forgot Password?'), findsOneWidget);
    
    // Verify that the login button is displayed
    expect(find.text('Login'), findsOneWidget);
    
    // Verify that the sign up link is displayed
    expect(find.text('Don\'t have an account?'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation errors for empty fields', (WidgetTester tester) async {
    // Build the LoginScreen widget
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Tap the login button without entering any data
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that validation error messages are displayed
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation error for invalid email', (WidgetTester tester) async {
    // Build the LoginScreen widget
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Enter invalid email and valid password
    await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
    await tester.enterText(find.byKey(const Key('password_field')), 'password123');
    
    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that validation error message is displayed for email
    expect(find.text('Please enter a valid email'), findsOneWidget);
    
    // Verify that no validation error is displayed for password
    expect(find.text('Please enter your password'), findsNothing);
  });

  testWidgets('LoginScreen calls signIn when form is valid', (WidgetTester tester) async {
    // Arrange
    when(mockAuthNotifier.signIn('test@example.com', 'password123'))
        .thenAnswer((_) async => {});

    // Build the LoginScreen widget
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Enter valid email and password
    await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password123');
    
    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that signIn was called with the correct parameters
    verify(mockAuthNotifier.signIn('test@example.com', 'password123')).called(1);
  });

  testWidgets('LoginScreen shows error dialog when signIn fails', (WidgetTester tester) async {
    // Arrange
    when(mockAuthNotifier.signIn('test@example.com', 'password123'))
        .thenThrow(AuthException('Invalid credentials'));

    // Build the LoginScreen widget
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Enter valid email and password
    await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password123');
    
    // Tap the login button
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify that error dialog is displayed
    expect(find.text('Login Error'), findsOneWidget);
    expect(find.text('Invalid credentials'), findsOneWidget);
    
    // Tap the OK button to dismiss the dialog
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    
    // Verify that the dialog is dismissed
    expect(find.text('Login Error'), findsNothing);
  });

  testWidgets('LoginScreen navigates to forgot password screen', (WidgetTester tester) async {
    // Build the LoginScreen widget with GoRouter
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: LoginScreen(),
          ),
        ),
      ),
    );

    // Tap the forgot password link
    await tester.tap(find.text('Forgot Password?'));
    await tester.pump();

    // Verify that push was called with the correct route
    verify(mockGoRouter.push('/auth/forgot-password')).called(1);
  });

  testWidgets('LoginScreen navigates to sign up screen', (WidgetTester tester) async {
    // Build the LoginScreen widget with GoRouter
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockGoRouter,
            child: LoginScreen(),
          ),
        ),
      ),
    );

    // Tap the sign up link
    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    // Verify that push was called with the correct route
    verify(mockGoRouter.push('/auth/signup')).called(1);
  });
}

// Mock InheritedGoRouter for testing
class InheritedGoRouter extends InheritedWidget {
  final GoRouter goRouter;

  const InheritedGoRouter({
    Key? key,
    required this.goRouter,
    required Widget child,
  }) : super(key: key, child: child);

  static InheritedGoRouter of(BuildContext context) {
    final InheritedGoRouter? result =
        context.dependOnInheritedWidgetOfExactType<InheritedGoRouter>();
    assert(result != null, 'No GoRouter found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedGoRouter oldWidget) {
    return goRouter != oldWidget.goRouter;
  }
}

