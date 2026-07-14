import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {}

class NotificationsUpdated extends NotificationsEvent {
  final List<NotificationEntity> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class MarkAsReadEvent extends NotificationsEvent {
  final String id;

  const MarkAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class DeleteNotificationEvent extends NotificationsEvent {
  final String id;

  const DeleteNotificationEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationsErrorOccurred extends NotificationsEvent {
  final String message;

  const NotificationsErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}
