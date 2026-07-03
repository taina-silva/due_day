import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class CategoryFormActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const CategoryFormActions({
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = context.spacing;

    return Row(
      children: [
        Expanded(
          child: AppTextButtonSecondary(
            label: l10n.profileCancel,
            onPressed: onCancel,
          ),
        ),
        SizedBox(width: spacing.medium.width),
        Expanded(
          child: AppTextButtonPrimary(
            label: l10n.categoriesSave,
            onPressed: onSave,
          ),
        ),
      ],
    );
  }
}
