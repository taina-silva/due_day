import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TransactionNavigationButtons extends StatelessWidget {
  final AppLocalizations l10n;

  const TransactionNavigationButtons({required this.l10n, super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = DueDayTheme.dimensions.spacing;

    return Row(
      children: [
        Expanded(
          child: _NavigationSmallButton(
            label: l10n.transactionsHistory,
            icon: Icons.history_rounded,
            onTap: () => context.push('/transactions/history'),
          ),
        ),
        SizedBox(width: spacing.medium.width),
        Expanded(
          child: _NavigationSmallButton(
            label: l10n.transactionsSchedule,
            icon: Icons.calendar_month_rounded,
            onTap: () => context.push('/transactions/schedule'),
          ),
        ),
      ],
    );
  }
}

class _NavigationSmallButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavigationSmallButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    final spacing = DueDayTheme.dimensions.spacing;
    const typography = DueDayTheme.typography;
    final radius = DueDayTheme.dimensions.radius;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: spacing.medium.height),
        decoration: BoxDecoration(
          border: Border.all(color: colors.resource.primary),
          borderRadius: BorderRadius.circular(radius.large),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colors.resource.primary, size: 20.width),
            SizedBox(width: spacing.small.width),
            Text(
              label,
              style: typography.label.medium.copyWith(
                color: colors.resource.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
