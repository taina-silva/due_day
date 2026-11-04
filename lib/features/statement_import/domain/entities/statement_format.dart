import 'package:due_day/features/accounts/domain/entities/account_category.dart';

/// Statement formats detected by content (IMP-003).
enum StatementFormat {
  /// Nubank checking account OFX.
  nubankOfx,

  /// Nubank checking account CSV (`Data,Valor,Identificador,Descrição`).
  checkingCsv,

  /// Nubank credit card bill CSV (`date,title,amount`).
  cardBillCsv;

  /// Account type listed first in the import account picker (IMP-004).
  AccountCategory get matchingAccountType => this == StatementFormat.cardBillCsv
      ? AccountCategory.creditCard
      : AccountCategory.checking;
}
