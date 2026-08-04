import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_action_state.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/transaction_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/transaction_test_helpers.dart';

class FakeTransactionActionEvent extends Fake
    implements TransactionActionEvent {}

void main() {
  late MockTransactionActionBloc mockTransactionActionBloc;
  late MockAccountLoadBloc mockAccountLoadBloc;
  late MockCategoryLoadBloc mockCategoryLoadBloc;
  late StreamController<TransactionActionState> actionStateController;

  // The action buttons are sized to fit the real "Sofia Sans" font. Without
  // loading it, the test font fallback renders wider glyphs and trips a
  // false RenderFlex overflow on the button row.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeTransactionActionEvent());

    final fontLoader = FontLoader('Sofia Sans')
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-Bold.ttf'));
    await fontLoader.load();
  });

  setUp(() {
    mockTransactionActionBloc = MockTransactionActionBloc();
    mockAccountLoadBloc = MockAccountLoadBloc();
    mockCategoryLoadBloc = MockCategoryLoadBloc();

    when(
      () => mockTransactionActionBloc.state,
    ).thenReturn(TransactionActionInitial());
    when(
      () => mockTransactionActionBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockAccountLoadBloc.state,
    ).thenReturn(AccountLoaded(accounts: [tAccountEntity]));
    when(
      () => mockAccountLoadBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockCategoryLoadBloc.state,
    ).thenReturn(CategoryLoaded(categories: [tCategoryExpense]));
    when(
      () => mockCategoryLoadBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    actionStateController =
        StreamController<TransactionActionState>.broadcast();
  });

  tearDown(() async {
    await actionStateController.close();
  });

  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpBottomSheet(
    WidgetTester tester,
    TransactionEntity transaction,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TransactionActionBloc>.value(
            value: mockTransactionActionBloc,
          ),
          BlocProvider<AccountLoadBloc>.value(value: mockAccountLoadBloc),
          BlocProvider<CategoryLoadBloc>.value(value: mockCategoryLoadBloc),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) =>
                        TransactionDetailsBottomSheet(transaction: transaction),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('TransactionDetailsBottomSheet Mark as Paid', () {
    testWidgets(
      'given an unpaid transaction when the sheet renders then the Mark as '
      'Paid button is shown',
      (tester) async {
        setupTestWindow(tester);
        final transaction = tTransactionEntity.copyWith(paid: false);

        await pumpBottomSheet(tester, transaction);

        expect(find.text('Mark as Paid'), findsOneWidget);
      },
    );

    testWidgets(
      'given an already paid transaction when the sheet renders then the '
      'Mark as Paid button is not shown',
      (tester) async {
        setupTestWindow(tester);
        final transaction = tTransactionEntity.copyWith(paid: true);

        await pumpBottomSheet(tester, transaction);

        expect(find.text('Mark as Paid'), findsNothing);
      },
    );

    testWidgets('given an unpaid transaction when Mark as Paid is tapped then '
        'UpdateTransactionEvent is dispatched with paid set to true', (
      tester,
    ) async {
      setupTestWindow(tester);
      final transaction = tTransactionEntity.copyWith(paid: false);

      await pumpBottomSheet(tester, transaction);

      await tester.tap(find.text('Mark as Paid'));
      await tester.pump();

      final captured = verify(
        () => mockTransactionActionBloc.add(captureAny()),
      ).captured;
      expect(captured.single, isA<UpdateTransactionEvent>());
      final event = captured.single as UpdateTransactionEvent;
      expect(event.transaction.id, transaction.id);
      expect(event.transaction.paid, isTrue);
      expect(event.transaction.paidDate, isNotNull);
    });

    testWidgets(
      'given TransactionActionSuccess after marking as paid then the sheet '
      'closes',
      (tester) async {
        setupTestWindow(tester);
        final transaction = tTransactionEntity.copyWith(paid: false);

        whenListen(
          mockTransactionActionBloc,
          actionStateController.stream,
          initialState: TransactionActionInitial(),
        );

        await pumpBottomSheet(tester, transaction);

        await tester.tap(find.text('Mark as Paid'));
        await tester.pump();

        actionStateController.add(TransactionActionSuccess());
        await tester.pumpAndSettle();

        expect(find.byType(TransactionDetailsBottomSheet), findsNothing);
      },
    );

    testWidgets(
      'given TransactionActionError after marking as paid then the sheet '
      'stays open and shows the failure message',
      (tester) async {
        setupTestWindow(tester);
        final transaction = tTransactionEntity.copyWith(paid: false);

        whenListen(
          mockTransactionActionBloc,
          actionStateController.stream,
          initialState: TransactionActionInitial(),
        );

        await pumpBottomSheet(tester, transaction);

        await tester.tap(find.text('Mark as Paid'));
        await tester.pump();

        actionStateController.add(
          const TransactionActionError(
            failure: ServerFailure('Failed to update transaction.'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TransactionDetailsBottomSheet), findsOneWidget);
      },
    );
  });
}
