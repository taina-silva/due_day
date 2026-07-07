import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/domain/errors/auth_failures.dart';
import 'package:flutter/material.dart';

extension AuthFailureExtension on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (this is InvalidCredentialsFailure) {
      return l10n.authErrorInvalidCredentials;
    }
    if (this is EmailAlreadyInUseFailure) {
      return l10n.authErrorEmailAlreadyInUse;
    }
    if (this is WeakPasswordFailure) {
      return l10n.authErrorWeakPassword;
    }
    if (this is UserDisabledFailure) {
      return l10n.authErrorUserDisabled;
    }
    if (this is AuthCancelledFailure) {
      return l10n.authErrorCancelled;
    }
    if (this is UserNotFoundFailure) {
      return l10n.authErrorUserNotFound;
    }

    return l10n.loginErrorFallback;
  }
}
