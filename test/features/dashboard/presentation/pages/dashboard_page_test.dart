import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:due_day/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../auth/helpers/auth_test_helpers.dart';
import '../../../transactions/helpers/transaction_test_helpers.dart'
    show MockAccountLoadBloc, MockCategoryLoadBloc;
import '../../helpers/dashboard_test_helpers.dart';

class MockDashboardBloc extends MockBloc<DashboardEvent, DashboardState>
    implements DashboardBloc {}

class MockTransactionLoadBloc
    extends MockBloc<TransactionLoadEvent, TransactionLoadState>
    implements TransactionLoadBloc {}

class MockNotificationsLoadBloc
    extends MockBloc<NotificationsLoadEvent, NotificationsLoadState>
    implements NotificationsLoadBloc {}

void main() {
  late MockDashboardBloc dashboardBloc;
  late MockAuthBloc authBloc;
  late MockAccountLoadBloc accountLoadBloc;
  late MockCategoryLoadBloc categoryLoadBloc;
  late MockTransactionLoadBloc transactionLoadBloc;
  late MockNotificationsLoadBloc notificationsBloc;

  setUp(() {
    dashboardBloc = MockDashboardBloc();
    authBloc = MockAuthBloc();
    accountLoadBloc = MockAccountLoadBloc();
    categoryLoadBloc = MockCategoryLoadBloc();
    transactionLoadBloc = MockTransactionLoadBloc();
    notificationsBloc = MockNotificationsLoadBloc();

    when(
      () => dashboardBloc.state,
    ).thenReturn(DashboardLoaded(tDashboardSummary));
    // No photoUrl, so the avatar renders initials instead of a network load.
    final user = UserEntity(
      uid: tUserEntity.uid,
      email: tUserEntity.email,
      name: tUserEntity.name,
      createdAt: tUserEntity.createdAt,
    );
    when(() => authBloc.state).thenReturn(AuthAuthenticated(user: user));
    when(
      () => accountLoadBloc.state,
    ).thenReturn(AccountLoaded(accounts: [tAccount1]));
    when(
      () => categoryLoadBloc.state,
    ).thenReturn(CategoryLoaded(categories: [tCategory1]));
    when(() => transactionLoadBloc.state).thenReturn(TransactionInitial());
    when(() => notificationsBloc.state).thenReturn(NotificationsInitial());
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<DashboardBloc>.value(value: dashboardBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<AccountLoadBloc>.value(value: accountLoadBloc),
          BlocProvider<CategoryLoadBloc>.value(value: categoryLoadBloc),
          BlocProvider<TransactionLoadBloc>.value(value: transactionLoadBloc),
          BlocProvider<NotificationsLoadBloc>.value(value: notificationsBloc),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: DashboardPage(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('DSH-007: opening the dashboard shows no current or projected '
      'balance', (tester) async {
    await pump(tester);

    expect(
      find.textContaining(RegExp('balance', caseSensitive: false)),
      findsNothing,
    );
    expect(find.text('Spent'), findsOneWidget);
    expect(find.text('Incomes'), findsOneWidget);
    expect(find.text('Invested'), findsOneWidget);
  });

  testWidgets('DSH-001: the header shows month and year and steps months', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('July 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    verify(
      () => dashboardBloc.add(DashboardMonthChanged(DateTime(2026, 6))),
    ).called(1);

    await tester.tap(find.byTooltip('Next month'));
    verify(
      () => dashboardBloc.add(DashboardMonthChanged(DateTime(2026, 8))),
    ).called(1);
  });
}
