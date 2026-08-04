import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfilePictureRequested extends ProfileEvent {
  final ImageSource source;
  final UserEntity currentUser;

  const ProfilePictureRequested({
    required this.source,
    required this.currentUser,
  });

  @override
  List<Object> get props => [source, currentUser];
}
