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
  late MockGetCategories mockGetCategories;
  late DashboardBloc dashboardBloc;

  final tNow = DateTime(2026, 7, 20);
  final tJuly = DateTime(2026, 7);
  final tJune = DateTime(2026, 6);

  setUpAll(() => registerFallbackValue(DateTime(2000)));

  setUp(() {
    mockGetDashboardSummary = MockGetDashboardSummary();
    mockGetAccounts = MockGetAccounts();
    mockGetTransactions = MockGetTransactions();
    mockGetCategories = MockGetCategories();

    dashboardBloc = DashboardBloc(
      getDashboardSummary: mockGetDashboardSummary,
      getAccounts: mockGetAccounts,
      getTransactions: mockGetTransactions,
      getCategories: mockGetCategories,
      now: () => tNow,
    );
  });

  tearDown(() {
    dashboardBloc.close();
  });

  void stubStreams() {
    when(
      () => mockGetAccounts(),
    ).thenAnswer((_) => Stream.value(Right([tAccount1, tAccount2])));
    when(() => mockGetTransactions()).thenAnswer(
      (_) => Stream.value(Right([tIncomeTx, tExpenseTx, tUnpaidExpenseTx])),
    );
    when(
      () => mockGetCategories(),
    ).thenAnswer((_) => Stream.value(Right([tCategory1])));
    when(
      () => mockGetDashboardSummary(
        month: any(named: 'month'),
        transactions: any(named: 'transactions'),
        categories: any(named: 'categories'),
        now: any(named: 'now'),
      ),
    ).thenReturn(tDashboardSummary);
  }

  test('initial state is DashboardInitial and month is the current one', () {
    expect(dashboardBloc.state, equals(DashboardInitial()));
    expect(dashboardBloc.selectedMonth, tJuly);
  });

  group('DashboardLoadRequested', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Loaded] with the current month when data loads',
      build: () {
        stubStreams();
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        DashboardLoading(),
        DashboardLoaded(tDashboardSummary, selectedAccountIds: const []),
      ],
      verify: (_) {
        verify(
          () => mockGetDashboardSummary(
            month: tJuly,
            transactions: [tIncomeTx, tExpenseTx, tUnpaidExpenseTx],
            categories: [tCategory1],
            now: tNow,
          ),
        ).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Error] when getAccounts fails',
      build: () {
        stubStreams();
        when(() => mockGetAccounts()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Accounts error'))),
        );
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        DashboardLoading(),
        const DashboardError(ServerFailure('Accounts error')),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Error] when getTransactions fails',
      build: () {
        stubStreams();
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

    blocTest<DashboardBloc, DashboardState>(
      'emits [Loading, Error] when getCategories fails',
      build: () {
        stubStreams();
        when(() => mockGetCategories()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Categories error'))),
        );
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const DashboardLoadRequested()),
      expect: () => [
        DashboardLoading(),
        const DashboardError(ServerFailure('Categories error')),
      ],
    );
  });

  group('DashboardMonthChanged', () {
    blocTest<DashboardBloc, DashboardState>(
      'DSH-001: going back recomputes every total for the previous month',
      build: () {
        stubStreams();
        return dashboardBloc;
      },
      act: (bloc) async {
        bloc.add(const DashboardLoadRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(DashboardMonthChanged(DateTime(2026, 6, 15)));
      },
      verify: (bloc) {
        expect(bloc.selectedMonth, tJune);
        verify(
          () => mockGetDashboardSummary(
            month: tJune,
            transactions: any(named: 'transactions'),
            categories: any(named: 'categories'),
            now: any(named: 'now'),
          ),
        ).called(1);
      },
    );
  });

  group('DashboardFilterAccountsRequested', () {
    blocTest<DashboardBloc, DashboardState>(
      'filters transactions by account and emits DashboardLoaded',
      build: () {
        stubStreams();
        return dashboardBloc;
      },
      act: (bloc) async {
        bloc.add(const DashboardLoadRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DashboardFilterAccountsRequested(['acc-2']));
      },
      expect: () => [
        DashboardLoading(),
        DashboardLoaded(tDashboardSummary, selectedAccountIds: const []),
        DashboardLoaded(tDashboardSummary, selectedAccountIds: const ['acc-2']),
      ],
      verify: (_) {
        verify(
          () => mockGetDashboardSummary(
            month: tJuly,
            transactions: const [],
            categories: [tCategory1],
            now: tNow,
          ),
        ).called(1);
      },
    );
  });
}
