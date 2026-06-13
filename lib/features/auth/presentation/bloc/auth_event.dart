import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const AuthSignUpEmailEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthGoogleSignInEvent extends AuthEvent {}

class AuthSignOutEvent extends AuthEvent {}
