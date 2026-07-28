import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/settings_radio_option.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final currentTheme = context.watch<SettingsBloc>().state.themeMode;

    return SettingsSection(
      icon: Icons.palette_outlined,
      iconColor: colors.resource.primary,
      title: l10n.profileTheme,
      children: [
        SettingsRadioOption<ThemeMode>(
          label: l10n.profileThemeSystem,
          value: ThemeMode.system,
          groupValue: currentTheme,
          onChanged: (val) {
            if (val != null) {
              context.read<SettingsBloc>().add(ChangeThemeEvent(val));
            }
          },
        ),
        SizedBox(height: spacing.smallMedium.height),
        SettingsRadioOption<ThemeMode>(
          label: l10n.profileThemeLight,
          value: ThemeMode.light,
          groupValue: currentTheme,
          onChanged: (val) {
            if (val != null) {
              context.read<SettingsBloc>().add(ChangeThemeEvent(val));
            }
          },
        ),
        SizedBox(height: spacing.smallMedium.height),
        SettingsRadioOption<ThemeMode>(
          label: l10n.profileThemeDark,
          value: ThemeMode.dark,
          groupValue: currentTheme,
          onChanged: (val) {
            if (val != null) {
              context.read<SettingsBloc>().add(ChangeThemeEvent(val));
            }
          },
        ),
      ],
    );
  }
}
