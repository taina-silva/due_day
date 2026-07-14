import 'dart:async';

import 'package:collection/collection.dart';
import 'package:due_day/core/l10n/l10n_resolver.dart';
import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/transactions/domain/usecases/classify_transaction_reminders.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

const _remindersEquality = ListEquality<TransactionReminder>();

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final GetTransactions getTransactions;
  final SettingsBloc settingsBloc;
  final NotificationService notificationService;
  final AddNotification addNotification;
  final ClassifyTransactionReminders classifyTransactionReminders;

  StreamSubscription? _transactionsSubscription;
  List<TransactionReminder>? _lastReminders;

  TransactionBloc({
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.getTransactions,
    required this.settingsBloc,
    required this.notificationService,
    required this.addNotification,
    required this.classifyTransactionReminders,
  }) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    // ignore: library_private_types_in_public_api
    on<TransactionsUpdated>(_onTransactionsUpdated);
    on<TransactionLoadFailed>(_onTransactionLoadFailed);
  }

  void _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
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
    Emitter<TransactionState> emit,
  ) {
    emit(TransactionError(failure: event.failure));
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionState> emit,
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

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransaction(event.transaction);
    result.fold((failure) => emit(TransactionError(failure: failure)), (_) {});
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await updateTransaction(event.transaction);
    result.fold((failure) => emit(TransactionError(failure: failure)), (_) {});
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(event.transactionId);
    result.fold((failure) => emit(TransactionError(failure: failure)), (_) {});
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
