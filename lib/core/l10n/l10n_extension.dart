import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get localeString => Localizations.localeOf(this).toString();
}
