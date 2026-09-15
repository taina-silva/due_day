import 'package:flutter/material.dart';

/// Wraps a scrollable bottom sheet body so that pulling down while already
/// at the top of the scroll content dismisses the sheet, mirroring the
/// native iOS/Android sheet drag-to-close gesture.
///
/// Two scroll physics report a top overscroll differently, so both are
/// handled: [ClampingScrollPhysics] (Android) clamps `metrics.pixels` at
/// the boundary and only exposes the pulled-past distance as per-frame
/// deltas via [OverscrollNotification], which are accumulated below.
/// [BouncingScrollPhysics] (iOS) never emits [OverscrollNotification] at
/// all — it lets `metrics.pixels` go negative directly, so that absolute
/// distance is compared instead of accumulating deltas.
class PullToDismissSheet extends StatefulWidget {
  final Widget child;
  final double dismissThreshold;

  const PullToDismissSheet({
    required this.child,
    super.key,
    this.dismissThreshold = 80,
  });

  @override
  State<PullToDismissSheet> createState() => _PullToDismissSheetState();
}

class _PullToDismissSheetState extends State<PullToDismissSheet> {
  double _accumulatedOverscroll = 0;
  bool _isDismissing = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification &&
            notification.dragDetails != null &&
            notification.overscroll < 0) {
          _accumulatedOverscroll += notification.overscroll.abs();
          _maybeDismiss(context, _accumulatedOverscroll);
        } else if (notification is ScrollUpdateNotification &&
            notification.dragDetails != null &&
            notification.metrics.pixels <
                notification.metrics.minScrollExtent) {
          final overscroll =
              notification.metrics.minScrollExtent -
              notification.metrics.pixels;
          _maybeDismiss(context, overscroll);
        } else if (notification is ScrollEndNotification) {
          _accumulatedOverscroll = 0;
        }
        return false;
      },
      child: widget.child,
    );
  }

  void _maybeDismiss(BuildContext context, double overscroll) {
    if (_isDismissing || overscroll < widget.dismissThreshold) return;
    _isDismissing = true;
    Navigator.of(context).maybePop();
  }
}
