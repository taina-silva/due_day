import 'package:due_day/core/utils/converters/timestamp_converter.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    required String userId,
    required String type,
    required double amount,
    required bool paid,
    required bool isRecurring,
    @TimestampConverter() required DateTime createdAt,
    String? category,
    String? accountFrom,
    String? accountTo,
    @NullableTimestampConverter() DateTime? dueDate,
    @NullableTimestampConverter() DateTime? paidDate,
    String? frequency,
    String? notes,
    String? parentRecurringId,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type.name,
      amount: entity.amount,
      category: entity.category,
      accountFrom: entity.accountFrom,
      accountTo: entity.accountTo,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      paid: entity.paid,
      isRecurring: entity.isRecurring,
      frequency: entity.frequency.name,
      notes: entity.notes,
      parentRecurringId: entity.parentRecurringId,
      createdAt: entity.createdAt,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      type: TransactionType.fromString(type),
      amount: amount,
      category: category,
      accountFrom: accountFrom,
      accountTo: accountTo,
      dueDate: dueDate,
      paidDate: paidDate,
      paid: paid,
      isRecurring: isRecurring,
      frequency: TransactionFrequency.fromString(frequency),
      notes: notes,
      parentRecurringId: parentRecurringId,
      createdAt: createdAt,
    );
  }
}
