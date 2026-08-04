import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileActionInitial extends ProfileState {}

class ProfileActionInProgress extends ProfileState {}

class ProfileActionSuccess extends ProfileState {
  final UserEntity user;

  const ProfileActionSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class ProfileActionError extends ProfileState {
  final Failure failure;

  const ProfileActionError({required this.failure});

  @override
  List<Object> get props => [failure];
}
