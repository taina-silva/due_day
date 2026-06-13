import 'dart:async';

import 'package:due_day/core/services/notification_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final GetTransactions getTransactions;

  StreamSubscription? _transactionsSubscription;

  TransactionBloc({
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.getTransactions,
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
            (failure) => add(TransactionLoadFailed(failure.message)),
            (transactions) => add(TransactionsUpdated(transactions)),
          );
        });
  }

  void _onTransactionLoadFailed(
    TransactionLoadFailed event,
    Emitter<TransactionState> emit,
  ) {
    emit(TransactionError(message: event.message));
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoaded(transactions: event.transactions));

    try {
      final settingsBloc = GetIt.instance<SettingsBloc>();
      final notificationService = GetIt.instance<NotificationService>();
      final addNotification = GetIt.instance<AddNotification>();

      await notificationService.cancelAll();

      if (!settingsBloc.state.pushNotificationsEnabled) {
        return;
      }

      int seqId = 0;
      for (var t in event.transactions) {
        if (t.dueDate != null &&
            t.paid == false &&
            t.type == TransactionType.expense) {
          final dueDate = t.dueDate!;
          final today = DateTime.now();
          final todayMidnight = DateTime(today.year, today.month, today.day);
          final dueDateMidnight =
              DateTime(dueDate.year, dueDate.month, dueDate.day);

          // 1 dia antes às 8:00 AM
          final dayBefore = dueDate.subtract(const Duration(days: 1));
          final notifyDayBefore =
              DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 8, 0);

          // No dia do vencimento às 8:00 AM
          final notifyDueDay =
              DateTime(dueDate.year, dueDate.month, dueDate.day, 8, 0);

          if (dueDateMidnight.isBefore(todayMidnight)) {
            // Atrasada! Criar apenas histórico no Firestore
            final notifOverdue = NotificationEntity(
              id: '${t.id}_overdue',
              userId: t.userId,
              title: 'Conta atrasada!',
              description:
                  "A transação '${t.notes ?? 'Despesa'}' de R\$ ${t.amount.toStringAsFixed(2)} está atrasada desde ${dueDate.day}/${dueDate.month}.",
              timestamp: dueDate,
              read: false,
              isUrgent: true,
              type: NotificationType.overdue,
            );
            await addNotification(notifOverdue);
          } else if (dueDateMidnight.isAtSameMomentAs(todayMidnight)) {
            // Vence hoje!
            if (notifyDueDay.isAfter(DateTime.now())) {
              await notificationService.scheduleTransactionReminder(
                id: seqId++,
                title: 'Conta vence hoje!',
                body:
                    "Sua transação '${t.notes ?? 'Despesa'}' de R\$ ${t.amount.toStringAsFixed(2)} vence hoje. Realize o pagamento!",
                scheduledDate: notifyDueDay,
              );
            }
            final notifDueToday = NotificationEntity(
              id: '${t.id}_due_today',
              userId: t.userId,
              title: 'Conta vence hoje!',
              description:
                  "Sua transação '${t.notes ?? 'Despesa'}' de R\$ ${t.amount.toStringAsFixed(2)} vence hoje. Realize o pagamento!",
              timestamp: notifyDueDay,
              read: false,
              isUrgent: true,
              type: NotificationType.dueToday,
            );
            await addNotification(notifDueToday);
          } else {
            // Vence no futuro!
            // 1. Um dia antes
            if (notifyDayBefore.isAfter(DateTime.now())) {
              await notificationService.scheduleTransactionReminder(
                id: seqId++,
                title: 'Conta vence amanhã!',
                body:
                    "Sua transação '${t.notes ?? 'Despesa'}' de R\$ ${t.amount.toStringAsFixed(2)} vence amanhã.",
                scheduledDate: notifyDayBefore,
              );
            }
            final notifDayBeforeObj = NotificationEntity(
              id: '${t.id}_day_before',
              userId: t.userId,
              title: 'Conta vence amanhã!',
              description:
                  "Sua transação '${t.notes ?? 'Despesa'}' de R\$ ${t.amount.toStringAsFixed(2)} vence amanhã.",
              timestamp: notifyDayBefore,
              read: false,
              isUrgent: false,
              type: NotificationType.upcomingDue,
            );
            await addNotification(notifDayBeforeObj);

            // 2. No próprio dia
            if (notifyDueDay.isAfter(DateTime.now())) {
              await notificationService.scheduleTransactionReminder(
                id: seqId++,
                title: 'Conta vence hoje!',
                body:
                    "Sua transação '${t.notes ?? 'Despesa'}' de R\$ ${t.amount.toStringAsFixed(2)} vence hoje. Realize o pagamento!",
                scheduledDate: notifyDueDay,
              );
            }
            final notifDueDayObj = NotificationEntity(
              id: '${t.id}_due_day',
              userId: t.userId,
              title: 'Conta vence hoje!',
              description:
                  "Sua transação '${t.notes ?? 'Despesa'}' de R\$ ${t.amount.toStringAsFixed(2)} vence hoje. Realize o pagamento!",
              timestamp: notifyDueDay,
              read: false,
              isUrgent: true,
              type: NotificationType.dueToday,
            );
            await addNotification(notifDueDayObj);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await updateTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransaction(event.transactionId);
    result.fold(
      (failure) => emit(TransactionError(message: failure.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
