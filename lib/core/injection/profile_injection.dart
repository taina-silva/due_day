import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/profile/data/datasources/user_data_remote_data_source.dart';
import 'package:due_day/features/profile/data/repositories/user_data_repository_impl.dart';
import 'package:due_day/features/profile/domain/repositories/user_data_repository.dart';
import 'package:due_day/features/profile/domain/usecases/delete_all_user_data.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_bloc.dart';
import 'package:get_it/get_it.dart';

void initProfile() {
  final sl = GetIt.instance;

  // Blocs
  sl.registerFactory(
    () => ProfileBloc(updateUser: sl<UpdateUser>(), imagePickerService: sl()),
  );
  sl.registerFactory(
    () =>
        UserDataActionBloc(deleteAllUserData: sl(), notificationService: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => DeleteAllUserData(sl()));

  // Repository
  sl.registerLazySingleton<UserDataRepository>(
    () => UserDataRepositoryImpl(remoteDataSource: sl(), observability: sl()),
  );

  // Data sources
  sl.registerLazySingleton<UserDataRemoteDataSource>(
    () => UserDataRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
}
