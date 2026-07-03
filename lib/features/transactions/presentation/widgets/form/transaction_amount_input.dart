import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/core/utils/formatters/currency_input_formatter.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class TransactionAmountInput extends StatelessWidget {
  final TransactionType selectedType;
  final TextEditingController controller;
  final AppLocalizations l10n;

  const TransactionAmountInput({
    required this.selectedType,
    required this.controller,
    required this.l10n,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    final isExpense = selectedType == TransactionType.expense;
    final isTransfer = selectedType == TransactionType.transfer;
    final sign = isTransfer ? '' : (isExpense ? '-' : '+');
    final activeColor = isTransfer
        ? colors.resource.secondary
        : (isExpense ? colors.system.error : colors.system.success);

    return Column(
      children: [
        Text(
          l10n.transactionsAmount,
          style: typography.label.small.copyWith(
            color: colors.resource.secondary,
          ),
        ),
        SizedBox(height: spacing.small.height),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$sign\$',
              style: typography.headline.large.copyWith(
                color: activeColor,
                fontSize: 48.width,
              ),
            ),
            SizedBox(width: spacing.small.width),
            Flexible(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [
                  CurrencyInputFormatter(
                    locale: Localizations.localeOf(context).toString(),
                  ),
                ],
                style: typography.headline.large.copyWith(
                  fontSize: 64.width,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: const InputDecoration(
                  hintText: '0,00',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.small.height),
        ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            final value = controller.text.isEmpty ? '0,00' : controller.text;
            return Text(
              '$sign\$ $value',
              style: typography.body.medium.copyWith(
                color: colors.resource.secondary,
              ),
            );
          },
        ),
      ],
    );
  }
}
