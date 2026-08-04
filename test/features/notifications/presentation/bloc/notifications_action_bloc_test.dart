import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:due_day/features/notifications/domain/errors/notification_failures.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_action_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_action_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_action_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/notifications_test_helpers.dart';

void main() {
  late MockMarkNotificationAsRead mockMarkNotificationAsRead;
  late MockMarkAllNotificationsAsRead mockMarkAllNotificationsAsRead;
  late MockDeleteNotification mockDeleteNotification;
  late NotificationsActionBloc notificationsActionBloc;

  setUp(() {
    mockMarkNotificationAsRead = MockMarkNotificationAsRead();
    mockMarkAllNotificationsAsRead = MockMarkAllNotificationsAsRead();
    mockDeleteNotification = MockDeleteNotification();

    notificationsActionBloc = NotificationsActionBloc(
      markNotificationAsRead: mockMarkNotificationAsRead,
      markAllNotificationsAsRead: mockMarkAllNotificationsAsRead,
      deleteNotification: mockDeleteNotification,
    );
  });

  tearDown(() {
    notificationsActionBloc.close();
  });

  test('initial state should be NotificationsActionInitial', () {
    expect(notificationsActionBloc.state, equals(NotificationsActionInitial()));
  });

  group('MarkAsReadEvent', () {
    blocTest<NotificationsActionBloc, NotificationsActionState>(
      'given a successful call when MarkAsReadEvent is added then emit [InProgress, Success]',
      build: () {
        when(
          () => mockMarkNotificationAsRead(any()),
        ).thenAnswer((_) async => const Right(null));
        return notificationsActionBloc;
      },
      act: (bloc) => bloc.add(const MarkAsReadEvent('notification-1')),
      expect: () => [
        NotificationsActionInProgress(),
        NotificationsActionSuccess(),
      ],
      verify: (_) {
        verify(() => mockMarkNotificationAsRead('notification-1')).called(1);
      },
    );

    blocTest<NotificationsActionBloc, NotificationsActionState>(
      'given a failed call when MarkAsReadEvent is added then emit [InProgress, Error]',
      build: () {
        when(() => mockMarkNotificationAsRead(any())).thenAnswer(
          (_) async => const Left(NotificationSaveFailure('Cache error')),
        );
        return notificationsActionBloc;
      },
      act: (bloc) => bloc.add(const MarkAsReadEvent('notification-1')),
      expect: () => [
        NotificationsActionInProgress(),
        const NotificationsActionError(
          failure: NotificationSaveFailure('Cache error'),
        ),
      ],
    );
  });

  group('MarkAllAsReadEvent', () {
    blocTest<NotificationsActionBloc, NotificationsActionState>(
      'given a successful call when MarkAllAsReadEvent is added then emit [InProgress, Success]',
      build: () {
        when(
          () => mockMarkAllNotificationsAsRead(),
        ).thenAnswer((_) async => const Right(null));
        return notificationsActionBloc;
      },
      act: (bloc) => bloc.add(const MarkAllAsReadEvent()),
      expect: () => [
        NotificationsActionInProgress(),
        NotificationsActionSuccess(),
      ],
      verify: (_) {
        verify(() => mockMarkAllNotificationsAsRead()).called(1);
      },
    );

    blocTest<NotificationsActionBloc, NotificationsActionState>(
      'given a failed call when MarkAllAsReadEvent is added then emit [InProgress, Error]',
      build: () {
        when(() => mockMarkAllNotificationsAsRead()).thenAnswer(
          (_) async => const Left(NotificationSaveFailure('Cache error')),
        );
        return notificationsActionBloc;
      },
      act: (bloc) => bloc.add(const MarkAllAsReadEvent()),
      expect: () => [
        NotificationsActionInProgress(),
        const NotificationsActionError(
          failure: NotificationSaveFailure('Cache error'),
        ),
      ],
    );
  });

  group('DeleteNotificationEvent', () {
    blocTest<NotificationsActionBloc, NotificationsActionState>(
      'given a successful call when DeleteNotificationEvent is added then emit [InProgress, Success]',
      build: () {
        when(
          () => mockDeleteNotification(any()),
        ).thenAnswer((_) async => const Right(null));
        return notificationsActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteNotificationEvent('notification-1')),
      expect: () => [
        NotificationsActionInProgress(),
        NotificationsActionSuccess(),
      ],
      verify: (_) {
        verify(() => mockDeleteNotification('notification-1')).called(1);
      },
    );

    blocTest<NotificationsActionBloc, NotificationsActionState>(
      'given a failed call when DeleteNotificationEvent is added then emit [InProgress, Error]',
      build: () {
        when(() => mockDeleteNotification(any())).thenAnswer(
          (_) async => const Left(NotificationDeleteFailure('Cache error')),
        );
        return notificationsActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteNotificationEvent('notification-1')),
      expect: () => [
        NotificationsActionInProgress(),
        const NotificationsActionError(
          failure: NotificationDeleteFailure('Cache error'),
        ),
      ],
    );
  });
}
