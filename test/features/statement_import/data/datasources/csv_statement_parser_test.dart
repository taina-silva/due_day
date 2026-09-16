import 'dart:io';

import 'package:due_day/features/statement_import/data/datasources/csv_statement_parser.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CsvStatementParserImpl parser;

  setUp(() {
    parser = CsvStatementParserImpl();
  });

  String loadFixture(String name) {
    return File(
      'test/features/statement_import/fixtures/$name',
    ).readAsStringSync();
  }

  group('CsvStatementParserImpl', () {
    test('parses all transactions from a Nubank-style CSV statement', () {
      final content = loadFixture('sample_nubank.csv');

      final result = parser.parse(content);

      expect(result, hasLength(6));
      expect(result.every((t) => t.source == StatementSource.csv), isTrue);
    });

    test('parses field values correctly for a plain debit line', () {
      final content = loadFixture('sample_nubank.csv');

      final result = parser.parse(content);
      final debit = result.firstWhere(
        (t) => t.rawIdentifier == 'deadbeef-0001-0001-0001-000000000001',
      );

      expect(debit.amount, -19.90);
      expect(debit.date, DateTime(2026, 8, 1));
      expect(debit.memo, 'Compra no débito - FAKE COMERCIO LTDA');
    });

    test(
      'the reversal row (same Identificador, flipped sign) yields a distinct '
      'externalId from the original row',
      () {
        final content = loadFixture('sample_nubank.csv');

        final result = parser.parse(content);
        final matching = result
            .where(
              (t) => t.rawIdentifier == 'deadbeef-0005-0005-0005-000000000005',
            )
            .toList();

        expect(matching, hasLength(2));
        expect(matching[0].amount, -75.00);
        expect(matching[1].amount, 75.00);
        expect(
          matching[0].externalId,
          isNot(equals(matching[1].externalId)),
        );
      },
    );

    test('throws a FormatException when the header does not match', () {
      const badContent = 'foo,bar,baz\n1,2,3\n';

      expect(() => parser.parse(badContent), throwsFormatException);
    });

    test('returns an empty list for a header-only CSV', () {
      final content = loadFixture('empty.csv');

      final result = parser.parse(content);

      expect(result, isEmpty);
    });
  });
}
