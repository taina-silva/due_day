import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/presentation/widgets/import_review_item_tile.dart';
import 'package:flutter/material.dart';

class ImportReviewList extends StatelessWidget {
  final List<ImportReviewItem> items;
  final void Function(int index) onToggleSelected;
  final void Function(int index) onTapCategory;

  const ImportReviewList({
    required this.items,
    required this.onToggleSelected,
    required this.onTapCategory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    final newIndices = <int>[];
    final duplicateIndices = <int>[];
    for (var i = 0; i < items.length; i++) {
      if (items[i].status == ImportReviewStatus.alreadyImported) {
        duplicateIndices.add(i);
      } else {
        newIndices.add(i);
      }
    }

    return ListView(
      padding: EdgeInsets.all(spacing.medium.width),
      children: [
        Text(
          l10n.statementImportSectionNew(newIndices.length),
          style: typography.title.small.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: spacing.small.height),
        for (final index in newIndices)
          ImportReviewItemTile(
            key: ValueKey('new_$index'),
            item: items[index],
            onToggleSelected: () => onToggleSelected(index),
            onTapCategory: () => onTapCategory(index),
          ),
        if (duplicateIndices.isNotEmpty) ...[
          SizedBox(height: spacing.medium.height),
          Text(
            l10n.statementImportSectionDuplicate(duplicateIndices.length),
            style: typography.title.small.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: spacing.small.height),
          for (final index in duplicateIndices)
            ImportReviewItemTile(key: ValueKey('dup_$index'), item: items[index]),
        ],
      ],
    );
  }
}
