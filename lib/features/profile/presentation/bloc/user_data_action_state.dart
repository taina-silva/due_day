import 'package:due_day/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class UserDataActionState extends Equatable {
  const UserDataActionState();

  @override
  List<Object?> get props => [];
}

class UserDataActionInitial extends UserDataActionState {
  const UserDataActionInitial();
}

class UserDataActionInProgress extends UserDataActionState {
  const UserDataActionInProgress();
}

class UserDataActionSuccess extends UserDataActionState {
  const UserDataActionSuccess();
}

class UserDataActionError extends UserDataActionState {
  final Failure failure;

  const UserDataActionError(this.failure);

  @override
  List<Object?> get props => [failure];
}
