import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/repositories/account_repository.dart';
import 'package:due_day/features/statement_import/data/datasources/csv_statement_parser.dart';
import 'package:due_day/features/statement_import/data/datasources/ofx_statement_parser.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:due_day/features/statement_import/domain/repositories/statement_import_repository.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

class StatementImportRepositoryImpl implements StatementImportRepository {
  final OfxStatementParser ofxParser;
  final CsvStatementParser csvParser;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
  final ObservabilityService observability;

  static const String _tag = 'statement_import';

  StatementImportRepositoryImpl({
    required this.ofxParser,
    required this.csvParser,
    required this.transactionRepository,
    required this.accountRepository,
    required this.observability,
  });

  @override
  Either<Failure, List<ParsedStatementTransaction>> parseStatement({
    required String fileName,
    required String content,
  }) {
    try {
      final lowerName = fileName.toLowerCase();
      final List<ParsedStatementTransaction> result;

      if (lowerName.endsWith('.ofx')) {
        result = ofxParser.parse(content);
      } else if (lowerName.endsWith('.csv')) {
        result = csvParser.parse(content);
      } else {
        return const Left(UnsupportedFileFormatFailure());
      }

      if (result.isEmpty) {
        return const Left(EmptyStatementFailure());
      }

      return Right(result);
    } catch (e, stackTrace) {
      observability.error(
        'parseStatement failed',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(StatementParseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> findExistingExternalIds(
    Set<String> externalIds,
  ) {
    return transactionRepository.findExistingExternalIds(externalIds);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> confirmImport({
    required List<TransactionEntity> transactionsToCreate,
    required String destinationAccountId,
  }) async {
    try {
      final addResult = await transactionRepository.addTransactionsBatch(
        transactionsToCreate,
      );

      return await addResult.fold((failure) async => Left(failure), (
        created,
      ) async {
        await _applyNetBalanceDelta(created, destinationAccountId);
        return Right(created);
      });
    } catch (e, stackTrace) {
      observability.error(
        'confirmImport failed',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ImportPersistFailure(e.toString()));
    }
  }

  // MVP writes to a single destination account per import, so the balance
  // impact of the whole batch collapses to one net delta (income sums add,
  // expense sums subtract) instead of a per-transaction read-modify-write.
  Future<void> _applyNetBalanceDelta(
    List<TransactionEntity> transactions,
    String accountId,
  ) async {
    var delta = 0.0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        delta += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        delta -= transaction.amount;
      }
    }

    if (delta == 0) return;

    final accountResult = await accountRepository.getAccountById(accountId);
    await accountResult.fold((failure) async => null, (
      AccountEntity account,
    ) async {
      final updatedAccount = AccountEntity(
        id: account.id,
        userId: account.userId,
        name: account.name,
        category: account.category,
        balance: account.balance + delta,
        createdAt: account.createdAt,
        dueDay: account.dueDay,
      );
      await accountRepository.updateAccount(updatedAccount);
    });
  }
}
