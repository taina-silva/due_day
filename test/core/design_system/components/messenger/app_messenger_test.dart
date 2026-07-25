import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
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

  Widget buildTestableWidget(void Function(BuildContext context) onPressed) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text('trigger'),
          ),
        ),
      ),
    );
  }

  Finder findToast() => find.byKey(const Key('app_messenger_toast'));

  group('AppMessenger', () {
    testWidgets(
      'given showSuccess when called then displays a green toast with the message',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(
            (context) => AppMessenger.showSuccess(context, 'All good'),
          ),
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(findToast(), findsOneWidget);
        expect(find.text('All good'), findsOneWidget);

        final toast = tester.widget<Material>(findToast());
        expect(toast.color, DueDayTheme.colors.system.success);
      },
    );

    testWidgets(
      'given showError when called then displays a red toast with the message',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(
            (context) => AppMessenger.showError(context, 'Something failed'),
          ),
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(findToast(), findsOneWidget);
        expect(find.text('Something failed'), findsOneWidget);

        final toast = tester.widget<Material>(findToast());
        expect(toast.color, DueDayTheme.colors.system.error);
      },
    );

    testWidgets(
      'given showInfo when called then displays a blue toast with the message',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(
            (context) => AppMessenger.showInfo(context, 'Heads up'),
          ),
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(findToast(), findsOneWidget);
        expect(find.text('Heads up'), findsOneWidget);

        final toast = tester.widget<Material>(findToast());
        expect(toast.color, DueDayTheme.colors.system.info);
      },
    );

    testWidgets(
      'given a visible toast when the close icon is tapped then it is dismissed',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(
            (context) => AppMessenger.showError(context, 'Dismiss me'),
          ),
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(findToast(), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(findToast(), findsNothing);
      },
    );

    testWidgets(
      'given a toast auto-dismiss duration when it elapses then the toast is removed',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(
            (context) => AppMessenger.show(
              context,
              message: 'Times out',
              type: AppMessengerType.info,
              duration: const Duration(seconds: 1),
            ),
          ),
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(findToast(), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(milliseconds: 250));

        expect(findToast(), findsNothing);
      },
    );

    testWidgets(
      'given a new message when triggered while one is visible then replaces the current toast',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(
            (context) => AppMessenger.showError(context, 'First'),
          ),
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(find.text('First'), findsOneWidget);

        AppMessenger.showSuccess(
          tester.element(find.byType(Scaffold)),
          'Second',
        );
        await tester.pump();

        expect(find.text('First'), findsNothing);
        expect(find.text('Second'), findsOneWidget);
      },
    );
  });
}
