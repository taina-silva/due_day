import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockAddCategory mockAddCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;
  late CategoryActionBloc categoryActionBloc;

  setUpAll(() {
    registerFallbackValue(tCategoryEntity);
  });

  setUp(() {
    mockAddCategory = MockAddCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();

    categoryActionBloc = CategoryActionBloc(
      addCategory: mockAddCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
    );
  });

  tearDown(() {
    categoryActionBloc.close();
  });

  test('initial state should be CategoryActionInitial', () {
    expect(categoryActionBloc.state, equals(CategoryActionInitial()));
  });

  group('AddCategoryEvent', () {
    blocTest<CategoryActionBloc, CategoryActionState>(
      'should emit [CategoryActionInProgress, CategoryActionSuccess] when '
      'AddCategory succeeds',
      build: () {
        when(
          () => mockAddCategory(any()),
        ).thenAnswer((_) async => Right(tCategoryEntity));
        return categoryActionBloc;
      },
      act: (bloc) => bloc.add(AddCategoryEvent(tCategoryEntity)),
      expect: () => [CategoryActionInProgress(), CategoryActionSuccess()],
      verify: (_) {
        verify(() => mockAddCategory(tCategoryEntity)).called(1);
      },
    );

    blocTest<CategoryActionBloc, CategoryActionState>(
      'should emit [CategoryActionInProgress, CategoryActionError] when '
      'AddCategory fails',
      build: () {
        when(
          () => mockAddCategory(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));
        return categoryActionBloc;
      },
      act: (bloc) => bloc.add(AddCategoryEvent(tCategoryEntity)),
      expect: () => [
        CategoryActionInProgress(),
        const CategoryActionError(failure: ServerFailure('Add failed')),
      ],
    );
  });

  group('UpdateCategoryEvent', () {
    blocTest<CategoryActionBloc, CategoryActionState>(
      'should emit [CategoryActionInProgress, CategoryActionSuccess] when '
      'UpdateCategory succeeds',
      build: () {
        when(
          () => mockUpdateCategory(any()),
        ).thenAnswer((_) async => Right(tCategoryEntity));
        return categoryActionBloc;
      },
      act: (bloc) => bloc.add(UpdateCategoryEvent(tCategoryEntity)),
      expect: () => [CategoryActionInProgress(), CategoryActionSuccess()],
      verify: (_) {
        verify(() => mockUpdateCategory(tCategoryEntity)).called(1);
      },
    );

    blocTest<CategoryActionBloc, CategoryActionState>(
      'should emit [CategoryActionInProgress, CategoryActionError] when '
      'UpdateCategory fails',
      build: () {
        when(
          () => mockUpdateCategory(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));
        return categoryActionBloc;
      },
      act: (bloc) => bloc.add(UpdateCategoryEvent(tCategoryEntity)),
      expect: () => [
        CategoryActionInProgress(),
        const CategoryActionError(failure: ServerFailure('Update failed')),
      ],
    );
  });

  group('DeleteCategoryEvent', () {
    blocTest<CategoryActionBloc, CategoryActionState>(
      'should emit [CategoryActionInProgress, CategoryActionSuccess] when '
      'DeleteCategory succeeds',
      build: () {
        when(
          () => mockDeleteCategory(any()),
        ).thenAnswer((_) async => const Right(null));
        return categoryActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteCategoryEvent('category-1')),
      expect: () => [CategoryActionInProgress(), CategoryActionSuccess()],
      verify: (_) {
        verify(() => mockDeleteCategory('category-1')).called(1);
      },
    );

    blocTest<CategoryActionBloc, CategoryActionState>(
      'should emit [CategoryActionInProgress, CategoryActionError] when '
      'DeleteCategory fails',
      build: () {
        when(
          () => mockDeleteCategory(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));
        return categoryActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteCategoryEvent('category-1')),
      expect: () => [
        CategoryActionInProgress(),
        const CategoryActionError(failure: ServerFailure('Delete failed')),
      ],
    );
  });
}
