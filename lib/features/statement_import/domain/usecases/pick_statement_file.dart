import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/services/statement_file_picker_service.dart';
import 'package:due_day/features/statement_import/domain/entities/picked_statement_file.dart';
import 'package:fpdart/fpdart.dart';

class PickStatementFile {
  final StatementFilePickerService filePicker;

  PickStatementFile(this.filePicker);

  Future<Either<Failure, PickedStatementFile?>> call() => filePicker.pickFile();
}
