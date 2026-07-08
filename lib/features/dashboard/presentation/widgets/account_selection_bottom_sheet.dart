import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSelectionBottomSheet extends StatefulWidget {
  final List<AccountEntity> allAccounts;
  final List<String> initialSelectedIds;

  const AccountSelectionBottomSheet({
    required this.allAccounts,
    required this.initialSelectedIds,
    super.key,
  });

  @override
  State<AccountSelectionBottomSheet> createState() =>
      _AccountSelectionBottomSheetState();
}

class _AccountSelectionBottomSheetState
    extends State<AccountSelectionBottomSheet> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initialSelectedIds);
  }

  void _toggleAccount(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = AppLocalizations.of(context);

    final radius = context.radius;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.large.width,
        vertical: spacing.large.height,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radius.extraLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.navAccount, style: typography.title.medium),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (_selectedIds.length == widget.allAccounts.length) {
                      _selectedIds.clear();
                    } else {
                      _selectedIds = widget.allAccounts
                          .map((a) => a.id)
                          .toList();
                    }
                  });
                },
                child: Text(
                  _selectedIds.length == widget.allAccounts.length
                      ? l10n.clear
                      : l10n.all,
                  style: typography.body.medium.copyWith(
                    color: colors.resource.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.medium.height),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.allAccounts.length,
              itemBuilder: (context, index) {
                final account = widget.allAccounts[index];
                final isSelected = _selectedIds.contains(account.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) => _toggleAccount(account.id),
                  title: Text(
                    account.name,
                    style: typography.body.large.copyWith(
                      color: context.onSurfaceColor,
                    ),
                  ),
                  subtitle: Text(
                    account.category.localizedName(l10n),
                    style: typography.body.small.copyWith(
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                  activeColor: colors.resource.primary,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              },
            ),
          ),
          SizedBox(height: spacing.large.height),
          SizedBox(
            width: double.infinity,
            child: AppTextButtonPrimary(
              label: l10n.apply,
              onPressed: () => context.pop(_selectedIds),
            ),
          ),
          SizedBox(height: spacing.medium.height),
        ],
      ),
    );
  }
}
