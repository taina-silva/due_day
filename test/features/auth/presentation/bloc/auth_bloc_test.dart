import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_test_helpers.dart';

void main() {
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignUpWithEmail mockSignUpWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;
  late AuthBloc authBloc;

  setUp(() {
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignUpWithEmail = MockSignUpWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();

    authBloc = AuthBloc(
      signInWithEmail: mockSignInWithEmail,
      signUpWithEmail: mockSignUpWithEmail,
      signInWithGoogle: mockSignInWithGoogle,
      signOut: mockSignOut,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  test('given AuthBloc when initialized then state is AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'given GetCurrentUser returns UserEntity when AuthCheckRequested is added then emit [AuthLoading, AuthAuthenticated]',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => fp.Right(tUserEntity));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [AuthLoading(), AuthAuthenticated(user: tUserEntity)],
      verify: (_) {
        verify(() => mockGetCurrentUser()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'given GetCurrentUser returns null when AuthCheckRequested is added then emit [AuthLoading, AuthUnauthenticated]',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => const fp.Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'given GetCurrentUser returns failure when AuthCheckRequested is added then emit [AuthLoading, AuthUnauthenticated]',
      build: () {
        when(
          () => mockGetCurrentUser(),
        ).thenAnswer((_) async => const fp.Left(ServerFailure()));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );
  });

  group('AuthSignInEmailEvent', () {
    blocTest<AuthBloc, AuthState>(
      'given SignInWithEmail is successful when AuthSignInEmailEvent is added then emit [AuthLoading, AuthAuthenticated]',
      build: () {
        when(
          () => mockSignInWithEmail(tEmail, tPassword),
        ).thenAnswer((_) async => fp.Right(tUserEntity));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignInEmailEvent(email: tEmail, password: tPassword),
      ),
      expect: () => [AuthLoading(), AuthAuthenticated(user: tUserEntity)],
    );

    blocTest<AuthBloc, AuthState>(
      'given SignInWithEmail fails when AuthSignInEmailEvent is added then emit [AuthLoading, AuthError]',
      build: () {
        when(() => mockSignInWithEmail(tEmail, tPassword)).thenAnswer(
          (_) async => const fp.Left(ServerFailure('Sign in failed')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignInEmailEvent(email: tEmail, password: tPassword),
      ),
      expect: () => [
        AuthLoading(),
        const AuthError(failure: ServerFailure('Sign in failed')),
      ],
    );
  });

  group('AuthSignUpEmailEvent', () {
    blocTest<AuthBloc, AuthState>(
      'given SignUpWithEmail is successful when AuthSignUpEmailEvent is added then emit [AuthLoading, AuthAuthenticated]',
      build: () {
        when(
          () => mockSignUpWithEmail(tEmail, tPassword, tDisplayName),
        ).thenAnswer((_) async => fp.Right(tUserEntity));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        const AuthSignUpEmailEvent(
          email: tEmail,
          password: tPassword,
          displayName: tDisplayName,
        ),
      ),
      expect: () => [AuthLoading(), AuthAuthenticated(user: tUserEntity)],
    );
  });

  group('AuthGoogleSignInEvent', () {
    blocTest<AuthBloc, AuthState>(
      'given SignInWithGoogle is successful when AuthGoogleSignInEvent is added then emit [AuthLoading, AuthAuthenticated]',
      build: () {
        when(
          () => mockSignInWithGoogle(),
        ).thenAnswer((_) async => fp.Right(tUserEntity));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthGoogleSignInEvent()),
      expect: () => [AuthLoading(), AuthAuthenticated(user: tUserEntity)],
    );
  });

  group('AuthSignOutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'given SignOut is successful when AuthSignOutEvent is added then emit [AuthLoading, AuthUnauthenticated]',
      build: () {
        when(() => mockSignOut()).thenAnswer((_) async => const fp.Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSignOutEvent()),
      expect: () => [AuthLoading(), AuthUnauthenticated()],
    );
  });
}
