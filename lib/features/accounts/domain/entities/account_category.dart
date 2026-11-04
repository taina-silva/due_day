import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Where money is spent from (ACC-001). Legacy stored values
/// (`investments`, `savings`, `daily_use`, unknown) read as [checking]
/// (ACC-002) through `unknownEnumValue` on the model field.
enum AccountCategory {
  @JsonValue('checking')
  checking,
  @JsonValue('credit_card')
  creditCard,
  @JsonValue('cash')
  cash;

  bool get hasDueDay => this == AccountCategory.creditCard;

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case AccountCategory.checking:
        return l10n.accountsCategoryChecking;
      case AccountCategory.creditCard:
        return l10n.accountsCategoryCreditCard;
      case AccountCategory.cash:
        return l10n.accountsCategoryCash;
    }
  }

  IconData get icon {
    switch (this) {
      case AccountCategory.checking:
        return Icons.account_balance_rounded;
      case AccountCategory.creditCard:
        return Icons.credit_card_rounded;
      case AccountCategory.cash:
        return Icons.payments_rounded;
    }
  }
}
