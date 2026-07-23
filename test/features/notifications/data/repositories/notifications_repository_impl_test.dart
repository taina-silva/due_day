import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/notifications/data/models/notification_model.dart';
import 'package:due_day/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/notifications_test_helpers.dart';

void main() {
  late MockNotificationsLocalDataSource mockLocalDataSource;
  late NotificationsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(NotificationModel.fromEntity(tNotificationEntity));
  });

  setUp(() {
    mockLocalDataSource = MockNotificationsLocalDataSource();
    repository = NotificationsRepositoryImpl(
      localDataSource: mockLocalDataSource,
      observability: ObservabilityServiceImpl(sinks: const []),
    );
  });

  group('addNotification', () {
    test(
      'given a successful call when addNotification is called then return Right(null)',
      () async {
        when(
          () => mockLocalDataSource.addNotification(any()),
        ).thenAnswer((_) async {});

        final result = await repository.addNotification(tNotificationEntity);

        expect(result, const Right(null));
        verify(
          () => mockLocalDataSource.addNotification(any()),
        ).called(1);
      },
    );

    test(
      'given a CacheException when addNotification is called then return Left(CacheFailure)',
      () async {
        when(
          () => mockLocalDataSource.addNotification(any()),
        ).thenThrow(const CacheException('Cache error'));

        final result = await repository.addNotification(tNotificationEntity);

        expect(result, const Left(CacheFailure('Cache error')));
      },
    );
  });

  group('markAsRead', () {
    test(
      'given a successful call when markAsRead is called then return Right(null)',
      () async {
        when(
          () => mockLocalDataSource.markAsRead(any()),
        ).thenAnswer((_) async {});

        final result = await repository.markAsRead('notification-1');

        expect(result, const Right(null));
        verify(
          () => mockLocalDataSource.markAsRead('notification-1'),
        ).called(1);
      },
    );

    test(
      'given a CacheException when markAsRead is called then return Left(CacheFailure)',
      () async {
        when(
          () => mockLocalDataSource.markAsRead(any()),
        ).thenThrow(const CacheException('Cache error'));

        final result = await repository.markAsRead('notification-1');

        expect(result, const Left(CacheFailure('Cache error')));
      },
    );
  });

  group('deleteNotification', () {
    test(
      'given a successful call when deleteNotification is called then return Right(null)',
      () async {
        when(
          () => mockLocalDataSource.deleteNotification(any()),
        ).thenAnswer((_) async {});

        final result = await repository.deleteNotification('notification-1');

        expect(result, const Right(null));
        verify(
          () => mockLocalDataSource.deleteNotification('notification-1'),
        ).called(1);
      },
    );

    test(
      'given a CacheException when deleteNotification is called then return Left(CacheFailure)',
      () async {
        when(
          () => mockLocalDataSource.deleteNotification(any()),
        ).thenThrow(const CacheException('Cache error'));

        final result = await repository.deleteNotification('notification-1');

        expect(result, const Left(CacheFailure('Cache error')));
      },
    );
  });

  group('getNotifications', () {
    test(
      'given the data source emits models when getNotifications is called then return Right(entities)',
      () async {
        final model = NotificationModel.fromEntity(tNotificationEntity);
        when(
          () => mockLocalDataSource.getNotifications(),
        ).thenAnswer((_) => Stream.value([model]));

        final result = await repository.getNotifications().first;

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('expected Right'),
          (entities) => expect(entities, [tNotificationEntity]),
        );
      },
    );

    test(
      'given the data source stream throws when getNotifications is called then return Left(CacheFailure)',
      () async {
        when(
          () => mockLocalDataSource.getNotifications(),
        ).thenAnswer((_) => Stream.error(Exception('boom')));

        final result = await repository.getNotifications().first;

        expect(result.isLeft(), isTrue);
      },
    );
  });
}
