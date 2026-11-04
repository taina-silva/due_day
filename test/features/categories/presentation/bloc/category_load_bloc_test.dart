import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockGetCategories mockGetCategories;
  late MockEnsureCategories mockEnsureCategories;
  late CategoryLoadBloc categoryLoadBloc;

  setUpAll(() => registerFallbackValue(tDefaultNames));

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockEnsureCategories = MockEnsureCategories();
    when(
      () => mockEnsureCategories(
        existing: any(named: 'existing'),
        names: any(named: 'names'),
      ),
    ).thenAnswer((_) async => const Right(null));

    categoryLoadBloc = CategoryLoadBloc(
      getCategories: mockGetCategories,
      ensureCategories: mockEnsureCategories,
    );
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
      act: (bloc) => bloc.add(const LoadCategories()),
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
      act: (bloc) => bloc.add(const LoadCategories()),
      expect: () => [
        CategoryLoading(),
        const CategoryError(failure: ServerFailure('Fetch failed')),
      ],
    );
  });

  group('EnsureCategories trigger', () {
    blocTest<CategoryLoadBloc, CategoryLoadState>(
      'CAT-004: runs once with the first loaded list when names are given',
      build: () {
        final controller =
            StreamController<Either<Failure, List<CategoryEntity>>>();
        when(() => mockGetCategories()).thenAnswer((_) => controller.stream);
        addTearDown(controller.close);
        Future<void>.delayed(Duration.zero, () {
          controller.add(const Right([]));
          controller.add(Right([tCategoryEntity]));
        });
        return categoryLoadBloc;
      },
      act: (bloc) =>
          bloc.add(const LoadCategories(defaultNames: tDefaultNames)),
      wait: const Duration(milliseconds: 10),
      verify: (_) {
        verify(
          () => mockEnsureCategories(existing: const [], names: tDefaultNames),
        ).called(1);
      },
    );

    blocTest<CategoryLoadBloc, CategoryLoadState>(
      'does not run when no names are given',
      build: () {
        when(
          () => mockGetCategories(),
        ).thenAnswer((_) => Stream.value(Right([tCategoryEntity])));
        return categoryLoadBloc;
      },
      act: (bloc) => bloc.add(const LoadCategories()),
      verify: (_) {
        verifyNever(
          () => mockEnsureCategories(
            existing: any(named: 'existing'),
            names: any(named: 'names'),
          ),
        );
      },
    );

    blocTest<CategoryLoadBloc, CategoryLoadState>(
      'regression: a seed that completes after the next snapshot does not '
      'overwrite the list with the stale one',
      build: () {
        final controller =
            StreamController<Either<Failure, List<CategoryEntity>>>();
        final seed = Completer<Either<Failure, void>>();
        when(() => mockGetCategories()).thenAnswer((_) => controller.stream);
        when(
          () => mockEnsureCategories(
            existing: any(named: 'existing'),
            names: any(named: 'names'),
          ),
        ).thenAnswer((_) {
          // Local write lands before the server ack completes the commit.
          Future<void>.delayed(Duration.zero, () {
            controller.add(Right([tCategoryEntity]));
            Future<void>.delayed(
              Duration.zero,
              () => seed.complete(right(null)),
            );
          });
          return seed.future;
        });
        addTearDown(controller.close);
        Future<void>.delayed(
          Duration.zero,
          () => controller.add(const Right([])),
        );
        return categoryLoadBloc;
      },
      act: (bloc) =>
          bloc.add(const LoadCategories(defaultNames: tDefaultNames)),
      wait: const Duration(milliseconds: 20),
      expect: () => [
        CategoryLoading(),
        const CategoryLoaded(categories: []),
        CategoryLoaded(categories: [tCategoryEntity]),
      ],
    );
  });
}
