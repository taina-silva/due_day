import 'package:due_day/core/services/statement_file_picker_service.dart';
import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/statement_import/data/datasources/csv_statement_parser.dart';
import 'package:due_day/features/statement_import/data/datasources/ofx_statement_parser.dart';
import 'package:due_day/features/statement_import/data/repositories/statement_import_repository_impl.dart';
import 'package:due_day/features/statement_import/domain/repositories/statement_import_repository.dart';
import 'package:due_day/features/statement_import/domain/usecases/build_review_list.dart';
import 'package:due_day/features/statement_import/domain/usecases/confirm_import.dart';
import 'package:due_day/features/statement_import/domain/usecases/parse_statement.dart';
import 'package:due_day/features/statement_import/domain/usecases/pick_statement_file.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_bloc.dart';
import 'package:get_it/get_it.dart';

void initStatementImport() {
  final sl = GetIt.instance;

  // Bloc
  sl.registerFactory(
    () => StatementImportBloc(
      pickStatementFile: sl(),
      parseStatement: sl(),
      buildReviewList: sl(),
      confirmImport: sl(),
      getCurrentUser: sl<GetCurrentUser>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => PickStatementFile(sl()));
  sl.registerLazySingleton(() => ParseStatement(sl()));
  sl.registerLazySingleton(() => BuildReviewList(sl()));
  sl.registerLazySingleton(() => ConfirmImport(sl()));

  // Repository
  sl.registerLazySingleton<StatementImportRepository>(
    () => StatementImportRepositoryImpl(
      ofxParser: sl(),
      csvParser: sl(),
      transactionRepository: sl(),
      accountRepository: sl(),
      observability: sl(),
    ),
  );

  // Parsers
  sl.registerLazySingleton<OfxStatementParser>(() => OfxStatementParserImpl());
  sl.registerLazySingleton<CsvStatementParser>(() => CsvStatementParserImpl());

  // File picker (core service)
  sl.registerLazySingleton<StatementFilePickerService>(
    () => StatementFilePickerServiceImpl(observability: sl()),
  );
}
