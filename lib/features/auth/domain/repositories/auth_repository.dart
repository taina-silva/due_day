import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> updateUser(UserEntity user);
}
