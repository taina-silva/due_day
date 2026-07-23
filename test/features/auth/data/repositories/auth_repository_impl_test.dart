import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:due_day/features/auth/domain/errors/auth_failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      observability: ObservabilityServiceImpl(sinks: const []),
    );
  });

  group('signInWithEmail', () {
    test(
      'given RemoteDataSource returns UserModel when signInWithEmail is called then return Right(UserEntity)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signInWithEmail(tEmail, tPassword),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signInWithEmail(tEmail, tPassword);

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(
          () => mockRemoteDataSource.signInWithEmail(tEmail, tPassword),
        ).called(1);
      },
    );

    test(
      'given RemoteDataSource throws ServerException with wrong-password code when signInWithEmail is called then return Left(InvalidCredentialsFailure)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signInWithEmail(tEmail, tPassword),
        ).thenThrow(const ServerException('Wrong password', 'wrong-password'));

        // act
        final result = await repository.signInWithEmail(tEmail, tPassword);

        // assert
        expect(result, equals(const fp.Left(InvalidCredentialsFailure())));
      },
    );

    test(
      'given RemoteDataSource throws any other Exception when signInWithEmail is called then return Left(GenericFailure)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signInWithEmail(tEmail, tPassword),
        ).thenThrow(Exception('Generic error'));

        // act
        final result = await repository.signInWithEmail(tEmail, tPassword);

        // assert
        expect(
          result,
          equals(const fp.Left(GenericFailure('Exception: Generic error'))),
        );
      },
    );
  });

  group('signUpWithEmail', () {
    test(
      'given RemoteDataSource returns UserModel when signUpWithEmail is called then return Right(UserEntity)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signUpWithEmail(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signUpWithEmail(
          tEmail,
          tPassword,
          tDisplayName,
        );

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(
          () => mockRemoteDataSource.signUpWithEmail(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).called(1);
      },
    );

    test(
      'given RemoteDataSource throws ServerException with email-already-in-use code when signUpWithEmail is called then return Left(EmailAlreadyInUseFailure)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signUpWithEmail(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).thenThrow(
          const ServerException('Email already in use', 'email-already-in-use'),
        );

        // act
        final result = await repository.signUpWithEmail(
          tEmail,
          tPassword,
          tDisplayName,
        );

        // assert
        expect(result, equals(const fp.Left(EmailAlreadyInUseFailure())));
      },
    );

    test(
      'given RemoteDataSource throws ServerException with weak-password code when signUpWithEmail is called then return Left(WeakPasswordFailure)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signUpWithEmail(
            tEmail,
            tPassword,
            tDisplayName,
          ),
        ).thenThrow(const ServerException('Weak password', 'weak-password'));

        // act
        final result = await repository.signUpWithEmail(
          tEmail,
          tPassword,
          tDisplayName,
        );

        // assert
        expect(result, equals(const fp.Left(WeakPasswordFailure())));
      },
    );
  });

  group('signInWithGoogle', () {
    test(
      'given RemoteDataSource returns UserModel when signInWithGoogle is called then return Right(UserEntity)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signInWithGoogle(),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signInWithGoogle();

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(() => mockRemoteDataSource.signInWithGoogle()).called(1);
      },
    );

    test(
      'given RemoteDataSource throws ServerException with google-sign-in-canceled code when signInWithGoogle is called then return Left(AuthCancelledFailure)',
      () async {
        // arrange
        when(() => mockRemoteDataSource.signInWithGoogle()).thenThrow(
          const ServerException('Cancelled', 'google-sign-in-canceled'),
        );

        // act
        final result = await repository.signInWithGoogle();

        // assert
        expect(result, equals(const fp.Left(AuthCancelledFailure())));
      },
    );
  });

  group('signOut', () {
    test(
      'given RemoteDataSource sign out is successful when signOut is called then return Right(null)',
      () async {
        // arrange
        when(() => mockRemoteDataSource.signOut()).thenAnswer((_) async => {});

        // act
        final result = await repository.signOut();

        // assert
        expect(result, equals(const fp.Right(null)));
        verify(() => mockRemoteDataSource.signOut()).called(1);
      },
    );

    test(
      'given RemoteDataSource throws ServerException when signOut is called then return Left(ServerFailure)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.signOut(),
        ).thenThrow(const ServerException('Sign out failed'));

        // act
        final result = await repository.signOut();

        // assert
        expect(result, equals(const fp.Left(ServerFailure('Sign out failed'))));
      },
    );
  });

  group('getCurrentUser', () {
    test(
      'given RemoteDataSource returns UserModel when getCurrentUser is called then return Right(UserEntity)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
      },
    );

    test(
      'given RemoteDataSource returns null when getCurrentUser is called then return Right(null)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getCurrentUser(),
        ).thenAnswer((_) async => null);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, equals(const fp.Right(null)));
      },
    );
  });

  group('updateUser', () {
    setUpAll(() {
      registerFallbackValue(tUserModel);
    });

    test(
      'given RemoteDataSource update is successful when updateUser is called then return Right(null)',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.updateUser(any()),
        ).thenAnswer((_) async => {});

        // act
        final result = await repository.updateUser(tUserEntity);

        // assert
        expect(result, equals(const fp.Right(null)));
        verify(() => mockRemoteDataSource.updateUser(tUserModel)).called(1);
      },
    );
  });
}
