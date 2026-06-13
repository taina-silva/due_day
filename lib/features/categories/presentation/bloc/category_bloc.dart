import 'dart:async';

import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/categories/presentation/bloc/category_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AddCategory addCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final GetCategories getCategories;

  StreamSubscription? _categoriesSubscription;

  CategoryBloc({
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.getCategories,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<CategoriesUpdated>(_onCategoriesUpdated);
  }

  void _onLoadCategories(LoadCategories event, Emitter<CategoryState> emit) {
    emit(CategoryLoading());
    _categoriesSubscription?.cancel();
    _categoriesSubscription = getCategories().listen((result) {
      result.fold(
        (failure) => addError(failure.message),
        (categories) => add(CategoriesUpdated(categories)),
      );
    });
  }

  void _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoryState> emit,
  ) {
    final sortedCategories = List<CategoryEntity>.from(event.categories)
      ..sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
    emit(CategoryLoaded(categories: sortedCategories));
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await addCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await updateCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(message: failure.message)),
      (_) {},
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await deleteCategory(event.categoryId);
    result.fold(
      (failure) => emit(CategoryError(message: failure.message)),
      (_) {},
    );
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
