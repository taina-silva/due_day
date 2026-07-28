import 'dart:async';

import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsLoadBloc
    extends Bloc<NotificationsLoadEvent, NotificationsLoadState> {
  final GetNotifications getNotifications;

  StreamSubscription? _subscription;

  NotificationsLoadBloc({required this.getNotifications})
    : super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<NotificationsUpdated>(_onNotificationsUpdated);
    on<NotificationsLoadFailed>(_onNotificationsLoadFailed);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsLoadState> emit,
  ) {
    emit(NotificationsLoading());
    _subscription?.cancel();
    _subscription = getNotifications().listen((result) {
      result.fold(
        (failure) => add(NotificationsLoadFailed(failure)),
        (notifications) => add(NotificationsUpdated(notifications)),
      );
    });
  }

  void _onNotificationsUpdated(
    NotificationsUpdated event,
    Emitter<NotificationsLoadState> emit,
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

  void _onNotificationsLoadFailed(
    NotificationsLoadFailed event,
    Emitter<NotificationsLoadState> emit,
  ) {
    emit(NotificationsError(failure: event.failure));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
