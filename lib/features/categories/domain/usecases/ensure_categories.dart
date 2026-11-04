import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/default_category_names.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:due_day/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Makes sure the user has the categories the app relies on.
///
/// - No categories at all → creates the 13 localized defaults plus the
///   system categories in one batch (CAT-004).
/// - Otherwise → creates only the missing system categories (CAT-002).
///   Deleted defaults are never recreated.
///
/// Ids are fixed (`system_*`, `default_*`) so a repeated seed overwrites the
/// same documents instead of duplicating them. `userId` is stamped by the
/// data source from the signed-in user.
class EnsureCategories {
  final CategoryRepository repository;
  final DateTime Function() _now;

  EnsureCategories(this.repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<Either<Failure, void>> call({
    required List<CategoryEntity> existing,
    required DefaultCategoryNames names,
  }) async {
    final createdAt = _now();
    final existingIds = existing.map((c) => c.id).toSet();

    final missingSystem = _systemCategories(
      createdAt,
    ).where((c) => !existingIds.contains(c.id)).toList();

    final toCreate = existing.isEmpty
        ? [..._defaultCategories(names, createdAt), ...missingSystem]
        : missingSystem;

    if (toCreate.isEmpty) return const Right(null);
    return repository.addCategories(toCreate);
  }

  static List<CategoryEntity> _systemCategories(DateTime createdAt) => [
    CategoryEntity(
      id: SystemCategories.investmentId,
      userId: '',
      name: SystemCategories.investmentStoredName,
      color: '#9C6B00',
      icon: '0xf0254', // trending_up_rounded
      createdAt: createdAt,
      kind: CategoryKind.investment,
    ),
    CategoryEntity(
      id: SystemCategories.ignoredId,
      userId: '',
      name: SystemCategories.ignoredStoredName,
      color: '#34495E',
      icon: '0xf5be', // block_rounded
      createdAt: createdAt,
      kind: CategoryKind.ignored,
    ),
  ];

  static List<CategoryEntity> _defaultCategories(
    DefaultCategoryNames n,
    DateTime createdAt,
  ) {
    // (id suffix, name, color, icon code point)
    final seeds = <(String, String, String, String)>[
      ('food', n.food, '#E63946', '0xf0108'), // restaurant
      ('groceries', n.groceries, '#06A77D', '0xf0171'), // shopping_cart
      ('transport', n.transport, '#3A86FF', '0xf6b3'), // directions_car
      ('housing', n.housing, '#4361EE', '0xf7f5'), // home
      ('bills', n.bills, '#EF6C00', '0xf00e1'), // receipt_long
      ('health', n.health, '#C2185B', '0xf86f'), // local_hospital
      ('leisure', n.leisure, '#7B2D8E', '0xf8e7'), // movie
      ('shopping', n.shopping, '#A0522D', '0xf016f'), // shopping_bag
      ('subscriptions', n.subscriptions, '#00838F', '0xf02bf'), // wifi
      ('education', n.education, '#3730A3', '0xf012e'), // school
      ('other', n.other, '#6C757D', '0xf624'), // category
      ('salary', n.salary, '#558B2F', '0xf58f'), // attach_money
      (
        'other_income',
        n.otherIncome,
        '#2A9D8F',
        '0xf520',
      ), // account_balance_wallet
    ];
    return [
      for (final (key, name, color, icon) in seeds)
        CategoryEntity(
          id: 'default_$key',
          userId: '',
          name: name,
          color: color,
          icon: icon,
          createdAt: createdAt,
        ),
    ];
  }
}
