import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/categories/presentation/pages/categories_page.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_bloc.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_event.dart';
import 'package:due_day/features/notifications/presentation/bloc/notifications_load_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../auth/helpers/auth_test_helpers.dart';
import '../../helpers/category_test_helpers.dart';

class MockNotificationsBloc
    extends MockBloc<NotificationsLoadEvent, NotificationsLoadState>
    implements NotificationsLoadBloc {}

void main() {
  late MockCategoryLoadBloc mockCategoryLoadBloc;
  late MockNotificationsBloc mockNotificationsBloc;
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockCategoryLoadBloc = MockCategoryLoadBloc();
    when(() => mockCategoryLoadBloc.state).thenReturn(CategoryInitial());
    when(
      () => mockCategoryLoadBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    mockNotificationsBloc = MockNotificationsBloc();
    when(() => mockNotificationsBloc.state).thenReturn(NotificationsInitial());
    when(
      () => mockNotificationsBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestableWidget({
    required Widget child,
    required GoRouter router,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoryLoadBloc>.value(value: mockCategoryLoadBloc),
        BlocProvider<NotificationsLoadBloc>.value(value: mockNotificationsBloc),
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
      ),
    );
  }

  group('CategoriesPage Widget Tests', () {
    testWidgets(
      'given CategoryLoading/Initial state when page loads then show CircularProgressIndicator',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockCategoryLoadBloc.state).thenReturn(CategoryLoading());

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CategoriesPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const CategoriesPage(), router: router),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'given CategoryError state when page loads then display failure localized message',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockCategoryLoadBloc.state).thenReturn(
          const CategoryError(failure: ServerFailure('Server failure message')),
        );

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CategoriesPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const CategoriesPage(), router: router),
        );
        await tester.pump();

        // The fallback translated text for ServerFailure is "An error occurred while managing your categories."
        expect(
          find.text('An error occurred while managing your categories.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given CategoryLoaded state when page loads then display categories and most active card',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockCategoryLoadBloc.state).thenReturn(
          CategoryLoaded(categories: [tCategoryEntity, tCategoryEntity2]),
        );

        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CategoriesPage(),
            ),
          ],
        );

        await tester.pumpWidget(
          buildTestableWidget(child: const CategoriesPage(), router: router),
        );
        await tester.pumpAndSettle();

        // Should display Food category (both in hero card and list card)
        expect(find.text('Food'), findsNWidgets(2));
        // Should display Transport category
        expect(find.text('Transport'), findsOneWidget);
        // Should display New Category button
        expect(find.text('New Category'), findsOneWidget);
      },
    );
  });
}
