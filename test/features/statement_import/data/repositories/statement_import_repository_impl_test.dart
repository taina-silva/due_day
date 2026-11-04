import 'dart:convert';
import 'dart:io';

import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/core/services/statement_file_picker_service.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/statement_import/data/datasources/card_bill_csv_statement_parser.dart';
import 'package:due_day/features/statement_import/data/datasources/csv_statement_parser.dart';
import 'package:due_day/features/statement_import/data/datasources/ofx_statement_parser.dart';
import 'package:due_day/features/statement_import/data/repositories/statement_import_repository_impl.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../transactions/helpers/transaction_test_helpers.dart';

void main() {
  late MockTransactionRepository transactionRepository;
  late StatementImportRepositoryImpl repository;

  const fixtures = 'test/features/statement_import/fixtures';

  setUpAll(() => registerFallbackValue(<TransactionEntity>[]));

  setUp(() {
    transactionRepository = MockTransactionRepository();
    repository = StatementImportRepositoryImpl(
      ofxParser: OfxStatementParserImpl(),
      csvParser: CsvStatementParserImpl(),
      cardBillParser: CardBillCsvStatementParserImpl(),
      transactionRepository: transactionRepository,
      observability: ObservabilityServiceImpl(sinks: const []),
    );
  });

  String read(String name) => File('$fixtures/$name').readAsStringSync();

  StatementFormat formatOf(String content) => repository
      .parseStatement(content: content)
      .getOrElse((f) => fail('unexpected $f'))
      .first
      .format;

  group('parseStatement', () {
    test('IMP-003: detects Nubank OFX by content', () {
      expect(formatOf(read('sample_nubank.ofx')), StatementFormat.nubankOfx);
    });

    test('IMP-003: detects the checking CSV by its header', () {
      expect(formatOf(read('sample_nubank.csv')), StatementFormat.checkingCsv);
    });

    test(
      'IMP-003: renamed file — a card bill CSV is parsed as a card bill',
      () {
        // Content is what matters; there's no file name at all.
        expect(
          formatOf(read('sample_nubank_card.csv')),
          StatementFormat.cardBillCsv,
        );
      },
    );

    test('IMP-001: a PDF shows "unsupported file"', () {
      final pdfBytes = [
        ...'%PDF-1.7\n'.codeUnits,
        0xE2, 0xE3, 0xCF, 0xD3, // binary marker, invalid UTF-8
        ...'\n1 0 obj\n<< /Type /Catalog >>\nendobj\n'.codeUnits,
      ];

      final result = repository.parseStatement(
        content: decodeStatementBytes(pdfBytes),
      );

      expect(result, const Left(UnsupportedFileFormatFailure()));
    });

    test('IMP-001: unknown text is unsupported', () {
      expect(
        repository.parseStatement(content: 'hello,world\n1,2\n'),
        const Left(UnsupportedFileFormatFailure()),
      );
    });

    test('IMP-002: Latin-1 CSV — header recognized and memo decoded', () {
      final bytes = File(
        '$fixtures/sample_nubank_latin1.csv',
      ).readAsBytesSync();

      final parsed = repository
          .parseStatement(content: decodeStatementBytes(bytes))
          .getOrElse((f) => fail('unexpected $f'));

      expect(parsed.first.format, StatementFormat.checkingCsv);
      expect(parsed.first.memo, 'Padaria São João');
    });

    test('IMP-008: checking "Pagamento de fatura" is suggested as Ignored', () {
      final parsed = repository
          .parseStatement(content: read('sample_nubank.ofx'))
          .getOrElse((f) => fail('unexpected $f'));

      final billPayment = parsed.firstWhere(
        (t) => t.memo == 'Pagamento de fatura',
      );
      expect(billPayment.amount, isNegative);
      expect(billPayment.suggestedCategoryKind, CategoryKind.ignored);
      expect(
        parsed
            .where((t) => t.memo != 'Pagamento de fatura')
            .every((t) => t.suggestedCategoryKind == null),
        isTrue,
      );
    });
  });

  group('decodeStatementBytes', () {
    test('IMP-002: strips a UTF-8 BOM', () {
      final bytes = [0xEF, 0xBB, 0xBF, ...'date,title,amount'.codeUnits];

      expect(decodeStatementBytes(bytes), 'date,title,amount');
    });

    test('IMP-002: decodes valid UTF-8 as UTF-8', () {
      expect(decodeStatementBytes(utf8.encode('Descrição')), 'Descrição');
    });
  });

  group('confirmImport', () {
    test(
      'IMP-010: confirming 30 items writes 30 transactions and no account',
      () async {
        final items = List.generate(
          30,
          (i) => tTransactionEntity.copyWith(id: 'tx-$i'),
        );
        when(
          () => transactionRepository.addTransactionsBatch(any()),
        ).thenAnswer((_) async => Right(items));

        final result = await repository.confirmImport(
          transactionsToCreate: items,
        );

        expect(result.getOrElse((_) => const []), hasLength(30));
        verify(
          () => transactionRepository.addTransactionsBatch(items),
        ).called(1);
        verifyNoMoreInteractions(transactionRepository);
      },
    );
  });
}
