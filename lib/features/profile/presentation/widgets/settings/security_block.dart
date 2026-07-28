import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecurityBlock extends StatelessWidget {
  const SecurityBlock({super.key});

  String _messageForResult(AppLocalizations l10n, BiometricAuthResult result) {
    return switch (result) {
      BiometricAuthResult.lockedOut => l10n.profileBiometricsLockedOut,
      BiometricAuthResult.notEnrolled => l10n.profileBiometricsNotEnrolled,
      BiometricAuthResult.notAvailable => l10n.profileBiometricsNotSupported,
      _ => l10n.profileBiometricsAuthFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;

    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          current.biometricsToggleError != null &&
          previous.biometricsToggleError != current.biometricsToggleError,
      listener: (context, state) {
        AppMessenger.showError(
          context,
          _messageForResult(l10n, state.biometricsToggleError!),
        );
      },
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.largeExtraLarge.width,
            vertical: spacing.mediumLarge.height,
          ),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(radius.extraLarge),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing.mediumLarge.scale),
                decoration: BoxDecoration(
                  color: context.onSurfaceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(radius.large),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: colors.resource.primary,
                ),
              ),
              SizedBox(width: spacing.mediumLarge.width),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileSecurity,
                      style: typography.body.large.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.onSurfaceColor,
                      ),
                    ),
                    Text(
                      l10n.profileSecurityDesc,
                      style: typography.label.small.copyWith(
                        color: colors.resource.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: state.isBiometricsEnabled,
                activeTrackColor: colors.resource.primary,
                onChanged: state.isTogglingBiometrics
                    ? null
                    : (bool value) {
                        context.read<SettingsBloc>().add(
                          ToggleBiometricsEvent(value),
                        );
                      },
              ),
            ],
          ),
        );
      },
    );
  }
}
