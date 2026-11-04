import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/profile/domain/repositories/user_data_repository.dart';
import 'package:fpdart/fpdart.dart';

/// "Delete all my data" (SET-001).
class DeleteAllUserData {
  final UserDataRepository repository;
  DeleteAllUserData(this.repository);

  Future<Either<Failure, void>> call() => repository.deleteAllUserData();
}
