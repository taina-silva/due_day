import 'dart:async';

import 'package:collection/collection.dart';
import 'package:due_day/core/l10n/l10n_resolver.dart';
import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/classify_transaction_reminders.dart';
import 'package:due_day/features/transactions/domain/usecases/sync_recurring_transactions.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

const _remindersEquality = ListEquality<TransactionReminder>();

class TransactionLoadBloc
    extends Bloc<TransactionLoadEvent, TransactionLoadState> {
  final GetTransactions getTransactions;
  final SettingsBloc settingsBloc;
  final NotificationService notificationService;
  final AddNotification addNotification;
  final ClassifyTransactionReminders classifyTransactionReminders;
  final SyncRecurringTransactions syncRecurringTransactions;
  final GetCurrentUser getCurrentUser;

  StreamSubscription? _transactionsSubscription;
  List<TransactionReminder>? _lastReminders;

  TransactionLoadBloc({
    required this.getTransactions,
    required this.settingsBloc,
    required this.notificationService,
    required this.addNotification,
    required this.classifyTransactionReminders,
    required this.syncRecurringTransactions,
    required this.getCurrentUser,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<TransactionsUpdated>(_onTransactionsUpdated);
    on<TransactionLoadFailed>(_onTransactionLoadFailed);
    on<SyncRecurringTransactionsRequested>(
      _onSyncRecurringTransactionsRequested,
    );
  }

  void _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionLoadState> emit,
  ) {
    emit(TransactionLoading());
    _transactionsSubscription?.cancel();
    _transactionsSubscription =
        getTransactions(
          startDate: event.startDate,
          endDate: event.endDate,
          categoryId: event.categoryId,
          type: event.type,
          frequency: event.frequency,
        ).listen((result) {
          result.fold(
            (failure) => add(TransactionLoadFailed(failure)),
            (transactions) => add(TransactionsUpdated(transactions)),
          );
        });
  }

  void _onTransactionLoadFailed(
    TransactionLoadFailed event,
    Emitter<TransactionLoadState> emit,
  ) {
    emit(TransactionError(failure: event.failure));
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionLoadState> emit,
  ) async {
    emit(TransactionLoaded(transactions: event.transactions));

    try {
      final pushEnabled = settingsBloc.state.pushNotificationsEnabled;
      final reminders = pushEnabled
          ? classifyTransactionReminders(event.transactions)
          : const <TransactionReminder>[];

      if (_lastReminders != null &&
          _remindersEquality.equals(_lastReminders, reminders)) {
        return;
      }
      _lastReminders = reminders;

      await notificationService.cancelAll();

      if (!pushEnabled) {
        return;
      }

      final languageCode = settingsBloc.state.languageCode;
      final l10n = resolveLocalizations(languageCode);
      final currencyFormat = NumberFormat.currency(
        locale: languageCode,
        symbol: '\$',
        decimalDigits: 2,
      );
      final dateFormat = DateFormat.Md(languageCode);

      int seqId = 0;
      for (final reminder in reminders) {
        final t = reminder.transaction;
        final description = t.notes?.isNotEmpty == true
            ? t.notes!
            : l10n.defaultTransaction;
        final amount = currencyFormat.format(t.amount);

        switch (reminder.urgency) {
          case ReminderUrgency.overdue:
            // Overdue: only record history, no OS reminder.
            await addNotification(
              NotificationEntity(
                id: '${t.id}_overdue',
                userId: t.userId,
                title: l10n.transactionsNotificationOverdueTitle,
                description: l10n.transactionsNotificationOverdueBody(
                  description,
                  amount,
                  dateFormat.format(t.dueDate!),
                ),
                timestamp: reminder.notifyAt,
                read: false,
                isUrgent: true,
                type: NotificationType.overdue,
              ),
            );
            break;

          case ReminderUrgency.dueToday:
            if (reminder.notifyAt.isAfter(DateTime.now())) {
              await notificationService.scheduleTransactionReminder(
                id: seqId++,
                title: l10n.transactionsNotificationDueTodayTitle,
                body: l10n.transactionsNotificationDueTodayBody(
                  description,
                  amount,
                ),
                scheduledDate: reminder.notifyAt,
              );
            }
            await addNotification(
              NotificationEntity(
                id: '${t.id}_due_today',
                userId: t.userId,
                title: l10n.transactionsNotificationDueTodayTitle,
                description: l10n.transactionsNotificationDueTodayBody(
                  description,
                  amount,
                ),
                timestamp: reminder.notifyAt,
                read: false,
                isUrgent: true,
                type: NotificationType.dueToday,
              ),
            );
            break;

          case ReminderUrgency.dueTomorrow:
            if (reminder.notifyAt.isAfter(DateTime.now())) {
              await notificationService.scheduleTransactionReminder(
                id: seqId++,
                title: l10n.transactionsNotificationDueTomorrowTitle,
                body: l10n.transactionsNotificationDueTomorrowBody(
                  description,
                  amount,
                ),
                scheduledDate: reminder.notifyAt,
              );
            }
            await addNotification(
              NotificationEntity(
                id: '${t.id}_day_before',
                userId: t.userId,
                title: l10n.transactionsNotificationDueTomorrowTitle,
                description: l10n.transactionsNotificationDueTomorrowBody(
                  description,
                  amount,
                ),
                timestamp: reminder.notifyAt,
                read: false,
                isUrgent: false,
                type: NotificationType.upcomingDue,
              ),
            );
            break;
        }
      }
    } catch (_) {}
  }

  Future<void> _onSyncRecurringTransactionsRequested(
    SyncRecurringTransactionsRequested event,
    Emitter<TransactionLoadState> emit,
  ) async {
    final userResult = await getCurrentUser();
    await userResult.fold((failure) async => null, (user) async {
      if (user != null) {
        final createdInstances = await syncRecurringTransactions(user.uid);
        await _notifyRecurringDebited(createdInstances);
      }
    });
  }

  Future<void> _notifyRecurringDebited(
    List<TransactionEntity> createdInstances,
  ) async {
    if (createdInstances.isEmpty) return;

    final l10n = resolveLocalizations(settingsBloc.state.languageCode);
    final currencyFormat = NumberFormat.currency(
      locale: settingsBloc.state.languageCode,
      symbol: '\$',
      decimalDigits: 2,
    );

    for (final instance in createdInstances) {
      if (!instance.paid) continue;

      await addNotification(
        NotificationEntity(
          id: '${instance.id}_recurring_debited',
          userId: instance.userId,
          title: l10n.transactionsNotificationRecurringDebitedTitle,
          description: l10n.transactionsNotificationRecurringDebitedBody(
            instance.notes?.isNotEmpty == true
                ? instance.notes!
                : l10n.defaultTransaction,
            currencyFormat.format(instance.amount),
          ),
          timestamp: DateTime.now(),
          read: false,
          isUrgent: false,
          type: NotificationType.recurringDebited,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
