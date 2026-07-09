import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
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
        _RadioOption(
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
        _RadioOption(
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
        _RadioOption(
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

class _RadioOption extends StatelessWidget {
  final String label;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  const _RadioOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;
    final spacing = context.spacing;
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.smallMedium.width,
          vertical: spacing.small.height,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.resource.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(radius.large),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: typography.body.medium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.resource.primary,
                size: 20.scale,
              )
            else
              Container(
                width: 20.scale,
                height: 20.scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.resource.neutral),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
