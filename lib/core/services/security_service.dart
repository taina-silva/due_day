import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAuthResult {
  success,
  canceled,
  lockedOut,
  notEnrolled,
  notAvailable,
  error,
}

abstract class SecurityService {
  Future<bool> canAuthenticate();
  Future<BiometricAuthResult> authenticate();
  Future<bool> isBiometricsEnabled();
  Future<void> setBiometricsEnabled(bool enabled);
}

class SecurityServiceImpl implements SecurityService {
  final FlutterSecureStorage secureStorage;
  final LocalAuthentication localAuth;

  static const String _biometricKey = 'is_biometrics_enabled';

  SecurityServiceImpl({required this.secureStorage, required this.localAuth});

  @override
  Future<bool> canAuthenticate() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<BiometricAuthResult> authenticate() async {
    try {
      final bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para acessar suas finanças.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate
          ? BiometricAuthResult.success
          : BiometricAuthResult.canceled;
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.timeout:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.userRequestedFallback:
          return BiometricAuthResult.canceled;
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          return BiometricAuthResult.lockedOut;
        case LocalAuthExceptionCode.noBiometricsEnrolled:
          return BiometricAuthResult.notEnrolled;
        case LocalAuthExceptionCode.noCredentialsSet:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          return BiometricAuthResult.notAvailable;
        default:
          return BiometricAuthResult.error;
      }
    } on PlatformException catch (_) {
      return BiometricAuthResult.error;
    } catch (_) {
      return BiometricAuthResult.error;
    }
  }

  @override
  Future<bool> isBiometricsEnabled() async {
    try {
      final String? value = await secureStorage.read(key: _biometricKey);
      return value == 'true';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    try {
      await secureStorage.write(
        key: _biometricKey,
        value: enabled ? 'true' : 'false',
      );
    } catch (_) {
      // Falha silenciosa ou log de segurança
    }
  }
}
