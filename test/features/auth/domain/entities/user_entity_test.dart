import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tDateTime = DateTime(2026, 7, 7);

  final tUserEntity = UserEntity(
    uid: 'test-uid',
    email: 'test@example.com',
    name: 'Test User',
    photoUrl: 'https://example.com/photo.png',
    createdAt: tDateTime,
    themePreference: 'dark',
  );

  group('UserEntity', () {
    test(
      'given two UserEntity objects with identical values when compared then they should be equal',
      () {
        final userEntity2 = UserEntity(
          uid: 'test-uid',
          email: 'test@example.com',
          name: 'Test User',
          photoUrl: 'https://example.com/photo.png',
          createdAt: tDateTime,
          themePreference: 'dark',
        );

        expect(tUserEntity, equals(userEntity2));
      },
    );

    test(
      'given UserEntity when copyWith is called with new values then return a new instance with updated values',
      () {
        final updatedUser = tUserEntity.copyWith(
          name: 'New Name',
          themePreference: 'light',
        );

        expect(updatedUser.uid, equals(tUserEntity.uid));
        expect(updatedUser.email, equals(tUserEntity.email));
        expect(updatedUser.name, equals('New Name'));
        expect(updatedUser.photoUrl, equals(tUserEntity.photoUrl));
        expect(updatedUser.createdAt, equals(tUserEntity.createdAt));
        expect(updatedUser.themePreference, equals('light'));
      },
    );

    test(
      'given UserEntity when copyWith is called with null values then return a new instance with identical values',
      () {
        final copiedUser = tUserEntity.copyWith();

        expect(copiedUser, equals(tUserEntity));
      },
    );
  });
}
