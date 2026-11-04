import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/account_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/transaction_test_helpers.dart';

void main() {
  late MockAccountLoadBloc accountLoadBloc;

  final checking = AccountEntity(
    id: 'acc-checking',
    userId: 'user-1',
    name: 'Nubank',
    category: AccountCategory.checking,
    createdAt: DateTime(2026),
  );
  final card = AccountEntity(
    id: 'acc-card',
    userId: 'user-1',
    name: 'Nubank card',
    category: AccountCategory.creditCard,
    dueDay: 10,
    createdAt: DateTime(2026),
  );

  setUp(() {
    accountLoadBloc = MockAccountLoadBloc();
    when(
      () => accountLoadBloc.state,
    ).thenReturn(AccountLoaded(accounts: [checking, card]));
  });

  Future<void> pump(WidgetTester tester, AccountCategory? preferred) =>
      tester.pumpWidget(
        BlocProvider<AccountLoadBloc>.value(
          value: accountLoadBloc,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: AccountSelectionBottomSheet(preferredType: preferred),
            ),
          ),
        ),
      );

  double topOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  testWidgets('IMP-004: card bill → "Nubank card" is listed first', (
    tester,
  ) async {
    await pump(tester, StatementFormat.cardBillCsv.matchingAccountType);

    expect(topOf(tester, 'Nubank card'), lessThan(topOf(tester, 'Nubank')));
  });

  testWidgets('IMP-004: checking statement → checking first; others stay '
      'selectable', (tester) async {
    await pump(tester, StatementFormat.nubankOfx.matchingAccountType);

    expect(topOf(tester, 'Nubank'), lessThan(topOf(tester, 'Nubank card')));
    expect(find.text('Nubank card'), findsOneWidget);
  });

  test('IMP-004: matching account types', () {
    expect(
      StatementFormat.nubankOfx.matchingAccountType,
      AccountCategory.checking,
    );
    expect(
      StatementFormat.checkingCsv.matchingAccountType,
      AccountCategory.checking,
    );
    expect(
      StatementFormat.cardBillCsv.matchingAccountType,
      AccountCategory.creditCard,
    );
  });
}
