import 'package:freezed_annotation/freezed_annotation.dart';

/// How a category counts on the dashboard (CAT-001).
///
/// - [spending]: counts in Spent (default for every user category).
/// - [investment]: counts in Invested, never in Spent.
/// - [ignored]: counts nowhere (e.g. card bill payments).
enum CategoryKind {
  @JsonValue('spending')
  spending,
  @JsonValue('investment')
  investment,
  @JsonValue('ignored')
  ignored,
}
