import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/list/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../helpers/transaction_test_helpers.dart';

void main() {
  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestableWidget({required TransactionItem child}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  group('TransactionItem Widget Tests', () {
    testWidgets(
      'given an unpaid transaction when rendered then the Pending badge is shown',
      (tester) async {
        setupTestWindow(tester);
        final transaction = tTransactionEntity.copyWith(paid: false);

        await tester.pumpWidget(
          buildTestableWidget(child: TransactionItem(transaction: transaction)),
        );
        await tester.pumpAndSettle();

        expect(find.text('PENDING'), findsOneWidget);
      },
    );

    testWidgets(
      'given a paid transaction when rendered then the Pending badge is not shown',
      (tester) async {
        setupTestWindow(tester);
        final transaction = tTransactionEntity.copyWith(paid: true);

        await tester.pumpWidget(
          buildTestableWidget(child: TransactionItem(transaction: transaction)),
        );
        await tester.pumpAndSettle();

        expect(find.text('PENDING'), findsNothing);
      },
    );

    testWidgets(
      'given a transaction with a due date when rendered then its real due '
      'date is shown',
      (tester) async {
        setupTestWindow(tester);
        final transaction = tTransactionEntity.copyWith(
          dueDate: DateTime(2026, 7, 7),
        );

        await tester.pumpWidget(
          buildTestableWidget(child: TransactionItem(transaction: transaction)),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(DateFormat.MMMd('en').format(DateTime(2026, 7, 7))),
          findsOneWidget,
        );
      },
    );

    testWidgets('given a transaction without a due date when rendered then its '
        'creation date is shown instead', (tester) async {
      setupTestWindow(tester);
      final createdAt = DateTime(2026, 3, 15);
      final transaction = TransactionEntity(
        id: tTransactionEntity.id,
        userId: tTransactionEntity.userId,
        type: tTransactionEntity.type,
        amount: tTransactionEntity.amount,
        paid: tTransactionEntity.paid,
        isRecurring: tTransactionEntity.isRecurring,
        createdAt: createdAt,
      );

      await tester.pumpWidget(
        buildTestableWidget(child: TransactionItem(transaction: transaction)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(DateFormat.MMMd('en').format(createdAt)),
        findsOneWidget,
      );
    });
  });
}
