import 'dart:async';

import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

/// Feedback intent conveyed by an [AppMessenger] message.
enum AppMessengerType { success, error, info }

/// Content rendered inside the toast shown by [AppMessenger]: a type icon
/// followed by the message text.
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
        Icon(
          _icon,
          color: colors.onDarkBackground,
          size: dimensions.size.iconMedium,
        ),
        SizedBox(width: dimensions.spacing.smallMedium),
        Expanded(
          child: Text(
            message,
            style: typography.body.medium.copyWith(
              color: colors.onDarkBackground,
            ),
          ),
        ),
      ],
    );
  }
}

/// Static helper that presents success, error, or info feedback through a
/// single, consistently styled toast across the app.
///
/// Renders via an [OverlayEntry] inserted into the app's root [Overlay]
/// instead of [ScaffoldMessenger], so the message always appears above any
/// route — including modal bottom sheets and dialogs — without needing a
/// local [Scaffold] at each call site to register with [ScaffoldMessenger].
class AppMessenger {
  const AppMessenger._();

  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required String message,
    required AppMessengerType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    _removeCurrent();

    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _AppMessengerToast(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => _removeEntry(entry),
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void showSuccess(BuildContext context, String message) =>
      show(context, message: message, type: AppMessengerType.success);

  static void showError(BuildContext context, String message) =>
      show(context, message: message, type: AppMessengerType.error);

  static void showInfo(BuildContext context, String message) =>
      show(context, message: message, type: AppMessengerType.info);

  static void _removeCurrent() {
    final entry = _currentEntry;
    _currentEntry = null;
    entry?.remove();
  }

  static void _removeEntry(OverlayEntry entry) {
    if (_currentEntry != entry) return;
    _currentEntry = null;
    entry.remove();
  }
}

class _AppMessengerToast extends StatefulWidget {
  final String message;
  final AppMessengerType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AppMessengerToast({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AppMessengerToast> createState() => _AppMessengerToastState();
}

class _AppMessengerToastState extends State<_AppMessengerToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _controller.forward();
    _autoDismissTimer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    _autoDismissTimer?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimensions = context.dimensions;
    final mediaQuery = MediaQuery.of(context);

    final backgroundColor = switch (widget.type) {
      AppMessengerType.success => colors.system.success,
      AppMessengerType.error => colors.system.error,
      AppMessengerType.info => colors.system.info,
    };

    return Positioned(
      left: dimensions.spacing.medium.width,
      right: dimensions.spacing.medium.width,
      bottom:
          mediaQuery.viewInsets.bottom +
          mediaQuery.padding.bottom +
          dimensions.spacing.medium.height,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            key: const Key('app_messenger_toast'),
            color: backgroundColor,
            elevation: 6,
            borderRadius: BorderRadius.circular(dimensions.radius.medium),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.spacing.medium.width,
                vertical: dimensions.spacing.smallMedium,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppMessengerContent(
                      message: widget.message,
                      type: widget.type,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.onDarkBackground),
                    onPressed: _dismiss,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
