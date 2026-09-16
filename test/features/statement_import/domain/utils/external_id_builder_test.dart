import 'package:due_day/features/statement_import/domain/utils/external_id_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExternalIdBuilder', () {
    test('strips the OFX ":reversal" suffix before composing the key', () {
      final original = ExternalIdBuilder.build(
        rawIdentifier: 'abc-123',
        amountInCents: -5000,
      );
      final reversal = ExternalIdBuilder.build(
        rawIdentifier: 'abc-123:reversal',
        amountInCents: 5000,
      );

      expect(original, 'abc-123|-5000');
      expect(reversal, 'abc-123|5000');
      expect(original, isNot(equals(reversal)));
    });

    test(
      'produces the same key for the OFX and CSV representation of the same transaction',
      () {
        // OFX gives the reversal a ":reversal"-suffixed id; CSV reuses the
        // exact same raw id for both rows. Both must normalize to the same
        // key for a given (identifier, amount) pair so an OFX import and a
        // CSV import of the same statement agree on duplicates.
        final fromOfxOriginal = ExternalIdBuilder.build(
          rawIdentifier: 'abc-123',
          amountInCents: -5000,
        );
        final fromCsvOriginal = ExternalIdBuilder.build(
          rawIdentifier: 'abc-123',
          amountInCents: -5000,
        );
        final fromOfxReversal = ExternalIdBuilder.build(
          rawIdentifier: 'abc-123:reversal',
          amountInCents: 5000,
        );
        final fromCsvReversal = ExternalIdBuilder.build(
          rawIdentifier: 'abc-123',
          amountInCents: 5000,
        );

        expect(fromOfxOriginal, fromCsvOriginal);
        expect(fromOfxReversal, fromCsvReversal);
      },
    );

    test('differing amounts produce differing keys for the same identifier', () {
      final key1 = ExternalIdBuilder.build(
        rawIdentifier: 'same-id',
        amountInCents: 100,
      );
      final key2 = ExternalIdBuilder.build(
        rawIdentifier: 'same-id',
        amountInCents: 200,
      );

      expect(key1, isNot(equals(key2)));
    });

    test('rounds fractional cents before composing the key', () {
      final key = ExternalIdBuilder.build(
        rawIdentifier: 'id',
        amountInCents: 1990.0000001,
      );

      expect(key, 'id|1990');
    });
  });
}
