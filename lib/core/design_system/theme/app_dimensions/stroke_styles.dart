import 'package:flutter/material.dart';

class StrokeStyles {
  const StrokeStyles();

  double get extraSmall => 0.5;
  double get small => 1.0;
  double get medium => 1.5;
  double get large => 2.0;
  double get extraLarge => 2.5;
  double get extraExtraLarge => 3.0;

  BorderSide asBorderSide({required Color color, required double strokeWidth}) {
    return BorderSide(color: color, width: strokeWidth);
  }

  BorderSide asPrimarySide({required Color primaryColor}) {
    return BorderSide(color: primaryColor, width: large);
  }
}
