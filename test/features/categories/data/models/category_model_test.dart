import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:due_day/features/categories/data/models/category_model.dart';
import 'package:due_day/features/categories/domain/entities/category_kind.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/category_test_helpers.dart';

void main() {
  Map<String, dynamic> json({Object? kind}) => {
    'id': 'category-1',
    'userId': 'user-1',
    'name': 'Food',
    'color': '#4361EE',
    'icon': '0xe57a',
    'createdAt': Timestamp.fromDate(tDateTime),
    'transactionCount': 5,
    'kind': ?kind,
  };

  group('CategoryModel', () {
    test('CAT-001: a legacy category without kind is spending', () {
      final result = CategoryModel.fromJson(json());

      expect(result.kind, CategoryKind.spending);
      expect(result.toEntity(), tCategoryEntity);
    });

    test('CAT-001: an unknown kind reads as spending', () {
      expect(
        CategoryModel.fromJson(json(kind: 'weird')).kind,
        CategoryKind.spending,
      );
    });

    test('kind round-trips through JSON and entity', () {
      final model = CategoryModel.fromJson(json(kind: 'investment'));

      expect(model.kind, CategoryKind.investment);
      expect(model.toJson()['kind'], 'investment');
      expect(
        CategoryModel.fromEntity(model.toEntity()).kind,
        CategoryKind.investment,
      );
    });
  });
}
