// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountModelImpl _$$AccountModelImplFromJson(Map<String, dynamic> json) =>
    _$AccountModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$AccountCategoryEnumMap, json['category']),
      balance: (json['balance'] as num).toDouble(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      dueDay: (json['dueDay'] as num?)?.toInt(),
      deletedAt: const NullableTimestampConverter().fromJson(json['deletedAt']),
    );

Map<String, dynamic> _$$AccountModelImplToJson(
  _$AccountModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'category': _$AccountCategoryEnumMap[instance.category]!,
  'balance': instance.balance,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'dueDay': instance.dueDay,
  'deletedAt': const NullableTimestampConverter().toJson(instance.deletedAt),
};

const _$AccountCategoryEnumMap = {
  AccountCategory.investments: 'investments',
  AccountCategory.savings: 'savings',
  AccountCategory.dailyUse: 'daily_use',
};
