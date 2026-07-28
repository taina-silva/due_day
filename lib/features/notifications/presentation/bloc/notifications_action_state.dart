import 'package:due_day/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsActionState extends Equatable {
  const NotificationsActionState();

  @override
  List<Object?> get props => [];
}

class NotificationsActionInitial extends NotificationsActionState {}

class NotificationsActionInProgress extends NotificationsActionState {}

class NotificationsActionSuccess extends NotificationsActionState {}

class NotificationsActionError extends NotificationsActionState {
  final Failure failure;

  const NotificationsActionError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
