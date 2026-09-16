import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:due_day/features/statement_import/domain/utils/external_id_builder.dart';

abstract class OfxStatementParser {
  List<ParsedStatementTransaction> parse(String ofxContent);
}

/// Extracts transactions from an OFX statement using tolerant regex-based
/// tag extraction rather than a strict XML parser.
///
/// Nubank declares its export as `OFXSGML VERSION:102` (an old format that
/// classically omits closing tags) but actually closes every tag in
/// practice. Other banks' SGML exports may genuinely omit closing tags.
/// Regex extraction handles both cases without needing to coerce the file
/// into well-formed XML; scope for phase 1 is Nubank-only.
class OfxStatementParserImpl implements OfxStatementParser {
  static final RegExp _stmtTrnBlock = RegExp(
    r'<STMTTRN>(.*?)</STMTTRN>',
    dotAll: true,
  );
  static final RegExp _tzSuffix = RegExp(r'\[.*\]');

  @override
  List<ParsedStatementTransaction> parse(String ofxContent) {
    final blocks = _stmtTrnBlock.allMatches(ofxContent);
    final transactions = <ParsedStatementTransaction>[];

    for (final block in blocks) {
      final body = block.group(1) ?? '';
      final fitId = _extractTag(body, 'FITID');
      final dtPosted = _extractTag(body, 'DTPOSTED');
      final trnAmt = _extractTag(body, 'TRNAMT');
      final memo = _extractTag(body, 'MEMO') ?? '';

      if (fitId == null || dtPosted == null || trnAmt == null) {
        continue; // skip malformed block, don't fail the whole import
      }

      final amount = double.tryParse(trnAmt);
      if (amount == null) continue;

      final normalizedDate = dtPosted.replaceAll(_tzSuffix, '');
      final date = _parseOfxDateTime(normalizedDate);
      if (date == null) continue;

      transactions.add(
        ParsedStatementTransaction(
          rawIdentifier: fitId,
          externalId: ExternalIdBuilder.build(
            rawIdentifier: fitId,
            amountInCents: amount * 100,
          ),
          date: date,
          amount: amount,
          memo: memo,
          source: StatementSource.ofx,
        ),
      );
    }

    return transactions;
  }

  String? _extractTag(String block, String tag) {
    final pattern = RegExp('<$tag>([^<\r\n]*)');
    final match = pattern.firstMatch(block);
    return match?.group(1)?.trim();
  }

  // DTPOSTED is a contiguous digit run (yyyyMMddHHmmss, no separators).
  // DateFormat.parse's field-boundary detection is unreliable on
  // separator-less numeric patterns, so this slices fixed-width digit
  // groups manually instead.
  DateTime? _parseOfxDateTime(String value) {
    if (value.length < 8) return null;
    try {
      final year = int.parse(value.substring(0, 4));
      final month = int.parse(value.substring(4, 6));
      final day = int.parse(value.substring(6, 8));
      final hour = value.length >= 10 ? int.parse(value.substring(8, 10)) : 0;
      final minute = value.length >= 12
          ? int.parse(value.substring(10, 12))
          : 0;
      final second = value.length >= 14
          ? int.parse(value.substring(12, 14))
          : 0;
      return DateTime(year, month, day, hour, minute, second);
    } on FormatException {
      return null;
    }
  }
}
