import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/default_category_names.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryLoadEvent extends Equatable {
  const CategoryLoadEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryLoadEvent {
  /// When given, the first loaded list is passed to `EnsureCategories`
  /// with these localized names (CAT-002, CAT-004).
  final DefaultCategoryNames? defaultNames;

  const LoadCategories({this.defaultNames});

  @override
  List<Object> get props => [?defaultNames];
}

class CategoriesUpdated extends CategoryLoadEvent {
  final List<CategoryEntity> categories;
  const CategoriesUpdated(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoryLoadFailed extends CategoryLoadEvent {
  final Failure failure;
  const CategoryLoadFailed(this.failure);

  @override
  List<Object> get props => [failure];
}
