import 'package:due_day/core/utils/converters/timestamp_converter.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String uid,
    required String email,
    @TimestampConverter() required DateTime createdAt,
    String? name,
    String? photoUrl,
    String? themePreference,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      themePreference: entity.themePreference,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      name: name,
      photoUrl: photoUrl,
      createdAt: createdAt,
      themePreference: themePreference,
    );
  }
}
