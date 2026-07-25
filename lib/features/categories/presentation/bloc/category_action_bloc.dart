import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryActionBloc extends Bloc<CategoryActionEvent, CategoryActionState> {
  final AddCategory addCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  CategoryActionBloc({
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(CategoryActionInitial()) {
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryActionState> emit,
  ) async {
    emit(CategoryActionInProgress());
    final result = await addCategory(event.category);
    result.fold(
      (failure) => emit(CategoryActionError(failure: failure)),
      (_) => emit(CategoryActionSuccess()),
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryActionState> emit,
  ) async {
    emit(CategoryActionInProgress());
    final result = await updateCategory(event.category);
    result.fold(
      (failure) => emit(CategoryActionError(failure: failure)),
      (_) => emit(CategoryActionSuccess()),
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryActionState> emit,
  ) async {
    emit(CategoryActionInProgress());
    final result = await deleteCategory(event.categoryId);
    result.fold(
      (failure) => emit(CategoryActionError(failure: failure)),
      (_) => emit(CategoryActionSuccess()),
    );
  }
}
