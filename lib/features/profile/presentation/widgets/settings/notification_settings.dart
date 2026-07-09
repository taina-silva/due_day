import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);

    return SettingsSection(
      icon: Icons.notifications_active,
      iconColor: colors.system.warning,
      title: l10n.profileNotifications,
      children: [
        BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profilePushAlerts,
                        style: typography.body.large.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.onSurfaceColor,
                        ),
                      ),
                      Text(
                        l10n.profilePushAlertsDesc,
                        style: typography.label.small.copyWith(
                          color: colors.resource.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.pushNotificationsEnabled,
                  activeThumbColor: colors.resource.primary,
                  onChanged: (val) {
                    context.read<SettingsBloc>().add(
                      TogglePushNotificationsEvent(val),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
