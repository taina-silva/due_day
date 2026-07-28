import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/errors/notification_failures.dart';
import 'package:due_day/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsLocalDataSource localDataSource;
  final ObservabilityService observability;

  static const String _tag = 'notifications';

  NotificationsRepositoryImpl({
    required this.localDataSource,
    required this.observability,
  });

  @override
  Future<Either<Failure, void>> addNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      await localDataSource.addNotification(model);
      return const Right(null);
    } on CacheException catch (e) {
      observability.error(
        'addNotification failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(NotificationSaveFailure(e.message));
    } catch (e, stackTrace) {
      observability.error(
        'addNotification unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(NotificationSaveFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await localDataSource.markAsRead(notificationId);
      return const Right(null);
    } on CacheException catch (e) {
      observability.error(
        'markAsRead failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(NotificationSaveFailure(e.message));
    } catch (e, stackTrace) {
      observability.error(
        'markAsRead unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(NotificationSaveFailure(e.toString()));
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
      observability.error(
        'deleteNotification failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(NotificationDeleteFailure(e.message));
    } catch (e, stackTrace) {
      observability.error(
        'deleteNotification unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(NotificationDeleteFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> getNotifications() async* {
    try {
      await for (final models in localDataSource.getNotifications()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (error, stackTrace) {
      observability.error(
        'getNotifications stream unexpected failure',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      yield Left(CacheFailure(error.toString()));
    }
  }
}
