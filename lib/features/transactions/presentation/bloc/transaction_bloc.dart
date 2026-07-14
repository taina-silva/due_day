import 'dart:async';

import 'package:due_day/core/l10n/l10n_resolver.dart';
import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final GetTransactions getTransactions;
  final SettingsBloc settingsBloc;
  final NotificationService notificationService;
  final AddNotification addNotification;

  StreamSubscription? _transactionsSubscription;

  TransactionBloc({
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.getTransactions,
    required this.settingsBloc,
    required this.notificationService,
    required this.addNotification,
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
      await notificationService.cancelAll();

      if (!settingsBloc.state.pushNotificationsEnabled) {
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
      for (var t in event.transactions) {
        if (t.dueDate == null ||
            t.paid != false ||
            t.type != TransactionType.expense) {
          continue;
        }

        final dueDate = t.dueDate!;
        final description = t.notes?.isNotEmpty == true
            ? t.notes!
            : l10n.defaultTransaction;
        final amount = currencyFormat.format(t.amount);
        final today = DateTime.now();
        final todayMidnight = DateTime(today.year, today.month, today.day);
        final dueDateMidnight = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
        );

        // 1 day before, at 8:00 AM
        final dayBefore = dueDate.subtract(const Duration(days: 1));
        final notifyDayBefore = DateTime(
          dayBefore.year,
          dayBefore.month,
          dayBefore.day,
          8,
          0,
        );

        // On the due date, at 8:00 AM
        final notifyDueDay = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          8,
          0,
        );

        if (dueDateMidnight.isBefore(todayMidnight)) {
          // Overdue: only record history in Firestore
          await addNotification(
            NotificationEntity(
              id: '${t.id}_overdue',
              userId: t.userId,
              title: l10n.transactionsNotificationOverdueTitle,
              description: l10n.transactionsNotificationOverdueBody(
                description,
                amount,
                dateFormat.format(dueDate),
              ),
              timestamp: dueDate,
              read: false,
              isUrgent: true,
              type: NotificationType.overdue,
            ),
          );
        } else if (dueDateMidnight.isAtSameMomentAs(todayMidnight)) {
          // Due today!
          if (notifyDueDay.isAfter(DateTime.now())) {
            await notificationService.scheduleTransactionReminder(
              id: seqId++,
              title: l10n.transactionsNotificationDueTodayTitle,
              body: l10n.transactionsNotificationDueTodayBody(
                description,
                amount,
              ),
              scheduledDate: notifyDueDay,
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
              timestamp: notifyDueDay,
              read: false,
              isUrgent: true,
              type: NotificationType.dueToday,
            ),
          );
        } else {
          // Due in the future!
          // 1. One day before
          if (notifyDayBefore.isAfter(DateTime.now())) {
            await notificationService.scheduleTransactionReminder(
              id: seqId++,
              title: l10n.transactionsNotificationDueTomorrowTitle,
              body: l10n.transactionsNotificationDueTomorrowBody(
                description,
                amount,
              ),
              scheduledDate: notifyDayBefore,
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
              timestamp: notifyDayBefore,
              read: false,
              isUrgent: false,
              type: NotificationType.upcomingDue,
            ),
          );

          // 2. On the due date itself
          if (notifyDueDay.isAfter(DateTime.now())) {
            await notificationService.scheduleTransactionReminder(
              id: seqId++,
              title: l10n.transactionsNotificationDueTodayTitle,
              body: l10n.transactionsNotificationDueTodayBody(
                description,
                amount,
              ),
              scheduledDate: notifyDueDay,
            );
          }
          await addNotification(
            NotificationEntity(
              id: '${t.id}_due_day',
              userId: t.userId,
              title: l10n.transactionsNotificationDueTodayTitle,
              description: l10n.transactionsNotificationDueTodayBody(
                description,
                amount,
              ),
              timestamp: notifyDueDay,
              read: false,
              isUrgent: true,
              type: NotificationType.dueToday,
            ),
          );
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
