import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/services/statement_file_picker_service.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:due_day/features/statement_import/domain/repositories/statement_import_repository.dart';
import 'package:due_day/features/statement_import/domain/usecases/build_review_list.dart';
import 'package:due_day/features/statement_import/domain/usecases/confirm_import.dart';
import 'package:due_day/features/statement_import/domain/usecases/parse_statement.dart';
import 'package:due_day/features/statement_import/domain/usecases/pick_statement_file.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_bloc.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_event.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_state.dart';
import 'package:mocktail/mocktail.dart';

class MockStatementImportRepository extends Mock
    implements StatementImportRepository {}

class MockStatementFilePickerService extends Mock
    implements StatementFilePickerService {}

class MockStatementImportBloc
    extends MockBloc<StatementImportEvent, StatementImportState>
    implements StatementImportBloc {}

class MockPickStatementFile extends Mock implements PickStatementFile {}

class MockParseStatement extends Mock implements ParseStatement {}

class MockBuildReviewList extends Mock implements BuildReviewList {}

class MockConfirmImport extends Mock implements ConfirmImport {}

final tParsedDebit = ParsedStatementTransaction(
  rawIdentifier: 'deadbeef-0001',
  externalId: 'deadbeef-0001|-1990',
  date: DateTime(2026, 8, 1),
  amount: -19.90,
  memo: 'Compra no débito - FAKE COMERCIO LTDA',
  source: StatementSource.ofx,
);

final tParsedCredit = ParsedStatementTransaction(
  rawIdentifier: 'deadbeef-0004',
  externalId: 'deadbeef-0004|100000',
  date: DateTime(2026, 8, 10),
  amount: 1000.00,
  memo: 'Transferência Recebida - CICLANO DE SOUZA',
  source: StatementSource.ofx,
);

final tImportAccountEntity = AccountEntity(
  id: 'acc-import-1',
  userId: 'user-1',
  name: 'Nubank',
  category: AccountCategory.dailyUse,
  balance: 500.0,
  createdAt: DateTime(2026, 1, 1),
);
