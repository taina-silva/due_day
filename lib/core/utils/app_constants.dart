import 'dart:io';

import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

/// A class that contains UI and layout constants for the application.
class AppConstants {
  /// The size of the top safe area (app bar space).
  static double topSafeArea(BuildContext context, {bool isEmpty = false}) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return viewPadding.top +
        (!isEmpty ? 48 : (Platform.isIOS ? 14 : viewPadding.top));
  }

  /// The size of the bottom space to be added, considering safe areas and navigation mode.
  static double bottomSafeArea(BuildContext context, {double? padding}) {
    final isIOS = Platform.isIOS;

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomPadding = viewPadding.bottom;

    final minPadding = padding != null ? padding / 2 : null;

    if (isIOS) {
      if (bottomPadding > 0) return bottomPadding;
      return minPadding ?? bottomPadding;
    }

    if (isGestureModeNavigation(context)) {
      if (bottomPadding > 0) return bottomPadding + (minPadding ?? 0);
      return minPadding ?? bottomPadding;
    }

    if (bottomPadding > 0) return bottomPadding + (padding ?? 0);
    return padding ?? bottomPadding;
  }

  /// Check if the navigation is in gesture mode.
  static bool isGestureModeNavigation(BuildContext context) {
    final isIOS = Platform.isIOS;
    if (isIOS) return true;

    final isGestureMode = MediaQuery.systemGestureInsetsOf(context).left > 0;
    return isGestureMode;
  }

  // UI fixed constants
  static double get bottomNavHeight => 72.height;
}
