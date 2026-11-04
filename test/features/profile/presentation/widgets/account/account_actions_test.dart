import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/profile/domain/errors/user_data_failures.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_bloc.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_event.dart';
import 'package:due_day/features/profile/presentation/bloc/user_data_action_state.dart';
import 'package:due_day/features/profile/presentation/widgets/account/account_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../auth/helpers/auth_test_helpers.dart';
import '../../../../categories/helpers/category_test_helpers.dart';

class MockUserDataActionBloc
    extends MockBloc<UserDataActionEvent, UserDataActionState>
    implements UserDataActionBloc {}

void main() {
  late MockUserDataActionBloc userDataBloc;
  late MockCategoryLoadBloc categoryLoadBloc;
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(const DeleteAllUserDataRequested());
    registerFallbackValue(const LoadCategories());
  });

  setUp(() {
    userDataBloc = MockUserDataActionBloc();
    categoryLoadBloc = MockCategoryLoadBloc();
    authBloc = MockAuthBloc();
    when(() => userDataBloc.state).thenReturn(const UserDataActionInitial());
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<CategoryLoadBloc>.value(value: categoryLoadBloc),
          BlocProvider<UserDataActionBloc>.value(value: userDataBloc),
        ],
        // The dialog closes through GoRouter, as in the app.
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Scaffold(body: AccountActions()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openDialog(WidgetTester tester) async {
    await tester.tap(find.text('Delete all my data'));
    await tester.pumpAndSettle();
    expect(find.text('Delete all your data?'), findsOneWidget);
    expect(find.textContaining("can't be undone"), findsOneWidget);
  }

  group('AccountActions — delete all my data', () {
    testWidgets('SET-001: confirming dispatches the delete', (tester) async {
      await pump(tester);
      await openDialog(tester);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(
        () => userDataBloc.add(const DeleteAllUserDataRequested()),
      ).called(1);
    });

    testWidgets('SET-001: cancelling deletes nothing', (tester) async {
      await pump(tester);
      await openDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete all your data?'), findsNothing);
      verifyNever(() => userDataBloc.add(any()));
    });

    testWidgets('SET-001: success shows a message and reloads defaults', (
      tester,
    ) async {
      whenListen(
        userDataBloc,
        Stream.fromIterable(const [
          UserDataActionInProgress(),
          UserDataActionSuccess(),
        ]),
        initialState: const UserDataActionInitial(),
      );
      await pump(tester);
      await tester.pump();

      expect(find.text('Your data was deleted.'), findsOneWidget);
      final event =
          verify(() => categoryLoadBloc.add(captureAny())).captured.single
              as LoadCategories;
      expect(event.defaultNames?.food, 'Food');
    });

    testWidgets('SET-001: failure shows an error and the user can retry', (
      tester,
    ) async {
      whenListen(
        userDataBloc,
        Stream.fromIterable(const [
          UserDataActionInProgress(),
          UserDataActionError(DeleteUserDataFailure()),
        ]),
        initialState: const UserDataActionInitial(),
      );
      await pump(tester);
      await tester.pump();

      expect(find.byType(AppMessengerContent), findsOneWidget);
      expect(
        find.text("Couldn't delete your data. Please try again."),
        findsOneWidget,
      );
      expect(find.text('Delete all my data'), findsOneWidget);
    });
  });
}
