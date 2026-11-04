import 'dart:io';

import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/statement_import/data/datasources/card_bill_csv_statement_parser.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CardBillCsvStatementParserImpl parser;

  setUp(() => parser = CardBillCsvStatementParserImpl());

  String fixture() => File(
    'test/features/statement_import/fixtures/sample_nubank_card.csv',
  ).readAsStringSync();

  group('CardBillCsvStatementParserImpl', () {
    test('IMP-005: purchase and refund', () {
      final result = parser.parse(
        'date,title,amount\n'
        '2026-09-03,Padaria,25.90\n'
        '2026-09-05,Estorno Loja,-40.00\n',
      );

      expect(result, hasLength(2));
      expect(result[0].amount, -25.90); // expense
      expect(result[0].date, DateTime(2026, 9, 3));
      expect(result[0].memo, 'Padaria');
      expect(result[1].amount, 40.00); // income
      expect(result[1].date, DateTime(2026, 9, 5));
      expect(
        result.every((t) => t.format == StatementFormat.cardBillCsv),
        isTrue,
      );
    });

    test('IMP-005: rows with an invalid date or amount are skipped', () {
      final result = parser.parse(fixture());

      expect(result.map((t) => t.memo), isNot(contains('Broken')));
      expect(result.map((t) => t.memo), isNot(contains('Broken amount')));
      expect(result, hasLength(7));
    });

    test('IMP-006: two identical coffees get distinct, stable ids', () {
      final first = parser.parse(fixture());
      final second = parser.parse(fixture());

      final coffees = first.where((t) => t.memo == 'Cafe').toList();
      expect(coffees, hasLength(2));
      expect(coffees[0].externalId, isNot(coffees[1].externalId));
      expect(
        second.map((t) => t.externalId).toList(),
        first.map((t) => t.externalId).toList(),
      );
    });

    test('IMP-007: third installment is dated purchase + 2 months', () {
      final result = parser.parse(
        'date,title,amount\n2026-06-15,Loja X - Parcela 3/10,100.00\n',
      );

      expect(result.single.date, DateTime(2026, 8, 15));
      // The dedup id keeps the raw line date.
      expect(result.single.externalId, contains('2026-06-15'));
    });

    test('IMP-007: day clamping to the month end', () {
      final result = parser.parse(
        'date,title,amount\n2026-01-31,Loja Y - Parcela 2/3,50.00\n',
      );

      expect(result.single.date, DateTime(2026, 2, 28));
    });

    test('IMP-008: payment received is suggested as Ignored income', () {
      final result = parser.parse(
        'date,title,amount\n2026-09-10,Pagamento recebido,-2000.00\n',
      );

      expect(result.single.amount, 2000.00);
      expect(result.single.suggestedCategoryKind, CategoryKind.ignored);
    });

    test('IMP-009: other credits arrive uncategorized', () {
      final result = parser.parse(
        'date,title,amount\n2026-09-05,Estorno Loja,-40.00\n',
      );

      expect(result.single.suggestedCategoryKind, isNull);
    });

    test('rejects a file without the card bill header', () {
      expect(
        () => parser.parse('foo,bar\n1,2\n'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
