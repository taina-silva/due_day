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
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final typography = context.typography;
    final radius = context.radius;

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(radius.extraLarge),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.logout,
              color: context.onSurfaceColor.withValues(alpha: 0.5),
            ),
            title: Text(
              l10n.profileLogOut,
              style: typography.body.large.copyWith(
                fontWeight: FontWeight.bold,
                color: context.onSurfaceColor,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: context.onSurfaceColor.withValues(alpha: 0.3),
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
            onPressed: () => cntx.pop(),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () {
              cntx.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.profileExcludeDevAlert,
                    style: context.typography.body.medium.copyWith(
                      color: context.colors.onDarkBackground,
                    ),
                  ),
                  backgroundColor: context.colors.system.error,
                ),
              );
            },
            child: Text(
              l10n.profileExclude,
              style: TextStyle(color: context.colors.system.error),
            ),
          ),
        ],
      ),
    );
  }
}
