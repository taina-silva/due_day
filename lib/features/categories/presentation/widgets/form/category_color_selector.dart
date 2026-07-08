import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:flutter/material.dart';

class CategoryColorSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const CategoryColorSelector({
    required this.selectedColor,
    required this.onColorSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimensions = context.dimensions;

    return Row(
      children: CategoryColorUtils.availableColors.map((color) {
        final isSelected = color.toARGB32() == selectedColor.toARGB32();

        return Padding(
          padding: EdgeInsets.only(right: dimensions.spacing.medium.width),
          child: GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 44.scale,
              height: 44.scale,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: colors.onLightBackground, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: colors.lightSurface,
                      size: 20.scale,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
