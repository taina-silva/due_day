import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String color;
  final String icon;
  final DateTime createdAt;
  final int transactionCount;

  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.icon,
    required this.createdAt,
    this.transactionCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    color,
    icon,
    createdAt,
    transactionCount,
  ];
}
