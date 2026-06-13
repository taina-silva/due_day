import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotifications {
  final NotificationsRepository repository;

  GetNotifications(this.repository);

  Stream<Either<Failure, List<NotificationEntity>>> call() {
    return repository.getNotifications();
  }
}

class AddNotification {
  final NotificationsRepository repository;

  AddNotification(this.repository);

  Future<Either<Failure, void>> call(NotificationEntity notification) {
    return repository.addNotification(notification);
  }
}

class MarkNotificationAsRead {
  final NotificationsRepository repository;

  MarkNotificationAsRead(this.repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return repository.markAsRead(notificationId);
  }
}
