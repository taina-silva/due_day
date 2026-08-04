import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final Duration minimumSplashDuration;

  AuthBloc({
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
    required this.getCurrentUser,
    this.minimumSplashDuration = const Duration(milliseconds: 1000),
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInEmailEvent>(_onSignInEmail);
    on<AuthSignUpEmailEvent>(_onSignUpEmail);
    on<AuthGoogleSignInEvent>(_onGoogleSignIn);
    on<AuthSignOutEvent>(_onSignOut);
    on<AuthUserRefreshed>(_onUserRefreshed);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final startTime = DateTime.now();
    final result = await getCurrentUser();

    final elapsedTime = DateTime.now().difference(startTime);
    if (elapsedTime < minimumSplashDuration) {
      await Future.delayed(minimumSplashDuration - elapsedTime);
    }

    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onSignInEmail(
    AuthSignInEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmail(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignUpEmail(
    AuthSignUpEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signUpWithEmail(
      event.email,
      event.password,
      event.displayName,
    );
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOut();
    result.fold(
      (failure) => emit(AuthError(failure: failure)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  void _onUserRefreshed(AuthUserRefreshed event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(user: event.user));
  }
}
