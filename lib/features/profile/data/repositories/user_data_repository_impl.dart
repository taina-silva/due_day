import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/profile/data/datasources/user_data_remote_data_source.dart';
import 'package:due_day/features/profile/domain/errors/user_data_failures.dart';
import 'package:due_day/features/profile/domain/repositories/user_data_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserDataRepositoryImpl implements UserDataRepository {
  final UserDataRemoteDataSource remoteDataSource;
  final ObservabilityService observability;

  static const String _tag = 'user_data';

  UserDataRepositoryImpl({
    required this.remoteDataSource,
    required this.observability,
  });

  @override
  Future<Either<Failure, void>> deleteAllUserData() async {
    try {
      await remoteDataSource.deleteAll();
      return const Right(null);
    } on ServerException catch (e) {
      observability.error(
        'deleteAllUserData failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(DeleteUserDataFailure(e.message));
    } catch (e, stackTrace) {
      observability.error(
        'deleteAllUserData unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(DeleteUserDataFailure(e.toString()));
    }
  }
}
