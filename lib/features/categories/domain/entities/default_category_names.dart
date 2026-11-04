import 'package:equatable/equatable.dart';

/// Localized names for the default categories created on first use
/// (CAT-004). Built in the presentation layer from `AppLocalizations`, so
/// the domain never reads l10n itself.
class DefaultCategoryNames extends Equatable {
  final String food;
  final String groceries;
  final String transport;
  final String housing;
  final String bills;
  final String health;
  final String leisure;
  final String shopping;
  final String subscriptions;
  final String education;
  final String other;
  final String salary;
  final String otherIncome;

  const DefaultCategoryNames({
    required this.food,
    required this.groceries,
    required this.transport,
    required this.housing,
    required this.bills,
    required this.health,
    required this.leisure,
    required this.shopping,
    required this.subscriptions,
    required this.education,
    required this.other,
    required this.salary,
    required this.otherIncome,
  });

  @override
  List<Object?> get props => [
    food,
    groceries,
    transport,
    housing,
    bills,
    health,
    leisure,
    shopping,
    subscriptions,
    education,
    other,
    salary,
    otherIncome,
  ];
}
