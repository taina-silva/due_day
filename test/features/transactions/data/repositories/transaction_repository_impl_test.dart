import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:due_day/features/transactions/domain/errors/transaction_failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/transaction_test_helpers.dart';

void main() {
  late MockTransactionRemoteDataSource mockRemoteDataSource;
  late TransactionRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tTransactionModel);
  });

  setUp(() {
    mockRemoteDataSource = MockTransactionRemoteDataSource();
    repository = TransactionRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      observability: ObservabilityServiceImpl(sinks: const []),
    );
  });

  group('TransactionRepositoryImpl Tests', () {
    group('addTransaction', () {
      test('should return TransactionEntity on success', () async {
        when(
          () => mockRemoteDataSource.addTransaction(any()),
        ).thenAnswer((_) async => tTransactionModel);

        final result = await repository.addTransaction(tTransactionEntity);

        expect(result, equals(Right(tTransactionEntity)));
        verify(
          () => mockRemoteDataSource.addTransaction(tTransactionModel),
        ).called(1);
      });

      test(
        'should return UserNotAuthenticatedFailure when unauthenticated',
        () async {
          when(() => mockRemoteDataSource.addTransaction(any())).thenThrow(
            const ServerException('User not authenticated.', 'unauthenticated'),
          );

          final result = await repository.addTransaction(tTransactionEntity);

          expect(result, equals(const Left(UserNotAuthenticatedFailure())));
        },
      );

      test(
        'should return TransactionSaveFailure for general server exceptions',
        () async {
          when(
            () => mockRemoteDataSource.addTransaction(any()),
          ).thenThrow(const ServerException('Server error'));

          final result = await repository.addTransaction(tTransactionEntity);

          expect(
            result,
            equals(const Left(TransactionSaveFailure('Server error'))),
          );
        },
      );
    });

    group('updateTransaction', () {
      test('should return TransactionEntity on success', () async {
        when(
          () => mockRemoteDataSource.updateTransaction(any()),
        ).thenAnswer((_) async => tTransactionModel);

        final result = await repository.updateTransaction(tTransactionEntity);

        expect(result, equals(Right(tTransactionEntity)));
        verify(
          () => mockRemoteDataSource.updateTransaction(tTransactionModel),
        ).called(1);
      });

      test(
        'should return TransactionSaveFailure for general server exceptions',
        () async {
          when(
            () => mockRemoteDataSource.updateTransaction(any()),
          ).thenThrow(const ServerException('Server error'));

          final result = await repository.updateTransaction(tTransactionEntity);

          expect(
            result,
            equals(const Left(TransactionSaveFailure('Server error'))),
          );
        },
      );
    });

    group('deleteTransaction', () {
      test('should return const Right(null) on success', () async {
        when(
          () => mockRemoteDataSource.deleteTransaction(any()),
        ).thenAnswer((_) async {});

        final result = await repository.deleteTransaction('transaction-1');

        expect(result, equals(const Right(null)));
        verify(
          () => mockRemoteDataSource.deleteTransaction('transaction-1'),
        ).called(1);
      });

      test(
        'should return TransactionDeleteFailure for general server exceptions',
        () async {
          when(
            () => mockRemoteDataSource.deleteTransaction(any()),
          ).thenThrow(const ServerException('Server error'));

          final result = await repository.deleteTransaction('transaction-1');

          expect(
            result,
            equals(const Left(TransactionDeleteFailure('Server error'))),
          );
        },
      );
    });

    group('getTransaction', () {
      test('should return TransactionNotFoundFailure when not found', () async {
        when(() => mockRemoteDataSource.getTransaction(any())).thenThrow(
          const ServerException('Transaction not found.', 'not-found'),
        );

        final result = await repository.getTransaction('missing-id');

        expect(result, equals(const Left(TransactionNotFoundFailure())));
      });
    });

    group('getTransactions', () {
      test(
        'should return stream of Right(List<TransactionEntity>) on success',
        () async {
          when(
            () => mockRemoteDataSource.getTransactions(
              startDate: any(named: 'startDate'),
              endDate: any(named: 'endDate'),
              categoryId: any(named: 'categoryId'),
              type: any(named: 'type'),
              frequency: any(named: 'frequency'),
            ),
          ).thenAnswer((_) => Stream.value([tTransactionModel]));

          final stream = repository.getTransactions();

          final result = await stream.first;
          expect(result.isRight(), true);
          result.fold((l) => fail('Should not be left'), (r) {
            expect(r, equals([tTransactionEntity]));
          });
        },
      );

      test('should return Left(ServerFailure) on stream error', () async {
        when(
          () => mockRemoteDataSource.getTransactions(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            categoryId: any(named: 'categoryId'),
            type: any(named: 'type'),
            frequency: any(named: 'frequency'),
          ),
        ).thenAnswer(
          (_) => Stream.error(const ServerException('Connection lost')),
        );

        final stream = repository.getTransactions();

        final result = await stream.first;
        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l, equals(const ServerFailure('Connection lost')));
        }, (r) => fail('Should not be right'));
      });
    });
  });
}
