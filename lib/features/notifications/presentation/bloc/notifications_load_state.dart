import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsLoadState extends Equatable {
  const NotificationsLoadState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsLoadState {}

class NotificationsLoading extends NotificationsLoadState {}

class NotificationsLoaded extends NotificationsLoadState {
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

class NotificationsError extends NotificationsLoadState {
  final Failure failure;

  const NotificationsError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
