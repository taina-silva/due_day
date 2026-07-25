import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/categories/presentation/utils/category_failure_extension.dart';
import 'package:due_day/features/categories/presentation/widgets/bottom_sheets/add_edit_category_bottom_sheet.dart';
import 'package:due_day/features/categories/presentation/widgets/list/category_list_content.dart';
import 'package:due_day/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class CategoriesPage extends StatelessWidget {
  final bool isSelectionMode;

  const CategoriesPage({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final l10n = AppLocalizations.of(context);

    return CustomScaffold(
      appBar: DashboardAppBar(titleText: l10n.categoriesTitle),
      body: SafeArea(
        child: BlocBuilder<CategoryLoadBloc, CategoryLoadState>(
          builder: (context, state) {
            if (state is CategoryLoading || state is CategoryInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryError) {
              return Center(
                child: Text(
                  state.failure.toLocalizedString(context),
                  style: typography.body.medium,
                ),
              );
            } else if (state is CategoryLoaded) {
              return CategoryListContent(
                categories: state.categories,
                isSelectionMode: isSelectionMode,
                onAddCategory: () => _showAddEditCategoryBottomSheet(context),
                onCategoryTap: (category) {
                  if (isSelectionMode) {
                    context.pop(category);
                  } else {
                    _showAddEditCategoryBottomSheet(context, category);
                  }
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showAddEditCategoryBottomSheet(
    BuildContext context, [
    CategoryEntity? category,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.radius.extraLarge),
        ),
      ),
      builder: (ctx) {
        return AddEditCategoryBottomSheet(
          category: category,
          onSave: (name, icon, color) {
            final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
            final categoryBloc = context.read<CategoryActionBloc>();

            if (category == null) {
              categoryBloc.add(
                AddCategoryEvent(
                  CategoryEntity(
                    id: const Uuid().v4(),
                    userId: userId,
                    name: name,
                    color: color,
                    icon: icon,
                    createdAt: DateTime.now(),
                  ),
                ),
              );
            } else {
              categoryBloc.add(
                UpdateCategoryEvent(
                  CategoryEntity(
                    id: category.id,
                    userId: category.userId,
                    name: name,
                    color: color,
                    icon: icon,
                    createdAt: category.createdAt,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
