import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double? titleSpacing;

  const CustomAppBar({
    super.key,
    this.titleText,
    this.title,
    this.actions,
    this.leading,
    this.titleSpacing,
  }) : assert(
         titleText != null || title != null,
         'Either titleText or title must be provided',
       );

  @override
  Widget build(BuildContext context) {
    const typography = DueDayTheme.typography;
    final spacing = DueDayTheme.dimensions.spacing;

    final canPop = ModalRoute.of(context)?.canPop ?? false;

    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing:
          titleSpacing ?? (canPop ? 0 : spacing.largeExtraLarge.width),
      leading:
          leading ??
          (canPop
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: colorScheme.onSurface,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title:
          title ??
          Text(
            titleText!,
            style: typography.headline.small.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
