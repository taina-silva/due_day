import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/entities/import_summary.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:equatable/equatable.dart';

abstract class StatementImportState extends Equatable {
  const StatementImportState();

  @override
  List<Object?> get props => [];
}

class StatementImportInitial extends StatementImportState {
  const StatementImportInitial();
}

class StatementImportPicking extends StatementImportState {
  const StatementImportPicking();
}

class StatementImportParsing extends StatementImportState {
  const StatementImportParsing();
}

class StatementImportAwaitingAccount extends StatementImportState {
  final List<ParsedStatementTransaction> parsed;

  const StatementImportAwaitingAccount(this.parsed);

  @override
  List<Object?> get props => [parsed];
}

class StatementImportReviewing extends StatementImportState {
  final AccountEntity account;
  final List<ImportReviewItem> items;

  const StatementImportReviewing({required this.account, required this.items});

  @override
  List<Object?> get props => [account, items];
}

class StatementImportConfirming extends StatementImportState {
  final AccountEntity account;
  final List<ImportReviewItem> items;

  const StatementImportConfirming({
    required this.account,
    required this.items,
  });

  @override
  List<Object?> get props => [account, items];
}

class StatementImportSuccess extends StatementImportState {
  final ImportSummary summary;

  const StatementImportSuccess(this.summary);

  @override
  List<Object?> get props => [summary];
}

class StatementImportError extends StatementImportState {
  final Failure failure;

  const StatementImportError(this.failure);

  @override
  List<Object?> get props => [failure];
}
