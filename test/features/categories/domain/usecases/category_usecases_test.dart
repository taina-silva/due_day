import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockCategoryRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(tCategoryEntity);
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
  });

  group('Category UseCases Tests', () {
    test('AddCategory should call repository.addCategory', () async {
      // Arrange
      final usecase = AddCategory(mockRepository);
      when(
        () => mockRepository.addCategory(any()),
      ).thenAnswer((_) async => Right(tCategoryEntity));

      // Act
      final result = await usecase(tCategoryEntity);

      // Assert
      expect(result, Right(tCategoryEntity));
      verify(() => mockRepository.addCategory(tCategoryEntity)).called(1);
    });

    test('UpdateCategory should call repository.updateCategory', () async {
      // Arrange
      final usecase = UpdateCategory(mockRepository);
      when(
        () => mockRepository.updateCategory(any()),
      ).thenAnswer((_) async => Right(tCategoryEntity));

      // Act
      final result = await usecase(tCategoryEntity);

      // Assert
      expect(result, Right(tCategoryEntity));
      verify(() => mockRepository.updateCategory(tCategoryEntity)).called(1);
    });

    test('DeleteCategory should call repository.deleteCategory', () async {
      // Arrange
      final usecase = DeleteCategory(mockRepository);
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase('category-1');

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.deleteCategory('category-1')).called(1);
    });

    test('GetCategories should call repository.getCategories', () async {
      // Arrange
      final usecase = GetCategories(mockRepository);
      when(
        () => mockRepository.getCategories(),
      ).thenAnswer((_) => Stream.value(Right([tCategoryEntity])));

      // Act
      final stream = usecase();

      // Assert
      final result = await stream.first;
      expect(result.isRight(), true);
      result.fold((l) => fail('Should not be left'), (r) {
        expect(r, equals([tCategoryEntity]));
      });
      verify(() => mockRepository.getCategories()).called(1);
    });
  });
}
