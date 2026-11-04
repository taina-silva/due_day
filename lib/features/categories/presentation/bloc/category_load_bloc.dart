import 'dart:async';

import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/domain/entities/default_category_names.dart';
import 'package:due_day/features/categories/domain/usecases/category_usecases.dart';
import 'package:due_day/features/categories/domain/usecases/ensure_categories.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryLoadBloc extends Bloc<CategoryLoadEvent, CategoryLoadState> {
  final GetCategories getCategories;
  final EnsureCategories ensureCategories;

  StreamSubscription? _categoriesSubscription;

  /// Set by a [LoadCategories] carrying names; consumed by the first
  /// loaded list so `EnsureCategories` runs once per load (CAT-004).
  DefaultCategoryNames? _pendingEnsureNames;

  CategoryLoadBloc({
    required this.getCategories,
    required this.ensureCategories,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<CategoryLoadFailed>(_onCategoryLoadFailed);
  }

  void _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryLoadState> emit,
  ) {
    if (event.defaultNames != null) _pendingEnsureNames = event.defaultNames;
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

    // Seed after emitting and without awaiting: the batch commit only
    // completes on server ack, and the stream already delivers the created
    // categories. Awaiting here would re-emit this stale list afterwards.
    final names = _pendingEnsureNames;
    if (names != null) {
      _pendingEnsureNames = null;
      unawaited(ensureCategories(existing: event.categories, names: names));
    }
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }
}
