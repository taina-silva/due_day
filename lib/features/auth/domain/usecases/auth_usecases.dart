import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignInWithEmail {
  final AuthRepository repository;

  SignInWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}

class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
    String displayName,
  ) {
    return repository.signUpWithEmail(email, password, displayName);
  }
}

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<Failure, UserEntity?>> call() {
    return repository.getCurrentUser();
  }
}

class UpdateUser {
  final AuthRepository repository;

  UpdateUser(this.repository);

  Future<Either<Failure, void>> call(UserEntity user) {
    return repository.updateUser(user);
  }
}
