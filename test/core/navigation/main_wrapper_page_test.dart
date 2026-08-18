import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/navigation/biometric_lock_overlay.dart';
import 'package:due_day/core/navigation/main_wrapper_page.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAccountLoadBloc extends MockBloc<AccountLoadEvent, AccountLoadState>
    implements AccountLoadBloc {}

class MockCategoryLoadBloc
    extends MockBloc<CategoryLoadEvent, CategoryLoadState>
    implements CategoryLoadBloc {}

class MockTransactionLoadBloc
    extends MockBloc<TransactionLoadEvent, TransactionLoadState>
    implements TransactionLoadBloc {}

class MockNotificationsLoadBloc
    extends MockBloc<NotificationsLoadEvent, NotificationsLoadState>
    implements NotificationsLoadBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockSecurityService extends Mock implements SecurityService {}

void main() {
  late MockAccountLoadBloc mockAccountBloc;
  late MockCategoryLoadBloc mockCategoryLoadBloc;
  late MockTransactionLoadBloc mockTransactionBloc;
  late MockNotificationsLoadBloc mockNotificationsBloc;
  late MockSettingsBloc mockSettingsBloc;
  late MockSecurityService mockSecurityService;

  setUp(() async {
    mockAccountBloc = MockAccountLoadBloc();
    mockCategoryLoadBloc = MockCategoryLoadBloc();
    mockTransactionBloc = MockTransactionLoadBloc();
    mockNotificationsBloc = MockNotificationsLoadBloc();
    mockSettingsBloc = MockSettingsBloc();
    mockSecurityService = MockSecurityService();

    when(() => mockAccountBloc.state).thenReturn(AccountInitial());
    when(() => mockCategoryLoadBloc.state).thenReturn(CategoryInitial());
    when(() => mockTransactionBloc.state).thenReturn(TransactionInitial());
    when(
      () => mockNotificationsBloc.state,
    ).thenReturn(NotificationsInitial());

    // GetIt.reset() is asynchronous; awaiting it avoids a race where its
    // deferred clear() runs after registerLazySingleton and wipes it out.
    await sl.reset();
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

  Widget buildTestableWidget({required bool biometricsEnabled}) {
    when(
      () => mockSettingsBloc.state,
    ).thenReturn(SettingsState(isBiometricsEnabled: biometricsEnabled));
    when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              MainWrapperPage(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const Text('Home'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<AccountLoadBloc>.value(value: mockAccountBloc),
        BlocProvider<CategoryLoadBloc>.value(value: mockCategoryLoadBloc),
        BlocProvider<TransactionLoadBloc>.value(value: mockTransactionBloc),
        BlocProvider<NotificationsLoadBloc>.value(
          value: mockNotificationsBloc,
        ),
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

  group('MainWrapperPage biometric lock', () {
    testWidgets(
      'given biometrics enabled then the lock overlay shows immediately on load',
      (tester) async {
        setupTestWindow(tester);
        final canAuthCompleter = Completer<bool>();
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) => canAuthCompleter.future);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.success);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pump();

        expect(find.byType(BiometricLockOverlay), findsOneWidget);

        canAuthCompleter.complete(true);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'given successful authentication then the lock overlay is dismissed',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.success);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pumpAndSettle();

        expect(find.byType(BiometricLockOverlay), findsNothing);
      },
    );

    testWidgets(
      'given the device has no biometrics available then the app stays '
      'locked instead of bypassing authentication',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => false);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pumpAndSettle();

        expect(find.byType(BiometricLockOverlay), findsOneWidget);
        verifyNever(() => mockSecurityService.authenticate());
      },
    );

    testWidgets(
      'given an authentication already in progress then extra app-resumed '
      'lifecycle events do not trigger a second concurrent authenticate() call',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);

        final authenticateCompleter = Completer<BiometricAuthResult>();
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) => authenticateCompleter.future);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        // Lets the initial _checkInitialLock -> _authenticate() call reach
        // and block on the pending authenticate() future, mirroring how the
        // native biometric prompt itself causes extra resumed events before
        // the first authenticate() call ever resolves.
        await tester.pump();
        await tester.pump();

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        authenticateCompleter.complete(BiometricAuthResult.success);
        await tester.pumpAndSettle();

        verify(() => mockSecurityService.authenticate()).called(1);
      },
    );

    testWidgets(
      'given authentication in progress then the unlock button shows a '
      'loading indicator and is disabled',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);

        final authenticateCompleter = Completer<BiometricAuthResult>();
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) => authenticateCompleter.future);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pump();
        await tester.pump();

        final button = tester.widget<InkWell>(
          find.byKey(const Key('biometric_unlock_button')),
        );
        expect(button.onTap, isNull);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Unlock App'), findsNothing);

        authenticateCompleter.complete(BiometricAuthResult.success);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'given the biometric prompt blips the lifecycle through '
      'inactive/resumed without true backgrounding then it does not '
      'retrigger authenticate()',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.success);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pumpAndSettle();

        expect(find.byType(BiometricLockOverlay), findsNothing);

        // Mirrors the transient inactive -> resumed blip the system
        // biometric prompt itself causes, without ever truly backgrounding
        // the app (i.e. no `paused` state in between).
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        await tester.pump();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        expect(find.byType(BiometricLockOverlay), findsNothing);
        verify(() => mockSecurityService.authenticate()).called(1);
      },
    );

    testWidgets(
      'given the app is genuinely backgrounded and resumed then it re-locks '
      'and calls authenticate() again',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.success);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pumpAndSettle();
        expect(find.byType(BiometricLockOverlay), findsNothing);

        final secondAuthCompleter = Completer<BiometricAuthResult>();
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) => secondAuthCompleter.future);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.paused,
        );
        await tester.pump();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        expect(find.byType(BiometricLockOverlay), findsOneWidget);

        secondAuthCompleter.complete(BiometricAuthResult.success);
        await tester.pumpAndSettle();

        expect(find.byType(BiometricLockOverlay), findsNothing);
        verify(() => mockSecurityService.authenticate()).called(2);
      },
    );

    testWidgets(
      'given the settings toggle already owns an in-flight authentication '
      'then a genuine app resume does not start a competing '
      'authenticate() call',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.success);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pumpAndSettle();
        clearInteractions(mockSecurityService);

        when(() => mockSettingsBloc.state).thenReturn(
          const SettingsState(
            isBiometricsEnabled: true,
            isTogglingBiometrics: true,
          ),
        );

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.paused,
        );
        await tester.pump();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        verifyNever(() => mockSecurityService.authenticate());
      },
    );

    testWidgets(
      'given a temporary lockout then the overlay shows the localized '
      'lockout message',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.lockedOut);

        await tester.pumpWidget(buildTestableWidget(biometricsEnabled: true));
        await tester.pumpAndSettle();

        expect(find.byType(BiometricLockOverlay), findsOneWidget);
        expect(
          find.text(
            'Too many failed attempts. Biometric authentication has been '
            'temporarily locked.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
