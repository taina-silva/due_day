import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/filter/transaction_filter_bar.dart';
import 'package:due_day/features/transactions/presentation/widgets/form/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );

  testWidgets('TRX-001: the type selector offers only Income and Expense', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TransactionTypeSelector(
          selectedType: TransactionType.expense,
          onTypeChanged: (_) {},
        ),
      ),
    );

    expect(find.text('EXPENSE'), findsOneWidget);
    expect(find.text('INCOME'), findsOneWidget);
    expect(
      find.textContaining(RegExp('transfer', caseSensitive: false)),
      findsNothing,
    );
    expect(TransactionType.selectable, [
      TransactionType.income,
      TransactionType.expense,
    ]);
  });

  testWidgets('TRX-001: the history filter has no Transfer chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        TransactionFilterBar(
          selectedType: null,
          selectedCategoryId: null,
          selectedFrequency: null,
          startDate: null,
          endDate: null,
          categories: const [],
          onTypeChanged: (_) {},
          onCategoryTap: () {},
          onFrequencyTap: () {},
          onDateTap: () {},
          onOpenAdvancedFilters: () {},
        ),
      ),
    );

    expect(
      find.textContaining(RegExp('transfer', caseSensitive: false)),
      findsNothing,
    );
  });
}
