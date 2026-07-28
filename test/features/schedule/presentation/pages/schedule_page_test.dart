import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_action_state.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_state.dart';
import 'package:due_day/features/schedule/presentation/pages/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/schedule_test_helpers.dart';

class FakeScheduleActionEvent extends Fake implements ScheduleActionEvent {}

void main() {
  late MockScheduleLoadBloc mockScheduleLoadBloc;
  late MockScheduleActionBloc mockScheduleActionBloc;
  late MockCategoryLoadBloc mockCategoryLoadBloc;

  // The app's typography is sized to fit the real "Sofia Sans" font. Without
  // loading it, the test font fallback renders wider glyphs and trips false
  // RenderFlex overflows on the summary/timeline rows.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeScheduleActionEvent());

    final fontLoader = FontLoader('Sofia Sans')
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-Bold.ttf'));
    await fontLoader.load();
  });

  setUp(() {
    mockScheduleLoadBloc = MockScheduleLoadBloc();
    mockScheduleActionBloc = MockScheduleActionBloc();
    mockCategoryLoadBloc = MockCategoryLoadBloc();

    when(
      () => mockScheduleActionBloc.state,
    ).thenReturn(ScheduleActionInitial());
    when(
      () => mockScheduleActionBloc.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(
      () => mockCategoryLoadBloc.state,
    ).thenReturn(CategoryLoaded(categories: [tCategoryExpense]));
    when(
      () => mockCategoryLoadBloc.stream,
    ).thenAnswer((_) => const Stream.empty());
  });

  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestableWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ScheduleLoadBloc>.value(value: mockScheduleLoadBloc),
        BlocProvider<ScheduleActionBloc>.value(value: mockScheduleActionBloc),
        BlocProvider<CategoryLoadBloc>.value(value: mockCategoryLoadBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: ScheduleView(),
      ),
    );
  }

  group('ScheduleView Widget Tests', () {
    testWidgets(
      'given ScheduleLoading state when page loads then show CircularProgressIndicator',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockScheduleLoadBloc.state).thenReturn(ScheduleLoading());
        when(
          () => mockScheduleLoadBloc.stream,
        ).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'given ScheduleError state when page loads then display failure localized message',
      (tester) async {
        setupTestWindow(tester);
        when(() => mockScheduleLoadBloc.state).thenReturn(
          const ScheduleError(ServerFailure('Server failure message')),
        );
        when(
          () => mockScheduleLoadBloc.stream,
        ).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        expect(
          find.text('An error occurred while loading your schedule.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'given ScheduleLoaded state when page loads then display summary, '
      'next income and timeline items',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockScheduleLoadBloc.state,
        ).thenReturn(ScheduleLoaded(tScheduleSummaryNoIncome));
        when(
          () => mockScheduleLoadBloc.stream,
        ).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.text('WEEKLY OVERVIEW'), findsOneWidget);
        expect(find.text('Timeline & Agenda'), findsOneWidget);
        expect(find.text('Bills'), findsWidgets);
      },
    );

    testWidgets(
      'given an unpaid item when Mark as Paid is tapped then dispatch '
      'MarkAsPaidEvent to ScheduleActionBloc',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockScheduleLoadBloc.state,
        ).thenReturn(ScheduleLoaded(tScheduleSummaryNoIncome));
        when(
          () => mockScheduleLoadBloc.stream,
        ).thenAnswer((_) => const Stream.empty());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Mark as Paid'));
        await tester.pump();

        verify(
          () => mockScheduleActionBloc.add(any(that: isA<MarkAsPaidEvent>())),
        ).called(1);
      },
    );

    testWidgets(
      'given ScheduleActionError state then show an AppMessenger error toast',
      (tester) async {
        setupTestWindow(tester);
        when(
          () => mockScheduleLoadBloc.state,
        ).thenReturn(ScheduleLoaded(tScheduleSummaryNoIncome));
        when(
          () => mockScheduleLoadBloc.stream,
        ).thenAnswer((_) => const Stream.empty());
        whenListen(
          mockScheduleActionBloc,
          Stream.value(const ScheduleActionError(ServerFailure('Failed'))),
          initialState: ScheduleActionInitial(),
        );

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(
          find.text('Failed to update your schedule. Please try again.'),
          findsOneWidget,
        );
      },
    );
  });
}
