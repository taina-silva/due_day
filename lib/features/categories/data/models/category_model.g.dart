// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    _CategoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      kind:
          $enumDecodeNullable(
            _$CategoryKindEnumMap,
            json['kind'],
            unknownValue: CategoryKind.spending,
          ) ??
          CategoryKind.spending,
    );

Map<String, dynamic> _$CategoryModelToJson(_CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'color': instance.color,
      'icon': instance.icon,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'transactionCount': instance.transactionCount,
      'kind': _$CategoryKindEnumMap[instance.kind]!,
    };

const _$CategoryKindEnumMap = {
  CategoryKind.spending: 'spending',
  CategoryKind.investment: 'investment',
  CategoryKind.ignored: 'ignored',
};
