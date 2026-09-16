import 'dart:convert';

import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/statement_import/domain/entities/picked_statement_file.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';

abstract class StatementFilePickerService {
  /// Returns `Right(null)` if the user cancelled the picker (not a Failure).
  Future<Either<Failure, PickedStatementFile?>> pickFile();
}

class StatementFilePickerServiceImpl implements StatementFilePickerService {
  final ObservabilityService observability;

  static const String _tag = 'statement_import';

  StatementFilePickerServiceImpl({required this.observability});

  @override
  Future<Either<Failure, PickedStatementFile?>> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ofx', 'csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return const Right(null);
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        return const Left(StatementParseFailure('Could not read file.'));
      }

      final content = utf8.decode(bytes, allowMalformed: true);
      return Right(
        PickedStatementFile(fileName: file.name, content: content),
      );
    } catch (e, stackTrace) {
      observability.error(
        'pickFile failed',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(StatementParseFailure(e.toString()));
    }
  }
}
