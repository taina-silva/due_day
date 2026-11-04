import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Transactions never read or write account documents (TRX-004): accounts
/// have no balance (ACC-003).
class AddTransaction {
  final TransactionRepository repository;
  AddTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction,
  ) {
    return repository.addTransaction(transaction);
  }
}

class UpdateTransaction {
  final TransactionRepository repository;
  UpdateTransaction(this.repository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction,
  ) {
    return repository.updateTransaction(transaction);
  }
}

class DeleteTransaction {
  final TransactionRepository repository;
  DeleteTransaction(this.repository);

  Future<Either<Failure, void>> call(String transactionId) {
    return repository.deleteTransaction(transactionId);
  }
}

class GetTransactions {
  final TransactionRepository repository;
  GetTransactions(this.repository);

  Stream<Either<Failure, List<TransactionEntity>>> call({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    TransactionType? type,
    TransactionFrequency? frequency,
  }) {
    return repository.getTransactions(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      type: type,
      frequency: frequency,
    );
  }
}
