import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/statement_import/data/datasources/card_bill_csv_statement_parser.dart';
import 'package:due_day/features/statement_import/data/datasources/csv_statement_parser.dart';
import 'package:due_day/features/statement_import/data/datasources/ofx_statement_parser.dart';
import 'package:due_day/features/statement_import/data/datasources/statement_format_detector.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:due_day/features/statement_import/domain/repositories/statement_import_repository.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

class StatementImportRepositoryImpl implements StatementImportRepository {
  final OfxStatementParser ofxParser;
  final CsvStatementParser csvParser;
  final CardBillCsvStatementParser cardBillParser;
  final TransactionRepository transactionRepository;
  final ObservabilityService observability;

  static const String _tag = 'statement_import';

  StatementImportRepositoryImpl({
    required this.ofxParser,
    required this.csvParser,
    required this.cardBillParser,
    required this.transactionRepository,
    required this.observability,
  });

  @override
  Either<Failure, List<ParsedStatementTransaction>> parseStatement({
    required String content,
  }) {
    try {
      final format = StatementFormatDetector.detect(content);
      if (format == null) {
        return const Left(UnsupportedFileFormatFailure());
      }

      final List<ParsedStatementTransaction> result = switch (format) {
        StatementFormat.nubankOfx => ofxParser.parse(content),
        StatementFormat.checkingCsv => csvParser.parse(content),
        StatementFormat.cardBillCsv => cardBillParser.parse(content),
      };

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
  }) async {
    try {
      // Only transactions are written; accounts have no balance (IMP-010).
      return await transactionRepository.addTransactionsBatch(
        transactionsToCreate,
      );
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
}
