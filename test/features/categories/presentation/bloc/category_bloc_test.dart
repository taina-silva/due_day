import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/presentation/bloc/category_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockAddCategory mockAddCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;
  late MockGetCategories mockGetCategories;
  late CategoryBloc categoryBloc;

  setUpAll(() {
    registerFallbackValue(tCategoryEntity);
  });

  setUp(() {
    mockAddCategory = MockAddCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();
    mockGetCategories = MockGetCategories();

    categoryBloc = CategoryBloc(
      addCategory: mockAddCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
      getCategories: mockGetCategories,
    );
  });

  tearDown(() {
    categoryBloc.close();
  });

  test('initial state should be CategoryInitial', () {
    expect(categoryBloc.state, equals(CategoryInitial()));
  });

  group('LoadCategories Event', () {
    blocTest<CategoryBloc, CategoryState>(
      'should emit [CategoryLoading, CategoryLoaded] sorted by transactionCount on success',
      build: () {
        when(() => mockGetCategories()).thenAnswer(
          (_) => Stream.value(Right([tCategoryEntity2, tCategoryEntity])),
        );
        return categoryBloc;
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        CategoryLoading(),
        CategoryLoaded(categories: [tCategoryEntity, tCategoryEntity2]),
      ],
      verify: (_) {
        verify(() => mockGetCategories()).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'should emit [CategoryLoading, CategoryError] on stream failure',
      build: () {
        when(() => mockGetCategories()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Fetch failed'))),
        );
        return categoryBloc;
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        CategoryLoading(),
        const CategoryError(failure: ServerFailure('Fetch failed')),
      ],
    );
  });

  group('AddCategoryEvent', () {
    blocTest<CategoryBloc, CategoryState>(
      'should call AddCategory usecase and do nothing on success',
      build: () {
        when(
          () => mockAddCategory(any()),
        ).thenAnswer((_) async => Right(tCategoryEntity));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(AddCategoryEvent(tCategoryEntity)),
      expect: () => <CategoryState>[],
      verify: (_) {
        verify(() => mockAddCategory(tCategoryEntity)).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'should emit CategoryError when AddCategory fails',
      build: () {
        when(
          () => mockAddCategory(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(AddCategoryEvent(tCategoryEntity)),
      expect: () => [const CategoryError(failure: ServerFailure('Add failed'))],
    );
  });

  group('UpdateCategoryEvent', () {
    blocTest<CategoryBloc, CategoryState>(
      'should call UpdateCategory usecase and do nothing on success',
      build: () {
        when(
          () => mockUpdateCategory(any()),
        ).thenAnswer((_) async => Right(tCategoryEntity));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(UpdateCategoryEvent(tCategoryEntity)),
      expect: () => <CategoryState>[],
      verify: (_) {
        verify(() => mockUpdateCategory(tCategoryEntity)).called(1);
      },
    );
  });

  group('DeleteCategoryEvent', () {
    blocTest<CategoryBloc, CategoryState>(
      'should call DeleteCategory usecase and do nothing on success',
      build: () {
        when(
          () => mockDeleteCategory(any()),
        ).thenAnswer((_) async => const Right(null));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(const DeleteCategoryEvent('category-1')),
      expect: () => <CategoryState>[],
      verify: (_) {
        verify(() => mockDeleteCategory('category-1')).called(1);
      },
    );
  });
}
