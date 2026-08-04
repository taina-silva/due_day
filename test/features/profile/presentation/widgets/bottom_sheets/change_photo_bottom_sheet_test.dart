import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_event.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_state.dart';
import 'package:due_day/features/profile/presentation/widgets/bottom_sheets/change_photo_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../auth/helpers/auth_test_helpers.dart';

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class FakeProfileEvent extends Fake implements ProfileEvent {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockProfileBloc mockProfileBloc;
  late MockAuthBloc mockAuthBloc;
  late StreamController<ProfileState> profileStateController;

  // The action buttons are sized to fit the real "Sofia Sans" font. Without
  // loading it, the test font fallback renders wider glyphs and trips a
  // false RenderFlex overflow on the button row.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeProfileEvent());
    registerFallbackValue(FakeAuthEvent());

    final fontLoader = FontLoader('Sofia Sans')
      ..addFont(rootBundle.load('assets/fonts/SofiaSans-Bold.ttf'));
    await fontLoader.load();
  });

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    mockAuthBloc = MockAuthBloc();

    when(() => mockProfileBloc.state).thenReturn(ProfileActionInitial());
    when(() => mockProfileBloc.stream).thenAnswer((_) => const Stream.empty());

    when(
      () => mockAuthBloc.state,
    ).thenReturn(AuthAuthenticated(user: tUserEntity));
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    profileStateController = StreamController<ProfileState>.broadcast();
  });

  tearDown(() async {
    await profileStateController.close();
  });

  void setupTestWindow(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpBottomSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
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
                    builder: (_) =>
                        ChangePhotoBottomSheet(currentUser: tUserEntity),
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

  group('ChangePhotoBottomSheet', () {
    testWidgets(
      'given the sheet is open when Take Photo is tapped then dispatch '
      'ProfilePictureRequested with the camera source',
      (tester) async {
        setupTestWindow(tester);

        await pumpBottomSheet(tester);

        await tester.tap(find.text('Take Photo'));
        await tester.pump();

        final captured = verify(
          () => mockProfileBloc.add(captureAny()),
        ).captured;
        expect(captured.single, isA<ProfilePictureRequested>());
        final event = captured.single as ProfilePictureRequested;
        expect(event.source, ImageSource.camera);
        expect(event.currentUser, tUserEntity);
      },
    );

    testWidgets(
      'given the sheet is open when Choose from Gallery is tapped then '
      'dispatch ProfilePictureRequested with the gallery source',
      (tester) async {
        setupTestWindow(tester);

        await pumpBottomSheet(tester);

        await tester.tap(find.text('Choose from Gallery'));
        await tester.pump();

        final captured = verify(
          () => mockProfileBloc.add(captureAny()),
        ).captured;
        expect(captured.single, isA<ProfilePictureRequested>());
        final event = captured.single as ProfilePictureRequested;
        expect(event.source, ImageSource.gallery);
        expect(event.currentUser, tUserEntity);
      },
    );

    testWidgets(
      'given ProfileActionSuccess after picking a photo then the sheet '
      'closes and AuthBloc receives AuthUserRefreshed',
      (tester) async {
        setupTestWindow(tester);

        whenListen(
          mockProfileBloc,
          profileStateController.stream,
          initialState: ProfileActionInitial(),
        );

        await pumpBottomSheet(tester);

        await tester.tap(find.text('Take Photo'));
        await tester.pump();

        final updatedUser = tUserEntity.copyWith(
          photoUrl: 'data:image/jpeg;base64,abc',
        );
        profileStateController.add(ProfileActionSuccess(user: updatedUser));
        await tester.pumpAndSettle();

        expect(find.byType(ChangePhotoBottomSheet), findsNothing);
        final captured = verify(() => mockAuthBloc.add(captureAny())).captured;
        expect(captured.single, isA<AuthUserRefreshed>());
        final authEvent = captured.single as AuthUserRefreshed;
        expect(authEvent.user, updatedUser);
      },
    );

    testWidgets(
      'given ProfileActionError after picking a photo then the sheet stays '
      'open and shows the failure message',
      (tester) async {
        setupTestWindow(tester);

        whenListen(
          mockProfileBloc,
          profileStateController.stream,
          initialState: ProfileActionInitial(),
        );

        await pumpBottomSheet(tester);

        await tester.tap(find.text('Take Photo'));
        await tester.pump();

        profileStateController.add(
          const ProfileActionError(failure: ImageTooLargeFailure()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ChangePhotoBottomSheet), findsOneWidget);
        expect(find.byKey(const Key('app_messenger_toast')), findsOneWidget);
        verifyNever(() => mockAuthBloc.add(any()));
      },
    );
  });
}
