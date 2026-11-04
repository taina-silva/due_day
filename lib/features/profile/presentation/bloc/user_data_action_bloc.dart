import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/features/profile/domain/usecases/delete_all_user_data.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_event.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDataActionBloc
    extends Bloc<UserDataActionEvent, UserDataActionState> {
  final DeleteAllUserData deleteAllUserData;
  final NotificationService notificationService;

  UserDataActionBloc({
    required this.deleteAllUserData,
    required this.notificationService,
  }) : super(const UserDataActionInitial()) {
    on<DeleteAllUserDataRequested>(_onDeleteAll);
  }

  Future<void> _onDeleteAll(
    DeleteAllUserDataRequested event,
    Emitter<UserDataActionState> emit,
  ) async {
    emit(const UserDataActionInProgress());
    final result = await deleteAllUserData();
    await result.fold((failure) async => emit(UserDataActionError(failure)), (
      _,
    ) async {
      // Reminders point at transactions that no longer exist (SET-001).
      // The data is already gone, so a cancel failure must not leave the
      // screen stuck in progress.
      try {
        await notificationService.cancelAll();
      } catch (_) {
        // Stale reminders are harmless; nothing else to do here.
      }
      emit(const UserDataActionSuccess());
    });
  }
}
