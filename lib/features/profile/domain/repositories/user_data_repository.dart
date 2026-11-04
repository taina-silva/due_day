import 'package:due_day/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract class UserDataRepository {
  /// Deletes every account, category, and transaction of the signed-in
  /// user. Login, profile, and preferences stay (SET-001).
  Future<Either<Failure, void>> deleteAllUserData();
}
