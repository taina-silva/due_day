import 'package:csv/csv.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:due_day/features/statement_import/domain/utils/bill_payment_matcher.dart';
import 'package:due_day/features/statement_import/domain/utils/external_id_builder.dart';
import 'package:intl/intl.dart';

abstract class CardBillCsvStatementParser {
  List<ParsedStatementTransaction> parse(String csvContent);
}

/// Parses the Nubank credit card bill CSV (`date,title,amount`).
///
/// - `date` is `yyyy-MM-dd`; `amount` uses `.` as decimal separator
///   (IMP-005). Invalid rows are skipped.
/// - Positive = purchase (expense), negative = credit (income) (IMP-005).
/// - Dedup id from raw date + title + cents + occurrence index (IMP-006).
/// - An installment `N/M` at the end of the title is dated line date +
///   (N−1) months, day clamped (IMP-007).
/// - "Pagamento recebido" is suggested as *Ignored* (IMP-008); other
///   credits stay uncategorized (IMP-009).
class CardBillCsvStatementParserImpl implements CardBillCsvStatementParser {
  static const List<String> _expectedHeader = ['date', 'title', 'amount'];
  static final RegExp _installment = RegExp(r'(\d{1,3})\s*/\s*(\d{1,3})\s*$');

  final CsvToListConverter _converter;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  CardBillCsvStatementParserImpl({CsvToListConverter? converter})
    : _converter =
          converter ??
          const CsvToListConverter(eol: '\n', shouldParseNumbers: false);

  @override
  List<ParsedStatementTransaction> parse(String csvContent) {
    var normalized = csvContent.replaceAll('\r\n', '\n');
    if (normalized.startsWith('\uFEFF')) normalized = normalized.substring(1);
    final rows = _converter.convert(normalized);
    if (rows.isEmpty) return const [];

    final header = rows.first
        .map((cell) => cell.toString().trim().toLowerCase())
        .toList();
    if (header.length < _expectedHeader.length ||
        !_matchesExpectedHeader(header)) {
      throw const FormatException('Unrecognized card bill CSV format.');
    }

    final occurrences = <String, int>{};
    final transactions = <ParsedStatementTransaction>[];

    for (final row in rows.skip(1)) {
      if (row.length < 3) continue;

      final rawDate = row[0].toString().trim();
      final title = row[1].toString().trim();
      final csvAmount = double.tryParse(row[2].toString().trim());
      if (csvAmount == null) continue;

      final DateTime lineDate;
      try {
        lineDate = _dateFormat.parseStrict(rawDate);
      } catch (_) {
        continue;
      }

      final cents = (csvAmount * 100).round();
      final lineKey = '$rawDate|$title|$cents';
      final occurrence = occurrences[lineKey] ?? 0;
      occurrences[lineKey] = occurrence + 1;

      final isCredit = csvAmount < 0;
      final suggestedKind =
          isCredit && BillPaymentMatcher.isCardPaymentReceived(title)
          ? CategoryKind.ignored
          : null;

      transactions.add(
        ParsedStatementTransaction(
          rawIdentifier: '$lineKey|$occurrence',
          externalId: ExternalIdBuilder.buildCardBill(
            rawDate: rawDate,
            title: title,
            amountInCents: cents,
            occurrence: occurrence,
          ),
          date: _billedDate(lineDate, title),
          // Card: positive = purchase. Parsed amounts: negative = expense.
          amount: -csvAmount,
          memo: title,
          source: StatementSource.csv,
          format: StatementFormat.cardBillCsv,
          suggestedCategoryKind: suggestedKind,
        ),
      );
    }

    return transactions;
  }

  /// Installment `N/M` → line date + (N−1) months, clamped to the target
  /// month's last day (IMP-007).
  DateTime _billedDate(DateTime lineDate, String title) {
    final match = _installment.firstMatch(title);
    if (match == null) return lineDate;
    final n = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    if (n < 1 || m < 1 || n > m) return lineDate;

    final targetMonthStart = DateTime(lineDate.year, lineDate.month + n - 1);
    final lastDay = DateTime(
      targetMonthStart.year,
      targetMonthStart.month + 1,
      0,
    ).day;
    return DateTime(
      targetMonthStart.year,
      targetMonthStart.month,
      lineDate.day > lastDay ? lastDay : lineDate.day,
    );
  }

  bool _matchesExpectedHeader(List<String> header) {
    for (var i = 0; i < _expectedHeader.length; i++) {
      if (header[i] != _expectedHeader[i]) return false;
    }
    return true;
  }
}
