import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final AccountCategory category;
  final double balance;
  final int? dueDay; // para faturas de cartão de crédito (dia 1-31)
  final DateTime createdAt;
  final DateTime? deletedAt;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.balance,
    required this.createdAt,
    this.dueDay,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    category,
    balance,
    dueDay,
    createdAt,
    deletedAt,
  ];
}
