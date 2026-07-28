import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionActionEvent extends Equatable {
  const TransactionActionEvent();

  @override
  List<Object> get props => [];
}

class AddTransactionEvent extends TransactionActionEvent {
  final TransactionEntity transaction;
  const AddTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionActionEvent {
  final TransactionEntity transaction;
  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionActionEvent {
  final String transactionId;
  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}
