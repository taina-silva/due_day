import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../auth/helpers/auth_test_helpers.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsLoadEvent, NotificationsLoadState>
    implements NotificationsLoadBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockNotificationsBloc mockNotificationsBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockNotificationsBloc = MockNotificationsBloc();
    when(() => mockNotificationsBloc.state).thenReturn(NotificationsInitial());
    when(
      () => mockNotificationsBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  Widget buildTestableWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<NotificationsLoadBloc>.value(value: mockNotificationsBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(appBar: DashboardAppBar(titleText: 'Dashboard')),
      ),
    );
  }

  group('DashboardAppBar Widget Tests', () {
    testWidgets(
      'given AuthUnauthenticated when rendered then the fallback person '
      'icon is shown',
      (tester) async {
        when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byType(Image), findsNothing);
      },
    );

    testWidgets(
      'given an authenticated user with a photoUrl when rendered then the '
      'avatar image replaces the fallback icon',
      (tester) async {
        final pngBytes = base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAA'
          'AAYAAjCB0C8AAAAASUVORK5CYII=',
        );
        final photoUrl = 'data:image/jpeg;base64,${base64Encode(pngBytes)}';
        when(() => mockAuthBloc.state).thenReturn(
          AuthAuthenticated(user: tUserEntity.copyWith(photoUrl: photoUrl)),
        );

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsOneWidget);
        expect(find.byIcon(Icons.person), findsNothing);
      },
    );
  });
}
