import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, void>> addNotification(
    NotificationEntity notification,
  );
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Stream<Either<Failure, List<NotificationEntity>>> getNotifications();
}
