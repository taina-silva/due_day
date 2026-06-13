import 'package:due_day/core/l10n/app_localizations.dart';

/// Reusable form validators for the application.
///
/// All validators return localized error messages via [AppLocalizations].
class Validators {
  const Validators._();

  /// Validates that a text field is not null or empty (after trimming).
  static String? Function(String?) requiredField(AppLocalizations l10n) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return l10n.validatorRequired;
      }
      return null;
    };
  }

  /// Validates that a dropdown selection is not null or empty.
  static String? Function(T?) requiredSelection<T>(AppLocalizations l10n) {
    return (value) {
      if (value == null || (value is String && value.isEmpty)) {
        return l10n.validatorRequired;
      }
      return null;
    };
  }
}
