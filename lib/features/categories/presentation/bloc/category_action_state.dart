import 'package:due_day/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class CategoryActionState extends Equatable {
  const CategoryActionState();

  @override
  List<Object> get props => [];
}

class CategoryActionInitial extends CategoryActionState {}

class CategoryActionInProgress extends CategoryActionState {}

class CategoryActionSuccess extends CategoryActionState {}

class CategoryActionError extends CategoryActionState {
  final Failure failure;

  const CategoryActionError({required this.failure});

  @override
  List<Object> get props => [failure];
}
