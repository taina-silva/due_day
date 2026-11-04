import 'dart:convert';

import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/statement_import/domain/entities/picked_statement_file.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';

/// Decodes statement bytes as UTF-8 (BOM removed); if they aren't valid
/// UTF-8, as Latin-1 (IMP-002).
String decodeStatementBytes(List<int> bytes) {
  final hasBom =
      bytes.length >= 3 &&
      bytes[0] == 0xEF &&
      bytes[1] == 0xBB &&
      bytes[2] == 0xBF;
  final body = hasBom ? bytes.sublist(3) : bytes;
  try {
    return utf8.decode(body);
  } on FormatException {
    return latin1.decode(body);
  }
}

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
      // Any file: Android has no MIME type for `.ofx`, so a custom
      // extension filter hides it. The content is validated after reading
      // (IMP-001).
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
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

      final content = decodeStatementBytes(bytes);
      return Right(PickedStatementFile(fileName: file.name, content: content));
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
