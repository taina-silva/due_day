import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:due_day/features/transactions/domain/usecases/sync_recurring_transactions.dart';

void initDashboard() {
  // UseCases
  sl.registerLazySingleton(() => GetDashboardSummary());
  sl.registerLazySingleton(
    () => SyncRecurringTransactions(
      transactionRepository: sl(),
      accountRepository: sl(),
    ),
  );

  // Bloc
  sl.registerFactory(
    () => DashboardBloc(
      getDashboardSummary: sl(),
      syncRecurringTransactions: sl(),
      accountBloc: sl(),
      transactionBloc: sl(),
      authBloc: sl(),
    ),
  );
}
