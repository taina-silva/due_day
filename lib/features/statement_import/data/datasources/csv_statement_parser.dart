import 'package:csv/csv.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:due_day/features/statement_import/domain/utils/external_id_builder.dart';
import 'package:intl/intl.dart';

abstract class CsvStatementParser {
  List<ParsedStatementTransaction> parse(String csvContent);
}

class CsvStatementParserImpl implements CsvStatementParser {
  static const List<String> _expectedHeader = [
    'Data',
    'Valor',
    'Identificador',
    'Descrição',
  ];

  final CsvToListConverter _converter;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  CsvStatementParserImpl({CsvToListConverter? converter})
    : _converter =
          converter ??
          const CsvToListConverter(eol: '\n', shouldParseNumbers: false);

  @override
  List<ParsedStatementTransaction> parse(String csvContent) {
    // Normalize CRLF to LF first: CsvToListConverter matches [eol] literally
    // rather than auto-detecting it, and bank exports vary between the two.
    final normalizedContent = csvContent.replaceAll('\r\n', '\n');
    final rows = _converter.convert(normalizedContent);
    if (rows.isEmpty) return const [];

    final header = rows.first.map((cell) => cell.toString().trim()).toList();
    if (header.length < _expectedHeader.length ||
        !_matchesExpectedHeader(header)) {
      throw const FormatException('Unrecognized CSV statement format.');
    }

    final transactions = <ParsedStatementTransaction>[];

    for (final row in rows.skip(1)) {
      if (row.length < 4) continue;

      final rawDate = row[0].toString().trim();
      final rawAmount = row[1].toString().trim();
      final rawIdentifier = row[2].toString().trim();
      final memo = row[3].toString().trim();

      final amount = double.tryParse(rawAmount);
      if (amount == null || rawIdentifier.isEmpty) continue;

      final DateTime date;
      try {
        date = _dateFormat.parseStrict(rawDate);
      } catch (_) {
        continue;
      }

      transactions.add(
        ParsedStatementTransaction(
          rawIdentifier: rawIdentifier,
          externalId: ExternalIdBuilder.build(
            rawIdentifier: rawIdentifier,
            amountInCents: amount * 100,
          ),
          date: date,
          amount: amount,
          memo: memo,
          source: StatementSource.csv,
        ),
      );
    }

    return transactions;
  }

  bool _matchesExpectedHeader(List<String> header) {
    for (var i = 0; i < _expectedHeader.length; i++) {
      if (header[i] != _expectedHeader[i]) return false;
    }
    return true;
  }
}
