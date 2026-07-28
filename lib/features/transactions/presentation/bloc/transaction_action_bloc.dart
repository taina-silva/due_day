import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionActionBloc
    extends Bloc<TransactionActionEvent, TransactionActionState> {
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;

  TransactionActionBloc({
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
  }) : super(TransactionActionInitial()) {
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionInProgress());
    final result = await addTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionActionError(failure: failure)),
      (_) => emit(TransactionActionSuccess()),
    );
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionInProgress());
    final result = await updateTransaction(event.transaction);
    result.fold(
      (failure) => emit(TransactionActionError(failure: failure)),
      (_) => emit(TransactionActionSuccess()),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionActionState> emit,
  ) async {
    emit(TransactionActionInProgress());
    final result = await deleteTransaction(event.transactionId);
    result.fold(
      (failure) => emit(TransactionActionError(failure: failure)),
      (_) => emit(TransactionActionSuccess()),
    );
  }
}
