import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum AccountCategory {
  @JsonValue('investments')
  investments,
  @JsonValue('savings')
  savings,
  @JsonValue('daily_use')
  dailyUse;

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case AccountCategory.investments:
        return l10n.accountsCategoryInvestments;
      case AccountCategory.savings:
        return l10n.accountsCategorySavings;
      case AccountCategory.dailyUse:
        return l10n.accountsCategoryDailyUse;
    }
  }

  IconData get icon {
    switch (this) {
      case AccountCategory.investments:
        return Icons.trending_up_rounded;
      case AccountCategory.savings:
        return Icons.savings_rounded;
      case AccountCategory.dailyUse:
        return Icons.account_balance_wallet_rounded;
    }
  }
}
