import 'package:due_day/core/design_system/theme/app_dimensions/radius_styles.dart';
import 'package:due_day/core/design_system/theme/app_dimensions/sizes_styles.dart';
import 'package:due_day/core/design_system/theme/app_dimensions/spacing_styles.dart';
import 'package:due_day/core/design_system/theme/app_dimensions/stroke_styles.dart';

class AppDimensions {
  final RadiusStyles radius;
  final SizesStyles size;
  final SpacingStyles spacing;
  final StrokeStyles stroke;

  const AppDimensions()
      : radius = const RadiusStyles(),
        size = const SizesStyles(),
        spacing = const SpacingStyles(),
        stroke = const StrokeStyles();
}
