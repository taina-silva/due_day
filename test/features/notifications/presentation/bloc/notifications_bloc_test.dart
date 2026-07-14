import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/notifications_test_helpers.dart';

void main() {
  late MockGetNotifications mockGetNotifications;
  late MockMarkNotificationAsRead mockMarkNotificationAsRead;
  late MockDeleteNotification mockDeleteNotification;
  late NotificationsBloc notificationsBloc;

  setUp(() {
    mockGetNotifications = MockGetNotifications();
    mockMarkNotificationAsRead = MockMarkNotificationAsRead();
    mockDeleteNotification = MockDeleteNotification();

    notificationsBloc = NotificationsBloc(
      getNotifications: mockGetNotifications,
      markNotificationAsRead: mockMarkNotificationAsRead,
      deleteNotification: mockDeleteNotification,
    );
  });

  tearDown(() {
    notificationsBloc.close();
  });

  test('initial state should be NotificationsInitial', () {
    expect(notificationsBloc.state, equals(NotificationsInitial()));
  });

  group('LoadNotifications', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'given the repository emits notifications when LoadNotifications is added then emit [Loading, Loaded] split by read state',
      build: () {
        final unread = tNotificationEntity;
        final read = tNotificationEntity.copyWith(
          id: 'notification-2',
          read: true,
        );
        when(
          () => mockGetNotifications(),
        ).thenAnswer((_) => Stream.value(Right([unread, read])));
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(LoadNotifications()),
      expect: () => [
        NotificationsLoading(),
        NotificationsLoaded(
          newNotifications: [tNotificationEntity],
          earlierNotifications: [
            tNotificationEntity.copyWith(id: 'notification-2', read: true),
          ],
          urgentCount: 1,
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'given the repository emits a failure when LoadNotifications is added then emit [Loading, Error]',
      build: () {
        when(() => mockGetNotifications()).thenAnswer(
          (_) => Stream.value(const Left(CacheFailure('Cache error'))),
        );
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(LoadNotifications()),
      expect: () => [
        NotificationsLoading(),
        const NotificationsError(message: 'Cache error'),
      ],
    );
  });

  group('MarkAsReadEvent', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'given an id when MarkAsReadEvent is added then call MarkNotificationAsRead usecase',
      build: () {
        when(
          () => mockMarkNotificationAsRead(any()),
        ).thenAnswer((_) async => const Right(null));
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(const MarkAsReadEvent('notification-1')),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verify(() => mockMarkNotificationAsRead('notification-1')).called(1);
      },
    );
  });

  group('DeleteNotificationEvent', () {
    blocTest<NotificationsBloc, NotificationsState>(
      'given an id when DeleteNotificationEvent is added then call DeleteNotification usecase',
      build: () {
        when(
          () => mockDeleteNotification(any()),
        ).thenAnswer((_) async => const Right(null));
        return notificationsBloc;
      },
      act: (bloc) => bloc.add(const DeleteNotificationEvent('notification-1')),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verify(() => mockDeleteNotification('notification-1')).called(1);
      },
    );
  });
}
