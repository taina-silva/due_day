import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('SignInWithEmail', () {
    late SignInWithEmail usecase;

    setUp(() {
      usecase = SignInWithEmail(mockRepository);
    });

    test(
      'given email and password when SignInWithEmail is called then invoke repository.signInWithEmail and return UserEntity',
      () async {
        // arrange
        when(
          () => mockRepository.signInWithEmail(tEmail, tPassword),
        ).thenAnswer((_) async => fp.Right(tUserEntity));

        // act
        final result = await usecase(tEmail, tPassword);

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(
          () => mockRepository.signInWithEmail(tEmail, tPassword),
        ).called(1);
      },
    );
  });

  group('SignUpWithEmail', () {
    late SignUpWithEmail usecase;

    setUp(() {
      usecase = SignUpWithEmail(mockRepository);
    });

    test(
      'given email, password and displayName when SignUpWithEmail is called then invoke repository.signUpWithEmail and return UserEntity',
      () async {
        // arrange
        when(
          () => mockRepository.signUpWithEmail(tEmail, tPassword, tDisplayName),
        ).thenAnswer((_) async => fp.Right(tUserEntity));

        // act
        final result = await usecase(tEmail, tPassword, tDisplayName);

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(
          () => mockRepository.signUpWithEmail(tEmail, tPassword, tDisplayName),
        ).called(1);
      },
    );
  });

  group('SignInWithGoogle', () {
    late SignInWithGoogle usecase;

    setUp(() {
      usecase = SignInWithGoogle(mockRepository);
    });

    test(
      'given Google credentials when SignInWithGoogle is called then invoke repository.signInWithGoogle and return UserEntity',
      () async {
        // arrange
        when(
          () => mockRepository.signInWithGoogle(),
        ).thenAnswer((_) async => fp.Right(tUserEntity));

        // act
        final result = await usecase();

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(() => mockRepository.signInWithGoogle()).called(1);
      },
    );
  });

  group('SignOut', () {
    late SignOut usecase;

    setUp(() {
      usecase = SignOut(mockRepository);
    });

    test(
      'given user is authenticated when SignOut is called then invoke repository.signOut',
      () async {
        // arrange
        when(
          () => mockRepository.signOut(),
        ).thenAnswer((_) async => const fp.Right(null));

        // act
        final result = await usecase();

        // assert
        expect(result, equals(const fp.Right(null)));
        verify(() => mockRepository.signOut()).called(1);
      },
    );
  });

  group('GetCurrentUser', () {
    late GetCurrentUser usecase;

    setUp(() {
      usecase = GetCurrentUser(mockRepository);
    });

    test(
      'given authenticated user exists when GetCurrentUser is called then invoke repository.getCurrentUser and return UserEntity',
      () async {
        // arrange
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => fp.Right(tUserEntity));

        // act
        final result = await usecase();

        // assert
        expect(result, equals(fp.Right(tUserEntity)));
        verify(() => mockRepository.getCurrentUser()).called(1);
      },
    );
  });

  group('UpdateUser', () {
    late UpdateUser usecase;

    setUp(() {
      usecase = UpdateUser(mockRepository);
      registerFallbackValue(tUserEntity);
    });

    test(
      'given UserEntity when UpdateUser is called then invoke repository.updateUser with UserEntity',
      () async {
        // arrange
        when(
          () => mockRepository.updateUser(any()),
        ).thenAnswer((_) async => const fp.Right(null));

        // act
        final result = await usecase(tUserEntity);

        // assert
        expect(result, equals(const fp.Right(null)));
        verify(() => mockRepository.updateUser(tUserEntity)).called(1);
      },
    );
  });
}
