import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:due_day/features/auth/data/models/user_model.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/domain/errors/auth_failures.dart';
import 'package:due_day/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ObservabilityService observability;

  static const String _tag = 'auth';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.observability,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(email, password);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      observability.error(
        'signInWithEmail failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapException(e));
    } catch (e, stackTrace) {
      observability.error(
        'signInWithEmail unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmail(
        email,
        password,
        displayName,
      );
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      observability.error(
        'signUpWithEmail failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapException(e));
    } catch (e, stackTrace) {
      observability.error(
        'signUpWithEmail unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      observability.error(
        'signInWithGoogle failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapException(e));
    } catch (e, stackTrace) {
      observability.error(
        'signInWithGoogle unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      observability.error(
        'signOut failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapException(e));
    } catch (e, stackTrace) {
      observability.error(
        'signOut unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      if (userModel != null) {
        return Right(userModel.toEntity());
      }
      return const Right(null);
    } on ServerException catch (e) {
      observability.error(
        'getCurrentUser failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapException(e));
    } catch (e, stackTrace) {
      observability.error(
        'getCurrentUser unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    try {
      await remoteDataSource.updateUser(UserModel.fromEntity(user));
      return const Right(null);
    } on ServerException catch (e) {
      observability.error(
        'updateUser failed',
        tag: _tag,
        error: e,
        stackTrace: StackTrace.current,
      );
      return Left(_mapException(e));
    } catch (e, stackTrace) {
      observability.error(
        'updateUser unexpected failure',
        tag: _tag,
        error: e,
        stackTrace: stackTrace,
      );
      return Left(GenericFailure(e.toString()));
    }
  }

  Failure _mapException(ServerException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsFailure();
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'user-disabled':
        return const UserDisabledFailure();
      case 'google-sign-in-canceled':
        return const AuthCancelledFailure();
      case 'user-not-found-firestore':
        return const UserNotFoundFailure();
      default:
        return ServerFailure(e.message);
    }
  }
}
