import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/settings_radio_option.dart';
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
        SettingsRadioOption<String>(
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
        SettingsRadioOption<String>(
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
