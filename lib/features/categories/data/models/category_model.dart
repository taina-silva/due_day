import 'package:due_day/core/utils/converters/timestamp_converter.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const CategoryModel._();

  const factory CategoryModel({
    required String id,
    required String userId,
    required String name,
    required String color,
    required String icon,
    @TimestampConverter() required DateTime createdAt,
    @Default(0) int transactionCount,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      color: entity.color,
      icon: entity.icon,
      createdAt: entity.createdAt,
      transactionCount: entity.transactionCount,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      userId: userId,
      name: name,
      color: color,
      icon: icon,
      createdAt: createdAt,
      transactionCount: transactionCount,
    );
  }
}
