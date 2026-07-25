import 'dart:async';

import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryLoadBloc extends Bloc<CategoryLoadEvent, CategoryLoadState> {
  final GetCategories getCategories;

  StreamSubscription? _categoriesSubscription;

  CategoryLoadBloc({required this.getCategories}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<CategoryLoadFailed>(_onCategoryLoadFailed);
  }

  void _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryLoadState> emit,
  ) {
    emit(CategoryLoading());
    _categoriesSubscription?.cancel();
    _categoriesSubscription = getCategories().listen((result) {
      result.fold(
        (failure) => add(CategoryLoadFailed(failure)),
        (categories) => add(CategoriesUpdated(categories)),
      );
    });
  }

  void _onCategoryLoadFailed(
    CategoryLoadFailed event,
    Emitter<CategoryLoadState> emit,
  ) {
    emit(CategoryError(failure: event.failure));
  }

  void _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<CategoryLoadState> emit,
  ) {
    final sortedCategories = List<CategoryEntity>.from(event.categories)
      ..sort((a, b) => b.transactionCount.compareTo(a.transactionCount));
    emit(CategoryLoaded(categories: sortedCategories));
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
