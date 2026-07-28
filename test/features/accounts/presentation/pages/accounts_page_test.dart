import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/accounts/presentation/pages/accounts_page.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/account_test_helpers.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsLoadEvent, NotificationsLoadState>
    implements NotificationsLoadBloc {}

void main() {
  late MockAccountLoadBloc mockAccountLoadBloc;
  late MockNotificationsBloc mockNotificationsBloc;

  setUp(() {
    mockAccountLoadBloc = MockAccountLoadBloc();
    when(() => mockAccountLoadBloc.state).thenReturn(AccountInitial());
    when(
      () => mockAccountLoadBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    mockNotificationsBloc = MockNotificationsBloc();
    when(() => mockNotificationsBloc.state).thenReturn(NotificationsInitial());
    when(
      () => mockNotificationsBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
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
        BlocProvider<AccountLoadBloc>.value(value: mockAccountLoadBloc),
        BlocProvider<NotificationsLoadBloc>.value(value: mockNotificationsBloc),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
  }

  group('AccountsPage Widget Tests', () {
    testWidgets(
      'given AccountLoading/Initial state when page loads then show CircularProgressIndicator',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockAccountLoadBloc.state).thenReturn(AccountLoading());

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const AccountsPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const AccountsPage(), router: router),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'given AccountError state when page loads then display failure localized message',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockAccountLoadBloc.state).thenReturn(
          const AccountError(failure: ServerFailure('Server failure message')),
        );

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const AccountsPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const AccountsPage(), router: router),
        );
        await tester.pump();

        expect(
          find.text('An error occurred while managing your accounts.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given AccountLoaded state when page loads then display accounts list and total balance',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockAccountLoadBloc.state).thenReturn(
          AccountLoaded(accounts: [tAccountEntity, tCreditCardAccountEntity]),
        );

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const AccountsPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const AccountsPage(), router: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('Checking Account'), findsOneWidget);
        expect(find.text('Main Credit Card'), findsOneWidget);
        expect(find.text('Add Account'), findsOneWidget);
      },
    );

    testWidgets(
      'given AccountLoaded state with no active accounts then show the empty state',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockAccountLoadBloc.state,
        ).thenReturn(const AccountLoaded(accounts: []));

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const AccountsPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const AccountsPage(), router: router),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('No accounts added. Start by creating one!'),
          findsOneWidget,
        );
      },
    );
  });
}
