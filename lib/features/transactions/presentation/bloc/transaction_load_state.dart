import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionLoadState extends Equatable {
  const TransactionLoadState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionLoadState {}

class TransactionLoading extends TransactionLoadState {}

class TransactionLoaded extends TransactionLoadState {
  final List<TransactionEntity> transactions;

  const TransactionLoaded({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class TransactionError extends TransactionLoadState {
  final Failure failure;

  const TransactionError({required this.failure});

  @override
  List<Object> get props => [failure];
}
