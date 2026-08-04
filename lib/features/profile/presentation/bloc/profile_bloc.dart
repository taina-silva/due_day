import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/core/services/image_picker_service.dart';
import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_event.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateUser updateUser;
  final ImagePickerService imagePickerService;

  ProfileBloc({required this.updateUser, required this.imagePickerService})
    : super(ProfileActionInitial()) {
    on<ProfilePictureRequested>(_onProfilePictureRequested);
  }

  Future<void> _onProfilePictureRequested(
    ProfilePictureRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileActionInProgress());

    final pickResult = await imagePickerService.pickImage(event.source);

    switch (pickResult) {
      case ImagePickCanceled():
        emit(ProfileActionInitial());
      case ImagePickTooLarge():
        emit(const ProfileActionError(failure: ImageTooLargeFailure()));
      case ImagePickFailed():
        emit(const ProfileActionError(failure: GenericFailure()));
      case ImagePickSuccess(:final base64Image):
        final updatedUser = event.currentUser.copyWith(photoUrl: base64Image);
        final result = await updateUser(updatedUser);
        result.fold(
          (failure) => emit(ProfileActionError(failure: failure)),
          (_) => emit(ProfileActionSuccess(user: updatedUser)),
        );
    }
  }
}
