import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountActions extends StatelessWidget {
  const AccountActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final radius = DueDayTheme.dimensions.radius;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(radius.extraLarge),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.logout,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            title: Text(
              l10n.profileLogOut,
              style: typography.body.large.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            onTap: () {
              context.read<AuthBloc>().add(AuthSignOutEvent());
              context.go('/login');
            },
          ),
          Divider(
            height: 1,
            color: colors.resource.secondary.withValues(alpha: 0.1),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: colors.system.error.withValues(alpha: 0.7),
            ),
            title: Text(
              l10n.profileDeleteAccount,
              style: typography.body.large.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.system.error,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colors.system.error.withValues(alpha: 0.3),
            ),
            onTap: () => _showDeleteDialog(context, l10n),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (cntx) => AlertDialog(
        title: Text(l10n.profileConfirmDeleteTitle),
        content: Text(l10n.profileConfirmDeleteDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(cntx),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(cntx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.profileExcludeDevAlert),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text(
              l10n.profileExclude,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
