import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:equatable/equatable.dart';

/// Format-agnostic representation of a single statement line, produced by
/// both the OFX and CSV parsers so downstream review/dedup code never needs
/// to know which format it came from.
class ParsedStatementTransaction extends Equatable {
  final String rawIdentifier; // FITID (OFX) or Identificador (CSV), unmodified
  final String externalId; // composite dedup key, see ExternalIdBuilder
  final DateTime date;
  final double amount; // signed: negative = debit/expense, positive = credit/income
  final String memo;
  final StatementSource source;

  const ParsedStatementTransaction({
    required this.rawIdentifier,
    required this.externalId,
    required this.date,
    required this.amount,
    required this.memo,
    required this.source,
  });

  @override
  List<Object?> get props => [
    rawIdentifier,
    externalId,
    date,
    amount,
    memo,
    source,
  ];
}
