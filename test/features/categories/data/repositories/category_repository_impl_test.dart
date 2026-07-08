import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/data/repositories/category_repository_impl.dart';
import 'package:due_day/features/categories/domain/errors/category_failures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockCategoryRemoteDataSource mockRemoteDataSource;
  late CategoryRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(tCategoryModel);
  });

  setUp(() {
    mockRemoteDataSource = MockCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('CategoryRepositoryImpl Tests', () {
    group('addCategory', () {
      test('should return CategoryEntity on success', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.addCategory(any()),
        ).thenAnswer((_) async => tCategoryModel);

        // Act
        final result = await repository.addCategory(tCategoryEntity);

        // Assert
        expect(result, equals(Right(tCategoryEntity)));
        verify(
          () => mockRemoteDataSource.addCategory(tCategoryModel),
        ).called(1);
      });

      test(
        'should return UserNotAuthenticatedFailure when unauthenticated',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.addCategory(any())).thenThrow(
            const ServerException('User not authenticated.', 'unauthenticated'),
          );

          // Act
          final result = await repository.addCategory(tCategoryEntity);

          // Assert
          expect(result, equals(const Left(UserNotAuthenticatedFailure())));
        },
      );

      test(
        'should return ServerFailure for general server exceptions',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.addCategory(any()),
          ).thenThrow(const ServerException('Server error'));

          // Act
          final result = await repository.addCategory(tCategoryEntity);

          // Assert
          expect(result, equals(const Left(ServerFailure('Server error'))));
        },
      );
    });

    group('updateCategory', () {
      test('should return CategoryEntity on success', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.updateCategory(any()),
        ).thenAnswer((_) async => tCategoryModel);

        // Act
        final result = await repository.updateCategory(tCategoryEntity);

        // Assert
        expect(result, equals(Right(tCategoryEntity)));
        verify(
          () => mockRemoteDataSource.updateCategory(tCategoryModel),
        ).called(1);
      });
    });

    group('deleteCategory', () {
      test('should return const Right(null) on success', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.deleteCategory(any()),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await repository.deleteCategory('category-1');

        // Assert
        expect(result, equals(const Right(null)));
        verify(
          () => mockRemoteDataSource.deleteCategory('category-1'),
        ).called(1);
      });
    });

    group('getCategories', () {
      test(
        'should return stream of Right(List<CategoryEntity>) on success',
        () async {
          // Arrange
          when(
            () => mockRemoteDataSource.getCategories(),
          ).thenAnswer((_) => Stream.value([tCategoryModel]));

          // Act
          final stream = repository.getCategories();

          // Assert
          final result = await stream.first;
          expect(result.isRight(), true);
          result.fold((l) => fail('Should not be left'), (r) {
            expect(r, equals([tCategoryEntity]));
          });
        },
      );

      test('should return Left(ServerFailure) on stream error', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCategories()).thenAnswer(
          (_) => Stream.error(const ServerException('Connection lost')),
        );

        // Act
        final stream = repository.getCategories();

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
