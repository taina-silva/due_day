import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/core/services/security_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late MockFlutterSecureStorage mockSecureStorage;
  late MockLocalAuthentication mockLocalAuth;
  late SecurityServiceImpl securityService;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    mockLocalAuth = MockLocalAuthentication();
    securityService = SecurityServiceImpl(
      secureStorage: mockSecureStorage,
      localAuth: mockLocalAuth,
      observability: ObservabilityServiceImpl(sinks: const []),
    );
  });

  group('canAuthenticate', () {
    test(
      'given biometrics available and device supported then return true',
      () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenAnswer((_) async => true);
        when(
          () => mockLocalAuth.isDeviceSupported(),
        ).thenAnswer((_) async => true);

        final result = await securityService.canAuthenticate();

        expect(result, isTrue);
      },
    );

    test(
      'given no enrolled biometrics then return false',
      () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenAnswer((_) async => false);
        when(
          () => mockLocalAuth.isDeviceSupported(),
        ).thenAnswer((_) async => true);

        final result = await securityService.canAuthenticate();

        expect(result, isFalse);
      },
    );

    test(
      'given PlatformException thrown then return false instead of propagating',
      () async {
        when(
          () => mockLocalAuth.canCheckBiometrics,
        ).thenThrow(PlatformException(code: 'error'));

        final result = await securityService.canAuthenticate();

        expect(result, isFalse);
      },
    );
  });

  group('authenticate', () {
    void mockAuthenticateAnswer(
      Future<bool> Function(Invocation) answer,
    ) {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenAnswer(answer);
    }

    void mockAuthenticateThrows(Object error) {
      when(
        () => mockLocalAuth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          biometricOnly: any(named: 'biometricOnly'),
          persistAcrossBackgrounding: any(named: 'persistAcrossBackgrounding'),
        ),
      ).thenThrow(error);
    }

    test(
      'given local_auth confirms identity then return success',
      () async {
        mockAuthenticateAnswer((_) async => true);

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.success);
      },
    );

    test(
      'given local_auth returns false without throwing then return canceled',
      () async {
        mockAuthenticateAnswer((_) async => false);

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.canceled);
      },
    );

    test(
      'given user cancels the native prompt then return canceled',
      () async {
        mockAuthenticateThrows(
          const LocalAuthException(code: LocalAuthExceptionCode.userCanceled),
        );

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.canceled);
      },
    );

    test(
      'given temporary lockout after failed attempts then return lockedOut',
      () async {
        mockAuthenticateThrows(
          const LocalAuthException(
            code: LocalAuthExceptionCode.temporaryLockout,
          ),
        );

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.lockedOut);
      },
    );

    test(
      'given permanent biometric lockout then return lockedOut',
      () async {
        mockAuthenticateThrows(
          const LocalAuthException(
            code: LocalAuthExceptionCode.biometricLockout,
          ),
        );

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.lockedOut);
      },
    );

    test(
      'given device has no biometrics enrolled then return notEnrolled',
      () async {
        mockAuthenticateThrows(
          const LocalAuthException(
            code: LocalAuthExceptionCode.noBiometricsEnrolled,
          ),
        );

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.notEnrolled);
      },
    );

    test(
      'given device has no biometric hardware then return notAvailable',
      () async {
        mockAuthenticateThrows(
          const LocalAuthException(
            code: LocalAuthExceptionCode.noBiometricHardware,
          ),
        );

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.notAvailable);
      },
    );

    test(
      'given an unmapped LocalAuthExceptionCode then fall back to error',
      () async {
        mockAuthenticateThrows(
          const LocalAuthException(code: LocalAuthExceptionCode.deviceError),
        );

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.error);
      },
    );

    test(
      'given a raw PlatformException then return error',
      () async {
        mockAuthenticateThrows(PlatformException(code: 'unexpected'));

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.error);
      },
    );

    test(
      'given an unexpected exception then return error instead of propagating',
      () async {
        mockAuthenticateThrows(Exception('unexpected failure'));

        final result = await securityService.authenticate();

        expect(result, BiometricAuthResult.error);
      },
    );
  });

  group('isBiometricsEnabled', () {
    test(
      'given secure storage has "true" then return true',
      () async {
        when(
          () => mockSecureStorage.read(key: 'is_biometrics_enabled'),
        ).thenAnswer((_) async => 'true');

        final result = await securityService.isBiometricsEnabled();

        expect(result, isTrue);
      },
    );

    test(
      'given secure storage has no value then return false',
      () async {
        when(
          () => mockSecureStorage.read(key: 'is_biometrics_enabled'),
        ).thenAnswer((_) async => null);

        final result = await securityService.isBiometricsEnabled();

        expect(result, isFalse);
      },
    );

    test(
      'given secure storage read throws then return false',
      () async {
        when(
          () => mockSecureStorage.read(key: 'is_biometrics_enabled'),
        ).thenThrow(Exception('keychain error'));

        final result = await securityService.isBiometricsEnabled();

        expect(result, isFalse);
      },
    );
  });

  group('setBiometricsEnabled', () {
    test(
      'given enabled true then persist "true" under the biometric key',
      () async {
        when(
          () => mockSecureStorage.write(
            key: 'is_biometrics_enabled',
            value: 'true',
          ),
        ).thenAnswer((_) async {});

        await securityService.setBiometricsEnabled(true);

        verify(
          () => mockSecureStorage.write(
            key: 'is_biometrics_enabled',
            value: 'true',
          ),
        ).called(1);
      },
    );

    test(
      'given secure storage write throws then swallow the error',
      () async {
        when(
          () => mockSecureStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenThrow(Exception('keychain error'));

        await expectLater(
          securityService.setBiometricsEnabled(true),
          completes,
        );
      },
    );
  });
}
