import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class SyncRecurringTransactions {
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  SyncRecurringTransactions({
    required this.transactionRepository,
    required this.accountRepository,
  });

  /// Creates the next due instance for every active recurring template and
  /// returns the newly created instances so the caller can notify the user
  /// (notification content requires localization, which is a Presentation
  /// layer concern).
  Future<List<TransactionEntity>> call(String userId) async {
    final transactionsResult = await transactionRepository
        .getTransactions()
        .first;

    final transactions = transactionsResult.getOrElse(
      (_) => <TransactionEntity>[],
    );

    final now = DateTime.now();
    final templates = transactions
        .where((tx) => tx.isRecurring && tx.parentRecurringId == null)
        .toList();

    final createdInstances = <TransactionEntity>[];

    for (final template in templates) {
      final nextDate = _calculateNextDate(template);

      if (nextDate != null && nextDate.isBefore(now)) {
        final alreadyExists = transactions.any(
          (tx) =>
              tx.parentRecurringId == template.id &&
              tx.dueDate?.year == nextDate.year &&
              tx.dueDate?.month == nextDate.month &&
              tx.dueDate?.day == nextDate.day,
        );

        if (!alreadyExists) {
          final instance = await _createInstance(template, nextDate);
          createdInstances.add(instance);
        }
      }
    }

    return createdInstances;
  }

  DateTime? _calculateNextDate(TransactionEntity template) {
    if (template.frequency == TransactionFrequency.none) return null;

    final referenceDate = template.dueDate ?? template.createdAt;

    switch (template.frequency) {
      case TransactionFrequency.weekly:
        return referenceDate.add(const Duration(days: 7));
      case TransactionFrequency.biWeekly:
        return referenceDate.add(const Duration(days: 14));
      case TransactionFrequency.monthly:
        return DateTime(
          referenceDate.year,
          referenceDate.month + 1,
          referenceDate.day,
        );
      case TransactionFrequency.yearly:
        return DateTime(
          referenceDate.year + 1,
          referenceDate.month,
          referenceDate.day,
        );
      default:
        return null;
    }
  }

  Future<TransactionEntity> _createInstance(
    TransactionEntity template,
    DateTime dueDate,
  ) async {
    final newTransaction = TransactionEntity(
      id: const Uuid().v4(),
      userId: template.userId,
      type: template.type,
      amount: template.amount,
      category: template.category,
      accountFrom: template.accountFrom,
      accountTo: template.accountTo,
      dueDate: dueDate,
      paidDate: template.paid ? DateTime.now() : null,
      paid: template.paid, // Inherit "automatic" status from template
      isRecurring: false, // Instances are not recurring templates themselves
      frequency: TransactionFrequency.none,
      notes: template.notes,
      parentRecurringId: template.id,
      createdAt: DateTime.now(),
    );

    await transactionRepository.addTransaction(newTransaction);

    if (newTransaction.paid) {
      await _updateAccountBalance(newTransaction);
    }

    return newTransaction;
  }

  Future<void> _updateAccountBalance(TransactionEntity tx) async {
    if (tx.type == TransactionType.expense && tx.accountFrom != null) {
      await _adjustBalance(tx.accountFrom!, -tx.amount);
    } else if (tx.type == TransactionType.income && tx.accountTo != null) {
      await _adjustBalance(tx.accountTo!, tx.amount);
    } else if (tx.type == TransactionType.transfer &&
        tx.accountFrom != null &&
        tx.accountTo != null) {
      await _adjustBalance(tx.accountFrom!, -tx.amount);
      await _adjustBalance(tx.accountTo!, tx.amount);
    }
  }

  Future<void> _adjustBalance(String accountId, double amount) async {
    final accountsResult = await accountRepository.getAccounts().first;
    accountsResult.fold((failure) => null, (accounts) async {
      final account = accounts.firstWhere((a) => a.id == accountId);
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
    });
  }
}
