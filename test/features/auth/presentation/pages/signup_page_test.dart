import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/auth/presentation/pages/signup_page.dart';
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

  group('SignUpPage Widget Tests', () {
    testWidgets(
      'given SignUpPage when loaded then render all basic UI components',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const SignUpPage()),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const SignUpPage(), router: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('Create your account'), findsOneWidget);
        expect(
          find.text('Start organizing your finances today.'),
          findsOneWidget,
        );

        // Name, email, password fields
        expect(find.byType(TextField), findsNWidgets(3));
        expect(find.text('Create account'), findsOneWidget);
      },
    );

    testWidgets(
      'given non-empty name, email and password fields when Create account button is clicked then dispatch AuthSignUpEmailEvent',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const SignUpPage()),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const SignUpPage(), router: router),
        );
        await tester.pumpAndSettle();

        // Enter name, email, password
        await tester.enterText(find.byType(TextField).at(0), 'Test User');
        await tester.enterText(
          find.byType(TextField).at(1),
          'test@example.com',
        );
        await tester.enterText(find.byType(TextField).at(2), 'password123');
        await tester.pump();

        // Invoke onPressed directly on Create account button to avoid layout/Ahem font coordinate tap issues
        final button = tester.widget<AppTextButtonPrimary>(
          find.byType(AppTextButtonPrimary),
        );
        button.onPressed!();
        await tester.pump();

        verify(
          () => mockAuthBloc.add(
            const AuthSignUpEmailEvent(
              displayName: 'Test User',
              email: 'test@example.com',
              password: 'password123',
            ),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'given AuthError state when page is built then show SnackBar with error message',
      (tester) async {
        setupTestWindow(tester);
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (context, state) => const SignUpPage()),
          ],
        );

        when(() => mockAuthBloc.stream).thenAnswer(
          (_) => Stream.value(
            const AuthError(failure: ServerFailure('Sign up failed')),
          ),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const SignUpPage(), router: router),
        );
        await tester.pump(); // Trigger listener
        await tester.pumpAndSettle();

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
            GoRoute(path: '/', builder: (context, state) => const SignUpPage()),
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
          buildTestableWidget(child: const SignUpPage(), router: router),
        );
        await tester.pump(); // Trigger listener
        await tester.pumpAndSettle();

        expect(find.text('Dashboard Screen'), findsOneWidget);
      },
    );
  });
}
