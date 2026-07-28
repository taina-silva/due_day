import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsLoadEvent extends Equatable {
  const NotificationsLoadEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsLoadEvent {}

class NotificationsUpdated extends NotificationsLoadEvent {
  final List<NotificationEntity> notifications;

  const NotificationsUpdated(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class NotificationsLoadFailed extends NotificationsLoadEvent {
  final Failure failure;

  const NotificationsLoadFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
