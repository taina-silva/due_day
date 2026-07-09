import 'package:due_day/features/schedule/domain/usecases/get_schedule_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/schedule_test_helpers.dart';

void main() {
  late MockTransactionRepository mockTransactionRepository;
  late GetScheduleData getScheduleData;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    getScheduleData = GetScheduleData(mockTransactionRepository);
  });

  test(
    'should return grouped and filtered schedule data from repository',
    () async {
      // Arrange
      when(
        () => mockTransactionRepository.getTransactions(),
      ).thenAnswer((_) => Stream.value(Right(tTransactionsList)));

      // Act
      final resultStream = getScheduleData.execute();

      // Assert
      final result = await resultStream.first;
      expect(result.isRight(), true);

      result.fold((failure) => fail('Should not fail'), (summary) {
        expect(summary.totalAmount, 300.0);
        expect(summary.totalPaid, 200.0);
        expect(summary.totalToPay, 100.0);

        // Transactions list should be filtered: only expenses
        // Sorted by due date: tx-2 (2 days), tx-3 (5 days)
        expect(summary.transactions.length, 2);
        expect(summary.transactions[0].id, 'tx-2');
        expect(summary.transactions[1].id, 'tx-3');

        // Next income is tx-1 (since it is an income and not paid)
        expect(summary.nextIncomeAmount, 1500.0);
        expect(summary.nextIncomeDate, tDateTime.add(const Duration(days: 3)));
      });

      verify(() => mockTransactionRepository.getTransactions()).called(1);
    },
  );
}
