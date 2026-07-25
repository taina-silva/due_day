import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryActionEvent extends Equatable {
  const CategoryActionEvent();

  @override
  List<Object> get props => [];
}

class AddCategoryEvent extends CategoryActionEvent {
  final CategoryEntity category;
  const AddCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class UpdateCategoryEvent extends CategoryActionEvent {
  final CategoryEntity category;
  const UpdateCategoryEvent(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategoryEvent extends CategoryActionEvent {
  final String categoryId;
  const DeleteCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}
