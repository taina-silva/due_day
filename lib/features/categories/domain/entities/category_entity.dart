import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:due_day/features/categories/domain/entities/system_categories.dart';
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String color;
  final String icon;
  final DateTime createdAt;
  final int transactionCount;
  final CategoryKind kind;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.icon,
    required this.createdAt,
    this.transactionCount = 0,
    this.kind = CategoryKind.spending,
  });

  /// *Investment* and *Ignored* (CAT-002): can't be renamed or deleted.
  bool get isSystem => SystemCategories.isSystemId(id);

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    color,
    icon,
    createdAt,
    transactionCount,
    kind,
  ];
}
