import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_action_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_action_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsActionBloc
    extends Bloc<NotificationsActionEvent, NotificationsActionState> {
  final MarkNotificationAsRead markNotificationAsRead;
  final DeleteNotification deleteNotification;

  NotificationsActionBloc({
    required this.markNotificationAsRead,
    required this.deleteNotification,
  }) : super(NotificationsActionInitial()) {
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationsActionState> emit,
  ) async {
    emit(NotificationsActionInProgress());
    final result = await markNotificationAsRead(event.id);
    result.fold(
      (failure) => emit(NotificationsActionError(failure: failure)),
      (_) => emit(NotificationsActionSuccess()),
    );
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationsActionState> emit,
  ) async {
    emit(NotificationsActionInProgress());
    final result = await deleteNotification(event.id);
    result.fold(
      (failure) => emit(NotificationsActionError(failure: failure)),
      (_) => emit(NotificationsActionSuccess()),
    );
  }
}
