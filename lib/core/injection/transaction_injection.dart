import 'package:due_day/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:due_day/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:due_day/features/transactions/domain/usecases/classify_transaction_reminders.dart';
import 'package:due_day/features/transactions/domain/usecases/sync_recurring_transactions.dart';
import 'package:due_day/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_bloc.dart';
import 'package:get_it/get_it.dart';

void initTransactions() {
  final sl = GetIt.instance;

  // Blocs
  sl.registerFactory(
    () => TransactionLoadBloc(
      getTransactions: sl(),
      settingsBloc: sl(),
      notificationService: sl(),
      addNotification: sl(),
      classifyTransactionReminders: sl(),
      syncRecurringTransactions: sl(),
      getCurrentUser: sl(),
    ),
  );
  sl.registerFactory(
    () => TransactionActionBloc(
      addTransaction: sl(),
      updateTransaction: sl(),
      deleteTransaction: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AddTransaction(sl(), sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl(), sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl(), sl()));
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => ClassifyTransactionReminders());
  sl.registerLazySingleton(
    () => SyncRecurringTransactions(
      transactionRepository: sl(),
      accountRepository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<TransactionRepository>(
    () =>
        TransactionRepositoryImpl(remoteDataSource: sl(), observability: sl()),
  );

  // Data sources
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
}
