import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/schedule_test_helpers.dart';

class FakeTransactionEntity extends Fake implements TransactionEntity {}

void main() {
  late MockUpdateTransaction mockUpdateTransaction;
  late ScheduleActionBloc scheduleActionBloc;

  setUpAll(() {
    registerFallbackValue(FakeTransactionEntity());
  });

  setUp(() {
    mockUpdateTransaction = MockUpdateTransaction();
    scheduleActionBloc = ScheduleActionBloc(
      updateTransaction: mockUpdateTransaction,
    );
  });

  tearDown(() {
    scheduleActionBloc.close();
  });

  test('initial state should be ScheduleActionInitial', () {
    expect(scheduleActionBloc.state, equals(ScheduleActionInitial()));
  });

  group('MarkAsPaidEvent', () {
    final transactionToPay = tExpenseTransactions[1]; // unpaid expense

    blocTest<ScheduleActionBloc, ScheduleActionState>(
      'should emit [ScheduleActionInProgress, ScheduleActionSuccess] and '
      'mark the transaction as paid when UpdateTransaction succeeds',
      build: () {
        when(
          () => mockUpdateTransaction(any()),
        ).thenAnswer((_) async => Right(transactionToPay));
        return scheduleActionBloc;
      },
      act: (bloc) => bloc.add(MarkAsPaidEvent(transactionToPay)),
      expect: () => [ScheduleActionInProgress(), ScheduleActionSuccess()],
      verify: (_) {
        verify(
          () => mockUpdateTransaction(
            any(
              that: isA<TransactionEntity>()
                  .having((t) => t.id, 'id', transactionToPay.id)
                  .having((t) => t.paid, 'paid', true)
                  .having(
                    (t) => t.parentRecurringId,
                    'parentRecurringId',
                    transactionToPay.parentRecurringId,
                  ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ScheduleActionBloc, ScheduleActionState>(
      'should emit [ScheduleActionInProgress, ScheduleActionError] when '
      'UpdateTransaction fails',
      build: () {
        when(
          () => mockUpdateTransaction(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));
        return scheduleActionBloc;
      },
      act: (bloc) => bloc.add(MarkAsPaidEvent(transactionToPay)),
      expect: () => [
        ScheduleActionInProgress(),
        const ScheduleActionError(ServerFailure('Update failed')),
      ],
    );
  });
}
