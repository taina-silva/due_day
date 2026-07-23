import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:flutter/material.dart';

/// Feedback intent conveyed by an [AppMessenger] message.
enum AppMessengerType { success, error, info }

/// Content rendered inside the [SnackBar] shown by [AppMessenger]: a type
/// icon followed by the message text.
class AppMessengerContent extends StatelessWidget {
  final String message;
  final AppMessengerType type;

  const AppMessengerContent({
    required this.message,
    required this.type,
    super.key,
  });

  IconData get _icon => switch (type) {
    AppMessengerType.success => Icons.check_circle_rounded,
    AppMessengerType.error => Icons.error_rounded,
    AppMessengerType.info => Icons.info_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dimensions = context.dimensions;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(_icon, color: colors.onDarkBackground, size: dimensions.size.iconMedium),
        SizedBox(width: dimensions.spacing.smallMedium),
        Expanded(
          child: Text(
            message,
            style: typography.body.medium.copyWith(color: colors.onDarkBackground),
          ),
        ),
      ],
    );
  }
}

/// Static helper that presents success, error, or info feedback through a
/// single, consistently styled [SnackBar] across the app.
///
/// Replaces ad-hoc `ScaffoldMessenger.of(context).showSnackBar(SnackBar(...))`
/// calls scattered across features and always includes a dismiss (X) action
/// on the trailing edge, backed by Flutter's native [SnackBar.showCloseIcon].
class AppMessenger {
  const AppMessenger._();

  static void show(
    BuildContext context, {
    required String message,
    required AppMessengerType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final colors = context.colors;
    final dimensions = context.dimensions;

    final backgroundColor = switch (type) {
      AppMessengerType.success => colors.system.success,
      AppMessengerType.error => colors.system.error,
      AppMessengerType.info => colors.system.info,
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        showCloseIcon: true,
        closeIconColor: colors.onDarkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
        ),
        content: AppMessengerContent(message: message, type: type),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message: message, type: AppMessengerType.success);

  static void showError(BuildContext context, String message) =>
      show(context, message: message, type: AppMessengerType.error);

  static void showInfo(BuildContext context, String message) =>
      show(context, message: message, type: AppMessengerType.info);
}
