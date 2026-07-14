import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsLocalDataSource localDataSource;

  NotificationsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, void>> addNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      await localDataSource.addNotification(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await localDataSource.markAsRead(notificationId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await localDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> getNotifications() async* {
    try {
      await for (final models in localDataSource.getNotifications()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (error) {
      yield Left(CacheFailure(error.toString()));
    }
  }
}
