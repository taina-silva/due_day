import 'package:due_day/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class TransactionActionState extends Equatable {
  const TransactionActionState();

  @override
  List<Object> get props => [];
}

class TransactionActionInitial extends TransactionActionState {}

class TransactionActionInProgress extends TransactionActionState {}

class TransactionActionSuccess extends TransactionActionState {}

class TransactionActionError extends TransactionActionState {
  final Failure failure;

  const TransactionActionError({required this.failure});

  @override
  List<Object> get props => [failure];
}
