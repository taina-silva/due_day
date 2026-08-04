import 'package:equatable/equatable.dart';

abstract class NotificationsActionEvent extends Equatable {
  const NotificationsActionEvent();

  @override
  List<Object?> get props => [];
}

class MarkAsReadEvent extends NotificationsActionEvent {
  final String id;

  const MarkAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllAsReadEvent extends NotificationsActionEvent {
  const MarkAllAsReadEvent();
}

class DeleteNotificationEvent extends NotificationsActionEvent {
  final String id;

  const DeleteNotificationEvent(this.id);

  @override
  List<Object?> get props => [id];
}
