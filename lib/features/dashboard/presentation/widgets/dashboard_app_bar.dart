import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? title;

  const DashboardAppBar({super.key, this.titleText, this.title})
    : assert(
        titleText != null || title != null,
        'titleText or title must be provided',
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;

    return CustomAppBar(
      title: title ?? Text(titleText!, style: typography.title.medium),
      actions: [
        BlocBuilder<NotificationsLoadBloc, NotificationsLoadState>(
          builder: (context, state) {
            int unreadCount = 0;
            if (state is NotificationsLoaded) {
              unreadCount = state.urgentCount;
            }

            return IconButton(
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                label: Text('$unreadCount'),
                backgroundColor: colors.system.error,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: colors.resource.primary,
                ),
              ),
              onPressed: () => context.push('/notifications'),
            );
          },
        ),
        GestureDetector(
          onTap: () => context.push('/profile'),
          behavior: HitTestBehavior.opaque,
          child: Container(
            alignment: Alignment.center,
            width: 44.scale,
            height: 44.scale,
            margin: EdgeInsets.only(right: spacing.largeExtraLarge.width),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.resource.primaryWith15Opacity,
            ),
            child: Icon(Icons.person, color: colors.resource.primary),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
