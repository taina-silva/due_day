import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return const _NotificationsView();
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final spacing = DueDayTheme.dimensions.spacing;
    final l10n = AppLocalizations.of(context);

    return CustomScaffold(
      appBar: CustomAppBar(
        titleText: l10n.notificationsTitle,
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is NotificationsLoaded) {
              final newNotifications = state.newNotifications;
              final earlierNotifications = state.earlierNotifications;

              if (newNotifications.isEmpty && earlierNotifications.isEmpty) {
                return _buildEmptyState(context, spacing, l10n);
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.largeExtraLarge.width,
                  vertical: spacing.mediumLarge.height,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // New Section
                    if (newNotifications.isNotEmpty) ...[
                      _SectionTitle(title: l10n.notificationsGroupNew),
                      SizedBox(height: spacing.mediumLarge.height),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: newNotifications.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: spacing.medium.height),
                        itemBuilder: (context, index) {
                          final notif = newNotifications[index];
                          return _NotificationCard(
                            notification: notif,
                            time: _formatTime(notif.timestamp, l10n),
                            onMarkAsRead: () {
                              context
                                  .read<NotificationsBloc>()
                                  .add(MarkAsReadEvent(notif.id));
                            },
                          );
                        },
                      ),
                      SizedBox(height: spacing.largeExtraLarge.height),
                    ],

                    // Earlier Section
                    if (earlierNotifications.isNotEmpty) ...[
                      _SectionTitle(title: l10n.notificationsGroupEarlier),
                      SizedBox(height: spacing.mediumLarge.height),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: earlierNotifications.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: spacing.medium.height),
                        itemBuilder: (context, index) {
                          final notif = earlierNotifications[index];
                          return _NotificationCard(
                            notification: notif,
                            time: _formatTime(notif.timestamp, l10n),
                          );
                        },
                      ),
                      SizedBox(height: spacing.threeExtraLarge.height),
                    ],

                    // Footer illustration
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60.width,
                            height: 4.height,
                            decoration: BoxDecoration(
                              color: colors.resource.neutral
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          SizedBox(height: spacing.mediumLarge.height),
                          Text(
                            l10n.notificationsEnd.toUpperCase(),
                            style: typography.label.small.copyWith(
                              color: colors.resource.secondary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: spacing.largeExtraLarge.height),
                  ],
                ),
              );
            }

            return Center(
              child: Text(
                'Erro ao carregar notificações.',
                style: typography.body.medium,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, dynamic spacing, AppLocalizations l10n) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.twoExtraLarge.width),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(spacing.largeExtraLarge.width),
              decoration: BoxDecoration(
                color: colors.resource.primaryWith15Opacity,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 64.width,
                color: colors.resource.primary,
              ),
            ),
            SizedBox(height: spacing.largeExtraLarge.height),
            Text(
              'Tudo em dia!',
              style: typography.title.medium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.smallMedium.height),
            Text(
              'Você não tem nenhuma notificação pendente no momento.',
              style: typography.body.medium.copyWith(
                color: colors.resource.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return l10n.notifJustNow;
    } else if (difference.inMinutes < 60) {
      return difference.inMinutes == 1
          ? 'Há 1 minuto'
          : 'Há ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return difference.inHours == 1
          ? 'Há 1 hora'
          : 'Há ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return difference.inDays == 1
          ? l10n.notifYesterday
          : 'Há ${difference.inDays} dias';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DueDayTheme.dimensions.spacing.small.width,
      ),
      child: Text(
        title.toUpperCase(),
        style: typography.label.small.copyWith(
          color: colors.resource.secondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final String time;
  final VoidCallback? onMarkAsRead;

  const _NotificationCard({
    required this.notification,
    required this.time,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final radius = DueDayTheme.dimensions.radius;
    final spacing = DueDayTheme.dimensions.spacing;

    final isUrgent = notification.isUrgent;
    final isRead = notification.read;

    IconData getIcon() {
      switch (notification.type) {
        case NotificationType.dueToday:
          return Icons.alarm_rounded;
        case NotificationType.overdue:
          return Icons.warning_amber_rounded;
        case NotificationType.recurringDebited:
          return Icons.autorenew_rounded;
        case NotificationType.upcomingDue:
          return Icons.calendar_today_rounded;
      }
    }

    Color getIconColor() {
      if (isRead) return colors.resource.secondary;
      switch (notification.type) {
        case NotificationType.dueToday:
          return colors.system.warning;
        case NotificationType.overdue:
          return colors.system.error;
        case NotificationType.recurringDebited:
          return colors.system.success;
        case NotificationType.upcomingDue:
          return colors.resource.primary;
      }
    }

    return Container(
      padding: EdgeInsets.all(spacing.large.width),
      decoration: BoxDecoration(
        color: isRead
            ? colors.lightSurface.withValues(alpha: 0.6)
            : colors.lightSurface,
        borderRadius: BorderRadius.circular(radius.extraLarge),
        border: isUrgent && !isRead
            ? Border.all(color: colors.system.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(spacing.smallMedium.width),
            decoration: BoxDecoration(
              color: getIconColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              getIcon(),
              color: getIconColor(),
              size: 20.width,
            ),
          ),
          SizedBox(width: spacing.mediumLarge.width),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              notification.title,
                              style: typography.body.large.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isRead
                                    ? colors.resource.secondary
                                    : colors.resource.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUrgent && !isRead) ...[
                            SizedBox(width: spacing.smallMedium.width),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.smallMedium.width,
                                vertical: 2.height,
                              ),
                              decoration: BoxDecoration(
                                color: colors.system.error,
                                borderRadius:
                                    BorderRadius.circular(radius.small),
                              ),
                              child: Text(
                                'URGENTE',
                                style: typography.label.small.copyWith(
                                  color: colors.onDarkBackground,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.fontSize,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onMarkAsRead != null && !isRead) ...[
                      GestureDetector(
                        onTap: onMarkAsRead,
                        child: Icon(
                          Icons.done_all_rounded,
                          color: colors.resource.primary,
                          size: 18.width,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: spacing.small.height),
                Text(
                  notification.description,
                  style: typography.body.medium.copyWith(
                    color: isRead
                        ? colors.resource.neutral
                        : colors.resource.secondary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: spacing.smallMedium.height),
                Text(
                  time,
                  style: typography.label.small.copyWith(
                    color: colors.resource.neutral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
