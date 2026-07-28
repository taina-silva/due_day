import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/schedule/domain/entities/schedule_summary.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_event.dart';
import 'package:due_day/features/schedule/presentation/widgets/timeline/schedule_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TimelineSection extends StatelessWidget {
  final ScheduleSummary summary;
  final Map<String, CategoryEntity> categories;

  const TimelineSection({
    required this.summary,
    required this.categories,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    if (summary.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.extraLarge.width),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48.scale,
                color: colors.resource.secondary.withValues(alpha: 0.3),
              ),
              SizedBox(height: spacing.medium.height),
              Text(
                l10n.transactionsEmpty,
                style: typography.body.medium.copyWith(
                  color: colors.resource.secondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.largeExtraLarge.width,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.scheduleTimelineTitle,
                style: typography.title.large.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.medium.height),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.largeExtraLarge.width,
          ),
          itemCount: summary.transactions.length,
          itemBuilder: (context, index) {
            final tx = summary.transactions[index];
            final category = categories[tx.category];
            return ScheduleItemCard(
              transaction: tx,
              categoryName: category?.name,
              categoryIcon: category?.icon,
              categoryColor: category?.color,
              onMarkAsPaid: () {
                context.read<ScheduleActionBloc>().add(MarkAsPaidEvent(tx));
              },
            );
          },
        ),
        SizedBox(height: spacing.medium.height),
        Center(
          child: TextButton(
            onPressed: () {
              context.push('/transactions/history');
            },
            child: Text(
              l10n.commonSeeAll,
              style: typography.label.large.copyWith(
                color: colors.resource.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
