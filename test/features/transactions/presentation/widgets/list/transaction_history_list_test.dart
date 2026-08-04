import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/app_constants.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/list/transaction_history_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestableWidgetWith(List<TransactionEntity> txs) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: TransactionHistoryList(transactions: txs, categories: const []),
      ),
    );
  }

  TransactionEntity buildTransaction({
    required String id,
    required String notes,
    required DateTime createdAt,
    DateTime? dueDate,
  }) {
    return TransactionEntity(
      id: id,
      userId: 'user-1',
      type: TransactionType.expense,
      amount: 10.0,
      paid: true,
      isRecurring: false,
      notes: notes,
      dueDate: dueDate,
      createdAt: createdAt,
    );
  }

  group('TransactionHistoryList Pagination Widget Tests', () {
    // All 30 days apart from a base far in the past, so every one lands in
    // the same "Past" bucket and section-header logic doesn't interfere.
    final baseDate = DateTime(2026, 1, 31);
    final transactions = List.generate(30, (i) {
      return buildTransaction(
        id: 'tx-$i',
        notes: 'Item $i',
        createdAt: baseDate.subtract(Duration(days: i)),
      );
    });

    testWidgets(
      'given more than one page of transactions when the list first renders '
      'then only the first page is shown',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(buildTestableWidgetWith(transactions));
        await tester.pumpAndSettle();

        expect(find.text('Item 0'), findsOneWidget);
        // "Item 24" belongs to the 25th most-recent transaction, past the
        // first page (20 items), so it should not be built yet.
        expect(find.text('Item 24'), findsNothing);
      },
    );

    testWidgets(
      'given the user scrolls near the bottom then the next page loads and '
      'the load-more indicator disappears once everything is loaded',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(buildTestableWidgetWith(transactions));
        await tester.pumpAndSettle();

        await tester.fling(find.byType(ListView), const Offset(0, -5000), 3000);
        await tester.pumpAndSettle();

        expect(find.text('Item 24'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  group('TransactionHistoryList Section Grouping Widget Tests', () {
    testWidgets(
      'given a transaction recorded today but due far in the future then it '
      'is grouped under Upcoming instead of Today',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();
        final futureDueDate = DateTime(now.year, now.month, now.day + 8);

        final transaction = buildTransaction(
          id: 'future-tx',
          notes: 'Future bill',
          dueDate: futureDueDate,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestableWidgetWith([transaction]));
        await tester.pumpAndSettle();

        expect(find.text('TODAY'), findsNothing);
        expect(find.text('UPCOMING'), findsOneWidget);
      },
    );

    testWidgets(
      'given a transaction due tomorrow then it is also grouped under '
      'Upcoming',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1);

        final transaction = buildTransaction(
          id: 'tomorrow-tx',
          notes: 'Due tomorrow',
          dueDate: tomorrow,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestableWidgetWith([transaction]));
        await tester.pumpAndSettle();

        expect(find.text('UPCOMING'), findsOneWidget);
      },
    );

    testWidgets(
      'given a transaction with no due date then it falls back to its '
      'creation date and is grouped under Today',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();

        final transaction = buildTransaction(
          id: 'no-due-date-tx',
          notes: 'Recorded now',
          createdAt: now,
        );

        await tester.pumpWidget(buildTestableWidgetWith([transaction]));
        await tester.pumpAndSettle();

        expect(find.text('TODAY'), findsOneWidget);
      },
    );

    testWidgets(
      'given a transaction due 3 days ago then it is grouped under Last Week',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();
        final threeDaysAgo = DateTime(now.year, now.month, now.day - 3);

        final transaction = buildTransaction(
          id: 'last-week-tx',
          notes: 'A few days ago',
          dueDate: threeDaysAgo,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestableWidgetWith([transaction]));
        await tester.pumpAndSettle();

        expect(find.text('LAST WEEK'), findsOneWidget);
      },
    );

    testWidgets(
      'given a transaction due 15 days ago then it is grouped under Last '
      'Month',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();
        final fifteenDaysAgo = DateTime(now.year, now.month, now.day - 15);

        final transaction = buildTransaction(
          id: 'last-month-tx',
          notes: 'Two weeks ago',
          dueDate: fifteenDaysAgo,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestableWidgetWith([transaction]));
        await tester.pumpAndSettle();

        expect(find.text('LAST MONTH'), findsOneWidget);
      },
    );

    testWidgets(
      'given a transaction due 40 days ago then it is grouped under Past',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();
        final fortyDaysAgo = DateTime(now.year, now.month, now.day - 40);

        final transaction = buildTransaction(
          id: 'past-tx',
          notes: 'Over a month ago',
          dueDate: fortyDaysAgo,
          createdAt: now,
        );

        await tester.pumpWidget(buildTestableWidgetWith([transaction]));
        await tester.pumpAndSettle();

        expect(find.text('PAST'), findsOneWidget);
      },
    );

    testWidgets(
      'given transactions across every section then headers render in the '
      'Upcoming, Today, Last Week, Last Month, Past order',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();

        final transactions = [
          buildTransaction(
            id: 'past',
            notes: 'Past item',
            dueDate: DateTime(now.year, now.month, now.day - 40),
            createdAt: now,
          ),
          buildTransaction(
            id: 'upcoming',
            notes: 'Upcoming item',
            dueDate: DateTime(now.year, now.month, now.day + 8),
            createdAt: now,
          ),
          buildTransaction(id: 'today', notes: 'Today item', createdAt: now),
          buildTransaction(
            id: 'last-month',
            notes: 'Last month item',
            dueDate: DateTime(now.year, now.month, now.day - 15),
            createdAt: now,
          ),
          buildTransaction(
            id: 'last-week',
            notes: 'Last week item',
            dueDate: DateTime(now.year, now.month, now.day - 3),
            createdAt: now,
          ),
        ];

        await tester.pumpWidget(buildTestableWidgetWith(transactions));
        await tester.pumpAndSettle();

        final headerOrder = [
          'UPCOMING',
          'TODAY',
          'LAST WEEK',
          'LAST MONTH',
          'PAST',
        ];
        final positions = headerOrder
            .map((label) => tester.getTopLeft(find.text(label)).dy)
            .toList();

        for (var i = 0; i < positions.length - 1; i++) {
          expect(
            positions[i],
            lessThan(positions[i + 1]),
            reason:
                '${headerOrder[i]} should render above ${headerOrder[i + 1]}',
          );
        }
      },
    );

    testWidgets(
      'given two upcoming transactions then Upcoming sorts soonest-first '
      'while other sections keep most-recent-first',
      (tester) async {
        setupTestWindow(tester);
        final now = DateTime.now();

        final soonUpcoming = buildTransaction(
          id: 'soon',
          notes: 'Soon',
          dueDate: DateTime(now.year, now.month, now.day + 2),
          createdAt: now,
        );
        final laterUpcoming = buildTransaction(
          id: 'later',
          notes: 'Later',
          dueDate: DateTime(now.year, now.month, now.day + 10),
          createdAt: now,
        );

        await tester.pumpWidget(
          buildTestableWidgetWith([laterUpcoming, soonUpcoming]),
        );
        await tester.pumpAndSettle();

        final soonY = tester.getTopLeft(find.text('Soon')).dy;
        final laterY = tester.getTopLeft(find.text('Later')).dy;

        expect(soonY, lessThan(laterY));
      },
    );
  });

  group('TransactionHistoryList Floating Bottom Nav Overlap', () {
    testWidgets(
      'given the floating bottom nav overlays the page when scrolled to the '
      'bottom then the last transaction stays fully above it',
      (tester) async {
        // A shorter viewport forces the content to overflow and scroll,
        // which is what exposes the floating bottom nav overlap.
        tester.view.physicalSize = const Size(390, 500);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final now = DateTime.now();
        final transactions = List.generate(10, (i) {
          return buildTransaction(
            id: 'tx-$i',
            notes: 'Bucket Item $i',
            createdAt: now,
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: Stack(
                children: [
                  TransactionHistoryList(
                    transactions: transactions,
                    categories: const [],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      key: const Key('fake_floating_bottom_nav'),
                      height: AppConstants.bottomNavHeight,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.fling(find.byType(ListView), const Offset(0, -3000), 3000);
        await tester.pumpAndSettle();

        final lastItemRect = tester.getRect(find.text('Bucket Item 9'));
        final navRect = tester.getRect(
          find.byKey(const Key('fake_floating_bottom_nav')),
        );

        expect(lastItemRect.bottom, lessThanOrEqualTo(navRect.top));
      },
    );
  });
}
