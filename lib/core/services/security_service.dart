import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

abstract class SecurityService {
  Future<bool> canAuthenticate();
  Future<bool> authenticate();
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
  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Por favor, autentique-se para acessar suas finanças.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate;
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
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
