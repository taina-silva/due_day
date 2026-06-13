import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/injection/injection_container.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final radius = DueDayTheme.dimensions.radius;
    final spacing = DueDayTheme.dimensions.spacing;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(spacing.largeExtraLarge.width),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(radius.extraLarge),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(spacing.mediumLarge.width),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.1),
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
                      ),
                    ),
                    Text(
                      l10n.profileSecurityDesc,
                      style: typography.label.small,
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: state.isBiometricsEnabled,
                activeTrackColor: colors.resource.primary,
                onChanged: (bool value) async {
                  final securityService = sl<SecurityService>();
                  
                  // Verifica se o dispositivo possui suporte ativo
                  final isSupported = await securityService.canAuthenticate();
                  if (!isSupported) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Este dispositivo não possui suporte biométrico ativo.'),
                        ),
                      );
                    }
                    return;
                  }

                  // Solicita biometria para autorizar a mudança de preferência
                  final authenticated = await securityService.authenticate();
                  if (authenticated) {
                    if (context.mounted) {
                      context.read<SettingsBloc>().add(
                            ToggleBiometricsEvent(value),
                          );
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Autenticação cancelada ou incorreta.'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
