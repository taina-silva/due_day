// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      icon: json['icon'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'color': instance.color,
      'icon': instance.icon,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'transactionCount': instance.transactionCount,
    };
