// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  paid: json['paid'] as bool,
  isRecurring: json['isRecurring'] as bool,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  category: json['category'] as String?,
  accountFrom: json['accountFrom'] as String?,
  accountTo: json['accountTo'] as String?,
  dueDate: const NullableTimestampConverter().fromJson(json['dueDate']),
  paidDate: const NullableTimestampConverter().fromJson(json['paidDate']),
  frequency: json['frequency'] as String?,
  notes: json['notes'] as String?,
  parentRecurringId: json['parentRecurringId'] as String?,
);

Map<String, dynamic> _$$TransactionModelImplToJson(
  _$TransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': instance.type,
  'amount': instance.amount,
  'paid': instance.paid,
  'isRecurring': instance.isRecurring,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'category': instance.category,
  'accountFrom': instance.accountFrom,
  'accountTo': instance.accountTo,
  'dueDate': const NullableTimestampConverter().toJson(instance.dueDate),
  'paidDate': const NullableTimestampConverter().toJson(instance.paidDate),
  'frequency': instance.frequency,
  'notes': instance.notes,
  'parentRecurringId': instance.parentRecurringId,
};
