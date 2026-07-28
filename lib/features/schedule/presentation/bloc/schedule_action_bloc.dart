import 'package:due_day/features/schedule/presentation/bloc/schedule_action_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_state.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleActionBloc
    extends Bloc<ScheduleActionEvent, ScheduleActionState> {
  final UpdateTransaction updateTransaction;

  ScheduleActionBloc({required this.updateTransaction})
    : super(ScheduleActionInitial()) {
    on<MarkAsPaidEvent>(_onMarkAsPaid);
  }

  Future<void> _onMarkAsPaid(
    MarkAsPaidEvent event,
    Emitter<ScheduleActionState> emit,
  ) async {
    emit(ScheduleActionInProgress());

    final updatedTransaction = event.transaction.copyWith(
      paid: true,
      paidDate: DateTime.now(),
    );

    final result = await updateTransaction(updatedTransaction);
    result.fold(
      (failure) => emit(ScheduleActionError(failure)),
      (_) => emit(ScheduleActionSuccess()),
    );
  }
}
