import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
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
    registerFallbackValue(tAccountEntity);
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockAccountRepository = MockAccountRepository();
  });

  group('AddTransaction', () {
    test(
      'should add the transaction and update account balance when paid',
      () async {
        final usecase = AddTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.addTransaction(any()),
        ).thenAnswer((_) async => Right(tTransactionEntity));
        when(
          () => mockAccountRepository.getAccountById('acc-1'),
        ).thenAnswer((_) async => Right(tAccountEntity));
        when(
          () => mockAccountRepository.updateAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));

        final result = await usecase(tTransactionEntity);

        expect(result, Right(tTransactionEntity));
        verify(
          () => mockTransactionRepository.addTransaction(tTransactionEntity),
        ).called(1);
        verify(() => mockAccountRepository.getAccountById('acc-1')).called(1);
        verify(
          () => mockAccountRepository.updateAccount(
            any(
              that: predicate<dynamic>(
                (a) => a.balance == tAccountEntity.balance - 50.0,
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'should not touch account balance when transaction is unpaid',
      () async {
        final unpaidTx = TransactionEntity(
          id: 'transaction-2',
          userId: 'user-1',
          type: TransactionType.expense,
          amount: 20.0,
          accountFrom: 'acc-1',
          paid: false,
          isRecurring: false,
          createdAt: tDateTime,
        );
        final usecase = AddTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.addTransaction(any()),
        ).thenAnswer((_) async => Right(unpaidTx));

        final result = await usecase(unpaidTx);

        expect(result, Right(unpaidTx));
        verifyNever(() => mockAccountRepository.getAccountById(any()));
      },
    );

    test('should return Left(failure) when repository fails', () async {
      final usecase = AddTransaction(
        mockTransactionRepository,
        mockAccountRepository,
      );
      when(
        () => mockTransactionRepository.addTransaction(any()),
      ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));

      final result = await usecase(tTransactionEntity);

      expect(result, const Left(ServerFailure('Add failed')));
      verifyNever(() => mockAccountRepository.getAccountById(any()));
    });
  });

  group('UpdateTransaction', () {
    test('should revert old balance and apply new balance when both the old '
        'and the updated transaction are paid', () async {
      final newTx = tTransactionEntity.copyWith(amount: 80.0);
      final usecase = UpdateTransaction(
        mockTransactionRepository,
        mockAccountRepository,
      );
      when(
        () => mockTransactionRepository.getTransaction('transaction-1'),
      ).thenAnswer((_) async => Right(tTransactionEntity));
      when(
        () => mockTransactionRepository.updateTransaction(any()),
      ).thenAnswer((_) async => Right(newTx));
      when(
        () => mockAccountRepository.getAccountById('acc-1'),
      ).thenAnswer((_) async => Right(tAccountEntity));
      when(
        () => mockAccountRepository.updateAccount(any()),
      ).thenAnswer((_) async => Right(tAccountEntity));

      final result = await usecase(newTx);

      expect(result, Right(newTx));
      verify(() => mockTransactionRepository.updateTransaction(newTx));
      // Revert of the old (50.0) paid impact.
      verify(
        () => mockAccountRepository.updateAccount(
          any(
            that: predicate<dynamic>(
              (a) => a.balance == tAccountEntity.balance + 50.0,
            ),
          ),
        ),
      ).called(1);
      // Apply of the new (80.0) paid impact.
      verify(
        () => mockAccountRepository.updateAccount(
          any(
            that: predicate<dynamic>(
              (a) => a.balance == tAccountEntity.balance - 80.0,
            ),
          ),
        ),
      ).called(1);
    });

    test(
      'should not touch account balance when the transaction stays unpaid',
      () async {
        final oldTx = tTransactionEntity.copyWith(paid: false);
        final newTx = oldTx.copyWith(amount: 80.0);
        final usecase = UpdateTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.getTransaction('transaction-1'),
        ).thenAnswer((_) async => Right(oldTx));
        when(
          () => mockTransactionRepository.updateTransaction(any()),
        ).thenAnswer((_) async => Right(newTx));

        final result = await usecase(newTx);

        expect(result, Right(newTx));
        verifyNever(() => mockAccountRepository.getAccountById(any()));
        verifyNever(() => mockAccountRepository.updateAccount(any()));
      },
    );

    test(
      'should revert balance when the transaction changes from paid to unpaid',
      () async {
        final newTx = tTransactionEntity.copyWith(paid: false);
        final usecase = UpdateTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.getTransaction('transaction-1'),
        ).thenAnswer((_) async => Right(tTransactionEntity));
        when(
          () => mockTransactionRepository.updateTransaction(any()),
        ).thenAnswer((_) async => Right(newTx));
        when(
          () => mockAccountRepository.getAccountById('acc-1'),
        ).thenAnswer((_) async => Right(tAccountEntity));
        when(
          () => mockAccountRepository.updateAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));

        final result = await usecase(newTx);

        expect(result, Right(newTx));
        verify(
          () => mockAccountRepository.updateAccount(
            any(
              that: predicate<dynamic>(
                (a) => a.balance == tAccountEntity.balance + 50.0,
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'should apply balance when the transaction changes from unpaid to paid',
      () async {
        final oldTx = tTransactionEntity.copyWith(paid: false);
        final usecase = UpdateTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.getTransaction('transaction-1'),
        ).thenAnswer((_) async => Right(oldTx));
        when(
          () => mockTransactionRepository.updateTransaction(any()),
        ).thenAnswer((_) async => Right(tTransactionEntity));
        when(
          () => mockAccountRepository.getAccountById('acc-1'),
        ).thenAnswer((_) async => Right(tAccountEntity));
        when(
          () => mockAccountRepository.updateAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));

        final result = await usecase(tTransactionEntity);

        expect(result, Right(tTransactionEntity));
        verify(
          () => mockAccountRepository.updateAccount(
            any(
              that: predicate<dynamic>(
                (a) => a.balance == tAccountEntity.balance - 50.0,
              ),
            ),
          ),
        ).called(1);
      },
    );

    test(
      'should return Left(failure) when fetching the old transaction fails',
      () async {
        final usecase = UpdateTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.getTransaction('transaction-1'),
        ).thenAnswer((_) async => const Left(ServerFailure('Fetch failed')));

        final result = await usecase(tTransactionEntity);

        expect(result, const Left(ServerFailure('Fetch failed')));
        verifyNever(() => mockTransactionRepository.updateTransaction(any()));
        verifyNever(() => mockAccountRepository.getAccountById(any()));
      },
    );

    test(
      'should return Left(failure) when the repository fails to update',
      () async {
        final oldTx = tTransactionEntity.copyWith(paid: false);
        final newTx = oldTx.copyWith(amount: 80.0);
        final usecase = UpdateTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.getTransaction('transaction-1'),
        ).thenAnswer((_) async => Right(oldTx));
        when(
          () => mockTransactionRepository.updateTransaction(any()),
        ).thenAnswer(
          (_) async => const Left(TransactionSaveFailure('Update failed')),
        );

        final result = await usecase(newTx);

        expect(result, const Left(TransactionSaveFailure('Update failed')));
      },
    );
  });

  group('DeleteTransaction', () {
    test(
      'should revert account balance and delete a paid transaction',
      () async {
        final usecase = DeleteTransaction(
          mockTransactionRepository,
          mockAccountRepository,
        );
        when(
          () => mockTransactionRepository.getTransaction('transaction-1'),
        ).thenAnswer((_) async => Right(tTransactionEntity));
        when(
          () => mockAccountRepository.getAccountById('acc-1'),
        ).thenAnswer((_) async => Right(tAccountEntity));
        when(
          () => mockAccountRepository.updateAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));
        when(
          () => mockTransactionRepository.deleteTransaction('transaction-1'),
        ).thenAnswer((_) async => const Right(null));

        final result = await usecase('transaction-1');

        expect(result, const Right(null));
        verify(
          () => mockAccountRepository.updateAccount(
            any(
              that: predicate<dynamic>(
                (a) => a.balance == tAccountEntity.balance + 50.0,
              ),
            ),
          ),
        ).called(1);
        verify(
          () => mockTransactionRepository.deleteTransaction('transaction-1'),
        ).called(1);
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
