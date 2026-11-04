import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

void main() {
  late MockTransactionRepository mockTransactionRepository;
  late MockAccountRepository mockAccountRepository;

  setUpAll(() {
    registerFallbackValue(tTransactionEntity);
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockAccountRepository = MockAccountRepository();
  });

  group('AddTransaction', () {
    test(
      'TRX-004: adding a paid expense writes only the transaction',
      () async {
        final usecase = AddTransaction(mockTransactionRepository);
        when(
          () => mockTransactionRepository.addTransaction(any()),
        ).thenAnswer((_) async => Right(tTransactionEntity));

        final result = await usecase(tTransactionEntity);

        expect(tTransactionEntity.paid, isTrue);
        expect(result, Right(tTransactionEntity));
        verify(
          () => mockTransactionRepository.addTransaction(tTransactionEntity),
        ).called(1);
        verifyZeroInteractions(mockAccountRepository);
      },
    );

    test('returns Left(failure) when the repository fails', () async {
      final usecase = AddTransaction(mockTransactionRepository);
      when(
        () => mockTransactionRepository.addTransaction(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));

      final result = await usecase(tTransactionEntity);

      expect(result, const Left(ServerFailure('Add failed')));
    });
  });

  group('UpdateTransaction', () {
    test('TRX-004: updating writes only the transaction', () async {
      final usecase = UpdateTransaction(mockTransactionRepository);
      final updated = tTransactionEntity.copyWith(amount: 80.0);
      when(
        () => mockTransactionRepository.updateTransaction(any()),
      ).thenAnswer((_) async => Right(updated));

      final result = await usecase(updated);

      expect(result, Right(updated));
      verify(
        () => mockTransactionRepository.updateTransaction(updated),
      ).called(1);
      verifyNever(() => mockTransactionRepository.getTransaction(any()));
      verifyZeroInteractions(mockAccountRepository);
    });

    test('returns Left(failure) when the repository fails', () async {
      final usecase = UpdateTransaction(mockTransactionRepository);
      when(
        () => mockTransactionRepository.updateTransaction(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));

      final result = await usecase(tTransactionEntity);

      expect(result, const Left(ServerFailure('Update failed')));
    });
  });

  group('DeleteTransaction', () {
    test(
      'TRX-004: deleting a paid transaction never touches accounts',
      () async {
        final usecase = DeleteTransaction(mockTransactionRepository);
        when(
          () => mockTransactionRepository.deleteTransaction(any()),
        ).thenAnswer((_) async => const Right(null));

        final result = await usecase(tTransactionEntity.id);

        expect(result, const Right(null));
        verify(
          () => mockTransactionRepository.deleteTransaction(
            tTransactionEntity.id,
          ),
        ).called(1);
        verifyZeroInteractions(mockAccountRepository);
      },
    );
  });

  group('GetTransactions', () {
    test('should call repository.getTransactions with given filters', () {
      final usecase = GetTransactions(mockTransactionRepository);
      when(
        () => mockTransactionRepository.getTransactions(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          categoryId: any(named: 'categoryId'),
          type: any(named: 'type'),
          frequency: any(named: 'frequency'),
        ),
      ).thenAnswer((_) => Stream.value(Right([tTransactionEntity])));

      final stream = usecase(type: TransactionType.expense);

      expect(stream, isA<Stream<Either<Failure, List<TransactionEntity>>>>());
      verify(
        () => mockTransactionRepository.getTransactions(
          startDate: null,
          endDate: null,
          categoryId: null,
          type: TransactionType.expense,
          frequency: null,
        ),
      ).called(1);
    });
  });
}
