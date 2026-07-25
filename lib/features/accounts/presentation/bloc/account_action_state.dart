import 'package:due_day/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class AccountActionState extends Equatable {
  const AccountActionState();

  @override
  List<Object> get props => [];
}

class AccountActionInitial extends AccountActionState {}

class AccountActionInProgress extends AccountActionState {}

class AccountActionSuccess extends AccountActionState {}

class AccountActionError extends AccountActionState {
  final Failure failure;

  const AccountActionError({required this.failure});

  @override
  List<Object> get props => [failure];
}
