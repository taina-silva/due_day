import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> newNotifications;
  final List<NotificationEntity> earlierNotifications;
  final int urgentCount;

  const NotificationsLoaded({
    required this.newNotifications,
    required this.earlierNotifications,
    required this.urgentCount,
  });

  @override
  List<Object?> get props => [
    newNotifications,
    earlierNotifications,
    urgentCount,
  ];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
