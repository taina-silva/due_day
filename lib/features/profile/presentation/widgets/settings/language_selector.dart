import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;
    final currentLanguage = context.watch<SettingsBloc>().state.languageCode;

    return SettingsSection(
      icon: Icons.language,
      iconColor: colors.system.info,
      title: l10n.profileLanguage,
      children: [
        _RadioOption(
          label: l10n.profileLanguageEn,
          value: 'en',
          groupValue: currentLanguage,
          onChanged: (val) {
            if (val != null) {
              context.read<SettingsBloc>().add(ChangeLanguageEvent(val));
            }
          },
        ),
        SizedBox(height: spacing.smallMedium.height),
        _RadioOption(
          label: l10n.profileLanguagePt,
          value: 'pt',
          groupValue: currentLanguage,
          onChanged: (val) {
            if (val != null) {
              context.read<SettingsBloc>().add(ChangeLanguageEvent(val));
            }
          },
        ),
      ],
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

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

    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.smallMedium.width,
          vertical: spacing.small.height,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
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
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.resource.primary,
                size: 20.width,
              )
            else
              Container(
                width: 20.width,
                height: 20.height,
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
