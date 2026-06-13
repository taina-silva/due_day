import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:due_day/features/transactions/presentation/widgets/form/transaction_create_form.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomScaffold(
      appBar: DashboardAppBar(titleText: l10n.transactionsTitle),
      body: const SafeArea(child: TransactionCreateForm()),
    );
  }
}
