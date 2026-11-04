import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:due_day/features/categories/domain/errors/category_failures.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/categories/domain/usecases/ensure_categories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  late MockCategoryRepository repository;
  late EnsureCategories ensureCategories;

  final now = DateTime(2026, 10, 4);

  CategoryEntity existing(String id, {CategoryKind? kind, String? name}) =>
      CategoryEntity(
        id: id,
        userId: 'user-1',
        name: name ?? id,
        color: '#000000',
        icon: '0xf624',
        createdAt: now,
        kind: kind ?? CategoryKind.spending,
      );

  final investment = existing(
    SystemCategories.investmentId,
    kind: CategoryKind.investment,
    name: SystemCategories.investmentStoredName,
  );
  final ignored = existing(
    SystemCategories.ignoredId,
    kind: CategoryKind.ignored,
    name: SystemCategories.ignoredStoredName,
  );

  setUpAll(() {
    registerFallbackValue(<CategoryEntity>[]);
    registerFallbackValue(investment);
  });

  setUp(() {
    repository = MockCategoryRepository();
    ensureCategories = EnsureCategories(repository, now: () => now);
    when(
      () => repository.addCategories(any()),
    ).thenAnswer((_) async => const Right(null));
  });

  List<CategoryEntity> captureCreated() =>
      verify(() => repository.addCategories(captureAny())).captured.single
          as List<CategoryEntity>;

  group('EnsureCategories', () {
    test('CAT-004: new user gets 13 defaults in English plus the system '
        'categories, in one batch', () async {
      final result = await ensureCategories(
        existing: const [],
        names: tDefaultNames,
      );

      expect(result, const Right(null));
      final created = captureCreated();
      expect(created, hasLength(15));
      expect(
        created.map((c) => c.name),
        containsAll(<String>[
          'Food',
          'Groceries',
          'Transport',
          'Housing',
          'Bills',
          'Health',
          'Leisure',
          'Shopping',
          'Subscriptions',
          'Education',
          'Other',
          'Salary',
          'Other income',
        ]),
      );
      expect(
        created.where((c) => c.kind == CategoryKind.spending),
        hasLength(13),
      );
      final system = created.where((c) => c.isSystem).toList();
      expect(system.map((c) => c.id), SystemCategories.ids);
      expect(system.map((c) => c.kind), [
        CategoryKind.investment,
        CategoryKind.ignored,
      ]);
    });

    test(
      'CAT-002: existing user without system categories gets both once',
      () async {
        await ensureCategories(
          existing: [existing('cat-food')],
          names: tDefaultNames,
        );

        final created = captureCreated();
        expect(created.map((c) => c.id), SystemCategories.ids);
      },
    );

    test('CAT-004: a deleted default is not recreated', () async {
      final result = await ensureCategories(
        existing: [existing('default_food'), investment, ignored],
        names: tDefaultNames,
      );

      expect(result, const Right(null));
      verifyNever(() => repository.addCategories(any()));
    });

    test('creates only the missing system category', () async {
      await ensureCategories(
        existing: [existing('cat-food'), investment],
        names: tDefaultNames,
      );

      expect(captureCreated().map((c) => c.id), [SystemCategories.ignoredId]);
    });

    test('propagates a repository failure', () async {
      when(
        () => repository.addCategories(any()),
      ).thenAnswer((_) async => const Left(CategorySaveFailure()));

      final result = await ensureCategories(
        existing: const [],
        names: tDefaultNames,
      );

      expect(result, const Left(CategorySaveFailure()));
    });
  });

  group('CAT-003: system categories are protected', () {
    test('trying to delete Ignored is rejected', () async {
      final result = await DeleteCategory(repository)(
        SystemCategories.ignoredId,
      );

      expect(result, const Left(SystemCategoryProtectedFailure()));
      verifyNever(() => repository.deleteCategory(any()));
    });

    test('renaming a system category is rejected', () async {
      final renamed = CategoryEntity(
        id: SystemCategories.investmentId,
        userId: 'user-1',
        name: 'Stocks',
        color: '#000000',
        icon: '0xf624',
        createdAt: now,
        kind: CategoryKind.investment,
      );

      final result = await UpdateCategory(repository)(renamed);

      expect(result, const Left(SystemCategoryProtectedFailure()));
      verifyNever(() => repository.updateCategory(any()));
    });

    test('changing color and icon of a system category is allowed', () async {
      final recolored = CategoryEntity(
        id: SystemCategories.investmentId,
        userId: 'user-1',
        name: SystemCategories.investmentStoredName,
        color: '#FFFFFF',
        icon: '0xf0108',
        createdAt: now,
        kind: CategoryKind.investment,
      );
      when(
        () => repository.updateCategory(recolored),
      ).thenAnswer((_) async => Right(recolored));

      final result = await UpdateCategory(repository)(recolored);

      expect(result, Right<Failure, CategoryEntity>(recolored));
    });
  });
}
