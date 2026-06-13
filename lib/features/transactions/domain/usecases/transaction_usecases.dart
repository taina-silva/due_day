import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

abstract class _TransactionBaseUseCase {
  final TransactionRepository repository;
  final AccountRepository accountRepository;

  _TransactionBaseUseCase(this.repository, this.accountRepository);

  Future<void> _updateBalance(TransactionEntity tx, {required bool isAddition}) async {
    final multiplier = isAddition ? 1 : -1;

    if (tx.type == TransactionType.expense && tx.accountFrom != null) {
      await _adjustAccountBalance(tx.accountFrom!, -tx.amount * multiplier);
    } else if (tx.type == TransactionType.income && tx.accountTo != null) {
      await _adjustAccountBalance(tx.accountTo!, tx.amount * multiplier);
    } else if (tx.type == TransactionType.transfer &&
        tx.accountFrom != null &&
        tx.accountTo != null) {
      await _adjustAccountBalance(tx.accountFrom!, -tx.amount * multiplier);
      await _adjustAccountBalance(tx.accountTo!, tx.amount * multiplier);
    }
  }

  Future<void> _adjustAccountBalance(String accountId, double amount) async {
    final result = await accountRepository.getAccountById(accountId);
    await result.fold(
      (failure) async => null,
      (account) async {
        final updatedAccount = AccountEntity(
          id: account.id,
          userId: account.userId,
          name: account.name,
          category: account.category,
          balance: account.balance + amount,
          createdAt: account.createdAt,
          dueDay: account.dueDay,
        );
        await accountRepository.updateAccount(updatedAccount);
      },
    );
  }
}

class AddTransaction extends _TransactionBaseUseCase {
  AddTransaction(super.repository, super.accountRepository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction,
  ) async {
    final result = await repository.addTransaction(transaction);

    return await result.fold(
      (failure) async => Left(failure),
      (newTx) async {
        if (newTx.paid) {
          await _updateBalance(newTx, isAddition: true);
        }
        return Right(newTx);
      },
    );
  }
}

class UpdateTransaction extends _TransactionBaseUseCase {
  UpdateTransaction(super.repository, super.accountRepository);

  Future<Either<Failure, TransactionEntity>> call(
    TransactionEntity transaction,
  ) async {
    // 1. Get the old transaction to see if we need to revert balance
    final oldTxResult = await repository.getTransaction(transaction.id);

    return await oldTxResult.fold(
      (failure) async => Left(failure),
      (oldTx) async {
        // 2. Revert old balance impact if it was paid
        if (oldTx.paid) {
          await _updateBalance(oldTx, isAddition: false);
        }

        // 3. Update the transaction
        final result = await repository.updateTransaction(transaction);

        return await result.fold(
          (failure) async => Left(failure),
          (newTx) async {
            // 4. Apply new balance impact if it is paid
            if (newTx.paid) {
              await _updateBalance(newTx, isAddition: true);
            }
            return Right(newTx);
          },
        );
      },
    );
  }
}

class DeleteTransaction extends _TransactionBaseUseCase {
  DeleteTransaction(super.repository, super.accountRepository);

  Future<Either<Failure, void>> call(String transactionId) async {
    // 1. Get transaction to revert balance if needed
    final txResult = await repository.getTransaction(transactionId);

    return await txResult.fold(
      (failure) async => Left(failure),
      (tx) async {
        if (tx.paid) {
          await _updateBalance(tx, isAddition: false);
        }
        return repository.deleteTransaction(transactionId);
      },
    );
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
