import 'dart:async';

import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:due_day/features/schedule/domain/usecases/get_schedule_data.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:rxdart/rxdart.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetScheduleData getScheduleData;
  final GetCategories getCategories;
  final UpdateTransaction updateTransaction;
  ScheduleBloc({
    required this.getScheduleData,
    required this.getCategories,
    required this.updateTransaction,
  }) : super(ScheduleInitial()) {
    on<LoadScheduleData>(_onLoadScheduleData);
    on<MarkAsPaid>(_onMarkAsPaid);
  }

  Future<void> _onLoadScheduleData(
    LoadScheduleData event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ScheduleLoading());

    await emit.forEach<
      Either<Failure, (ScheduleSummary, Map<String, CategoryEntity>)>
    >(
      Rx.combineLatest2(getScheduleData.execute(), getCategories.call(), (
        scheduleResult,
        categoriesResult,
      ) {
        return scheduleResult.flatMap((summary) {
          return categoriesResult.map((categories) {
            final categoryMap = {for (var c in categories) c.id: c};
            return (summary, categoryMap);
          });
        });
      }),
      onData: (result) {
        return result.fold(
          (failure) => ScheduleError(failure),
          (data) => ScheduleLoaded(data.$1, categories: data.$2),
        );
      },
      onError: (error, stackTrace) => ScheduleError(
        error is Failure ? error : ServerFailure(error.toString()),
      ),
    );
  }

  Future<void> _onMarkAsPaid(
    MarkAsPaid event,
    Emitter<ScheduleState> emit,
  ) async {
    final updatedTx = TransactionEntity(
      id: event.transaction.id,
      userId: event.transaction.userId,
      type: event.transaction.type,
      amount: event.transaction.amount,
      paid: true,
      paidDate: DateTime.now(),
      isRecurring: event.transaction.isRecurring,
      createdAt: event.transaction.createdAt,
      category: event.transaction.category,
      accountFrom: event.transaction.accountFrom,
      accountTo: event.transaction.accountTo,
      dueDate: event.transaction.dueDate,
      frequency: event.transaction.frequency,
      notes: event.transaction.notes,
    );

    final result = await updateTransaction(updatedTx);
    result.fold(
      (failure) => emit(ScheduleError(failure)),
      (_) => null, // The stream will auto-update the UI
    );
  }
}
