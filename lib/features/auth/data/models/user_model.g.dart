// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      name: json['name'] as String?,
      photoUrl: json['photoUrl'] as String?,
      themePreference: json['themePreference'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'themePreference': instance.themePreference,
    };
