import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class TransactionRepository {
  Future<Either<Failure, TransactionEntity>> addTransaction(
    TransactionEntity transaction,
  );
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );
  Future<Either<Failure, void>> deleteTransaction(String transactionId);
  Future<Either<Failure, TransactionEntity>> getTransaction(
    String transactionId,
  );

  // Method with optional filters
  Stream<Either<Failure, List<TransactionEntity>>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
    TransactionFrequency? frequency,
  });
}
