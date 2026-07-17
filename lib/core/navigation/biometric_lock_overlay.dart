import 'dart:ui';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class BiometricLockOverlay extends StatelessWidget {
  final VoidCallback onAuthenticate;
  final bool isAuthenticating;
  final String? errorMessage;

  const BiometricLockOverlay({
    required this.onAuthenticate,
    this.isAuthenticating = false,
    this.errorMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        body: Stack(
          children: [
            // Blur effect over the existing UI background
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Main content
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.threeExtraLarge.width,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo with an animated pulse or secure visual
                    Container(
                      padding: EdgeInsets.all(spacing.largeExtraLarge.width),
                      decoration: BoxDecoration(
                        color: colors.resource.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.resource.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: colors.resource.primary,
                        size: 64.scale,
                      ),
                    ),
                    SizedBox(height: spacing.threeExtraLarge.height),
                    Text(
                      l10n.biometricLockTitle,
                      textAlign: TextAlign.center,
                      style: typography.headline.large.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing.mediumLarge.height),
                    Text(
                      l10n.biometricLockDescription,
                      textAlign: TextAlign.center,
                      style: typography.body.medium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                    if (errorMessage != null) ...[
                      SizedBox(height: spacing.mediumLarge.height),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: typography.body.medium.copyWith(
                          color: colors.system.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    SizedBox(height: spacing.threeExtraLarge.height),
                    // Authentication button using the app's design system
                    InkWell(
                      key: const Key('biometric_unlock_button'),
                      onTap: isAuthenticating ? null : onAuthenticate,
                      borderRadius: BorderRadius.circular(radius.extraLarge),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: spacing.large.height,
                        ),
                        decoration: BoxDecoration(
                          color: isAuthenticating
                              ? colors.resource.primary.withValues(alpha: 0.5)
                              : colors.resource.primary,
                          borderRadius: BorderRadius.circular(
                            radius.extraLarge,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.resource.primary.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: isAuthenticating
                              ? SizedBox(
                                  width: 24.scale,
                                  height: 24.scale,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.biometricUnlockButton,
                                  style: typography.body.large.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
