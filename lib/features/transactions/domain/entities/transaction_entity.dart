import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense,
  transfer;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

enum TransactionFrequency {
  none,
  weekly,
  biWeekly,
  monthly,
  yearly;

  static TransactionFrequency fromString(String? value) {
    return TransactionFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionFrequency.none,
    );
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double
  amount; // Always positive. Impact on balance depends on transaction type.
  final String? category; // reference to categoryId (if income/expense)
  final String? accountFrom; // accountId (if expense or transfer)
  final String? accountTo; // accountId (if income or transfer)
  final DateTime? dueDate;
  final DateTime? paidDate;
  final bool paid;
  final bool isRecurring;
  final TransactionFrequency frequency;
  final String? notes;
  final String? parentRecurringId;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.paid,
    required this.isRecurring,
    required this.createdAt,
    this.category,
    this.accountFrom,
    this.accountTo,
    this.dueDate,
    this.paidDate,
    this.frequency = TransactionFrequency.none,
    this.notes,
    this.parentRecurringId,
  });

  TransactionEntity copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? category,
    String? accountFrom,
    String? accountTo,
    DateTime? dueDate,
    DateTime? paidDate,
    bool? paid,
    bool? isRecurring,
    TransactionFrequency? frequency,
    String? notes,
    String? parentRecurringId,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      accountFrom: accountFrom ?? this.accountFrom,
      accountTo: accountTo ?? this.accountTo,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      paid: paid ?? this.paid,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      notes: notes ?? this.notes,
      parentRecurringId: parentRecurringId ?? this.parentRecurringId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    amount,
    category,
    accountFrom,
    accountTo,
    dueDate,
    paidDate,
    paid,
    isRecurring,
    frequency,
    notes,
    parentRecurringId,
    createdAt,
  ];
}
