import 'package:due_day/features/auth/data/models/user_model.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tDateTime = DateTime(2026, 7, 7);

  final tUserModel = UserModel(
    uid: 'test-uid',
    email: 'test@example.com',
    name: 'Test User',
    photoUrl: 'https://example.com/photo.png',
    createdAt: tDateTime,
    themePreference: 'dark',
  );

  final tUserEntity = UserEntity(
    uid: 'test-uid',
    email: 'test@example.com',
    name: 'Test User',
    photoUrl: 'https://example.com/photo.png',
    createdAt: tDateTime,
    themePreference: 'dark',
  );

  final tJson = {
    'uid': 'test-uid',
    'email': 'test@example.com',
    'name': 'Test User',
    'photoUrl': 'https://example.com/photo.png',
    'createdAt': '2026-07-07T00:00:00.000',
    'themePreference': 'dark',
  };

  group('UserModel', () {
    test(
      'given valid json map when fromJson is called then return a valid UserModel',
      () {
        final result = UserModel.fromJson(tJson);
        expect(result, equals(tUserModel));
      },
    );

    test(
      'given UserModel object when toJson is called then return a valid json map',
      () {
        final result = tUserModel.toJson();
        expect(result, equals(tJson));
      },
    );

    test(
      'given UserEntity object when fromEntity is called then return a valid UserModel',
      () {
        final result = UserModel.fromEntity(tUserEntity);
        expect(result, equals(tUserModel));
      },
    );

    test(
      'given UserModel object when toEntity is called then return a valid UserEntity',
      () {
        final result = tUserModel.toEntity();
        expect(result, equals(tUserEntity));
      },
    );
  });
}
