import 'package:due_day/core/utils/converters/timestamp_converter.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_model.freezed.dart';
part 'account_model.g.dart';

@freezed
class AccountModel with _$AccountModel {
  const AccountModel._();

  const factory AccountModel({
    required String id,
    required String userId,
    required String name,
    required AccountCategory category,
    required double balance,
    @TimestampConverter() required DateTime createdAt,
    int? dueDay,
    @NullableTimestampConverter() DateTime? deletedAt,
  }) = _AccountModel;

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  factory AccountModel.fromEntity(AccountEntity entity) {
    return AccountModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      category: entity.category,
      balance: entity.balance,
      dueDay: entity.dueDay,
      createdAt: entity.createdAt,
      deletedAt: entity.deletedAt,
    );
  }

  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      userId: userId,
      name: name,
      category: category,
      balance: balance,
      dueDay: dueDay,
      createdAt: createdAt,
      deletedAt: deletedAt,
    );
  }
}
