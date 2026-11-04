import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/default_category_names.dart';

extension CategoryL10nExtension on AppLocalizations {
  /// Names for the default categories, in the current language (CAT-004).
  DefaultCategoryNames get defaultCategoryNames => DefaultCategoryNames(
    food: categoriesDefaultFood,
    groceries: categoriesDefaultGroceries,
    transport: categoriesDefaultTransport,
    housing: categoriesDefaultHousing,
    bills: categoriesDefaultBills,
    health: categoriesDefaultHealth,
    leisure: categoriesDefaultLeisure,
    shopping: categoriesDefaultShopping,
    subscriptions: categoriesDefaultSubscriptions,
    education: categoriesDefaultEducation,
    other: categoriesDefaultOther,
    salary: categoriesDefaultSalary,
    otherIncome: categoriesDefaultOtherIncome,
  );

  /// Display name: system categories are named from their kind, not the
  /// stored name (CAT-002).
  String categoryDisplayName(CategoryEntity category) {
    if (!category.isSystem) return category.name;
    return switch (category.kind) {
      CategoryKind.investment => categoriesSystemInvestment,
      CategoryKind.ignored => categoriesSystemIgnored,
      CategoryKind.spending => category.name,
    };
  }

  String? categoryDisplayNameOrNull(CategoryEntity? category) =>
      category == null ? null : categoryDisplayName(category);
}
