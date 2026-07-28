import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/dashboard_test_helpers.dart';

void main() {
  late MockGetDashboardSummary mockGetDashboardSummary;
  late MockGetAccounts mockGetAccounts;
  late MockGetTransactions mockGetTransactions;
  late DashboardBloc dashboardBloc;

  setUp(() {
    mockGetDashboardSummary = MockGetDashboardSummary();
    mockGetAccounts = MockGetAccounts();
    mockGetTransactions = MockGetTransactions();

    dashboardBloc = DashboardBloc(
      getDashboardSummary: mockGetDashboardSummary,
      getAccounts: mockGetAccounts,
      getTransactions: mockGetTransactions,
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
