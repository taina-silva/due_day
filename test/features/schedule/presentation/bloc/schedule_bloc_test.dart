import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/schedule_test_helpers.dart';

class FakeTransactionEntity extends Fake implements TransactionEntity {}

void main() {
  late MockGetScheduleData mockGetScheduleData;
  late MockGetCategories mockGetCategories;
  late MockUpdateTransaction mockUpdateTransaction;
  late ScheduleBloc scheduleBloc;

  setUpAll(() {
    registerFallbackValue(FakeTransactionEntity());
  });

  setUp(() {
    mockGetScheduleData = MockGetScheduleData();
    mockGetCategories = MockGetCategories();
    mockUpdateTransaction = MockUpdateTransaction();

    scheduleBloc = ScheduleBloc(
      getScheduleData: mockGetScheduleData,
      getCategories: mockGetCategories,
      updateTransaction: mockUpdateTransaction,
    );
  });

  tearDown(() {
    scheduleBloc.close();
  });

  test('initial state should be ScheduleInitial', () {
    expect(scheduleBloc.state, equals(ScheduleInitial()));
  });

  group('LoadScheduleData', () {
    blocTest<ScheduleBloc, ScheduleState>(
      'should emit [ScheduleLoading, ScheduleLoaded] when data is loaded successfully',
      build: () {
        when(
          () => mockGetScheduleData.execute(),
        ).thenAnswer((_) => Stream.value(Right(tScheduleSummary)));
        when(() => mockGetCategories.call()).thenAnswer(
          (_) => Stream.value(Right([tCategoryIncome, tCategoryExpense])),
        );
        return scheduleBloc;
      },
      act: (bloc) => bloc.add(LoadScheduleData()),
      expect: () => [
        ScheduleLoading(),
        ScheduleLoaded(
          tScheduleSummary,
          categories: {
            tCategoryIncome.id: tCategoryIncome,
            tCategoryExpense.id: tCategoryExpense,
          },
        ),
      ],
      verify: (_) {
        verify(() => mockGetScheduleData.execute()).called(1);
        verify(() => mockGetCategories.call()).called(1);
      },
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'should emit [ScheduleLoading, ScheduleError] when getScheduleData fails',
      build: () {
        when(() => mockGetScheduleData.execute()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Schedule error'))),
        );
        when(
          () => mockGetCategories.call(),
        ).thenAnswer((_) => Stream.value(Right([tCategoryIncome])));
        return scheduleBloc;
      },
      act: (bloc) => bloc.add(LoadScheduleData()),
      expect: () => [
        ScheduleLoading(),
        const ScheduleError(ServerFailure('Schedule error')),
      ],
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'should emit [ScheduleLoading, ScheduleError] when getCategories fails',
      build: () {
        when(
          () => mockGetScheduleData.execute(),
        ).thenAnswer((_) => Stream.value(Right(tScheduleSummary)));
        when(() => mockGetCategories.call()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Categories error'))),
        );
        return scheduleBloc;
      },
      act: (bloc) => bloc.add(LoadScheduleData()),
      expect: () => [
        ScheduleLoading(),
        const ScheduleError(ServerFailure('Categories error')),
      ],
    );
  });

  group('MarkAsPaid', () {
    final transactionToPay = tTransactionsList[2]; // tx-3, unpaid expense

    blocTest<ScheduleBloc, ScheduleState>(
      'should call UpdateTransaction when MarkAsPaid is added',
      build: () {
        when(
          () => mockUpdateTransaction(any()),
        ).thenAnswer((_) async => Right(transactionToPay));
        return scheduleBloc;
      },
      act: (bloc) => bloc.add(MarkAsPaid(transactionToPay)),
      expect: () => <ScheduleState>[],
      verify: (_) {
        verify(
          () => mockUpdateTransaction(
            any(
              that: isA<TransactionEntity>().having(
                (t) => t.id,
                'id',
                transactionToPay.id,
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ScheduleBloc, ScheduleState>(
      'should emit ScheduleError when UpdateTransaction fails',
      build: () {
        when(
          () => mockUpdateTransaction(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));
        return scheduleBloc;
      },
      act: (bloc) => bloc.add(MarkAsPaid(transactionToPay)),
      expect: () => [const ScheduleError(ServerFailure('Update failed'))],
    );
  });
}
