import 'dart:async';

import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotifications getNotifications;
  final MarkNotificationAsRead markNotificationAsRead;
  final DeleteNotification deleteNotification;

  StreamSubscription? _subscription;

  NotificationsBloc({
    required this.getNotifications,
    required this.markNotificationAsRead,
    required this.deleteNotification,
  }) : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<NotificationsErrorOccurred>(_onNotificationsErrorOccurred);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) {
    emit(NotificationsLoading());
    _subscription?.cancel();
    _subscription = getNotifications().listen((result) {
      result.fold(
        (failure) => add(NotificationsErrorOccurred(failure.message)),
        (notifications) => add(NotificationsUpdated(notifications)),
      );
    });
  }

  void _onNotificationsErrorOccurred(
    NotificationsErrorOccurred event,
    Emitter<NotificationsState> emit,
  ) {
    emit(NotificationsError(message: event.message));
  }

  void _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationsState> emit,
  ) {
    final unread = event.notifications.where((n) => !n.read).toList();
    final read = event.notifications.where((n) => n.read).toList();

    emit(
      NotificationsLoaded(
        newNotifications: unread,
        earlierNotifications: read,
        urgentCount: unread.length,
      ),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await markNotificationAsRead(event.id);
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    await deleteNotification(event.id);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
