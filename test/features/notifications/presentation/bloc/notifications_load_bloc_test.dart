import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/notifications_test_helpers.dart';

void main() {
  late MockGetNotifications mockGetNotifications;
  late NotificationsLoadBloc notificationsLoadBloc;

  setUp(() {
    mockGetNotifications = MockGetNotifications();

    notificationsLoadBloc = NotificationsLoadBloc(
      getNotifications: mockGetNotifications,
    );
  });

  tearDown(() {
    notificationsLoadBloc.close();
  });

  test('initial state should be NotificationsInitial', () {
    expect(notificationsLoadBloc.state, equals(NotificationsInitial()));
  });

  group('LoadNotifications', () {
    blocTest<NotificationsLoadBloc, NotificationsLoadState>(
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
        return notificationsLoadBloc;
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

    blocTest<NotificationsLoadBloc, NotificationsLoadState>(
      'given the repository emits a failure when LoadNotifications is added then emit [Loading, Error]',
      build: () {
        when(() => mockGetNotifications()).thenAnswer(
          (_) => Stream.value(const Left(CacheFailure('Cache error'))),
        );
        return notificationsLoadBloc;
      },
      act: (bloc) => bloc.add(LoadNotifications()),
      expect: () => [
        NotificationsLoading(),
        const NotificationsError(failure: CacheFailure('Cache error')),
      ],
    );
  });
}
