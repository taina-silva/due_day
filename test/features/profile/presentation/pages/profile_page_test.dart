import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../auth/helpers/auth_test_helpers.dart';

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockSecurityService extends Mock implements SecurityService {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockSecurityService mockSecurityService;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockSecurityService = MockSecurityService();

    // Setup default states
    when(() => mockAuthBloc.state).thenReturn(
      AuthAuthenticated(user: tUserEntity),
    );
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockSettingsBloc.state).thenReturn(
      const SettingsState(
        languageCode: 'en',
        themeMode: ThemeMode.system,
        pushNotificationsEnabled: true,
        isBiometricsEnabled: false,
      ),
    );
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());

    // Register mocks in service locator
    sl.reset();
    sl.registerLazySingleton<SecurityService>(() => mockSecurityService);
  });

  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestableWidget({
    required Widget child,
    required GoRouter router,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
  }

  group('ProfilePage Widget Tests', () {
    testWidgets(
      'given ProfilePage loaded when authenticated then render user profile details',
      (tester) async {
        setupTestWindow(tester);

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const ProfilePage(), router: router),
        );
        await tester.pumpAndSettle();

        // Verify user initials, name, and email
        expect(find.text('TU'), findsOneWidget); // Initials of "Test User"
        expect(find.text('Test User'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);

        // Verify that Settings sections are displayed
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Biometric Security'), findsOneWidget);

        // Verify actions
        expect(find.text('Log Out'), findsOneWidget);
        expect(find.text('Delete Account'), findsOneWidget);
      },
    );
  });
}
