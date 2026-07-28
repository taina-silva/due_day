import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:due_day/core/settings/settings_bloc.dart';
import 'package:due_day/core/settings/settings_event.dart';
import 'package:due_day/core/settings/settings_state.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../features/auth/helpers/auth_test_helpers.dart';

class MockSecurityService extends Mock implements SecurityService {}

void main() {
  late MockUpdateUser mockUpdateUser;
  late MockAuthBloc mockAuthBloc;
  late MockSecurityService mockSecurityService;

  setUp(() {
    mockUpdateUser = MockUpdateUser();
    mockAuthBloc = MockAuthBloc();
    mockSecurityService = MockSecurityService();

    when(() => mockAuthBloc.state).thenReturn(AuthUnauthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => mockSecurityService.isBiometricsEnabled(),
    ).thenAnswer((_) async => false);
  });

  SettingsBloc buildBloc() {
    return SettingsBloc(
      updateUser: mockUpdateUser,
      authBloc: mockAuthBloc,
      securityService: mockSecurityService,
    );
  }

  test(
    'given SettingsBloc is created then it loads the persisted biometric preference',
    () async {
      when(
        () => mockSecurityService.isBiometricsEnabled(),
      ).thenAnswer((_) async => true);

      final bloc = buildBloc();
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.isBiometricsEnabled, isTrue);
      await bloc.close();
    },
  );

  group('ToggleBiometricsEvent', () {
    blocTest<SettingsBloc, SettingsState>(
      'given device supports biometrics and user authenticates then persist the preference and emit enabled state',
      build: () {
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.success);
        when(
          () => mockSecurityService.setBiometricsEnabled(true),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      // Normalizes the bloc's initial-emission quirk so the constructor's own
      // LoadBiometricsSettingsEvent (fired on startup) doesn't leak into the
      // states asserted below.
      seed: () => const SettingsState(),
      act: (bloc) => bloc.add(const ToggleBiometricsEvent(true)),
      expect: () => [
        const SettingsState(isTogglingBiometrics: true),
        const SettingsState(isBiometricsEnabled: true),
      ],
      verify: (_) {
        verify(() => mockSecurityService.setBiometricsEnabled(true)).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'given device supports biometrics and user authenticates then persist the preference and emit disabled state',
      seed: () => const SettingsState(isBiometricsEnabled: true),
      build: () {
        // Aligns the constructor's own LoadBiometricsSettingsEvent result with
        // the seeded state, so its concurrent emission is a no-op (equal
        // states are deduped by Bloc) instead of racing with the toggle flow.
        when(
          () => mockSecurityService.isBiometricsEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.success);
        when(
          () => mockSecurityService.setBiometricsEnabled(false),
        ).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleBiometricsEvent(false)),
      expect: () => [
        const SettingsState(
          isBiometricsEnabled: true,
          isTogglingBiometrics: true,
        ),
        const SettingsState(isBiometricsEnabled: false),
      ],
      verify: (_) {
        verify(() => mockSecurityService.setBiometricsEnabled(false)).called(1);
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'given device does not support biometrics then emit a notAvailable error and never persist',
      seed: () => const SettingsState(),
      build: () {
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleBiometricsEvent(true)),
      expect: () => [
        const SettingsState(isTogglingBiometrics: true),
        const SettingsState(
          biometricsToggleError: BiometricAuthResult.notAvailable,
        ),
      ],
      verify: (_) {
        verifyNever(() => mockSecurityService.setBiometricsEnabled(any()));
      },
    );

    blocTest<SettingsBloc, SettingsState>(
      'given user fails biometric authentication then emit the failure result and never persist',
      seed: () => const SettingsState(),
      build: () {
        when(
          () => mockSecurityService.canAuthenticate(),
        ).thenAnswer((_) async => true);
        when(
          () => mockSecurityService.authenticate(),
        ).thenAnswer((_) async => BiometricAuthResult.lockedOut);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ToggleBiometricsEvent(true)),
      expect: () => [
        const SettingsState(isTogglingBiometrics: true),
        const SettingsState(
          biometricsToggleError: BiometricAuthResult.lockedOut,
        ),
      ],
      verify: (_) {
        verifyNever(() => mockSecurityService.setBiometricsEnabled(any()));
      },
    );
  });

  group('LoadBiometricsSettingsEvent', () {
    blocTest<SettingsBloc, SettingsState>(
      'given secure storage has biometrics enabled then emit enabled state',
      build: () {
        when(
          () => mockSecurityService.isBiometricsEnabled(),
        ).thenAnswer((_) async => true);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadBiometricsSettingsEvent()),
      expect: () => [const SettingsState(isBiometricsEnabled: true)],
    );

    blocTest<SettingsBloc, SettingsState>(
      'given secure storage read fails then keep biometrics disabled',
      build: () {
        when(
          () => mockSecurityService.isBiometricsEnabled(),
        ).thenAnswer((_) async => false);
        return buildBloc();
      },
      seed: () => const SettingsState(),
      act: (bloc) => bloc.add(LoadBiometricsSettingsEvent()),
      expect: () => <SettingsState>[],
    );
  });
}
