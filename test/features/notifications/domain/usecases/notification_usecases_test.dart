import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/notifications_test_helpers.dart';

void main() {
  late MockNotificationsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(tNotificationEntity);
  });

  setUp(() {
    mockRepository = MockNotificationsRepository();
  });

  group('GetNotifications', () {
    test(
      'given a stream from the repository when call is invoked then return the same stream',
      () async {
        final usecase = GetNotifications(mockRepository);
        when(
          () => mockRepository.getNotifications(),
        ).thenAnswer((_) => Stream.value(Right([tNotificationEntity])));

        final result = await usecase().first;

        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('expected Right'),
          (entities) => expect(entities, [tNotificationEntity]),
        );
      },
    );
  });

  group('AddNotification', () {
    test(
      'given a notification when call is invoked then delegate to the repository and return Right(null)',
      () async {
        final usecase = AddNotification(mockRepository);
        when(
          () => mockRepository.addNotification(any()),
        ).thenAnswer((_) async => const Right(null));

        final result = await usecase(tNotificationEntity);

        expect(result, const Right(null));
        verify(
          () => mockRepository.addNotification(tNotificationEntity),
        ).called(1);
      },
    );
  });

  group('MarkNotificationAsRead', () {
    test(
      'given an id when call is invoked then delegate to the repository and return Right(null)',
      () async {
        final usecase = MarkNotificationAsRead(mockRepository);
        when(
          () => mockRepository.markAsRead(any()),
        ).thenAnswer((_) async => const Right(null));

        final result = await usecase('notification-1');

        expect(result, const Right(null));
        verify(() => mockRepository.markAsRead('notification-1')).called(1);
      },
    );

    test(
      'given a repository failure when call is invoked then return Left(failure)',
      () async {
        final usecase = MarkNotificationAsRead(mockRepository);
        when(
          () => mockRepository.markAsRead(any()),
        ).thenAnswer((_) async => const Left(CacheFailure('Cache error')));

        final result = await usecase('notification-1');

        expect(result, const Left(CacheFailure('Cache error')));
      },
    );
  });

  group('MarkAllNotificationsAsRead', () {
    test(
      'given a call when invoked then delegate to the repository and return Right(null)',
      () async {
        final usecase = MarkAllNotificationsAsRead(mockRepository);
        when(
          () => mockRepository.markAllAsRead(),
        ).thenAnswer((_) async => const Right(null));

        final result = await usecase();

        expect(result, const Right(null));
        verify(() => mockRepository.markAllAsRead()).called(1);
      },
    );

    test(
      'given a repository failure when invoked then return Left(failure)',
      () async {
        final usecase = MarkAllNotificationsAsRead(mockRepository);
        when(
          () => mockRepository.markAllAsRead(),
        ).thenAnswer((_) async => const Left(CacheFailure('Cache error')));

        final result = await usecase();

        expect(result, const Left(CacheFailure('Cache error')));
      },
    );
  });

  group('DeleteNotification', () {
    test(
      'given an id when call is invoked then delegate to the repository and return Right(null)',
      () async {
        final usecase = DeleteNotification(mockRepository);
        when(
          () => mockRepository.deleteNotification(any()),
        ).thenAnswer((_) async => const Right(null));

        final result = await usecase('notification-1');

        expect(result, const Right(null));
        verify(
          () => mockRepository.deleteNotification('notification-1'),
        ).called(1);
      },
    );

    test(
      'given a repository failure when call is invoked then return Left(failure)',
      () async {
        final usecase = DeleteNotification(mockRepository);
        when(
          () => mockRepository.deleteNotification(any()),
        ).thenAnswer((_) async => const Left(CacheFailure('Cache error')));

        final result = await usecase('notification-1');

        expect(result, const Left(CacheFailure('Cache error')));
      },
    );
  });
}
