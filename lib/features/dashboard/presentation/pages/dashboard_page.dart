import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:due_day/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:due_day/features/dashboard/presentation/utils/dashboard_failure_extension.dart';
import 'package:due_day/features/dashboard/presentation/widgets/account_selection_bottom_sheet.dart';
import 'package:due_day/features/dashboard/presentation/widgets/cards/due_item_card.dart';
import 'package:due_day/features/dashboard/presentation/widgets/cards/financial_health_card.dart';
import 'package:due_day/features/dashboard/presentation/widgets/cards/summary_card.dart';
import 'package:due_day/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:due_day/features/dashboard/presentation/widgets/insights/insight_card.dart';
import 'package:due_day/features/dashboard/presentation/widgets/spending/category_spending_list.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_load_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();

    context.read<DashboardBloc>().add(const DashboardLoadRequested());
    context.read<TransactionLoadBloc>().add(
      SyncRecurringTransactionsRequested(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final l10n = AppLocalizations.of(context);
    final localeStr = context.localeString;

    return CustomScaffold(
      appBar: DashboardAppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String name = l10n.dashboardMonthlySummary;
            if (state is AuthAuthenticated) {
              name = l10n.dashboardGreeting(
                state.user.name ?? l10n.profileDefaultUserName,
              );
            }
            return Text(name, style: typography.title.medium);
          },
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading || state is DashboardInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Text(
                  state.failure.toLocalizedString(context),
                  style: typography.body.medium.copyWith(
                    color: context.onSurfaceColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (state is DashboardLoaded) {
              final summary = state.summary;

              return BlocBuilder<CategoryLoadBloc, CategoryLoadState>(
                builder: (context, categoryState) {
                  final categories = categoryState is CategoryLoaded
                      ? categoryState.categories
                      : <CategoryEntity>[];

                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      spacing.largeExtraLarge.width,
                      0,
                      spacing.largeExtraLarge.width,
                      spacing.safeBottomNav.height,
                    ),
                    children: [
                      SizedBox(height: spacing.medium.height),

                      // Saldo & Projected Balance Card
                      Builder(
                        builder: (context) {
                          final accountState = context
                              .watch<AccountLoadBloc>()
                              .state;
                          final allAccounts = accountState is AccountLoaded
                              ? accountState.activeAccounts
                              : <AccountEntity>[];
                          final selectedAccountNames = allAccounts
                              .where(
                                (a) => state.selectedAccountIds.contains(a.id),
                              )
                              .map((a) => a.name)
                              .toList();

                          return FinancialHealthCard(
                            currentBalance: summary.currentBalance,
                            projectedBalance: summary.projectedBalance,
                            selectedAccountNames: selectedAccountNames,
                            onFilterTap: () async {
                              final selectedIds =
                                  await showModalBottomSheet<List<String>>(
                                    context: context,
                                    isScrollControlled: true,
                                    useRootNavigator: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) =>
                                        AccountSelectionBottomSheet(
                                          allAccounts: allAccounts,
                                          initialSelectedIds:
                                              state.selectedAccountIds,
                                        ),
                                  );

                              if (selectedIds != null && context.mounted) {
                                context.read<DashboardBloc>().add(
                                  DashboardFilterAccountsRequested(selectedIds),
                                );
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(height: spacing.twoExtraLarge.height),

                      // Incomes / Expenses
                      Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: l10n.dashboardIncomes,
                              amount: NumberFormat.simpleCurrency(
                                locale: localeStr,
                              ).format(summary.monthlyIncome),
                              icon: Icons.arrow_upward_rounded,
                              color: colors.system.success,
                            ),
                          ),
                          SizedBox(width: spacing.mediumLarge.width),
                          Expanded(
                            child: SummaryCard(
                              title: l10n.dashboardExpenses,
                              amount: NumberFormat.simpleCurrency(
                                locale: localeStr,
                              ).format(summary.monthlyExpenses),
                              icon: Icons.arrow_downward_rounded,
                              color: colors.system.error,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.twoExtraLarge.height),

                      // Financial Insights
                      if (summary.spendingByCategory.isNotEmpty) ...[
                        Text(
                          l10n.dashboardFinancialInsights,
                          style: typography.title.medium,
                        ),
                        SizedBox(height: spacing.mediumLarge.height),
                        InsightCard(
                          summary: summary,
                          l10n: l10n,
                          categories: categories,
                        ),
                        SizedBox(height: spacing.twoExtraLarge.height),
                      ],

                      // Category Spending
                      if (summary.spendingByCategory.isNotEmpty) ...[
                        Text(
                          l10n.dashboardCategorySpending,
                          style: typography.title.medium,
                        ),
                        SizedBox(height: spacing.mediumLarge.height),
                        CategorySpendingList(
                          spending: summary.spendingByCategory,
                          total: summary.monthlyExpenses,
                          localeStr: localeStr,
                          categories: categories,
                        ),
                        SizedBox(height: spacing.twoExtraLarge.height),
                      ],

                      // Upcoming Dues
                      Text(
                        l10n.dashboardUpcomingDues,
                        style: typography.title.medium,
                      ),
                      SizedBox(height: spacing.mediumLarge.height),

                      if (summary.upcomingDues.isEmpty)
                        Text(
                          l10n.dashboardNoUpcomingDues,
                          style: typography.body.medium.copyWith(
                            color: colors.resource.secondary,
                          ),
                        )
                      else
                        ...summary.upcomingDues.map((t) {
                          final daysUntilDue = t.dueDate!
                              .difference(DateTime.now())
                              .inDays;
                          final String dueDateStr = switch (daysUntilDue) {
                            0 => l10n.dashboardDueToday,
                            1 => l10n.dashboardDueTomorrow,
                            _ => l10n.dashboardDueInDays(daysUntilDue),
                          };

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: spacing.medium.height,
                            ),
                            child: DueItemCard(
                              title: t.notes != null && t.notes!.isNotEmpty
                                  ? t.notes!
                                  : l10n.defaultTransaction,
                              date: dueDateStr,
                              amount: NumberFormat.simpleCurrency(
                                locale: localeStr,
                              ).format(t.amount.abs()),
                              icon: Icons.receipt_long,
                              isWarning: daysUntilDue <= 3,
                            ),
                          );
                        }),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
