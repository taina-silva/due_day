import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/injection/injection_container.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:due_day/features/schedule/presentation/utils/schedule_failure_extension.dart';
import 'package:due_day/features/schedule/presentation/widgets/summary/next_income_card.dart';
import 'package:due_day/features/schedule/presentation/widgets/summary/weekly_overview_card.dart';
import 'package:due_day/features/schedule/presentation/widgets/timeline/timeline_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ScheduleBloc>()..add(LoadScheduleData()),
      child: const ScheduleView(),
    );
  }
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final l10n = context.l10n;
    final colors = context.colors;

    return CustomScaffold(
      appBar: CustomAppBar(
        titleText: l10n.scheduleTitle,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colors.resource.primary,
            ),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ScheduleError) {
              return Center(
                child: Text(state.failure.toLocalizedString(context)),
              );
            }

            if (state is ScheduleLoaded) {
              final summary = state.summary;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.largeExtraLarge.width,
                            ),
                            child: WeeklyOverviewCard(
                              totalAmount: summary.totalAmount,
                              totalPaid: summary.totalPaid,
                              totalToPay: summary.totalToPay,
                            ),
                          ),
                          SizedBox(height: spacing.large.height),
                          if (summary.nextIncomeAmount != null) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.largeExtraLarge.width,
                              ),
                              child: SizedBox(
                                height: 160.height,
                                child: NextIncomeCard(
                                  amount: summary.nextIncomeAmount!,
                                  arrivalDate: summary.nextIncomeDate,
                                ),
                              ),
                            ),
                            SizedBox(height: spacing.extraLarge.height),
                          ],
                          TimelineSection(
                            summary: summary,
                            categories: state.categories,
                          ),
                          SizedBox(height: spacing.extraLarge.height),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
