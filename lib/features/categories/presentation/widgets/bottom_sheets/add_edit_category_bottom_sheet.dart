import 'package:due_day/core/design_system/components/form_fields/app_text_field.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/core/utils/validators/validators.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/utils/category_utils.dart';
import 'package:due_day/features/categories/presentation/widgets/bottom_sheets/parts/category_form_actions.dart';
import 'package:due_day/features/categories/presentation/widgets/bottom_sheets/parts/category_form_header.dart';
import 'package:due_day/features/categories/presentation/widgets/bottom_sheets/parts/category_section_title.dart';
import 'package:due_day/features/categories/presentation/widgets/form/category_color_selector.dart';
import 'package:due_day/features/categories/presentation/widgets/form/category_icon_selector.dart';
import 'package:flutter/material.dart';

class AddEditCategoryBottomSheet extends StatefulWidget {
  final CategoryEntity? category;
  final void Function(String name, String icon, String color) onSave;

  const AddEditCategoryBottomSheet({
    required this.onSave,
    super.key,
    this.category,
  });

  @override
  State<AddEditCategoryBottomSheet> createState() =>
      _AddEditCategoryBottomSheetState();
}

class _AddEditCategoryBottomSheetState
    extends State<AddEditCategoryBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late IconData _selectedIcon;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category?.name ?? '');

    if (widget.category != null) {
      _selectedIcon = CategoryIconUtils.parseIcon(widget.category!.icon);
      _selectedColor = CategoryColorUtils.parseColor(
        widget.category!.color,
        CategoryColorUtils.availableColors.first,
      );
    } else {
      _selectedIcon = CategoryIconUtils.availableIcons.first;
      _selectedColor = CategoryColorUtils.availableColors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = context.dimensions;
    final l10n = AppLocalizations.of(context);

    final isEditing = widget.category != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: dimensions.spacing.medium.width,
        right: dimensions.spacing.medium.width,
        top: dimensions.spacing.large.height,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategoryFormHeader(
              title: isEditing
                  ? l10n.categoriesEditCategory
                  : l10n.categoriesNewCategory,
              onClose: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: dimensions.spacing.extraLarge.height),
            AppTextField(
              controller: _nameController,
              label: l10n.categoriesNameLabel,
              hintText: l10n.categoriesNameHint,
              prefixIcon: Icons.label_outline_rounded,
              validator: Validators.requiredField(l10n),
            ),
            SizedBox(height: dimensions.spacing.extraLarge.height),
            CategorySectionTitle(title: l10n.categoriesSelectIcon),
            SizedBox(height: dimensions.spacing.medium.height),
            CategoryIconSelector(
              selectedIcon: _selectedIcon,
              selectedColor: _selectedColor,
              onIconSelected: (icon) => setState(() => _selectedIcon = icon),
            ),
            SizedBox(height: dimensions.spacing.extraLarge.height),
            CategorySectionTitle(title: l10n.categoriesSelectColor),
            SizedBox(height: dimensions.spacing.medium.height),
            CategoryColorSelector(
              selectedColor: _selectedColor,
              onColorSelected: (color) =>
                  setState(() => _selectedColor = color),
            ),
            SizedBox(height: dimensions.spacing.extraLarge.height),
            CategoryFormActions(
              onCancel: () => Navigator.of(context).pop(),
              onSave: _submit,
            ),
            SizedBox(height: dimensions.spacing.large.height),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _nameController.text.trim(),
        CategoryIconUtils.encode(_selectedIcon),
        CategoryColorUtils.encode(_selectedColor),
      );
      Navigator.of(context).pop();
    }
  }
}
