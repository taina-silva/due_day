import 'package:due_day/features/accounts/data/datasources/account_remote_data_source.dart';
import 'package:due_day/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:get_it/get_it.dart';

void initAccounts() {
  final sl = GetIt.instance;

  // Blocs
  sl.registerFactory(() => AccountLoadBloc(getAccounts: sl()));
  sl.registerFactory(
    () => AccountActionBloc(
      addAccount: sl(),
      updateAccount: sl(),
      deleteAccount: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AddAccount(sl()));
  sl.registerLazySingleton(() => UpdateAccount(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => GetAccounts(sl()));

  // Repository
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(remoteDataSource: sl(), observability: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
}
