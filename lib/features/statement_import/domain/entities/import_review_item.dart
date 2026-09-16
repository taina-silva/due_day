import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:equatable/equatable.dart';

enum ImportReviewStatus { pendingNew, alreadyImported }

class ImportReviewItem extends Equatable {
  final ParsedStatementTransaction parsed;
  final ImportReviewStatus status;
  final String? categoryId;
  final String? categoryName;
  final bool selectedForImport;

  const ImportReviewItem({
    required this.parsed,
    required this.status,
    required this.selectedForImport,
    this.categoryId,
    this.categoryName,
  });

  ImportReviewItem copyWith({
    ParsedStatementTransaction? parsed,
    ImportReviewStatus? status,
    bool? selectedForImport,
    String? categoryId,
    String? categoryName,
  }) {
    return ImportReviewItem(
      parsed: parsed ?? this.parsed,
      status: status ?? this.status,
      selectedForImport: selectedForImport ?? this.selectedForImport,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  List<Object?> get props => [
    parsed,
    status,
    categoryId,
    categoryName,
    selectedForImport,
  ];
}
