import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/features/accounts/data/models/account_model.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  group('AccountModel Tests', () {
    test('should return a valid AccountModel from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'account-1',
        'userId': 'user-1',
        'name': 'Checking Account',
        'category': 'checking',
        'createdAt': Timestamp.fromDate(tDateTime),
        'dueDay': null,
        'deletedAt': null,
      };

      // Act
      final result = AccountModel.fromJson(jsonMap);

      // Assert
      expect(result, tAccountModel);
    });

    test('should return a JSON map containing the correct data', () {
      // Arrange
      final model = AccountModel(
        id: 'account-1',
        userId: 'user-1',
        name: 'Checking Account',
        category: AccountCategory.checking,
        createdAt: tDateTime,
      );

      // Act
      final result = model.toJson();

      // Assert
      expect(result['id'], 'account-1');
      expect(result['userId'], 'user-1');
      expect(result['name'], 'Checking Account');
      expect(result['category'], 'checking');
      expect(result.containsKey('balance'), isFalse);
    });

    for (final legacy in ['investments', 'savings', 'daily_use', 'unknown']) {
      test('ACC-002: stored type "$legacy" loads as checking', () {
        final result = AccountModel.fromJson({
          'id': 'account-1',
          'userId': 'user-1',
          'name': 'Old account',
          'category': legacy,
          'createdAt': Timestamp.fromDate(tDateTime),
        });

        expect(result.category, AccountCategory.checking);
      });
    }

    test('ACC-003: a stored balance is ignored on read and not written', () {
      final result = AccountModel.fromJson({
        'id': 'account-1',
        'userId': 'user-1',
        'name': 'Checking Account',
        'category': 'checking',
        'balance': 1500.0,
        'createdAt': Timestamp.fromDate(tDateTime),
      });

      expect(result, tAccountModel);
      expect(result.toJson().containsKey('balance'), isFalse);
    });

    test('ACC-001: cash type round-trips', () {
      final result = AccountModel.fromJson({
        'id': 'account-1',
        'userId': 'user-1',
        'name': 'Wallet',
        'category': 'cash',
        'createdAt': Timestamp.fromDate(tDateTime),
      });

      expect(result.category, AccountCategory.cash);
      expect(result.toJson()['category'], 'cash');
    });

    test('should map properly fromEntity and toEntity', () {
      // Act & Assert
      final modelFromEntity = AccountModel.fromEntity(tAccountEntity);
      expect(modelFromEntity, tAccountModel);

      final entityFromModel = tAccountModel.toEntity();
      expect(entityFromModel, tAccountEntity);
    });

    test('should support credit card category and dueDay mapping', () {
      // Act & Assert
      final modelFromEntity = AccountModel.fromEntity(tCreditCardAccountEntity);
      expect(modelFromEntity, tCreditCardAccountModel);

      final entityFromModel = tCreditCardAccountModel.toEntity();
      expect(entityFromModel, tCreditCardAccountEntity);
      expect(entityFromModel.dueDay, 15);
      expect(entityFromModel.category, AccountCategory.creditCard);
    });
  });
}
