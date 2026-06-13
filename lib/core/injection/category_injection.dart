import 'package:due_day/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:due_day/features/categories/data/repositories/category_repository_impl.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/categories/presentation/bloc/category_bloc.dart';
import 'package:get_it/get_it.dart';

void initCategories() {
  final sl = GetIt.instance;

  // Bloc
  sl.registerFactory(
    () => CategoryBloc(
      addCategory: sl(),
      updateCategory: sl(),
      deleteCategory: sl(),
      getCategories: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AddCategory(sl()));
  sl.registerLazySingleton(() => UpdateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
}
