import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_action_state.dart';
import 'package:due_day/features/categories/presentation/widgets/bottom_sheets/add_edit_category_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/category_test_helpers.dart';

void main() {
  late MockCategoryActionBloc mockCategoryActionBloc;
  late StreamController<CategoryActionState> stateController;

  // The app's "Save Category" button is sized to fit the real "Sofia Sans"
  // font. Without loading it, the test font fallback renders wider glyphs
  // and trips a false RenderFlex overflow on the button row.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final fontLoader = FontLoader('Sofia Sans')
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-Bold.ttf'));
    await fontLoader.load();
  });

  setUp(() {
    mockCategoryActionBloc = MockCategoryActionBloc();
    stateController = StreamController<CategoryActionState>.broadcast();

    whenListen(
      mockCategoryActionBloc,
      stateController.stream,
      initialState: CategoryActionInitial(),
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
    required void Function(String name, String icon, String color) onSave,
  }) async {
    setupTestWindow(tester);
    await tester.pumpWidget(
      BlocProvider<CategoryActionBloc>.value(
        value: mockCategoryActionBloc,
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
                    builder: (_) => AddEditCategoryBottomSheet(onSave: onSave),
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

  Future<void> fillNameAndTapSave(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField), 'Groceries');
    await tester.pump();
    await tester.ensureVisible(find.text('Save Category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Category'));
    await tester.pump();
  }

  group('AddEditCategoryBottomSheet', () {
    testWidgets(
      'given AddCategory fails when the user submits then the bottom sheet '
      'stays open and an AppMessenger error is shown instead of a generic '
      'categories-list error',
      (tester) async {
        var onSaveCalled = false;

        await pumpBottomSheet(
          tester,
          onSave: (name, icon, color) => onSaveCalled = true,
        );

        expect(find.byType(AddEditCategoryBottomSheet), findsOneWidget);

        await fillNameAndTapSave(tester);
        expect(onSaveCalled, isTrue);

        // Simulate the CategoryActionBloc reacting to the failed add operation.
        stateController.add(
          const CategoryActionError(
            failure: ServerFailure('Failed to add category.'),
          ),
        );
        await tester.pumpAndSettle();

        // Bottom sheet must remain open.
        expect(find.byType(AddEditCategoryBottomSheet), findsOneWidget);
        // The failure must be surfaced via AppMessenger's root-Overlay toast.
        expect(find.byType(AppMessengerContent), findsOneWidget);
        expect(
          find.text('An error occurred while managing your categories.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given AddCategory succeeds when the user submits then the bottom '
      'sheet closes',
      (tester) async {
        var onSaveCalled = false;

        await pumpBottomSheet(
          tester,
          onSave: (name, icon, color) => onSaveCalled = true,
        );

        await fillNameAndTapSave(tester);
        expect(onSaveCalled, isTrue);
        expect(find.byType(AddEditCategoryBottomSheet), findsOneWidget);

        // Simulate the CategoryActionBloc reacting to the successful add operation.
        stateController.add(CategoryActionSuccess());
        await tester.pumpAndSettle();

        expect(find.byType(AddEditCategoryBottomSheet), findsNothing);
      },
    );

    testWidgets(
      'given the name field is empty when the user taps save then no event '
      'is dispatched and the bottom sheet stays open',
      (tester) async {
        var onSaveCalled = false;

        await pumpBottomSheet(
          tester,
          onSave: (name, icon, color) => onSaveCalled = true,
        );

        await tester.ensureVisible(find.text('Save Category'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save Category'));
        await tester.pumpAndSettle();

        expect(onSaveCalled, isFalse);
        expect(find.byType(AddEditCategoryBottomSheet), findsOneWidget);
      },
    );
  });
}
