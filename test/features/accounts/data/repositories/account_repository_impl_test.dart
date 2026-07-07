import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/data/repositories/account_repository_impl.dart';
import 'package:due_day/features/accounts/domain/errors/account_failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  late MockAccountRemoteDataSource mockRemoteDataSource;
  late AccountRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tAccountModel);
  });

  setUp(() {
    mockRemoteDataSource = MockAccountRemoteDataSource();
    repository = AccountRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('AccountRepositoryImpl Tests', () {
    group('addAccount', () {
      test('should return AccountEntity on success', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.addAccount(any()),
        ).thenAnswer((_) async => tAccountModel);

        // Act
        final result = await repository.addAccount(tAccountEntity);

        // Assert
        expect(result, equals(Right(tAccountEntity)));
        verify(() => mockRemoteDataSource.addAccount(tAccountModel)).called(1);
      });

      test(
        'should return UserNotAuthenticatedFailure when unauthenticated',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.addAccount(any())).thenThrow(
            const ServerException('User not authenticated.', 'unauthenticated'),
          );

          // Act
          final result = await repository.addAccount(tAccountEntity);

          // Assert
          expect(result, equals(const Left(UserNotAuthenticatedFailure())));
        },
      );

      test(
        'should return ServerFailure for general server exceptions',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.addAccount(any()),
          ).thenThrow(const ServerException('Server error'));

          // Act
          final result = await repository.addAccount(tAccountEntity);

          // Assert
          expect(result, equals(const Left(ServerFailure('Server error'))));
        },
      );
    });

    group('getAccountById', () {
      test('should return AccountEntity on success', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getAccountById(any()),
        ).thenAnswer((_) async => tAccountModel);

        // Act
        final result = await repository.getAccountById('account-1');

        // Assert
        expect(result, equals(Right(tAccountEntity)));
      });

      test('should return AccountNotFoundFailure when not found', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getAccountById(any()),
        ).thenThrow(const ServerException('Account not found.', 'not-found'));

        // Act
        final result = await repository.getAccountById('account-1');

        // Assert
        expect(result, equals(const Left(AccountNotFoundFailure())));
      });
    });

    group('getAccounts', () {
      test(
        'should return stream of Right(List<AccountEntity>) on success',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.getAccounts(),
          ).thenAnswer((_) => Stream.value([tAccountModel]));

          // Act
          final stream = repository.getAccounts();

          // Assert
          final result = await stream.first;
          expect(result.isRight(), true);
          result.fold((l) => fail('Should not be left'), (r) {
            expect(r, equals([tAccountEntity]));
          });
        },
      );

      test('should return Left(ServerFailure) on stream error', () async {
        // Arrange
        when(() => mockRemoteDataSource.getAccounts()).thenAnswer(
          (_) => Stream.error(const ServerException('Connection lost')),
        );

        // Act
        final stream = repository.getAccounts();

        // Assert
        final result = await stream.first;
        expect(result.isLeft(), true);
        result.fold((l) {
          expect(l, equals(const ServerFailure('Connection lost')));
        }, (r) => fail('Should not be right'));
      });
    });
  });
}
