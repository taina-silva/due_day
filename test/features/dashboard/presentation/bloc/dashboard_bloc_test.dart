import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/dashboard_test_helpers.dart';

void main() {
  late MockGetDashboardSummary mockGetDashboardSummary;
  late MockSyncRecurringTransactions mockSyncRecurringTransactions;
  late MockGetAccounts mockGetAccounts;
  late MockGetTransactions mockGetTransactions;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockAddNotification mockAddNotification;
  late MockSettingsBloc mockSettingsBloc;
  late DashboardBloc dashboardBloc;

  setUp(() {
    mockGetDashboardSummary = MockGetDashboardSummary();
    mockSyncRecurringTransactions = MockSyncRecurringTransactions();
    mockGetAccounts = MockGetAccounts();
    mockGetTransactions = MockGetTransactions();
    mockGetCurrentUser = MockGetCurrentUser();
    mockAddNotification = MockAddNotification();
    mockSettingsBloc = MockSettingsBloc();
    when(() => mockSettingsBloc.state).thenReturn(const SettingsState());

    dashboardBloc = DashboardBloc(
      getDashboardSummary: mockGetDashboardSummary,
      syncRecurringTransactions: mockSyncRecurringTransactions,
      getAccounts: mockGetAccounts,
      getTransactions: mockGetTransactions,
      getCurrentUser: mockGetCurrentUser,
      addNotification: mockAddNotification,
      settingsBloc: mockSettingsBloc,
    );
  });

  tearDown(() {
    dashboardBloc.close();
  });

  test('initial state should be DashboardInitial', () {
    expect(dashboardBloc.state, equals(DashboardInitial()));
  });

  group('DashboardLoadRequested', () {
    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardLoaded] when data is fetched successfully',
      build: () {
        when(
          () => mockGetAccounts(),
        ).thenAnswer((_) => Stream.value(Right([tAccount1, tAccount2])));
        when(() => mockGetTransactions()).thenAnswer(
          (_) => Stream.value(Right([tIncomeTx, tExpenseTx, tUnpaidExpenseTx])),
        );
        when(
          () => mockGetDashboardSummary(
            accounts: any(named: 'accounts'),
            transactions: any(named: 'transactions'),
          ),
        ).thenReturn(tDashboardSummary);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        DashboardLoading(),
        DashboardLoaded(tDashboardSummary, selectedAccountIds: const []),
      ],
      verify: (_) {
        verify(() => mockGetAccounts()).called(1);
        verify(() => mockGetTransactions()).called(1);
        verify(
          () => mockGetDashboardSummary(
            accounts: [tAccount1, tAccount2],
            transactions: [tIncomeTx, tExpenseTx, tUnpaidExpenseTx],
          ),
        ).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardError] when getAccounts fails',
      build: () {
        when(() => mockGetAccounts()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Accounts error'))),
        );
        when(
          () => mockGetTransactions(),
        ).thenAnswer((_) => Stream.value(Right([tIncomeTx])));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        DashboardLoading(),
        const DashboardError(ServerFailure('Accounts error')),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardError] when getTransactions fails',
      build: () {
        when(
          () => mockGetAccounts(),
        ).thenAnswer((_) => Stream.value(Right([tAccount1])));
        when(() => mockGetTransactions()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Transactions error'))),
        );
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        DashboardLoading(),
        const DashboardError(ServerFailure('Transactions error')),
      ],
    );
  });

  group('DashboardSyncRecurringRequested', () {
    blocTest<DashboardBloc, DashboardState>(
      'should call SyncRecurringTransactions when user is authenticated',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => Right(tUserEntity));
        when(
          () => mockSyncRecurringTransactions(any()),
        ).thenAnswer((_) async => <TransactionEntity>[]);
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(DashboardSyncRecurringRequested()),
      expect: () => <DashboardState>[],
      verify: (_) {
        verify(() => mockGetCurrentUser()).called(1);
        verify(() => mockSyncRecurringTransactions('user-1')).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'should not call SyncRecurringTransactions when user is not authenticated',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => const Right(null));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(DashboardSyncRecurringRequested()),
      expect: () => <DashboardState>[],
      verify: (_) {
        verify(() => mockGetCurrentUser()).called(1);
        verifyNever(() => mockSyncRecurringTransactions(any()));
      },
    );
  });

  group('DashboardFilterAccountsRequested', () {
    blocTest<DashboardBloc, DashboardState>(
      'should filter accounts and transactions and emit DashboardLoaded',
      build: () {
        // First load the data so the last emitted accounts/transactions are captured
        when(
          () => mockGetAccounts(),
        ).thenAnswer((_) => Stream.value(Right([tAccount1, tAccount2])));
        when(() => mockGetTransactions()).thenAnswer(
          (_) => Stream.value(Right([tIncomeTx, tExpenseTx, tUnpaidExpenseTx])),
        );
        when(
          () => mockGetDashboardSummary(
            accounts: any(named: 'accounts'),
            transactions: any(named: 'transactions'),
          ),
        ).thenReturn(tDashboardSummary);
        return dashboardBloc;
      },
      act: (bloc) async {
        bloc.add(const DashboardLoadRequested());
        // Wait for load to finish
        await Future.delayed(Duration.zero);
        // Request filter
        bloc.add(const DashboardFilterAccountsRequested(['acc-1']));
      },
      expect: () => [
        DashboardLoading(),
        DashboardLoaded(tDashboardSummary, selectedAccountIds: const []),
        DashboardLoaded(tDashboardSummary, selectedAccountIds: const ['acc-1']),
      ],
      verify: (_) {
        // Verify that the second call to getDashboardSummary only received filtered accounts and transactions
        verify(
          () => mockGetDashboardSummary(
            accounts: [tAccount1], // acc-1 only
            // tIncomeTx accountTo is acc-1, tExpenseTx accountFrom is acc-1, tUnpaidExpenseTx accountFrom is acc-1
            transactions: [tIncomeTx, tExpenseTx, tUnpaidExpenseTx],
          ),
        ).called(1);
      },
    );
  });
}
