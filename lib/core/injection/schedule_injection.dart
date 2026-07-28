import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/features/schedule/domain/usecases/get_schedule_data.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_bloc.dart';

void initSchedule() {
  // Use cases
  sl.registerLazySingleton(() => GetScheduleData(sl()));

  // Blocs
  sl.registerFactory(() => ScheduleLoadBloc(getScheduleData: sl()));
  sl.registerFactory(() => ScheduleActionBloc(updateTransaction: sl()));
}
