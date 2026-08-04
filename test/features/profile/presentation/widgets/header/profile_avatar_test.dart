import 'dart:convert';

import 'package:due_day/features/profile/presentation/widgets/header/profile_avatar.dart';
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
    return MaterialApp(home: Scaffold(body: child));
  }

  group('ProfileAvatar Widget Tests', () {
    testWidgets(
      'given no photoUrl when rendered then the initials text is shown',
      (tester) async {
        setupTestWindow(tester);

        await tester.pumpWidget(
          buildTestableWidget(child: const ProfileAvatar(initials: 'TU')),
        );
        await tester.pumpAndSettle();

        expect(find.text('TU'), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets(
      'given a data:image photoUrl when rendered then an Image widget is '
      'shown instead of the initials',
      (tester) async {
        setupTestWindow(tester);
        // 1x1 transparent PNG. Flutter's image codec sniffs the format from
        // the byte magic numbers, so this decodes fine even under a
        // `data:image/jpeg;...` prefix.
        final pngBytes = base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAA'
          'AAYAAjCB0C8AAAAASUVORK5CYII=',
        );
        final photoUrl = 'data:image/jpeg;base64,${base64Encode(pngBytes)}';

        await tester.pumpWidget(
          buildTestableWidget(
            child: ProfileAvatar(initials: 'TU', photoUrl: photoUrl),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsOneWidget);
        expect(find.text('TU'), findsNothing);
      },
    );

    testWidgets(
      'given an onTap callback when the avatar is tapped then the callback '
      'is invoked',
      (tester) async {
        setupTestWindow(tester);
        var tapped = false;

        await tester.pumpWidget(
          buildTestableWidget(
            child: ProfileAvatar(initials: 'TU', onTap: () => tapped = true),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ProfileAvatar));
        await tester.pump();

        expect(tapped, isTrue);
      },
    );
  });
}
