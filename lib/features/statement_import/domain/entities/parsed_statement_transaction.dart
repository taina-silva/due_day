import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_source.dart';
import 'package:equatable/equatable.dart';

/// Format-agnostic representation of a single statement line, produced by
/// every parser so downstream review/dedup code never needs to know which
/// format it came from.
class ParsedStatementTransaction extends Equatable {
  final String
  rawIdentifier; // FITID (OFX), Identificador (CSV), or card line key
  final String externalId; // composite dedup key, see ExternalIdBuilder
  final DateTime date;
  final double
  amount; // signed: negative = debit/expense, positive = credit/income
  final String memo;
  final StatementSource source;
  final StatementFormat format;

  /// Category kind the review list pre-selects (IMP-008), e.g. `ignored`
  /// for card bill payments. Null = uncategorized.
  final CategoryKind? suggestedCategoryKind;

  const ParsedStatementTransaction({
    required this.rawIdentifier,
    required this.externalId,
    required this.date,
    required this.amount,
    required this.memo,
    required this.source,
    required this.format,
    this.suggestedCategoryKind,
  });

  @override
  List<Object?> get props => [
    rawIdentifier,
    externalId,
    date,
    amount,
    memo,
    source,
    format,
    suggestedCategoryKind,
  ];
}
