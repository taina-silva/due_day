import 'package:due_day/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App Launches Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DueDayApp());
    await tester.pumpAndSettle();

    // Verify that it renders the initial route.
    expect(find.text('DueDay Initial'), findsOneWidget);
  });
}
