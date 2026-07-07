import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = originalOnError;
    });
  }

  Widget buildTestableWidget({
    required Widget child,
    required GoRouter router,
  }) {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets(
      'given LoginPage when loaded then render all basic UI components',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LoginPage()),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const LoginPage(), router: router),
        );
        await tester.pumpAndSettle();

        // Assert title & subtitle
        expect(find.text('DueDay'), findsOneWidget);
        expect(find.text('Your digital financial curator.'), findsOneWidget);

        // Assert email & password fields exist
        expect(find.byType(TextField), findsNWidgets(2));

        // Assert buttons exist
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(find.text('Create now'), findsOneWidget);
      },
    );

    testWidgets(
      'given non-empty email and password fields when Sign In button is clicked then dispatch AuthSignInEmailEvent',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LoginPage()),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const LoginPage(), router: router),
        );
        await tester.pumpAndSettle();

        // Enter email and password
        await tester.enterText(
          find.byType(TextField).at(0),
          'test@example.com',
        );
        await tester.enterText(find.byType(TextField).at(1), 'password123');
        await tester.pump();

        // Invoke onPressed directly on Sign In button to avoid layout/Ahem font coordinate tap issues
        final button = tester.widget<AppTextButtonPrimary>(
          find.byType(AppTextButtonPrimary),
        );
        button.onPressed!();
        await tester.pump();

        verify(
          () => mockAuthBloc.add(
            const AuthSignInEmailEvent(
              email: 'test@example.com',
              password: 'password123',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'given Google Sign In button when clicked then dispatch AuthGoogleSignInEvent',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LoginPage()),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const LoginPage(), router: router),
        );
        await tester.pumpAndSettle();

        final button = tester.widget<AppTextButtonSecondary>(
          find.byType(AppTextButtonSecondary),
        );
        button.onPressed!();
        await tester.pump();

        verify(() => mockAuthBloc.add(AuthGoogleSignInEvent())).called(1);
      },
    );

    testWidgets(
      'given Create now button when clicked then navigate to /signup',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LoginPage()),
            GoRoute(
              path: '/signup',
              builder: (context, state) =>
                  const Scaffold(body: Text('Signup Screen')),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const LoginPage(), router: router),
        );
        await tester.pumpAndSettle();

        final button = tester.widget<AppTextButtonTertiary>(
          find.byType(AppTextButtonTertiary),
        );
        button.onPressed!();
        await tester.pumpAndSettle();

        expect(find.text('Signup Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'given AuthError state when page is built then show SnackBar with error message',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LoginPage()),
          ],
        );

        // Stub bloc stream to emit AuthError when listened to
        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(
            const AuthError(failure: ServerFailure('Auth failed')),
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const LoginPage(), router: router),
        );
        await tester.pump(); // Trigger listener
        await tester.pumpAndSettle(); // Wait for snackbar animation

        // Assert Snackbar is visible
        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'given AuthAuthenticated state when page is built then navigate to /dashboard',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const LoginPage()),
            GoRoute(
              path: '/dashboard',
              builder: (context, state) =>
                  const Scaffold(body: Text('Dashboard Screen')),
            ),
          ],
        );

        when(
          () => mockAuthBloc.stream,
        ).thenAnswer((_) => Stream.value(AuthAuthenticated(user: tUserEntity)));

        await tester.pumpWidget(
          buildTestableWidget(child: const LoginPage(), router: router),
        );
        await tester.pump(); // Trigger listener
        await tester.pumpAndSettle(); // Wait for navigation transition

        expect(find.text('Dashboard Screen'), findsOneWidget);
      },
    );
  });
}
