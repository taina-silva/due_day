import 'package:due_day/core/design_system/images/app_images.dart';
import 'package:flutter/material.dart';

class AppImageWidget extends StatelessWidget {
  const AppImageWidget({
    required this.image,
    required this.semanticLabel,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final AppImages image;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image.path,
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticLabel,
    );
  }
}
