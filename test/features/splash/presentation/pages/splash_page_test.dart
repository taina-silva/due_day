import 'package:due_day/core/design_system/theme/app_theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/splash/presentation/pages/splash_page.dart';
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

  Widget buildTestableWidget({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: child,
    );
  }

  group('SplashPage Widget Tests', () {
    testWidgets(
      'given SplashPage loaded then renders logo, app name, and tagline with animation',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(child: const SplashPage()),
        );

        // Verify elements exist initially
        expect(find.byType(Image), findsOneWidget);
        expect(find.text('DueDay'), findsOneWidget);
        expect(find.text('Your finances, on the right day.'), findsOneWidget);

        // Check if Scaffold has the primary brand color
        final scaffoldFinder = find.byType(Scaffold);
        expect(scaffoldFinder, findsOneWidget);
        final scaffold = tester.widget<Scaffold>(scaffoldFinder);
        expect(scaffold.backgroundColor, const Color(0xFF166bd5));

        // Advance animation
        await tester.pumpAndSettle();

        // After animation completes, we should still see the items clearly
        expect(find.byType(Image), findsOneWidget);
        expect(find.text('DueDay'), findsOneWidget);
        expect(find.text('Your finances, on the right day.'), findsOneWidget);
      },
    );
  });
}
