import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/features/profile/domain/errors/user_data_failures.dart';
import 'package:due_day/features/profile/domain/usecases/delete_all_user_data.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_bloc.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_event.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockDeleteAllUserData extends Mock implements DeleteAllUserData {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockDeleteAllUserData deleteAllUserData;
  late MockNotificationService notificationService;

  setUp(() {
    deleteAllUserData = MockDeleteAllUserData();
    notificationService = MockNotificationService();
    when(() => notificationService.cancelAll()).thenAnswer((_) async {});
  });

  UserDataActionBloc build() => UserDataActionBloc(
    deleteAllUserData: deleteAllUserData,
    notificationService: notificationService,
  );

  blocTest<UserDataActionBloc, UserDataActionState>(
    'SET-001: confirming deletes the data and cancels reminders',
    build: () {
      when(
        () => deleteAllUserData(),
      ).thenAnswer((_) async => const Right(null));
      return build();
    },
    act: (bloc) => bloc.add(const DeleteAllUserDataRequested()),
    expect: () => const [UserDataActionInProgress(), UserDataActionSuccess()],
    verify: (_) => verify(() => notificationService.cancelAll()).called(1),
  );

  blocTest<UserDataActionBloc, UserDataActionState>(
    'SET-001: failure emits an error and keeps reminders',
    build: () {
      when(
        () => deleteAllUserData(),
      ).thenAnswer((_) async => const Left(DeleteUserDataFailure()));
      return build();
    },
    act: (bloc) => bloc.add(const DeleteAllUserDataRequested()),
    expect: () => const [
      UserDataActionInProgress(),
      UserDataActionError(DeleteUserDataFailure()),
    ],
    verify: (_) => verifyNever(() => notificationService.cancelAll()),
  );
}
