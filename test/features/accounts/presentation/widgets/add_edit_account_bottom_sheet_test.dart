import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/domain/errors/account_failures.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_state.dart';
import 'package:due_day/features/accounts/presentation/widgets/add_edit_account_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  late MockAccountActionBloc mockAccountActionBloc;
  late StreamController<AccountActionState> stateController;

  // The app's "Save Account" button is sized to fit the real "Sofia Sans"
  // font. Without loading it, the test font fallback renders wider glyphs
  // and trips a false RenderFlex overflow on the button row.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final fontLoader = FontLoader('Sofia Sans')
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-Bold.ttf'));
    await fontLoader.load();
  });

  setUp(() {
    mockAccountActionBloc = MockAccountActionBloc();
    stateController = StreamController<AccountActionState>.broadcast();

    whenListen(
      mockAccountActionBloc,
      stateController.stream,
      initialState: AccountActionInitial(),
    );
  });

  tearDown(() async {
    await stateController.close();
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
    WidgetTester tester, {
    required void Function(
      String name,
      AccountCategory category,
      double balance,
      int? dueDay,
    )
    onSave,
    AccountEntity? account,
  }) async {
    setupTestWindow(tester);
    await tester.pumpWidget(
      BlocProvider<AccountActionBloc>.value(
        value: mockAccountActionBloc,
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
                    builder: (_) => AddEditAccountBottomSheet(
                      account: account,
                      onSave: onSave,
                    ),
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

  Future<void> fillFormAndTapSave(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).first, 'Checking');

    await tester.tap(find.byType(DropdownButtonFormField<AccountCategory>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily Use').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), '100');
    await tester.pump();

    await tester.ensureVisible(find.text('Save Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Account'));
    await tester.pump();
  }

  group('AddEditAccountBottomSheet', () {
    testWidgets(
      'given AddAccount fails when the user submits then the bottom sheet '
      'stays open and an AppMessenger error with the save-specific message '
      'is shown instead of the generic accounts-list error',
      (tester) async {
        var onSaveCalled = false;

        await pumpBottomSheet(
          tester,
          onSave: (name, category, balance, dueDay) => onSaveCalled = true,
        );

        expect(find.byType(AddEditAccountBottomSheet), findsOneWidget);

        await fillFormAndTapSave(tester);
        expect(onSaveCalled, isTrue);

        // Simulate the AccountActionBloc reacting to the failed add operation.
        stateController.add(
          const AccountActionError(
            failure: AccountSaveFailure('Failed to add account.'),
          ),
        );
        await tester.pumpAndSettle();

        // Bottom sheet must remain open.
        expect(find.byType(AddEditAccountBottomSheet), findsOneWidget);
        // The failure must be surfaced via AppMessenger's root-Overlay toast,
        // using the save-specific wording rather than the generic load fallback.
        expect(find.byType(AppMessengerContent), findsOneWidget);
        expect(
          find.text('Failed to save account. Please try again.'),
          findsOneWidget,
        );
        expect(
          find.text('An error occurred while managing your accounts.'),
          findsNothing,
        );
      },
    );

    testWidgets('given AddAccount succeeds when the user submits then the bottom '
        'sheet closes', (tester) async {
      var onSaveCalled = false;

      await pumpBottomSheet(
        tester,
        onSave: (name, category, balance, dueDay) => onSaveCalled = true,
      );

      await fillFormAndTapSave(tester);
      expect(onSaveCalled, isTrue);
      expect(find.byType(AddEditAccountBottomSheet), findsOneWidget);

      // Simulate the AccountActionBloc reacting to the successful add operation.
      stateController.add(AccountActionSuccess());
      await tester.pumpAndSettle();

      expect(find.byType(AddEditAccountBottomSheet), findsNothing);
    });

    testWidgets(
      'given required fields are empty when the user taps save then no '
      'event is dispatched and the bottom sheet stays open',
      (tester) async {
        var onSaveCalled = false;

        await pumpBottomSheet(
          tester,
          onSave: (name, category, balance, dueDay) => onSaveCalled = true,
        );

        await tester.ensureVisible(find.text('Save Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save Account'));
        await tester.pumpAndSettle();

        expect(onSaveCalled, isFalse);
        expect(find.byType(AddEditAccountBottomSheet), findsOneWidget);
      },
    );

    testWidgets(
      'given the user confirms deletion then DeleteAccountEvent is '
      'dispatched and the sheet only closes once AccountActionBloc succeeds',
      (tester) async {
        await pumpBottomSheet(
          tester,
          onSave: (name, category, balance, dueDay) {},
          account: tAccountEntity,
        );

        await tester.ensureVisible(find.text('Delete Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();

        expect(
          find.text('Are you sure you want to delete this account?'),
          findsOneWidget,
        );

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        // Confirmation dialog closes but the sheet stays open, waiting for
        // the AccountActionBloc result.
        expect(
          find.text('Are you sure you want to delete this account?'),
          findsNothing,
        );
        expect(find.byType(AddEditAccountBottomSheet), findsOneWidget);

        stateController.add(AccountActionSuccess());
        await tester.pumpAndSettle();

        expect(find.byType(AddEditAccountBottomSheet), findsNothing);
      },
    );

    testWidgets(
      'given the delete operation fails then the sheet stays open and shows '
      'the delete-specific message rather than the save one',
      (tester) async {
        await pumpBottomSheet(
          tester,
          onSave: (name, category, balance, dueDay) {},
          account: tAccountEntity,
        );

        await tester.ensureVisible(find.text('Delete Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        stateController.add(
          const AccountActionError(
            failure: AccountDeleteFailure('Failed to delete account.'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AddEditAccountBottomSheet), findsOneWidget);
        expect(
          find.text('Failed to delete account. Please try again.'),
          findsOneWidget,
        );
        expect(
          find.text('Failed to save account. Please try again.'),
          findsNothing,
        );
      },
    );
  });
}
