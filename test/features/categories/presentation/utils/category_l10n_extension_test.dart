import 'package:due_day/core/l10n/l10n_resolver.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:due_day/features/categories/presentation/utils/category_l10n_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CategoryEntity system(String id, String name, CategoryKind kind) =>
      CategoryEntity(
        id: id,
        userId: 'user-1',
        name: name,
        color: '#000000',
        icon: '0xf624',
        createdAt: DateTime(2026),
        kind: kind,
      );

  final investment = system(
    SystemCategories.investmentId,
    SystemCategories.investmentStoredName,
    CategoryKind.investment,
  );
  final ignored = system(
    SystemCategories.ignoredId,
    SystemCategories.ignoredStoredName,
    CategoryKind.ignored,
  );

  test('CAT-002: language switch — in Portuguese the system categories read '
      '"Investimento" and "Ignorado"', () {
    final pt = resolveLocalizations('pt');

    expect(pt.categoryDisplayName(investment), 'Investimento');
    expect(pt.categoryDisplayName(ignored), 'Ignorado');
  });

  test('CAT-002: in English they read "Investment" and "Ignored"', () {
    final en = resolveLocalizations('en');

    expect(en.categoryDisplayName(investment), 'Investment');
    expect(en.categoryDisplayName(ignored), 'Ignored');
  });

  test('user categories keep their stored name', () {
    final pt = resolveLocalizations('pt');
    final food = system('cat-1', 'Padaria', CategoryKind.spending);

    expect(pt.categoryDisplayName(food), 'Padaria');
  });

  test('CAT-004: default names follow the app language', () {
    expect(resolveLocalizations('pt').defaultCategoryNames.food, 'Alimentação');
    expect(
      resolveLocalizations('en').defaultCategoryNames.otherIncome,
      'Other income',
    );
  });
}
