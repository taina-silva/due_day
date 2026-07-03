import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AccountSelectionBottomSheet extends StatelessWidget {
  const AccountSelectionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = AppLocalizations.of(context);
    final localeStr = Localizations.localeOf(context).toString();

    return Container(
      padding: EdgeInsets.symmetric(vertical: spacing.mediumLarge.height),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.width,
              height: 4.height,
              decoration: BoxDecoration(
                color: colors.resource.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: spacing.large.height),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.largeExtraLarge.width,
            ),
            child: Text(
              l10n.accountsTitle,
              style: typography.title.large.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: spacing.medium.height),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                if (state is AccountLoading || state is AccountInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AccountError) {
                  return Center(child: Text(state.message));
                } else if (state is AccountLoaded) {
                  final accounts = state.activeAccounts;

                  if (accounts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(spacing.largeExtraLarge.height),
                        child: Text(
                          l10n.accountsEmpty,
                          style: typography.body.medium,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      bottom: spacing.largeExtraLarge.height,
                    ),
                    itemCount: accounts.length,
                    itemBuilder: (context, index) {
                      final acc = accounts[index];

                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(spacing.small.width),
                          decoration: BoxDecoration(
                            color: colors.resource.primary.withValues(
                              alpha: 0.15,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_rounded,
                            color: colors.resource.primary,
                            size: 20.width,
                          ),
                        ),
                        title: Text(acc.name, style: typography.body.large),
                        subtitle: Text(
                          acc.category.localizedName(l10n),
                          style: typography.label.medium,
                        ),
                        trailing: Text(
                          NumberFormat.simpleCurrency(
                            locale: localeStr,
                          ).format(acc.balance),
                          style: typography.body.large.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => Navigator.pop(context, acc),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
