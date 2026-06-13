import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:due_day/features/auth/data/models/user_model.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(email, password);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
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
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
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
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    try {
      await remoteDataSource.updateUser(UserModel.fromEntity(user));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GenericFailure(e.toString()));
    }
  }
}
