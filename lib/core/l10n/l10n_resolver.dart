import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Resolves [AppLocalizations] outside of a widget tree (e.g. inside a BLoC
/// scheduling local notifications), using the user's persisted language
/// preference instead of [BuildContext].
AppLocalizations resolveLocalizations(String languageCode) {
  return lookupAppLocalizations(Locale(languageCode));
}
