import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = NotificationModel.fromEntity(notification);
      await remoteDataSource.addNotification(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> getNotifications() async* {
    try {
      await for (final models in remoteDataSource.getNotifications()) {
        yield Right(models.map((m) => m.toEntity()).toList());
      }
    } catch (error) {
      yield Left(ServerFailure(error.toString()));
    }
  }
}
