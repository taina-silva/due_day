import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/features/categories/presentation/bloc/category_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_state.dart';
import 'package:due_day/features/categories/presentation/utils/category_failure_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySelectionBottomSheet extends StatelessWidget {
  final String? selectedCategoryId;
  final bool showAllOption;

  const CategorySelectionBottomSheet({
    super.key,
    this.selectedCategoryId,
    this.showAllOption = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: EdgeInsets.only(
        top: spacing.medium,
        left: spacing.medium,
        right: spacing.medium,
        bottom: MediaQuery.of(context).padding.bottom + spacing.medium,
      ),
      decoration: BoxDecoration(
        color: colors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.resource.neutral.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: spacing.medium),
          Text(
            l10n.categoriesTitle,
            style: typography.title.medium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.medium),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading || state is CategoryInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryError) {
                  return Center(
                    child: Text(state.failure.toLocalizedString(context)),
                  );
                } else if (state is CategoryLoaded) {
                  final categories = state.categories;

                  return ListView(
                    shrinkWrap: true,
                    children: [
                      if (showAllOption)
                        _CategoryItem(
                          name: l10n.all,
                          color: colors.resource.secondary,
                          isSelected: selectedCategoryId == null,
                          onTap: () => Navigator.pop(context, null),
                        ),
                      ...categories.map((c) {
                        Color parsedColor = colors.resource.primary;
                        try {
                          parsedColor = Color(
                            int.parse(c.color.replaceAll('#', '0xff')),
                          );
                        } catch (_) {}

                        return _CategoryItem(
                          name: c.name,
                          color: parsedColor,
                          isSelected: selectedCategoryId == c.id,
                          onTap: () => Navigator.pop(context, c),
                        );
                      }),
                      if (categories.isEmpty && !showAllOption)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(spacing.large),
                            child: Text(
                              l10n.categoriesEmpty,
                              style: typography.body.medium,
                            ),
                          ),
                        ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.name,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final typography = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: spacing.small),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.medium,
          vertical: spacing.medium,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colors.lightSurface,
          borderRadius: BorderRadius.circular(radius.medium),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(spacing.small),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.category_rounded, color: color, size: 20),
            ),
            SizedBox(width: spacing.medium),
            Expanded(
              child: Text(
                name,
                style: typography.body.medium.copyWith(
                  color: colors.onLightBackground,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
