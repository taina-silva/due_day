import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:flutter/material.dart';

class CategoryIconSelector extends StatelessWidget {
  final IconData selectedIcon;
  final Color selectedColor;
  final ValueChanged<IconData> onIconSelected;

  const CategoryIconSelector({
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dimensions = context.dimensions;

    return Wrap(
      spacing: dimensions.spacing.medium.width,
      runSpacing: dimensions.spacing.medium.height,
      children: CategoryIconUtils.availableIcons.map((icon) {
        final isSelected = icon.codePoint == selectedIcon.codePoint;
        return GestureDetector(
          onTap: () => onIconSelected(icon),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withValues(alpha: 0.15)
                  : colors.lightSurface,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: selectedColor, width: 2)
                  : Border.all(
                      color: colors.resource.neutral.withValues(alpha: 0.15),
                    ),
            ),
            child: Icon(
              icon,
              size: 22.fontSize,
              color: isSelected ? selectedColor : colors.resource.neutral,
            ),
          ),
        );
      }).toList(),
    );
  }
}
