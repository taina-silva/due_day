import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryLoadState extends Equatable {
  const CategoryLoadState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryLoadState {}

class CategoryLoading extends CategoryLoadState {}

class CategoryLoaded extends CategoryLoadState {
  final List<CategoryEntity> categories;

  const CategoryLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

class CategoryError extends CategoryLoadState {
  final Failure failure;

  const CategoryError({required this.failure});

  @override
  List<Object> get props => [failure];
}
