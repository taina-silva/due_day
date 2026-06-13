import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

  String getLabel(BuildContext context) {
    return switch (this) {
      TransactionType.income => context.l10n.income,
      TransactionType.expense => context.l10n.expense,
      TransactionType.transfer => context.l10n.transfer,
    };
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

  String getLabel(BuildContext context) {
    return switch (this) {
      TransactionFrequency.none => context.l10n.transactionsFrequencyNone,
      TransactionFrequency.weekly => context.l10n.transactionsFrequencyWeekly,
      TransactionFrequency.biWeekly =>
        context.l10n.transactionsFrequencyBiWeekly,
      TransactionFrequency.monthly => context.l10n.transactionsFrequencyMonthly,
      TransactionFrequency.yearly => context.l10n.transactionsFrequencyYearly,
    };
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount; // Always positive. Impact on balance depends on transaction type.
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
