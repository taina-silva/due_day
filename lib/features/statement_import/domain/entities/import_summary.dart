import 'package:equatable/equatable.dart';

class ImportSummary extends Equatable {
  final int importedCount;
  final int skippedDuplicateCount;
  final int skippedByUserCount;

  const ImportSummary({
    required this.importedCount,
    required this.skippedDuplicateCount,
    required this.skippedByUserCount,
  });

  @override
  List<Object?> get props => [
    importedCount,
    skippedDuplicateCount,
    skippedByUserCount,
  ];
}
