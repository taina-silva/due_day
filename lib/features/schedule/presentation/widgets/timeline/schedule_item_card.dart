import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:due_day/features/schedule/presentation/widgets/timeline/status_tag.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleItemCard extends StatelessWidget {
  final TransactionEntity transaction;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final VoidCallback? onMarkAsPaid;

  const ScheduleItemCard({
    required this.transaction, super.key,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.onMarkAsPaid,
  });

  ScheduleStatus _getStatus() {
    if (transaction.paid) return ScheduleStatus.paid;
    final dueDate = transaction.dueDate ?? transaction.createdAt;
    final now = DateTime.now();
    if (dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return ScheduleStatus.overdue;
    }
    if (dueDate.isBefore(now.add(const Duration(days: 3)))) {
      return ScheduleStatus.dueSoon;
    }
    return ScheduleStatus.scheduled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final l10n = context.l10n;

    final date = transaction.dueDate ?? transaction.createdAt;
    final dayFormat = DateFormat('dd');
    final monthFormat = DateFormat('MMM');

    final currencyFormat = NumberFormat.simpleCurrency(
      locale: context.localeString,
    );

    final parsedColor = CategoryColorUtils.parseColor(
      categoryColor ?? '',
      colors.resource.secondary,
    );
    final iconData = CategoryIconUtils.parseIcon(categoryIcon ?? '');

    final status = _getStatus();

    return Container(
      margin: EdgeInsets.only(bottom: spacing.medium.height),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Column
          Container(
            width: 50.width,
            padding: EdgeInsets.only(top: spacing.small.height),
            child: Column(
              children: [
                Text(
                  monthFormat.format(date).toUpperCase(),
                  style: typography.label.small.copyWith(
                    color: colors.resource.secondary.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.width,
                  ),
                ),
                Text(
                  dayFormat.format(date),
                  style: typography.title.large.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onLightBackground,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.small.width),
          // Main Content Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(spacing.mediumLarge.width),
              decoration: BoxDecoration(
                color: colors.lightSurface,
                borderRadius: BorderRadius.circular(radius.large),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.width,
                        height: 40.width,
                        decoration: BoxDecoration(
                          color: parsedColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          color: parsedColor,
                          size: 20.width,
                        ),
                      ),
                      SizedBox(width: spacing.medium.width),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              categoryName ?? l10n.defaultTransaction,
                              style: typography.label.small.copyWith(
                                color: colors.resource.secondary
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.bold,
                                fontSize: 10.width,
                              ),
                            ),
                            Text(
                              transaction.notes ?? categoryName ?? '',
                              style: typography.body.medium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.onLightBackground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormat.format(transaction.amount),
                            style: typography.title.small.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onLightBackground,
                            ),
                          ),
                          SizedBox(height: 4.height),
                          StatusTag(status: status),
                        ],
                      ),
                    ],
                  ),
                  if (!transaction.paid) ...[
                    SizedBox(height: spacing.medium.height),
                    Divider(
                      color: colors.resource.secondary.withValues(alpha: 0.05),
                      height: 1,
                    ),
                    SizedBox(height: spacing.medium.height),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: onMarkAsPaid,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: spacing.small.height,
                          ),
                        ),
                        child: Text(
                          l10n.scheduleMarkAsPaid,
                          style: typography.label.medium.copyWith(
                            color: colors.resource.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(height: spacing.medium.height),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: colors.system.success,
                          size: 20.width,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
