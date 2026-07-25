import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockGetCategories mockGetCategories;
  late CategoryLoadBloc categoryLoadBloc;

  setUp(() {
    mockGetCategories = MockGetCategories();

    categoryLoadBloc = CategoryLoadBloc(getCategories: mockGetCategories);
  });

  tearDown(() {
    categoryLoadBloc.close();
  });

  test('initial state should be CategoryInitial', () {
    expect(categoryLoadBloc.state, equals(CategoryInitial()));
  });

  group('LoadCategories Event', () {
    blocTest<CategoryLoadBloc, CategoryLoadState>(
      'should emit [CategoryLoading, CategoryLoaded] sorted by transactionCount on success',
      build: () {
        when(() => mockGetCategories()).thenAnswer(
          (_) => Stream.value(Right([tCategoryEntity2, tCategoryEntity])),
        );
        return categoryLoadBloc;
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

    blocTest<CategoryLoadBloc, CategoryLoadState>(
      'should emit [CategoryLoading, CategoryError] on stream failure',
      build: () {
        when(() => mockGetCategories()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Fetch failed'))),
        );
        return categoryLoadBloc;
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        CategoryLoading(),
        const CategoryError(failure: ServerFailure('Fetch failed')),
      ],
    );
  });
}
