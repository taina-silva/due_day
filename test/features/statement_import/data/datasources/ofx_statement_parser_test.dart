import 'dart:io';

import 'package:due_day/features/statement_import/data/datasources/ofx_statement_parser.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late OfxStatementParserImpl parser;

  setUp(() {
    parser = OfxStatementParserImpl();
  });

  String loadFixture(String name) {
    return File(
      'test/features/statement_import/fixtures/$name',
    ).readAsStringSync();
  }

  group('OfxStatementParserImpl', () {
    test(
      'parses all transactions from a Nubank-style OFX statement',
      () {
        final content = loadFixture('sample_nubank.ofx');

        final result = parser.parse(content);

        expect(result, hasLength(6));
        expect(result.every((t) => t.source == StatementSource.ofx), isTrue);
      },
    );

    test('parses field values correctly for a plain debit line', () {
      final content = loadFixture('sample_nubank.ofx');

      final result = parser.parse(content);
      final debit = result.firstWhere(
        (t) => t.rawIdentifier == 'deadbeef-0001-0001-0001-000000000001',
      );

      expect(debit.amount, -19.90);
      expect(debit.date, DateTime(2026, 8, 1));
      expect(debit.memo, 'Compra no débito - FAKE COMERCIO LTDA');
    });

    test('strips the bracketed timezone suffix from DTPOSTED', () {
      final content = loadFixture('sample_nubank.ofx');

      final result = parser.parse(content);
      final credit = result.firstWhere(
        (t) => t.rawIdentifier == 'deadbeef-0004-0004-0004-000000000004',
      );

      expect(credit.date, DateTime(2026, 8, 10));
      expect(credit.amount, 1000.00);
    });

    test(
      'the reversal pair (":reversal"-suffixed FITID) yields two distinct externalIds',
      () {
        final content = loadFixture('sample_nubank.ofx');

        final result = parser.parse(content);
        final original = result.firstWhere(
          (t) => t.rawIdentifier == 'deadbeef-0005-0005-0005-000000000005',
        );
        final reversal = result.firstWhere(
          (t) =>
              t.rawIdentifier ==
              'deadbeef-0005-0005-0005-000000000005:reversal',
        );

        expect(original.amount, -75.00);
        expect(reversal.amount, 75.00);
        expect(original.externalId, isNot(equals(reversal.externalId)));
      },
    );

    test(
      'returns an empty list without throwing when there are no STMTTRN blocks',
      () {
        final content = loadFixture('malformed.ofx');

        final result = parser.parse(content);

        expect(result, isEmpty);
      },
    );
  });
}
