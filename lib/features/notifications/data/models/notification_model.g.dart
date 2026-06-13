// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationModelImpl _$$NotificationModelImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  timestamp: const TimestampConverter().fromJson(json['timestamp']),
  read: json['read'] as bool,
  isUrgent: json['isUrgent'] as bool,
  type: json['type'] as String,
);

Map<String, dynamic> _$$NotificationModelImplToJson(
  _$NotificationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'timestamp': const TimestampConverter().toJson(instance.timestamp),
  'read': instance.read,
  'isUrgent': instance.isUrgent,
  'type': instance.type,
};
