import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/features/notifications/data/datasources/notifications_local_data_source.dart';
import 'package:due_day/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:due_day/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:due_day/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_bloc.dart';

void initNotifications() {
  // Datasource
  sl.registerLazySingleton<NotificationsLocalDataSource>(
    () => NotificationsLocalDataSourceImpl(box: sl(), firebaseAuth: sl()),
  );

  // Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(localDataSource: sl(), observability: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => AddNotification(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));

  // Bloc
  sl.registerFactory(
    () => NotificationsBloc(
      getNotifications: sl(),
      markNotificationAsRead: sl(),
      deleteNotification: sl(),
    ),
  );
}
