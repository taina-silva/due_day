import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_state.dart';
import 'package:due_day/features/accounts/presentation/utils/account_failure_extension.dart';
import 'package:due_day/features/accounts/presentation/widgets/account_card.dart';
import 'package:due_day/features/accounts/presentation/widgets/add_edit_account_bottom_sheet.dart';
import 'package:due_day/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final l10n = AppLocalizations.of(context);
    final localeStr = context.localeString;

    return CustomScaffold(
      appBar: DashboardAppBar(titleText: l10n.accountsTitle),
      body: SafeArea(
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            if (state is AccountLoading || state is AccountInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AccountError) {
              return Center(
                child: Text(
                  state.failure.toLocalizedString(context),
                  style: typography.body.medium,
                ),
              );
            } else if (state is AccountLoaded) {
              final accounts = state.activeAccounts;
              final totalBalance = accounts.fold(
                0.0,
                (sum, acc) => sum + acc.balance,
              );

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  spacing.largeExtraLarge.width,
                  spacing.medium.height,
                  spacing.largeExtraLarge.width,
                  spacing.safeBottomNav.height,
                ),
                children: [
                  // Balance Sum
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: spacing.largeExtraLarge.height,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(radius.extraLarge),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.dashboardGeneralBalance,
                          style: typography.label.medium,
                        ),
                        SizedBox(height: spacing.smallMedium.height),
                        Text(
                          NumberFormat.simpleCurrency(
                            locale: localeStr,
                          ).format(totalBalance),
                          style: typography.headline.large.copyWith(
                            color: colors.resource.primary,
                            fontSize: 36.fontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing.mediumLarge.height),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AppTextButtonPrimary(
                      label: l10n.accountsAddAccount,
                      prefixIcon: Icons.add,
                      onPressed: () => _showAddEditAccountBottomSheet(context),
                    ),
                  ),
                  SizedBox(height: spacing.twoExtraLarge.height),

                  Text(l10n.accountsBanks, style: typography.title.medium),
                  SizedBox(height: spacing.mediumLarge.height),

                  if (accounts.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: spacing.mediumLarge.height,
                      ),
                      child: Text(
                        l10n.accountsEmpty,
                        style: typography.body.medium,
                      ),
                    ),

                  ...accounts.map(
                    (acc) => Padding(
                      padding: EdgeInsets.only(bottom: spacing.medium.height),
                      child: AccountCard(
                        account: acc,
                        onTap: () =>
                            _showAddEditAccountBottomSheet(context, acc),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showAddEditAccountBottomSheet(
    BuildContext context, [
    AccountEntity? account,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.extraLarge),
        ),
      ),
      builder: (ctx) {
        return AddEditAccountBottomSheet(
          account: account,
          onSave: (name, category, balance, dueDay) {
            final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
            final accountBloc = context.read<AccountBloc>();

            if (account == null) {
              accountBloc.add(
                AddAccountEvent(
                  AccountEntity(
                    id: const Uuid().v4(),
                    userId: userId,
                    name: name,
                    category: category,
                    balance: balance,
                    dueDay: dueDay,
                    createdAt: DateTime.now(),
                  ),
                ),
              );
            } else {
              accountBloc.add(
                UpdateAccountEvent(
                  AccountEntity(
                    id: account.id,
                    userId: account.userId,
                    name: name,
                    category: category,
                    balance: balance,
                    dueDay: dueDay,
                    createdAt: account.createdAt,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
