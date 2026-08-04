import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/domain/errors/auth_failures.dart';
import 'package:flutter/material.dart';

enum AuthFallbackContext { login, signup, profile }

extension AuthFailureExtension on Failure {
  String toLocalizedString(
    BuildContext context, {
    AuthFallbackContext fallbackContext = AuthFallbackContext.login,
  }) {
    final l10n = AppLocalizations.of(context);

    switch (this) {
      case InvalidCredentialsFailure():
        return l10n.authErrorInvalidCredentials;
      case EmailAlreadyInUseFailure():
        return l10n.authErrorEmailAlreadyInUse;
      case WeakPasswordFailure():
        return l10n.authErrorWeakPassword;
      case UserDisabledFailure():
        return l10n.authErrorUserDisabled;
      case AuthCancelledFailure():
        return l10n.authErrorCancelled;
      case UserNotFoundFailure():
        return l10n.authErrorUserNotFound;
      case ImageTooLargeFailure():
        return l10n.profilePhotoTooLargeError;
      default:
        switch (fallbackContext) {
          case AuthFallbackContext.signup:
            return l10n.signupErrorFallback;
          case AuthFallbackContext.profile:
            return l10n.profilePhotoPickError;
          case AuthFallbackContext.login:
            return l10n.loginErrorFallback;
        }
    }
  }
}
