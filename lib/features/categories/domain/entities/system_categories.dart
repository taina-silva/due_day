import 'package:due_day/features/categories/domain/entities/category_kind.dart';

/// Fixed ids and stored values of the system categories (CAT-002).
///
/// Their display names are localized from [CategoryKind], so the stored
/// name is a constant that never changes (CAT-003).
abstract final class SystemCategories {
  static const String investmentId = 'system_investment';
  static const String ignoredId = 'system_ignored';

  static const String investmentStoredName = 'Investment';
  static const String ignoredStoredName = 'Ignored';

  static const List<String> ids = [investmentId, ignoredId];

  static bool isSystemId(String id) => ids.contains(id);

  static CategoryKind? kindFor(String id) {
    switch (id) {
      case investmentId:
        return CategoryKind.investment;
      case ignoredId:
        return CategoryKind.ignored;
    }
    return null;
  }

  static String? storedNameFor(String id) {
    switch (id) {
      case investmentId:
        return investmentStoredName;
      case ignoredId:
        return ignoredStoredName;
    }
    return null;
  }
}
