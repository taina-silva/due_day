import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/widgets/list/category_card.dart';
import 'package:due_day/features/categories/presentation/widgets/list/category_hero_card.dart';
import 'package:flutter/material.dart';

class CategoryListContent extends StatelessWidget {
  final List<CategoryEntity> categories;
  final bool isSelectionMode;
  final VoidCallback onAddCategory;
  final Function(CategoryEntity) onCategoryTap;

  const CategoryListContent({
    required this.categories,
    required this.onAddCategory,
    required this.onCategoryTap,
    super.key,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.largeExtraLarge.width,
        spacing.medium.height,
        spacing.largeExtraLarge.width,
        spacing.safeBottomNav.height,
      ),
      children: [
        // Hero card (first category)
        if (categories.isNotEmpty) ...[
          CategoryHeroCard(
            category: categories.first,
            transactionCount: categories.first.transactionCount,
            mostActiveLabel: l10n.categoriesMostActive,
            transactionLabel: l10n.categoriesTransactionCount(
              categories.first.transactionCount,
            ),
          ),
          SizedBox(height: spacing.large.height),
        ],

        // + New Category button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppTextButtonPrimary(
              label: l10n.categoriesNewCategory,
              prefixIcon: Icons.add,
              onPressed: onAddCategory,
            ),
          ],
        ),
        SizedBox(height: spacing.extraLarge.height),

        // Empty state
        if (categories.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.extraLarge.height),
            child: Center(
              child: Text(
                l10n.categoriesEmpty,
                style: typography.body.medium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

        // Category list
        ...categories.map(
          (c) => Padding(
            padding: EdgeInsets.only(bottom: spacing.smallMedium.height),
            child: CategoryCard(
              category: c,
              transactionCount: c.transactionCount,
              transactionLabel: l10n.categoriesTransactionCount(
                c.transactionCount,
              ),
              onTap: () => onCategoryTap(c),
            ),
          ),
        ),
      ],
    );
  }
}
