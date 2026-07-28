import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionLoadEvent extends Equatable {
  const TransactionLoadEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionLoadEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final TransactionType? type;
  final TransactionFrequency? frequency;

  const LoadTransactions({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.type,
    this.frequency,
  });

  @override
  List<Object?> get props => [startDate, endDate, categoryId, type, frequency];
}

class TransactionsUpdated extends TransactionLoadEvent {
  final List<TransactionEntity> transactions;
  const TransactionsUpdated(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class TransactionLoadFailed extends TransactionLoadEvent {
  final Failure failure;
  const TransactionLoadFailed(this.failure);

  @override
  List<Object> get props => [failure];
}

class SyncRecurringTransactionsRequested extends TransactionLoadEvent {}
