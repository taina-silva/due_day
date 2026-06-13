import 'dart:ui';

/// An extension on the [num] class that provides methods for scaling based on the screen size
///
/// This extension enables responsive design by automatically scaling values based on the device's
/// screen dimensions. It calculates scaling factors using a reference device size (390x844).
extension NumExtension on num {
  /// Base width (reference device) - Standard phone portrait width
  static const baseWidth = 390.0;

  /// Base height (reference device) - Standard phone portrait height
  static const baseHeight = 844.0;

  /// Retrieves the screen's width and height scaling factors
  _ScalingFactors _getScalingFactors() {
    if (this == double.infinity) return _ScalingFactors(1, 1, 1);

    final base = PlatformDispatcher.instance.views.first;
    final screenSize = base.physicalSize / base.devicePixelRatio;

    final widthFactor = screenSize.width / baseWidth;
    final heightFactor = screenSize.height / baseHeight;

    final aspectRatio = screenSize.width / screenSize.height;

    final scaleFactor =
        (widthFactor + heightFactor) / 2 * (aspectRatio < 1 ? 1 : aspectRatio);

    return _ScalingFactors(widthFactor, heightFactor, scaleFactor);
  }

  /// Calculates the font size based on the screen size, clamped between min and max values
  ///
  /// Example:
  /// ```dart
  /// Text('Hello', style: TextStyle(fontSize: 16.fontSize))
  /// ```
  double get fontSize {
    final scaleFactor = _getScalingFactors().scaleFactor;

    const min = 12.0;
    const max = 36.0;

    return (this * scaleFactor).clamp(min, max);
  }

  /// Calculates the width based on the screen size
  ///
  /// Example:
  /// ```dart
  /// SizedBox(width: 200.width)
  /// ```
  double get width => this * _getScalingFactors().widthFactor;

  /// Calculates the height based on the screen size
  ///
  /// Example:
  /// ```dart
  /// SizedBox(height: 200.height)
  /// ```
  double get height => this * _getScalingFactors().heightFactor;

  /// Calculates the scale based on the screen size
  ///
  /// This is used for general scaling of components that should adapt to the screen size
  ///
  /// Example:
  /// ```dart
  /// Container(
  ///   width: 100.scale,
  ///   height: 100.scale,
  /// )
  /// ```
  double get scale => this * _getScalingFactors().scaleFactor;

  /// Alias for scale - same behavior, alternative name
  double get sp => scale;

  /// Alias for fontSize - shorter notation for font size
  double get fs => fontSize;

  /// Alias for width - shorter notation
  double get w => width;

  /// Alias for height - shorter notation
  double get h => height;
}

/// Private class to hold scaling factors
///
/// This class is used internally to cache the scaling factors calculated from the device dimensions
class _ScalingFactors {
  /// Constructor for scaling factors
  _ScalingFactors(this.widthFactor, this.heightFactor, this.scaleFactor);

  /// Factor to scale width values
  final double widthFactor;

  /// Factor to scale height values
  final double heightFactor;

  /// General scaling factor (average of width and height with aspect ratio adjustment)
  final double scaleFactor;
}
