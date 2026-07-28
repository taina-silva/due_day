import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_bloc.dart';

void initDashboard() {
  // UseCases
  sl.registerLazySingleton(() => GetDashboardSummary());

  // Bloc
  sl.registerFactory(
    () => DashboardBloc(
      getDashboardSummary: sl(),
      getAccounts: sl(),
      getTransactions: sl(),
    ),
  );
}
