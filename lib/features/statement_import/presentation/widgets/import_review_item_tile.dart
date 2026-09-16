import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImportReviewItemTile extends StatelessWidget {
  final ImportReviewItem item;
  final VoidCallback? onToggleSelected;
  final VoidCallback? onTapCategory;

  const ImportReviewItemTile({
    required this.item,
    this.onToggleSelected,
    this.onTapCategory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final l10n = context.l10n;

    final parsed = item.parsed;
    final isExpense = parsed.amount < 0;
    final isAlreadyImported =
        item.status == ImportReviewStatus.alreadyImported;
    final amountColor = isAlreadyImported
        ? colors.resource.secondary
        : (isExpense ? colors.system.error : colors.system.success);

    return Opacity(
      opacity: isAlreadyImported ? 0.5 : 1.0,
      child: Container(
        padding: EdgeInsets.all(spacing.medium.width),
        margin: EdgeInsets.only(bottom: spacing.small.height),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(radius.medium),
        ),
        child: Row(
          children: [
            if (!isAlreadyImported)
              Checkbox(
                value: item.selectedForImport,
                onChanged: onToggleSelected == null
                    ? null
                    : (_) => onToggleSelected!(),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parsed.memo.isNotEmpty ? parsed.memo : l10n.defaultTransaction,
                    style: typography.body.medium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.extraSmall.height),
                  Text(
                    DateFormat.yMd(context.localeString).format(parsed.date),
                    style: typography.label.small.copyWith(
                      color: colors.resource.secondary,
                    ),
                  ),
                  if (!isAlreadyImported) ...[
                    SizedBox(height: spacing.extraSmall.height),
                    GestureDetector(
                      onTap: onTapCategory,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.small.width,
                          vertical: 2.height,
                        ),
                        decoration: BoxDecoration(
                          color: colors.resource.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(radius.circle),
                        ),
                        child: Text(
                          item.categoryName ?? l10n.statementImportSelectCategory,
                          style: typography.label.small.copyWith(
                            color: colors.resource.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: spacing.medium.width),
            Text(
              '${isExpense ? '-' : '+'}${NumberFormat.simpleCurrency(locale: context.localeString).format(parsed.amount.abs())}',
              style: typography.body.large.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
