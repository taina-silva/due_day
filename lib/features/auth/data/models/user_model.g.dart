// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  name: json['name'] as String?,
  photoUrl: json['photoUrl'] as String?,
  themePreference: json['themePreference'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'name': instance.name,
      'photoUrl': instance.photoUrl,
      'themePreference': instance.themePreference,
    };
