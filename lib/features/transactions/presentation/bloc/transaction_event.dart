import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
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

class AddTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;
  const AddTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;
  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}

class TransactionsUpdated extends TransactionEvent {
  final List<TransactionEntity> transactions;
  const TransactionsUpdated(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class TransactionLoadFailed extends TransactionEvent {
  final Failure failure;
  const TransactionLoadFailed(this.failure);

  @override
  List<Object> get props => [failure];
}
