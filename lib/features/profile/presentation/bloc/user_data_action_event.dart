import 'package:equatable/equatable.dart';

abstract class UserDataActionEvent extends Equatable {
  const UserDataActionEvent();

  @override
  List<Object?> get props => [];
}

/// Confirmed "Delete all my data" (SET-001).
class DeleteAllUserDataRequested extends UserDataActionEvent {
  const DeleteAllUserDataRequested();
}
