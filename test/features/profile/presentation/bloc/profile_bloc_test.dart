import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/services/image_picker_service.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_event.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../auth/helpers/auth_test_helpers.dart';

class MockImagePickerService extends Mock implements ImagePickerService {}

void main() {
  late MockUpdateUser mockUpdateUser;
  late MockImagePickerService mockImagePickerService;
  late ProfileBloc profileBloc;

  setUpAll(() {
    registerFallbackValue(ImageSource.camera);
    registerFallbackValue(tUserEntity);
  });

  setUp(() {
    mockUpdateUser = MockUpdateUser();
    mockImagePickerService = MockImagePickerService();

    profileBloc = ProfileBloc(
      updateUser: mockUpdateUser,
      imagePickerService: mockImagePickerService,
    );
  });

  tearDown(() {
    profileBloc.close();
  });

  test(
    'given ProfileBloc when initialized then state is ProfileActionInitial',
    () {
      expect(profileBloc.state, equals(ProfileActionInitial()));
    },
  );

  group('ProfilePictureRequested', () {
    blocTest<ProfileBloc, ProfileState>(
      'given the image pick is canceled when ProfilePictureRequested is '
      'added then emit [ProfileActionInProgress, ProfileActionInitial]',
      build: () {
        when(
          () => mockImagePickerService.pickImage(any()),
        ).thenAnswer((_) async => const ImagePickCanceled());
        return profileBloc;
      },
      act: (bloc) => bloc.add(
        ProfilePictureRequested(
          source: ImageSource.gallery,
          currentUser: tUserEntity,
        ),
      ),
      expect: () => [ProfileActionInProgress(), ProfileActionInitial()],
      verify: (_) {
        verify(() => mockImagePickerService.pickImage(ImageSource.gallery));
        verifyNever(() => mockUpdateUser(any()));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'given the picked image is too large when ProfilePictureRequested is '
      'added then emit [ProfileActionInProgress, ProfileActionError('
      'ImageTooLargeFailure)]',
      build: () {
        when(
          () => mockImagePickerService.pickImage(any()),
        ).thenAnswer((_) async => const ImagePickTooLarge());
        return profileBloc;
      },
      act: (bloc) => bloc.add(
        ProfilePictureRequested(
          source: ImageSource.gallery,
          currentUser: tUserEntity,
        ),
      ),
      expect: () => [
        ProfileActionInProgress(),
        const ProfileActionError(failure: ImageTooLargeFailure()),
      ],
      verify: (_) {
        verifyNever(() => mockUpdateUser(any()));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'given the image pick fails when ProfilePictureRequested is added '
      'then emit [ProfileActionInProgress, ProfileActionError('
      'GenericFailure)]',
      build: () {
        when(
          () => mockImagePickerService.pickImage(any()),
        ).thenAnswer((_) async => const ImagePickFailed());
        return profileBloc;
      },
      act: (bloc) => bloc.add(
        ProfilePictureRequested(
          source: ImageSource.camera,
          currentUser: tUserEntity,
        ),
      ),
      expect: () => [
        ProfileActionInProgress(),
        const ProfileActionError(failure: GenericFailure()),
      ],
      verify: (_) {
        verifyNever(() => mockUpdateUser(any()));
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'given the image pick succeeds and UpdateUser succeeds when '
      'ProfilePictureRequested is added then emit [ProfileActionInProgress, '
      'ProfileActionSuccess] with the updated photoUrl',
      build: () {
        when(() => mockImagePickerService.pickImage(any())).thenAnswer(
          (_) async => const ImagePickSuccess('data:image/jpeg;base64,abc'),
        );
        when(
          () => mockUpdateUser(any()),
        ).thenAnswer((_) async => const fp.Right(null));
        return profileBloc;
      },
      act: (bloc) => bloc.add(
        ProfilePictureRequested(
          source: ImageSource.camera,
          currentUser: tUserEntity,
        ),
      ),
      expect: () => [
        ProfileActionInProgress(),
        ProfileActionSuccess(
          user: tUserEntity.copyWith(photoUrl: 'data:image/jpeg;base64,abc'),
        ),
      ],
      verify: (_) {
        final updatedUser = tUserEntity.copyWith(
          photoUrl: 'data:image/jpeg;base64,abc',
        );
        verify(() => mockUpdateUser(updatedUser)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'given the image pick succeeds but UpdateUser fails when '
      'ProfilePictureRequested is added then emit [ProfileActionInProgress, '
      'ProfileActionError]',
      build: () {
        when(() => mockImagePickerService.pickImage(any())).thenAnswer(
          (_) async => const ImagePickSuccess('data:image/jpeg;base64,abc'),
        );
        when(() => mockUpdateUser(any())).thenAnswer(
          (_) async => const fp.Left(ServerFailure('Failed to update user')),
        );
        return profileBloc;
      },
      act: (bloc) => bloc.add(
        ProfilePictureRequested(
          source: ImageSource.camera,
          currentUser: tUserEntity,
        ),
      ),
      expect: () => [
        ProfileActionInProgress(),
        const ProfileActionError(
          failure: ServerFailure('Failed to update user'),
        ),
      ],
    );
  });
}
